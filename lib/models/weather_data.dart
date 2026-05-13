class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String cityName;
  final List<double> hourlyTemperatures;
  final List<String> hourlyTimes;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.cityName,
    required this.hourlyTemperatures,
    required this.hourlyTimes,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    final current = json['current_weather'];
    final hourly = json['hourly'];
    
    List<double> temps = [];
    List<String> times = [];
    
    if (hourly != null) {
      temps = List<double>.from(hourly['temperature_2m'].map((e) => (e as num).toDouble()));
      times = List<String>.from(hourly['time']);
    }

    return WeatherData(
      temperature: current['temperature'],
      windSpeed: current['windspeed'],
      weatherCode: current['weathercode'],
      cityName: city,
      hourlyTemperatures: temps,
      hourlyTimes: times,
    );
  }

  // Mapeamento básico de códigos WMO para descrições de clima
  String get weatherDescription {
    switch (weatherCode) {
      case 0: return 'Céu limpo';
      case 1: case 2: case 3: return 'Parcialmente nublado';
      case 45: case 48: return 'Nevoeiro';
      case 51: case 53: case 55: return 'Garoa';
      case 61: case 63: case 65: return 'Chuva';
      case 71: case 73: case 75: return 'Neve';
      case 95: return 'Tempestade';
      default: return 'Desconhecido';
    }
  }

  // Caminho de imagem/ícone baseado no clima
  String get weatherIconAsset {
    if (weatherCode == 0) return 'assets/sun.png';
    if (weatherCode <= 3) return 'assets/cloud.png';
    if (weatherCode <= 65) return 'assets/rain.png';
    return 'assets/cloud.png'; // fallback
  }
}
