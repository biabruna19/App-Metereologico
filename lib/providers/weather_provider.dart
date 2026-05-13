import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final _supabase = Supabase.instance.client;

  Future<void> fetchWeatherForCity(String cityName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Busca as coordenadas da cidade
      final cityData = await _weatherService.searchCity(cityName);
      final double lat = cityData['latitude'];
      final double lon = cityData['longitude'];
      final String resolvedName = '${cityData['name']}, ${cityData['admin1'] ?? ''}';

      // 2. Busca o clima para as coordenadas
      final weather = await _weatherService.fetchCurrentWeather(lat, lon, resolvedName);
      _currentWeather = weather;

      // 3. Salva no Supabase (Histórico)
      try {
        await _supabase.from('search_history').insert({
          'city': weather.cityName,
          'temperature': weather.temperature,
          'weather_code': weather.weatherCode,
        });
      } catch (dbError) {
        debugPrint('Erro ao salvar no Supabase: $dbError');
      }

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Busca inicial (ex: São Paulo)
  Future<void> loadInitialData() async {
    await fetchWeatherForCity('São Paulo');
  }
}
