import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../models/cidade.dart';
import '../providers/clima_provider.dart';
import 'painel.dart';

/// Busca com sugestões enquanto a pessoa digita, botão de localização
/// e atalhos para as cidades favoritas e recentes.
class BarraBusca extends StatefulWidget {
  const BarraBusca({super.key});

  @override
  State<BarraBusca> createState() => _BarraBuscaState();
}

class _BarraBuscaState extends State<BarraBusca> {
  final _controle = TextEditingController();
  final _foco = FocusNode();
  Timer? _espera;
  List<Cidade> _sugestoes = const [];
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _foco.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _espera?.cancel();
    _controle.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _aoDigitar(String texto) {
    setState(() {}); // mostra/esconde o botão de limpar
    _espera?.cancel();
    if (texto.trim().length < 2) {
      setState(() => _sugestoes = const []);
      return;
    }
    _espera = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _buscando = true);
      final resultado = await context.read<ClimaProvider>().sugestoes(texto);
      if (!mounted || _controle.text != texto) return;
      setState(() {
        _sugestoes = resultado;
        _buscando = false;
      });
    });
  }

  void _limpar() {
    _espera?.cancel();
    _controle.clear();
    setState(() {
      _sugestoes = const [];
      _buscando = false;
    });
  }

  void _abrir(Cidade c) {
    _limpar();
    _foco.unfocus();
    context.read<ClimaProvider>().abrir(c);
  }

  void _confirmar(String texto) {
    if (texto.trim().isEmpty) return;
    if (_sugestoes.isNotEmpty) {
      _abrir(_sugestoes.first);
      return;
    }
    _limpar();
    _foco.unfocus();
    context.read<ClimaProvider>().buscar(texto);
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ClimaProvider>();
    final mostrarSugestoes = _foco.hasFocus && (_sugestoes.isNotEmpty || _buscando);
    final recentes = prov.recentes.where((r) => !prov.favoritos.contains(r)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controle,
                focusNode: _foco,
                textInputAction: TextInputAction.search,
                onChanged: _aoDigitar,
                onSubmitted: _confirmar,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Buscar cidade',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white),
                  suffixIcon: _controle.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: _limpar,
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.16),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: Colors.white70, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Tooltip(
              message: 'Usar minha localização',
              child: Material(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: prov.carregando ? null : prov.usarLocalizacao,
                  child: SizedBox(
                    width: 54,
                    height: 54,
                    child: prov.localizando
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                              semanticsLabel: 'Procurando sua localização',
                            ),
                          )
                        : const Icon(Icons.my_location_rounded, color: Colors.white, semanticLabel: 'Usar minha localização'),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (mostrarSugestoes)
          // Conta como parte do campo: tocar aqui não tira o foco antes do clique.
          TextFieldTapRegion(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Painel(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: _buscando && _sugestoes.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                        ),
                      )
                    : Material(
                        type: MaterialType.transparency,
                        child: Column(
                          children: [
                            for (final c in _sugestoes)
                              ListTile(
                                leading: const Icon(Icons.location_on_outlined, color: Colors.white70),
                                title: Text(
                                  c.nome,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                                subtitle: c.regiao.isEmpty ? null : Text(c.regiao, style: const TextStyle(color: Colors.white70)),
                                onTap: () => _abrir(c),
                              ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        if (prov.favoritos.isNotEmpty || recentes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in prov.favoritos)
                  _Atalho(
                    icone: Icons.star_rounded,
                    corIcone: const Color(0xFFFFD54F),
                    texto: f.nome,
                    ativo: f == prov.cidade,
                    aoTocar: () => prov.abrir(f, registrar: false),
                  ),
                for (final r in recentes)
                  _Atalho(
                    icone: Icons.history_rounded,
                    texto: r.nome,
                    ativo: r == prov.cidade,
                    aoTocar: () => prov.abrir(r),
                    aoRemover: () => prov.removerRecente(r),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Atalho extends StatelessWidget {
  const _Atalho({
    required this.icone,
    required this.texto,
    required this.aoTocar,
    this.aoRemover,
    this.ativo = false,
    this.corIcone = Colors.white70,
  });

  final IconData icone;
  final Color corIcone;
  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;
  final VoidCallback? aoRemover;

  @override
  Widget build(BuildContext context) {
    return InputChip(
      avatar: Icon(icone, size: 18, color: corIcone),
      label: Text(texto),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      backgroundColor: Colors.white.withValues(alpha: ativo ? 0.28 : 0.12),
      side: BorderSide(color: Colors.white.withValues(alpha: ativo ? 0.5 : 0.18)),
      shape: const StadiumBorder(),
      onPressed: aoTocar,
      onDeleted: aoRemover,
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      deleteIconColor: Colors.white70,
      deleteButtonTooltipMessage: 'Remover dos recentes',
      showCheckmark: false,
    );
  }
}
