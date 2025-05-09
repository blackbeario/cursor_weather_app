import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../application/weather_cubit.dart';
import '../application/weather_state.dart';
import '../infrastructure/weather_service.dart';

class WeatherPage extends StatelessWidget {
  const WeatherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WeatherCubit(
        weatherService: WeatherService(),
      )..getWeatherForCity(cityName: 'New York'),
      child: const WeatherPageView(),
    );
  }
}

class WeatherPageView extends StatelessWidget {
  const WeatherPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4B89F0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Weather App Logo and Title
              const Row(
                children: [
                  Icon(
                    Icons.cloud,
                    color: Colors.white,
                    size: 40,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'WeatherApp',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // City Selection TextField
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      context.read<WeatherCubit>().getWeatherForCity(
                            cityName: value,
                          );
                    }
                  },
                  decoration: const InputDecoration(
                    hintText: 'Enter city name',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    suffixIcon: Icon(Icons.search),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Weather Information Card
              BlocBuilder<WeatherCubit, WeatherState>(
                builder: (context, state) {
                  return state.weatherData.maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    failure: (error) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            error.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<WeatherCubit>().getWeatherForCity(
                                    cityName: state.lastSearchedCity,
                                  );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4B89F0),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    success: (weather, _) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            weather.condition.toLowerCase().contains('cloud')
                                ? Icons.cloud
                                : weather.condition
                                        .toLowerCase()
                                        .contains('rain')
                                    ? Icons.water_drop
                                    : Icons.wb_sunny,
                            color: const Color(0xFFFFB800),
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            weather.cityName,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E2C),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.temperature.round().toString(),
                                style: const TextStyle(
                                  fontSize: 96,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E1E2C),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  weather.isFahrenheit ? '°F' : '°C',
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E1E2C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            weather.condition,
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color(0xFF666870),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context
                                .read<WeatherCubit>()
                                .toggleTemperatureUnit(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B89F0),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Switch to ${weather.isFahrenheit ? '°C' : '°F'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              WeatherInfoItem(
                                icon: Icons.water_drop,
                                label: 'Humidity: ${weather.humidity}%',
                              ),
                              WeatherInfoItem(
                                icon: Icons.air,
                                label:
                                    'Wind: ${weather.windSpeed.toStringAsFixed(1)} mph',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const WeatherInfoItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4B89F0),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF666870),
          ),
        ),
      ],
    );
  }
}
