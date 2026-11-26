import 'package:fl_chart/fl_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/clima_provider.dart';
import '../util/condicao.dart';
import '../util/formatos.dart';
import 'icone_tempo.dart';
import 'painel.dart';

class ProximasHoras extends StatelessWidget {
  const ProximasHoras({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    final horas = prov.previsao!.proximas24;
    final f = prov.fahrenheit;
    if (horas.isEmpty) return const SizedBox.shrink();

    final valores = [for (final h in horas) converter(h.temperatura, f)];
    final menor = valores.reduce((a, b) => a < b ? a : b);
    final maior = valores.reduce((a, b) => a > b ? a : b);

    return Painel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TituloSecao('Próximas 24 horas', icone: Icons.schedule_rounded),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (horas.length - 1).toDouble(),
                minY: menor.floorToDouble() - 2,
                maxY: maior.ceilToDouble() + 2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      interval: 3,
                      getTitlesWidget: (valor, meta) {
                        final i = valor.toInt();
                        if (i < 0 || i >= horas.length || valor != i.toDouble()) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            i == 0 ? 'Agora' : horaCurta(horas[i].hora),
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.black.withValues(alpha: 0.7),
                    tooltipBorderRadius: BorderRadius.circular(10),
                    getTooltipItems: (pontos) => [
                      for (final p in pontos)
                        LineTooltipItem(
                          '${horaCurta(horas[p.x.toInt()].hora)}\n${temperatura(horas[p.x.toInt()].temperatura, f)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [for (var i = 0; i < valores.length; i++) FlSpot(i.toDouble(), valores[i])],
                    isCurved: true,
                    preventCurveOverShooting: true,
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    gradient: const LinearGradient(colors: [Color(0xFFFFE082), Color(0xFFFFB74D)]),
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [const Color(0xFFFFCA28).withValues(alpha: 0.35), const Color(0xFFFFCA28).withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: horas.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final h = horas[i];
                final cond = Condicao.doCodigo(h.codigo);
                final chuva = h.chanceChuva ?? 0;
                return Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: i == 0 ? 0.2 : 0.07),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FittedBox(
                        child: Text(i == 0 ? 'Agora' : horaCurta(h.hora), style: const TextStyle(fontSize: 13, color: Colors.white70)),
                      ),
                      IconeTempo(cond, dia: h.dia, tamanho: 26),
                      FittedBox(
                        child: Text(temperatura(h.temperatura, f), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      SizedBox(
                        height: 16,
                        child: FittedBox(
                          child: Text(chuva >= 10 ? '$chuva%' : ' ', style: const TextStyle(fontSize: 12, color: Color(0xFF9AD8FF))),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
