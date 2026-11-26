import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cidade.dart';
import '../models/previsao.dart';

/// Erro com uma mensagem pronta para mostrar na tela.
class ClimaException implements Exception {
  final String mensagem;
  const ClimaException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Acesso à Open-Meteo (previsão e busca de cidades). Gratuita e sem chave.
class ClimaApi {
  ClimaApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();

  final http.Client _cliente;

  /// Até 6 cidades com o nome parecido, para as sugestões da busca.
  Future<List<Cidade>> buscarCidades(String termo) async {
    final t = termo.trim();
    if (t.length < 2) return const [];
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {'name': t, 'count': '6', 'language': 'pt', 'format': 'json'});
    final dados = await _get(uri);
    final resultados = dados['results'] as List?;
    if (resultados == null) return const [];
    return resultados.map((r) => Cidade.daBusca(r as Map<String, dynamic>)).toList();
  }

  Future<Previsao> previsao(Cidade cidade) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '${cidade.latitude}',
      'longitude': '${cidade.longitude}',
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,weather_code,wind_speed_10m,wind_direction_10m',
      'hourly': 'temperature_2m,precipitation_probability,weather_code,is_day',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,sunrise,sunset,uv_index_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    return Previsao.fromJson(await _get(uri));
  }

  /// Nome do lugar a partir das coordenadas do aparelho. A Open-Meteo não faz
  /// esse caminho inverso, então usamos o serviço gratuito da BigDataCloud.
  /// Se ele falhar, a previsão aparece mesmo assim, como "Sua localização".
  Future<Cidade> cidadeDaPosicao(double latitude, double longitude) async {
    try {
      final uri = Uri.https('api.bigdatacloud.net', '/data/reverse-geocode-client', {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'localityLanguage': 'pt',
      });
      final dados = await _get(uri);
      final nome = [dados['city'], dados['locality']].whereType<String>().firstWhere((n) => n.isNotEmpty);
      return Cidade(
        nome: nome,
        estado: dados['principalSubdivision'] as String?,
        pais: dados['countryName'] as String?,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (_) {
      return Cidade(nome: 'Sua localização', latitude: latitude, longitude: longitude);
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response resposta;
    try {
      resposta = await _cliente.get(uri).timeout(const Duration(seconds: 15));
    } catch (_) {
      throw const ClimaException('Sem conexão com o serviço de clima. Verifique a internet e tente de novo.');
    }
    if (resposta.statusCode != 200) {
      throw ClimaException('O serviço de clima não respondeu agora (erro ${resposta.statusCode}). Tente de novo em instantes.');
    }
    return json.decode(utf8.decode(resposta.bodyBytes)) as Map<String, dynamic>;
  }
}
