import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/clima_provider.dart';
import '../util/condicao.dart';
import '../util/formatos.dart';
import '../widgets/barra_busca.dart';
import '../widgets/cartao_atual.dart';
import '../widgets/detalhes.dart';
import '../widgets/painel.dart';
import '../widgets/proximas_horas.dart';
import '../widgets/proximos_dias.dart';
import '../widgets/rodape.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.iniciar = true});

  /// Nos testes a carga inicial é feita à mão.
  final bool iniciar;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ClimaProvider _prov;

  @override
  void initState() {
    super.initState();
    _prov = context.read<ClimaProvider>();
    _prov.addListener(_avisarErro);
    if (widget.iniciar) WidgetsBinding.instance.addPostFrameCallback((_) => _prov.iniciar());
  }

  @override
  void dispose() {
    _prov.removeListener(_avisarErro);
    super.dispose();
  }

  /// Se já há uma previsão na tela, o erro aparece num aviso embaixo
  /// em vez de apagar tudo.
  void _avisarErro() {
    final erro = _prov.erro;
    if (erro == null || _prov.previsao == null || _prov.carregando) return;
    _prov.limparErro();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(erro), behavior: SnackBarBehavior.floating));
  }

  Future<void> _compartilhar() async {
    final c = _prov.cidade;
    final p = _prov.previsao;
    if (c == null || p == null) return;
    final f = _prov.fahrenheit;
    final cond = Condicao.doCodigo(p.atual.codigo).descricao.toLowerCase();
    final hoje = p.hoje;
    final link = kIsWeb ? '\n${Uri.base.origin}${Uri.base.path}' : '';
    final texto =
        'Agora em ${c.nome}: ${temperatura(p.atual.temperatura, f, unidade: true)}, $cond.'
        '${hoje == null ? '' : ' Máxima de ${temperatura(hoje.maxima, f)} e mínima de ${temperatura(hoje.minima, f)}.'}'
        '\nPrevisão do Clima Brasil$link';
    final mensageiro = ScaffoldMessenger.of(context);
    try {
      final r = await SharePlus.instance.share(ShareParams(text: texto, subject: 'Clima em ${c.nome}'));
      if (r.status != ShareResultStatus.unavailable) return;
    } catch (_) {
      // navegador sem a janela de compartilhar: copia o texto
    }
    await Clipboard.setData(ClipboardData(text: texto));
    mensageiro
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Previsão copiada. É só colar onde quiser.'), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    final previsao = prov.previsao;
    final cond = Condicao.doCodigo(previsao?.atual.codigo ?? 2);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: cond.fundo(dia: previsao?.atual.dia ?? true),
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: prov.atualizar,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Topo(aoCompartilhar: previsao == null ? null : _compartilhar),
                        SizedBox(
                          height: 3,
                          child: prov.carregando && previsao != null
                              ? const LinearProgressIndicator(color: Colors.white, backgroundColor: Colors.transparent)
                              : null,
                        ),
                        const SizedBox(height: 10),
                        const BarraBusca(),
                        const SizedBox(height: 20),
                        _conteudo(prov),
                        const Rodape(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _conteudo(ClimaProvider prov) {
    if (prov.previsao == null) {
      if (prov.erro != null) return _PainelErro(mensagem: prov.erro!, aoTentar: prov.atualizar);
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 120),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    const espaco = SizedBox(height: 16);
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= 900) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: Column(children: [CartaoAtual(), espaco, Detalhes()])),
              SizedBox(width: 16),
              Expanded(flex: 6, child: Column(children: [ProximasHoras(), espaco, ProximosDias()])),
            ],
          );
        }
        return const Column(children: [CartaoAtual(), espaco, ProximasHoras(), espaco, Detalhes(), espaco, ProximosDias()]);
      },
    );
  }
}

class _Topo extends StatelessWidget {
  const _Topo({this.aoCompartilhar});
  final VoidCallback? aoCompartilhar;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    return Row(
      children: [
        const Icon(Icons.wb_sunny_rounded, color: Color(0xFFFFD54F), size: 26),
        const SizedBox(width: 8),
        // em telas muito estreitas fica só o sol, para não cortar o nome
        Expanded(
          child: MediaQuery.sizeOf(context).width < 360
              ? const SizedBox.shrink()
              : const Text(
                  'Clima Brasil',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
        ),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('°C'), tooltip: 'Celsius'),
            ButtonSegment(value: true, label: Text('°F'), tooltip: 'Fahrenheit'),
          ],
          selected: {prov.fahrenheit},
          onSelectionChanged: (s) {
            if (s.first != prov.fahrenheit) prov.alternarUnidade();
          },
          showSelectedIcon: false,
          style: SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: Colors.white,
            selectedForegroundColor: const Color(0xFF0B2545),
            selectedBackgroundColor: Colors.white,
            side: const BorderSide(color: Colors.white54),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          tooltip: 'Compartilhar previsão',
          onPressed: aoCompartilhar,
          icon: const Icon(Icons.ios_share_rounded),
          color: Colors.white,
        ),
      ],
    );
  }
}

class _PainelErro extends StatelessWidget {
  const _PainelErro({required this.mensagem, required this.aoTentar});
  final String mensagem;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Painel(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.white70),
            const SizedBox(height: 14),
            Text(mensagem, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: aoTentar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar de novo'),
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0B2545)),
            ),
          ],
        ),
      ),
    );
  }
}
