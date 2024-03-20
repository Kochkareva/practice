import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:practice_task/api_service/api_service.dart';
import 'package:practice_task/models/pokemon_model.dart';
import 'package:practice_task/storages/pokemon_storage.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme
          .of(context)
          .colorScheme
          .onPrimary,
        child: Center(
            child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 85.0, right: 85.0, top: 50.0),
                    child: Text('Покемоны', textAlign: TextAlign.center, style: Theme
                        .of(context)
                        .textTheme
                        .displayMedium!
                        .copyWith(
                        fontSize: 20
                    ),),
                  ),
                  const Expanded(
                    child: ItemPageView(),
                  )
                ]
            )
        )
    );
  }
}


/// Класс для работы со списком элементов типа PokemonModel.
class ItemPageView extends StatefulWidget {
  const ItemPageView({super.key});

  @override
  State<ItemPageView> createState() => _ItemPageViewState();
}

class _ItemPageViewState extends State<ItemPageView>
    with TickerProviderStateMixin {

  /// Список объектов типа PokemonModel для работы с данными.
  List<PokemonModel> arrayOfPokemons = [];
  /// Список объектов типа PokemonModel для сохранения данных при попытке их удаления.
  List<PokemonModel> savedPokemons = [];
  /// Список закешированных объектов типа PokemonModel.
  List<PokemonModel> cachedPokemons = Hive
      .box<PokemonModel>('pokemon_model')
      .values
      .toList();
  /// Список объектов типа PokemonModel для подгружаемых данных.
  late Future<List<PokemonModel>> future;
  /// Список ключей, выбранных для удаления объектов.
  List<int> selectedKeys = [];
  /// Словарь для хранения ключей выбранных объектов для удаления.
  Map<int, bool> selectedFlag = {};
  /// Нахождение приложения в режиме выбора элементов.
  bool isSelectionMode = false;
  /// Указание на процесс подгрузки данных.
  bool isLoading = false;
  /// Текущая страница подгружаемых данных.
  int _currentPage = -1;
  /// Общее количество записей.
  int totalRecord = 40;
  /// Сообщение об ошибке при ее наличии.
  String hasError = '';
  /// Контроллер для управления прокруткой в списке.
  late final ScrollController _scrollController;

  @override
  void initState() {
    _currentPage++;
    future = _getData(_currentPage);
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
    super.initState();
  }

  /// Отслеживание прокрутки списка и загрузка данных при достижении конца списка.
  _scrollListener() {
    if (totalRecord == arrayOfPokemons.length) {
      return;
    }
    if (_scrollController.position.extentAfter <= 0 && !isLoading) {
      _currentPage++;
      isLoading = true;
      _getData(_currentPage);
    }
  }

  /// Метод для подгрузки данных.
  ///
  /// [page] - текущая странница данных.
  Future<List<PokemonModel>> _getData(int page) async {
    try {
      arrayOfPokemons += (await ApiService().getPokemons(page))!;
      isLoading = false;
      hasError ='';
    } catch (e) {
      setState(() {
        hasError = 'Ошибка при загрузке данных: ${e.toString()}';
        isLoading = false;
      });
      rethrow;
    }
    Future.delayed(const Duration(seconds: 1)).then((value) => setState(() {}));
    _updateCache(arrayOfPokemons);
    return arrayOfPokemons;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    pokemonBox.compact();
    pokemonBox.close();
    super.dispose();
  }

  /// Метод для обновления данных в локальном хранилище.
  void _updateCache(List<PokemonModel> updatePokemons) async {
    await Hive.box<PokemonModel>('pokemon_model').clear();
    addPokemons(arrayOfPokemons);
  }

  /// Построение пользовательского интерфейса с FutureBuilder.
  ///
  /// * Если происходит ошибка при загрузке данных, то отображается сообщение об ошибке с возможностью повторной попытки загрузки данных.
  /// * Если данные успешно загружены, то показывается список загруженных данных.
  /// * Если данные не загружены и закешированных список пуст, то также отображается сообщение об ошибке с возможностью повторной попытки загрузки.
  /// * Если данные не загружены, то отображается список, с закешироваными данными.
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme
          .of(context)
          .colorScheme
          .onPrimary,
      child: FutureBuilder<List<PokemonModel>>(
          future: future,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.waiting:
                return _buildListViewProduct(cachedPokemons);
              case ConnectionState.done:
                if (snapshot.hasError && !snapshot.error.toString().contains(
                    "Failed host lookup: 'pokeapi.co'")) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Произошла ошибка ${snapshot.error.toString()}'),
                        action: SnackBarAction(
                          label: 'Повторить',
                          onPressed: () {
                            setState(() {
                              _currentPage = 1;
                              future = _getData(_currentPage);
                            });
                          },
                        ),
                      ),
                    );
                  });
                }
                else if (snapshot.data != null) {
                  isLoading = false;
                  return _buildListViewProduct(arrayOfPokemons);
                } else if (cachedPokemons.isEmpty && snapshot.data == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Произошла ошибка ${snapshot.error.toString()}'),
                        action: SnackBarAction(
                          label: 'Повторить',
                          onPressed: () {
                            setState(() {
                              _currentPage = 1;
                              future = _getData(_currentPage);
                            });
                          },
                        ),
                      ),
                    );
                  });
                }
                else if (snapshot.data == null) {
                  return _buildListViewProduct(cachedPokemons);
                }
            }
            return Scaffold(
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .onPrimary,
              body: const Center(),
            );
          }),
    );
  }

  /// Виджет для отрисовки списка данных.
  ///
  /// [listPokemons] - список входных данных типа PokemonModel для отрисовки.
  Widget _buildListViewProduct(List<PokemonModel> listPokemons) {
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .colorScheme
          .onPrimary,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _currentPage = 0;
            arrayOfPokemons = [];
            future = _getData(_currentPage);
          });
        },
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(8),
          itemCount: listPokemons.isEmpty ? 0 : listPokemons.length,
          controller: _scrollController,
          itemBuilder: (BuildContext context, int index) {
            PokemonModel data = listPokemons[index];
            selectedFlag[index] = selectedFlag[index] ?? false;
            bool? isSelected = selectedFlag[index];
            return Column(
              children: [
                ListTile(
                  leading: _buildSelectionIcon(isSelected!, data),
                  title: Text('Имя:${listPokemons[index].name}'),
                  subtitle: Text(
                      'Ссылка:${listPokemons[index].url}'),
                  onLongPress: () => onLongPress(isSelected!, index),
                  onTap: () => onTab(isSelected!, index),
                ),
                Container(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .onPrimary,
                  height: (index == listPokemons.length - 1 &&
                      totalRecord > listPokemons.length) ? 50 : 0,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  child: const Center(
                      child: CircularProgressIndicator()
                  ),
                ),
                if (hasError.isNotEmpty && index ==
                    listPokemons.length - 1)
                  Container(
                    color: Colors.red,
                    padding: const EdgeInsets.all(8),
                    child: Text(hasError,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildDeleteButton(),
    );
  }


  /// Создание кнопку удаления, которая отображается только в случае, если выбран хотя бы один элемент для удаления.
  Widget? _buildDeleteButton() {
    bool isFalseAvailable = selectedFlag.containsValue(false);

    selectedKeys = selectedFlag.entries.where((entry) =>
    entry.value == true)
        .map((entry) => entry.key)
        .toList();
    selectedKeys = selectedKeys.reversed.toList();

    if (isSelectionMode) {
      return FloatingActionButton(
        onPressed: () {
          _deleteAll(context, selectedKeys);
        },
        child: Icon(isFalseAvailable ? Icons.delete : Icons.delete_outline),
      );
    } else {
      return null;
    }
  }

  /// Метод для удаления всех выбранных данных в списке.
  ///
  /// В случае возникновения ошибки во время удаления, отображается SnackBar
  /// с текстом об ошибке и кнопкой для повторной попытки удаления.
  void _deleteAll(BuildContext context, List<int> selectedKeys) async {
    try {
      savedPokemons = [];
      savedPokemons.addAll(arrayOfPokemons);
      for (var id in selectedKeys) {
        arrayOfPokemons.removeAt(id);
      }
      selectedFlag.updateAll((key, value) => false);
      setState(() {
        isSelectionMode = selectedFlag.containsValue(true);
      });
      await ApiService().deletePokemonsAPI(selectedKeys);
      _updateCache(arrayOfPokemons);
      selectedKeys = [];
    } catch (e) {
      selectedFlag.updateAll((key, value) => false);
      setState(() {
        arrayOfPokemons = [];
        arrayOfPokemons.addAll(savedPokemons);
        isSelectionMode = selectedFlag.containsValue(true);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Отсутствует подключение к интернету, попробуйте позже'),
          action: SnackBarAction(
            label: 'Повторить',
            onPressed: () {
              _deleteAll(context, selectedKeys);
            },
          ),
        ),
      );
    }
  }

  /// Обработка события долгого нажатия на элемент списка для активации режима выбора.
  void onLongPress(bool isSelected, int index) {
    setState(() {
      selectedFlag[index] = !isSelected;
    });
    isSelectionMode = selectedFlag.containsValue(true);
  }

  /// Обработка события нажатия на элемент списка для выбора или отмены выбора элементов.
  void onTab(bool isSelected, int index) {
    if (isSelectionMode) {
      setState(() {
        selectedFlag[index] = !isSelected;
        isSelectionMode = selectedFlag.containsValue(true);
      });
    }
  }

  /// Отображение выбранных элементов списка.
  Widget _buildSelectionIcon(bool isSelected, PokemonModel data) {
    if (isSelectionMode) {
      return Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        color: Theme
            .of(context)
            .primaryColor,
      );
    } else {
      return CircleAvatar(
        backgroundColor: Theme
            .of(context)
            .primaryColor,
        backgroundImage: const AssetImage('assets/pokebol.jpg'),
        foregroundColor: Theme
            .of(context)
            .colorScheme
            .onPrimary,
        child: Text(data.id.toString()),
      );
    }
  }
}
