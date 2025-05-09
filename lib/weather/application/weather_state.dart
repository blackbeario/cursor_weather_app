import 'package:freezed_annotation/freezed_annotation.dart';

import '../../core/data_state.dart';
import '../domain/weather_model.dart';

part 'weather_state.freezed.dart';

@freezed
class WeatherState with _$WeatherState {
  const WeatherState._();

  const factory WeatherState({
    required DataState<WeatherModel> weatherData,
    @Default('') String lastSearchedCity,
  }) = _WeatherState;

  // Helper getters for derived states
  bool get isLoading => weatherData.isLoading;
  bool get hasError => weatherData.hasFailure;
  bool get isSuccess => weatherData.isSuccess;
  bool get isIdle => weatherData.isInitial;

  WeatherModel? get weather => weatherData.value;

  factory WeatherState.initial() => const WeatherState(
        weatherData: DataState.initial(),
        lastSearchedCity: '',
      );
}
