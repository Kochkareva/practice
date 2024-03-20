import 'package:flutter/material.dart';
import 'package:practice_task/models/pokemon_model.dart';
import 'package:provider/provider.dart';
import 'package:practice_task/pages/product_page.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(PokemonModelAdapter());
  await Hive.openBox<PokemonModel>('pokemon_model');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Name App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0x003b5bdb),
            secondary: const Color(0xFF5B5B5B),
            background: const Color(0xFFF1F3F5),
            onPrimary: Colors.white,
            primary: const Color(0xFFFFA500),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFFFA500),
            foregroundColor: Colors.white,
          ),
        ),
        home: const ProductPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {

}
