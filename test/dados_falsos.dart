import 'dart:convert';

import 'package:app_meteorologico/models/cidade.dart';
import 'package:app_meteorologico/services/localizador.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Previsão de mentira, no mesmo formato da Open-Meteo.
/// Hora atual 14:20, então as "próximas 24 horas" devem começar às 14:00.
Map<String, dynamic> previsaoFalsa({double temperatura = 27.4, int codigo = 2, bool dia = true}) {
  final horas = <String>[];
  for (var d = 26; d <= 27; d++) {
    for (var h = 0; h < 24; h++) {
      horas.add('2026-11-${d}T${h.toString().padLeft(2, '0')}:00');
    }
  }
  return {
    'current': {
      'time': '2026-11-26T14:20',
      'temperature_2m': temperatura,
      'relative_humidity_2m': 64,
      'apparent_temperature': 29.1,
      'is_day': dia ? 1 : 0,
      'precipitation': 0.0,
      'weather_code': codigo,
      'wind_speed_10m': 12.6,
      'wind_direction_10m': 45,
    },
    'hourly': {
      'time': horas,
      'temperature_2m': [for (var i = 0; i < horas.length; i++) 20 + (i % 24 - 12).abs() * -0.5 + 6],
      'precipitation_probability': [for (var i = 0; i < horas.length; i++) i % 24 > 16 ? 40 : 0],
      'weather_code': [for (var i = 0; i < horas.length; i++) i % 24 > 16 ? 81 : 1],
      'is_day': [for (var i = 0; i < horas.length; i++) (i % 24 >= 6 && i % 24 < 18) ? 1 : 0],
    },
    'daily': {
      'time': ['2026-11-26', '2026-11-27', '2026-11-28', '2026-11-29', '2026-11-30', '2026-12-01', '2026-12-02'],
      'weather_code': [2, 81, 95, 0, 3, 61, 45],
      'temperature_2m_max': [29.8, 26.1, 24.0, 31.2, 28.0, 23.5, 22.9],
      'temperature_2m_min': [19.2, 18.4, 17.0, 20.1, 19.0, 16.2, 15.8],
      'precipitation_probability_max': [35, 80, 95, 0, 10, 70, 20],
      'sunrise': ['2026-11-26T05:12', null, null, null, null, null, null],
      'sunset': ['2026-11-26T18:41', null, null, null, null, null, null],
      'uv_index_max': [9.4, 6.0, 3.0, 11.2, 8.0, 4.0, 2.0],
    },
  };
}

final cidadesFalsas = {
  'recife': [
    {'name': 'Recife', 'admin1': 'Pernambuco', 'country': 'Brasil', 'latitude': -8.05, 'longitude': -34.88},
  ],
  'santa': [
    {'name': 'Santa Maria', 'admin1': 'Rio Grande do Sul', 'country': 'Brasil', 'latitude': -29.68, 'longitude': -53.81},
    {'name': 'Santa Rita', 'admin1': 'Paraíba', 'country': 'Brasil', 'latitude': -7.11, 'longitude': -34.98},
  ],
};

/// Cliente HTTP que responde como a Open-Meteo sem acessar a internet.
/// [falhar] simula a falta de conexão; [pedidos] guarda o que foi chamado.
class ClienteFalso {
  bool falhar = false;
  int status = 200;
  final pedidos = <Uri>[];

  http.Client get cliente => MockClient((req) async {
    pedidos.add(req.url);
    if (falhar) throw http.ClientException('sem rede');
    if (status != 200) return http.Response('erro', status);
    final corpo = switch (req.url.host) {
      'geocoding-api.open-meteo.com' => {'results': cidadesFalsas[req.url.queryParameters['name']!.toLowerCase().split(' ').first]},
      'api.open-meteo.com' => previsaoFalsa(temperatura: req.url.queryParameters['latitude']!.startsWith('-8') ? 30.2 : 27.4),
      'api.bigdatacloud.net' => {'city': 'Campinas', 'principalSubdivision': 'São Paulo', 'countryName': 'Brasil'},
      _ => {},
    };
    return http.Response.bytes(utf8.encode(json.encode(corpo)), 200, headers: {'content-type': 'application/json'});
  });
}

class LocalizadorFalso implements Localizador {
  LocalizadorFalso({this.erro});
  final Exception? erro;

  @override
  Future<({double latitude, double longitude})> posicao() async {
    if (erro != null) throw erro!;
    return (latitude: -22.9, longitude: -47.06);
  }
}

extension CidadeDeTeste on Cidade {
  /// A mesma cidade em outra coordenada, para encher a lista de recentes.
  Cidade copiaEm(double deslocamento) =>
      Cidade(nome: '$nome $deslocamento', estado: estado, pais: pais, latitude: latitude + deslocamento, longitude: longitude);
}
