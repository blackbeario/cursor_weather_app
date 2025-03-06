import 'package:result_type/result_type.dart';

import 'weather_model.dart';

/// Possible types of weather-related errors
enum WeatherErrorType {
  network,
  cityNotFound,
  server,
  unknown,
}

/// Exception thrown when weather operations fail
class WeatherException implements Exception {
  final WeatherErrorType type;
  final String? message;

  const WeatherException({
    required this.type,
    this.message,
  });

  @override
  String toString() =>
      'WeatherException: ${type.name}${message != null ? ' - $message' : ''}';
}

/// Interface for weather service operations
abstract class IWeatherService {
  /// Fetches current weather data for the specified city
  ///
  /// Returns [Result.success] with [WeatherModel] if successful
  /// Returns [Result.failure] with [WeatherException]:
  /// - [WeatherErrorType.network] for network connectivity issues
  /// - [WeatherErrorType.cityNotFound] if the city doesn't exist
  /// - [WeatherErrorType.server] for server-side errors
  /// - [WeatherErrorType.unknown] for unexpected errors
  Future<Result<WeatherModel, WeatherException>> getWeatherForCity({
    required String cityName,
  });
}
