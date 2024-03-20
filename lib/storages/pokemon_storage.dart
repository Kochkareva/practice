import 'dart:developer';
import 'package:practice_task/models/pokemon_model.dart';
import 'package:hive/hive.dart';

/// Доступ к хранилищу данных Hive типа PokemonModel.
final pokemonBox = Hive.box<PokemonModel>('pokemon_model');

/// Добавление данных в хранилище
///
/// [models] - список с данными типа PokemonModel.
void addPokemons(List<PokemonModel> models) {
  try {
    pokemonBox.addAll(models);
  } catch (e) {
    log('Failed to add data to Hive: ${e.toString()}');
  }
}
