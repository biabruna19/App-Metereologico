import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

class WeatherService {
  // Coordenadas padrão (São Paulo) caso a geolocalização falhe
  static const double defaultLat = -23.5505;
  static const double defaultLon = -46.6333;

  Future<WeatherData> fetchCurrentWeather(double lat, double lon, String cityName) async {
    final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m&timezone=auto');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return WeatherData.fromJson(data, cityName);
      } else {
        throw Exception('Erro ao buscar dados do clima: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }

  // Geocoding básico do Open-Meteo para buscar cidades
  Future<Map<String, dynamic>> searchCity(String query) async {
    final url = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$query&count=1&language=pt&format=json');
    
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return {
            'name': result['name'],
            'latitude': result['latitude'],
            'longitude': result['longitude'],
            'admin1': result['admin1'], // Estado
          };
        } else {
          throw Exception('Cidade não encontrada');
        }
      }
      throw Exception('Erro ao buscar cidade');
    } catch (e) {
      throw Exception('Falha na conexão: $e');
    }
  }
}
