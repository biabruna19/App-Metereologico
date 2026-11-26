import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../util/condicao.dart';

/// Ícone do tempo. A maioria vem pronta do Material, mas não existe um ícone
/// de chuva nem de "sol entre nuvens", então esses são montados aqui.
class IconeTempo extends StatelessWidget {
  const IconeTempo(this.condicao, {super.key, this.dia = true, this.tamanho = 24});

  final Condicao condicao;
  final bool dia;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final s = tamanho;
    Widget conteudo;
    switch (condicao.grupo) {
      case Grupo.poucasNuvens when dia:
        conteudo = Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Icon(Icons.wb_sunny_rounded, size: s * 0.66, color: const Color(0xFFFFD54F)),
            ),
            Positioned(
              left: 0,
              bottom: s * 0.04,
              child: Icon(Icons.cloud_rounded, size: s * 0.8, color: Colors.white),
            ),
          ],
        );
      case Grupo.chuva:
      case Grupo.garoa:
        final garoa = condicao.grupo == Grupo.garoa;
        conteudo = Stack(
          children: [
            Positioned(
              top: -s * 0.06,
              left: s * 0.05,
              child: Icon(Icons.cloud_rounded, size: s * 0.9, color: Colors.white),
            ),
            Positioned(
              left: s * 0.22,
              right: s * 0.18,
              bottom: s * 0.02,
              height: s * 0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var i = 0; i < 3; i++)
                    Transform.rotate(
                      angle: math.pi / 9,
                      child: Container(
                        width: math.max(1.5, s * 0.07),
                        height: garoa ? s * 0.1 : s * 0.24,
                        decoration: BoxDecoration(color: const Color(0xFF9AD8FF), borderRadius: BorderRadius.circular(s)),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      default:
        return Icon(
          condicao.icone(dia: dia),
          size: s,
          color: condicao.corIcone(dia: dia),
          semanticLabel: condicao.descricao,
        );
    }
    return Semantics(
      label: condicao.descricao,
      child: SizedBox(width: s, height: s, child: conteudo),
    );
  }
}
