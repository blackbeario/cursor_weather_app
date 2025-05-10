class WeatherApiKeys {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'bb148e13e57a1b139bd596b34bc43a5b'; // Replace with your OpenWeatherMap API key

  static String getWeatherByCity(String cityName) {
    return '$baseUrl/weather?q=$cityName&appid=$apiKey&units=imperial';
  }
} 