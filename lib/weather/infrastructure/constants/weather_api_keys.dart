class WeatherApiKeys {
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String apiKey = 'YOUR_API_KEY'; // Replace with your OpenWeatherMap API key

  static String getWeatherByCity(String cityName) {
    return '$baseUrl/weather?q=$cityName&appid=$apiKey&units=imperial';
  }
} 