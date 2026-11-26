import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/clima_provider.dart';
import '../util/condicao.dart';
import '../util/formatos.dart';
import 'icone_tempo.dart';
import 'painel.dart';

/// Previsão da semana, com uma barra mostrando a faixa de temperatura de
/// cada dia em relação à semana toda.
class ProximosDias extends StatelessWidget {
  const ProximosDias({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    final dias = prov.previsao!.dias;
    final f = prov.fahrenheit;
    if (dias.isEmpty) return const SizedBox.shrink();

    final minSemana = dias.map((d) => d.minima).reduce((a, b) => a < b ? a : b);
    final maxSemana = dias.map((d) => d.maxima).reduce((a, b) => a > b ? a : b);
    final faixa = (maxSemana - minSemana).abs() < 0.1 ? 1.0 : maxSemana - minSemana;

    return Painel(
      child: Column(
        children: [
          TituloSecao('Próximos ${dias.length} dias', icone: Icons.calendar_month_rounded),
          for (var i = 0; i < dias.length; i++) ...[
            if (i > 0) Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
            _LinhaDia(
              nome: nomeDoDia(dias[i].data, i),
              cond: Condicao.doCodigo(dias[i].codigo),
              chuva: dias[i].chanceChuva ?? 0,
              minima: temperatura(dias[i].minima, f),
              maxima: temperatura(dias[i].maxima, f),
              inicio: (dias[i].minima - minSemana) / faixa,
              fim: (dias[i].maxima - minSemana) / faixa,
            ),
          ],
        ],
      ),
    );
  }
}

class _LinhaDia extends StatelessWidget {
  const _LinhaDia({
    required this.nome,
    required this.cond,
    required this.chuva,
    required this.minima,
    required this.maxima,
    required this.inicio,
    required this.fim,
  });

  final String nome;
  final Condicao cond;
  final int chuva;
  final String minima;
  final String maxima;
  final double inicio;
  final double fim;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$nome: ${cond.descricao}, mínima $minima, máxima $maxima${chuva >= 10 ? ', $chuva% de chance de chuva' : ''}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              child: Text(nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Tooltip(message: cond.descricao, child: IconeTempo(cond, tamanho: 28)),
            SizedBox(
              width: 42,
              child: Text(
                chuva >= 10 ? '$chuva%' : '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF9AD8FF)),
              ),
            ),
            SizedBox(
              width: 34,
              child: Text(
                minima,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, c) => Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(3)),
                    ),
                    Positioned(
                      left: c.maxWidth * inicio.clamp(0.0, 1.0),
                      width: math.min(c.maxWidth, math.max(6.0, c.maxWidth * (fim - inicio).clamp(0.0, 1.0))),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: const LinearGradient(colors: [Color(0xFF81D4FA), Color(0xFFFFD54F), Color(0xFFFF8A65)]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 34,
              child: Text(maxima, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
