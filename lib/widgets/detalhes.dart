import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/clima_provider.dart';
import '../util/formatos.dart';
import 'painel.dart';

/// Umidade, vento, chuva, UV, nascer e pôr do sol.
/// (Na versão anterior a umidade aparecia sempre como "Variável".)
class Detalhes extends StatelessWidget {
  const Detalhes({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ClimaProvider>().previsao!;
    final atual = p.atual;
    final hoje = p.hoje;

    final itens = <_Item>[
      _Item(
        Icons.water_drop_outlined,
        'Umidade',
        '${atual.umidade}%',
        atual.umidade >= 80
            ? 'Ar bem úmido'
            : atual.umidade <= 30
            ? 'Ar seco: beba água'
            : null,
      ),
      _Item(
        Icons.air_rounded,
        'Vento',
        '${atual.vento.round()} km/h',
        'Vindo do ${direcaoDoVento(atual.direcaoVento)}',
        extra: Transform.rotate(
          // a seta aponta para onde o vento vai
          angle: (atual.direcaoVento + 180) * math.pi / 180,
          child: const Icon(Icons.navigation_rounded, size: 16, color: Colors.white70),
        ),
      ),
      _Item(
        Icons.umbrella_outlined,
        'Chuva hoje',
        hoje?.chanceChuva == null ? '--' : '${hoje!.chanceChuva}%',
        atual.precipitacao > 0 ? 'Chovendo agora: ${atual.precipitacao.toStringAsFixed(1)} mm' : 'Chance de chuva',
      ),
      _Item(
        Icons.wb_sunny_outlined,
        'Índice UV',
        hoje?.uv == null ? '--' : hoje!.uv!.round().toString(),
        hoje?.uv == null ? null : nivelUv(hoje!.uv!),
      ),
      _Item(Icons.wb_twilight_rounded, 'Nascer do sol', horaMinuto(hoje?.nascer), null),
      _Item(Icons.nights_stay_outlined, 'Pôr do sol', horaMinuto(hoje?.por), null),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final colunas = c.maxWidth >= 520 ? 3 : 2;
        const espaco = 12.0;
        final largura = (c.maxWidth - espaco * (colunas - 1)) / colunas;
        return Wrap(
          spacing: espaco,
          runSpacing: espaco,
          children: [
            for (final i in itens)
              SizedBox(
                width: largura,
                child: _Bloco(item: i),
              ),
          ],
        );
      },
    );
  }
}

class _Item {
  const _Item(this.icone, this.titulo, this.valor, this.legenda, {this.extra});
  final IconData icone;
  final String titulo;
  final String valor;
  final String? legenda;
  final Widget? extra;
}

class _Bloco extends StatelessWidget {
  const _Bloco({required this.item});
  final _Item item;

  @override
  Widget build(BuildContext context) {
    return Painel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icone, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  item.titulo,
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(item.valor, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                ),
              ),
              if (item.extra != null) ...[const SizedBox(width: 8), item.extra!],
            ],
          ),
          SizedBox(
            height: 20,
            child: item.legenda == null
                ? null
                : Text(
                    item.legenda!,
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        ],
      ),
    );
  }
}
