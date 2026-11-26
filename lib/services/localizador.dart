import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import 'clima_api.dart';

/// Pega a posição do aparelho. Fica atrás de uma interface para os testes.
abstract class Localizador {
  Future<({double latitude, double longitude})> posicao();
}

class LocalizadorGps implements Localizador {
  static const _limite = Duration(seconds: 15);

  @override
  Future<({double latitude, double longitude})> posicao() async {
    try {
      // No navegador não pedimos a permissão antes: o pacote faz isso
      // consultando a posição sem limite de tempo, e se a pessoa fechar o
      // aviso (ou o computador não souber onde está) a espera nunca acaba.
      // Pedindo a posição direto, o próprio navegador mostra o aviso.
      if (!kIsWeb) {
        if (!await Geolocator.isLocationServiceEnabled()) {
          throw const ClimaException('A localização está desligada neste aparelho. Ligue-a ou busque a cidade pelo nome.');
        }
        var permissao = await Geolocator.checkPermission();
        if (permissao == LocationPermission.denied) {
          permissao = await Geolocator.requestPermission().timeout(const Duration(seconds: 60));
        }
        if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
          throw const _SemPermissao();
        }
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: _limite),
      ).timeout(_limite + const Duration(seconds: 5));
      return (latitude: p.latitude, longitude: p.longitude);
    } on ClimaException {
      rethrow;
    } on _SemPermissao {
      throw const ClimaException(mensagemSemPermissao);
    } on PermissionDeniedException {
      throw const ClimaException(mensagemSemPermissao);
    } on LocationServiceDisabledException {
      throw const ClimaException('A localização está desligada neste aparelho. Ligue-a ou busque a cidade pelo nome.');
    } on TimeoutException {
      throw const ClimaException(mensagemDemorou);
    } catch (_) {
      throw const ClimaException(mensagemDemorou);
    }
  }

  static const mensagemSemPermissao =
      'Sem permissão para usar sua localização. Libere nas configurações do navegador ou busque a cidade pelo nome.';
  static const mensagemDemorou =
      'Não conseguimos descobrir sua localização. Confira se ela está ligada e liberada para este site, ou busque a cidade pelo nome.';
}

class _SemPermissao implements Exception {
  const _SemPermissao();
}
