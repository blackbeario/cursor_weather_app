import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherApiKeys {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static String apiKey = dotenv.get('WEATHER_KEY');

  static String getWeatherByCity(String cityName) {
    return '$baseUrl/weather?q=$cityName&appid=$apiKey&units=imperial';
  }
} 