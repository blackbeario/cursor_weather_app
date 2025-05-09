import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/weather_model.dart';

part 'weather_dto.freezed.dart';
part 'weather_dto.g.dart';

/// Data Transfer Object for weather information from the API
@freezed
class WeatherDto with _$WeatherDto {
  const factory WeatherDto({
    required String cityName,
    required WeatherMainDto main,
    required List<WeatherConditionDto> weather,
    required WindDto wind,
  }) = _WeatherDto;

  factory WeatherDto.fromJson(Map<String, dynamic> json) =>
      _$WeatherDtoFromJson(json);
}

@freezed
class WeatherMainDto with _$WeatherMainDto {
  const factory WeatherMainDto({
    required double temperature,
    required int humidity,
  }) = _WeatherMainDto;

  factory WeatherMainDto.fromJson(Map<String, dynamic> json) =>
      _$WeatherMainDtoFromJson(json);
}

@freezed
class WeatherConditionDto with _$WeatherConditionDto {
  const factory WeatherConditionDto({
    required String main,
    required String description,
  }) = _WeatherConditionDto;

  factory WeatherConditionDto.fromJson(Map<String, dynamic> json) =>
      _$WeatherConditionDtoFromJson(json);
}

@freezed
class WindDto with _$WindDto {
  const factory WindDto({
    required double speed,
  }) = _WindDto;

  factory WindDto.fromJson(Map<String, dynamic> json) =>
      _$WindDtoFromJson(json);
}

/// Extension to convert WeatherDto to domain model
extension WeatherDtoX on WeatherDto {
  /// Converts the DTO to a domain model
  WeatherModel toDomain() => WeatherModel(
        cityName: cityName,
        temperature: main.temperature,
        condition: weather.first.main,
        humidity: main.humidity,
        windSpeed: wind.speed,
        isFahrenheit: true, // API returns data in Fahrenheit (imperial units)
      );
}
