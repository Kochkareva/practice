/// Класс для хранения констант, связанных с API
class ApiConstants {
  /// Базовый URL для обращения к API.
  static const String pokemonBaseUrl = 'https://pokeapi.co/api/v2/';

  /// Конечная точка для получения списка покемонов.
  static const String getPokemonEndPoint = 'pokemon?limit=10&offset=';
}