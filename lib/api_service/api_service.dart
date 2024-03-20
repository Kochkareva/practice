import 'dart:developer' as dev;
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:practice_task/constants/api_constants.dart';
import 'package:practice_task/models/pokemon_model.dart';

/// Класс для выполнения запросов к Api.
class ApiService {

  /// Метод загрузки списка элементов с сервера.
  ///
  /// [page] - номер необходимой страницы списка.
  Future<List<PokemonModel>?> getPokemons(int page) async{
    try {
      var url = Uri.parse('${ApiConstants.pokemonBaseUrl}${ApiConstants
          .getPokemonEndPoint}${page}0');
      var response = await http.get(url);
      if (response.statusCode == 200) {
        List<PokemonModel> pokemons = pokemonModelFromJson(response.body);
        return pokemons;
      }
    } catch (e) {
      dev.log('Не удалось загрузить данные: ${e.toString()}');
      rethrow;
    }
    return null;
  }

  /// Метод удаления элементов списка с сервера.
  ///
  /// [indexes] - индексы, удаляемых элементов.
  Future<void> deletePokemonsAPI(List<int> indexes) async{
    try {
      // Здесь должен быть запрос на удаление, аналогичный запросу выше, но у данного api такое отсутствует,
      // пусть успешность удаления с сервера определяется рандомом для имитации ошибок
      // true - statusCode = 200
      // false - statusCode = 400
      Random random = Random();
      bool statusCode = random.nextBool();
      var url = Uri.parse('${ApiConstants.pokemonBaseUrl}${ApiConstants
          .getPokemonEndPoint}10');
      var response = await http.get(url);
      if (statusCode) {
        print('Удаление прошло без ошибок');
      } else {
        throw Exception('При удалении возникла ошибка : $statusCode');
      }
    } catch (e) {
      dev.log('Не удалось удалить данные: ${e.toString()}');
      rethrow;
    }
  }
}