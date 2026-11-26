import 'package:geolocator/geolocator.dart';

import 'clima_api.dart';

/// Pega a posição do aparelho. Fica atrás de uma interface para os testes.
abstract class Localizador {
  Future<({double latitude, double longitude})> posicao();
}

class LocalizadorGps implements Localizador {
  @override
  Future<({double latitude, double longitude})> posicao() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ClimaException('A localização está desligada neste aparelho. Ligue-a ou busque a cidade pelo nome.');
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.denied || permissao == LocationPermission.deniedForever) {
      throw const ClimaException('Sem permissão para usar sua localização. Você pode buscar a cidade pelo nome.');
    }
    final p = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 20)),
    );
    return (latitude: p.latitude, longitude: p.longitude);
  }
}
