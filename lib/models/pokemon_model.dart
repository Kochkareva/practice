import 'dart:convert';
import 'package:hive/hive.dart';
part 'pokemon_model.g.dart';

/// Метод для преобразования JSON-строки в список объектов [PokemonModel].
///
/// [str] - входная строка
List<PokemonModel> pokemonModelFromJson(String str) {
  Map<String, dynamic> data = jsonDecode(str);
  List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(data['results']);
  return results.map((x) => PokemonModel.fromJson(x)).toList();
}

/// Модель данных покемона.
///
/// * [id] - id.
/// * [name] - имя покемона.
/// * [url] - ссылка на покемона.
@HiveType(typeId: 1)
class PokemonModel{
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String url;

  PokemonModel({
    required this.id,
    required this.name,
    required this.url,
  });

  /// Метод для преобразования JSON в модель данных [PokemonModel].
  factory PokemonModel.fromJson(Map<String, dynamic> json) => PokemonModel(
      id: int.parse(json['url'].replaceAll('https://pokeapi.co/api/v2/pokemon/', '').replaceAll('/', '')),
      name: json['name'],
      url: json['url'],
  );
}
