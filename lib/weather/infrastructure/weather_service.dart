import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';

import '../domain/i_weather_service.dart';
import '../domain/weather_model.dart';
import 'constants/weather_api_keys.dart';
import 'dtos/weather_dto.dart';

class WeatherService implements IWeatherService {
  final http.Client _client;
  final String Function(String) _urlBuilder;

  WeatherService({
    http.Client? client,
    String Function(String)? urlBuilder,
  })  : _client = client ?? http.Client(),
        _urlBuilder = urlBuilder ?? WeatherApiKeys.getWeatherByCity;

  @override
  Future<Result<WeatherModel, WeatherException>> getWeatherForCity({
    required String cityName,
  }) async {
    try {
      final url = _urlBuilder(cityName);
      log('Requesting weather data from: $url');

      final response = await _client.get(Uri.parse(url));

      log('Response status code: ${response.statusCode}');
      log('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final dto = WeatherDto.fromJson(json);
        return Success(dto.toDomain());
      } else if (response.statusCode == 401) {
        final errorBody = jsonDecode(response.body);
        return Failure(
          WeatherException(
            type: WeatherErrorType.server,
            message: 'API Error: ${errorBody['message'] ?? 'Unknown error'}',
          ),
        );
      } else if (response.statusCode == 404) {
        return Failure(
          WeatherException(
            type: WeatherErrorType.cityNotFound,
            message: 'City not found: $cityName',
          ),
        );
      } else {
        return Failure(
          WeatherException(
            type: WeatherErrorType.server,
            message: 'Server error: ${response.statusCode}',
          ),
        );
      }
    } catch (e) {
      log('Error fetching weather data: $e');
      return Failure(
        WeatherException(
          type: WeatherErrorType.network,
          message: e.toString(),
        ),
      );
    }
  }
}
