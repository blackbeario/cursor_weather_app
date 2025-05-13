import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:cursor_tutorial_weather_app/weather/domain/i_weather_service.dart';
import 'package:cursor_tutorial_weather_app/weather/domain/weather_model.dart';
import 'package:cursor_tutorial_weather_app/weather/infrastructure/weather_service.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late WeatherService weatherService;
  late MockHttpClient mockHttpClient;
  late String Function(String) mockUrlBuilder;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockUrlBuilder = (cityName) => 'https://api.example.com/weather?q=$cityName';
    weatherService = WeatherService(
      client: mockHttpClient,
      urlBuilder: mockUrlBuilder,
    );
  });

  group('getWeatherForCity', () {
    const cityName = 'London';
    final successResponse = {
      'name': 'London',
      'main': {
        'temp': 20.0,
        'humidity': 75,
      },
      'weather': [
        {
          'main': 'Clouds',
          'description': 'scattered clouds',
        }
      ],
      'wind': {
        'speed': 5.0,
      },
    };

    test('returns weather data on successful API call', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response(jsonEncode(successResponse), 200),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.success, isA<WeatherModel>());
      expect(result.success.cityName, equals('London'));
      expect(result.success.temperature, equals(20.0));
      expect(result.success.humidity, equals(75));
      expect(result.success.condition, equals('Clouds'));
      expect(result.success.windSpeed, equals(5.0));
      expect(result.success.isFahrenheit, isTrue);
    });

    test('returns city not found error on 404 status code', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"message": "city not found"}', 404),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.cityNotFound));
      expect(result.failure.message, contains('City not found: $cityName'));
    });

    test('returns server error on 401 status code', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"message": "Invalid API key"}', 401),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.server));
      expect(result.failure.message, contains('API Error: Invalid API key'));
    });

    test('returns server error on other error status codes', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('{"message": "Internal server error"}', 500),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.server));
      expect(result.failure.message, contains('Server error: 500'));
    });

    test('returns network error on connection failure', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenThrow(
        const SocketException('Failed to connect'),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.network));
      expect(result.failure.message, contains('SocketException'));
    });

    test('returns network error on timeout', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenThrow(
        TimeoutException('Connection timed out'),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.network));
      expect(result.failure.message, contains('TimeoutException'));
    });

    test('returns network error on invalid JSON response', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer(
        (_) async => http.Response('invalid json', 200),
      );

      // Act
      final result = await weatherService.getWeatherForCity(cityName: cityName);

      // Assert
      expect(result.isFailure, isTrue);
      expect(result.failure, isA<WeatherException>());
      expect(result.failure.type, equals(WeatherErrorType.network));
      expect(result.failure.message, contains('FormatException'));
    });
  });
} 