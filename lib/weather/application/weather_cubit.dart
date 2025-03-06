import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data_state.dart';
import '../domain/i_weather_service.dart';
import 'weather_state.dart';

class WeatherCubit extends Cubit<WeatherState> {
  final IWeatherService _weatherService;

  WeatherCubit({
    required IWeatherService weatherService,
  })  : _weatherService = weatherService,
        super(WeatherState.initial());

  Future<void> getWeatherForCity({required String cityName}) async {
    emit(state.copyWith(
      weatherData: const DataState.loading(),
      lastSearchedCity: cityName,
    ));

    final result = await _weatherService.getWeatherForCity(cityName: cityName);

    if (result.isSuccess) {
      emit(state.copyWith(
        weatherData: DataState.success(value: result.success),
      ));
    } else {
      emit(state.copyWith(
        weatherData: DataState.failure(result.failure),
      ));
    }
  }

  void toggleTemperatureUnit() {
    state.weatherData.maybeWhen(
      success: (currentWeather, _) {
        final updatedWeather = currentWeather.copyWith(
          isFahrenheit: !currentWeather.isFahrenheit,
          temperature: currentWeather.isFahrenheit
              ? (currentWeather.temperature - 32) * 5 / 9 // F to C
              : (currentWeather.temperature * 9 / 5) + 32, // C to F
        );
        emit(state.copyWith(
          weatherData: DataState.success(value: updatedWeather),
        ));
      },
      orElse: () {},
    );
  }
}
