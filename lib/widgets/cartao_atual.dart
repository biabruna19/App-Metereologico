import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/clima_provider.dart';
import '../util/condicao.dart';
import '../util/formatos.dart';
import 'icone_tempo.dart';
import 'painel.dart';

class CartaoAtual extends StatelessWidget {
  const CartaoAtual({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    final cidade = prov.cidade!;
    final atual = prov.previsao!.atual;
    final hoje = prov.previsao!.hoje;
    final cond = Condicao.doCodigo(atual.codigo);
    final f = prov.fahrenheit;

    return Painel(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cidade.nome, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, height: 1.1)),
                    if (cidade.regiao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(cidade.regiao, style: const TextStyle(fontSize: 15, color: Colors.white70)),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${dataPorExtenso(atual.hora, curto: true)} · ${horaMinuto(atual.hora)} (hora local)',
                        style: const TextStyle(fontSize: 13, color: Colors.white60),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: prov.ehFavorita ? 'Tirar dos favoritos' : 'Salvar nos favoritos',
                onPressed: prov.alternarFavorito,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (w, a) => ScaleTransition(scale: a, child: w),
                  child: Icon(
                    prov.ehFavorita ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey(prov.ehFavorita),
                    size: 30,
                    color: prov.ehFavorita ? const Color(0xFFFFD54F) : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Semantics(
            label: 'Agora: ${temperatura(atual.temperatura, f, unidade: true)}, ${cond.descricao}',
            excludeSemantics: true,
            child: Row(
              children: [
                IconeTempo(cond, dia: atual.dia, tamanho: 80),
                const SizedBox(width: 18),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      temperatura(atual.temperatura, f, unidade: true),
                      style: const TextStyle(fontSize: 84, fontWeight: FontWeight.w300, height: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(cond.descricao, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            [
              if (hoje != null) 'Máx. ${temperatura(hoje.maxima, f)}',
              if (hoje != null) 'Mín. ${temperatura(hoje.minima, f)}',
              'Sensação ${temperatura(atual.sensacao, f)}',
            ].join('  ·  '),
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
