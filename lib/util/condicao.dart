import 'package:material_ui/material_ui.dart';

enum Grupo { limpo, poucasNuvens, nublado, neblina, garoa, chuva, neve, tempestade }

/// Tradução dos códigos de tempo da OMM (WMO) que a Open-Meteo usa.
/// A versão anterior só conhecia 18 códigos e mostrava "Desconhecido"
/// para pancadas de chuva (80–82), que são das mais comuns no Brasil.
class Condicao {
  final String descricao;
  final Grupo grupo;

  const Condicao(this.descricao, this.grupo);

  static Condicao doCodigo(int codigo) {
    switch (codigo) {
      case 0:
        return const Condicao('Céu limpo', Grupo.limpo);
      case 1:
        return const Condicao('Predomínio de sol', Grupo.poucasNuvens);
      case 2:
        return const Condicao('Parcialmente nublado', Grupo.poucasNuvens);
      case 3:
        return const Condicao('Nublado', Grupo.nublado);
      case 45:
        return const Condicao('Nevoeiro', Grupo.neblina);
      case 48:
        return const Condicao('Nevoeiro com geada', Grupo.neblina);
      case 51:
        return const Condicao('Garoa fraca', Grupo.garoa);
      case 53:
        return const Condicao('Garoa', Grupo.garoa);
      case 55:
        return const Condicao('Garoa forte', Grupo.garoa);
      case 56:
      case 57:
        return const Condicao('Garoa congelante', Grupo.garoa);
      case 61:
        return const Condicao('Chuva fraca', Grupo.chuva);
      case 63:
        return const Condicao('Chuva moderada', Grupo.chuva);
      case 65:
        return const Condicao('Chuva forte', Grupo.chuva);
      case 66:
      case 67:
        return const Condicao('Chuva congelante', Grupo.chuva);
      case 71:
        return const Condicao('Neve fraca', Grupo.neve);
      case 73:
        return const Condicao('Neve', Grupo.neve);
      case 75:
        return const Condicao('Neve forte', Grupo.neve);
      case 77:
        return const Condicao('Grãos de neve', Grupo.neve);
      case 80:
        return const Condicao('Pancadas de chuva fracas', Grupo.chuva);
      case 81:
        return const Condicao('Pancadas de chuva', Grupo.chuva);
      case 82:
        return const Condicao('Pancadas de chuva fortes', Grupo.chuva);
      case 85:
      case 86:
        return const Condicao('Pancadas de neve', Grupo.neve);
      case 95:
        return const Condicao('Tempestade', Grupo.tempestade);
      case 96:
      case 99:
        return const Condicao('Tempestade com granizo', Grupo.tempestade);
      default:
        return const Condicao('Tempo instável', Grupo.nublado);
    }
  }

  IconData icone({bool dia = true}) {
    switch (grupo) {
      case Grupo.limpo:
        return dia ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case Grupo.poucasNuvens:
        return dia ? Icons.wb_cloudy_rounded : Icons.nights_stay_rounded;
      case Grupo.nublado:
        return Icons.cloud_rounded;
      case Grupo.neblina:
        return Icons.foggy;
      case Grupo.garoa:
        return Icons.grain_rounded;
      case Grupo.chuva:
        return Icons.umbrella_rounded;
      case Grupo.neve:
        return Icons.ac_unit_rounded;
      case Grupo.tempestade:
        return Icons.thunderstorm_rounded;
    }
  }

  /// Sol em amarelo; o resto em branco.
  Color corIcone({bool dia = true}) =>
      dia && (grupo == Grupo.limpo || grupo == Grupo.poucasNuvens) ? const Color(0xFFFFD54F) : Colors.white;

  /// Degradê do fundo, que muda com o tempo e com o dia/noite da cidade.
  List<Color> fundo({bool dia = true}) {
    switch (grupo) {
      case Grupo.limpo:
        return dia ? const [Color(0xFF1E6FD0), Color(0xFF5AAFEA)] : const [Color(0xFF0A1433), Color(0xFF26306A)];
      case Grupo.poucasNuvens:
        return dia ? const [Color(0xFF2F74B5), Color(0xFF7FA9CD)] : const [Color(0xFF111A36), Color(0xFF333D66)];
      case Grupo.nublado:
        return dia ? const [Color(0xFF4F6075), Color(0xFF8796A7)] : const [Color(0xFF1A212C), Color(0xFF384352)];
      case Grupo.neblina:
        return dia ? const [Color(0xFF66727E), Color(0xFF9AA4AE)] : const [Color(0xFF23292F), Color(0xFF475059)];
      case Grupo.garoa:
      case Grupo.chuva:
        return dia ? const [Color(0xFF33506D), Color(0xFF61809D)] : const [Color(0xFF0E1828), Color(0xFF2A3C52)];
      case Grupo.neve:
        return dia ? const [Color(0xFF4E739A), Color(0xFF8FADCB)] : const [Color(0xFF1C2A41), Color(0xFF465C7A)];
      case Grupo.tempestade:
        return dia ? const [Color(0xFF282B44), Color(0xFF54506F)] : const [Color(0xFF100D1C), Color(0xFF302A46)];
    }
  }
}
