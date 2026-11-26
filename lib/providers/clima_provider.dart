import 'package:flutter/foundation.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';
import '../services/armazenamento.dart';
import '../services/clima_api.dart';
import '../services/localizador.dart';

class ClimaProvider extends ChangeNotifier {
  ClimaProvider({ClimaApi? api, Armazenamento? armazenamento, Localizador? localizador})
    : _api = api ?? ClimaApi(),
      _armazenamento = armazenamento ?? Armazenamento(),
      _localizador = localizador ?? LocalizadorGps();

  final ClimaApi _api;
  final Armazenamento _armazenamento;
  final Localizador _localizador;

  /// Cidade aberta na primeira visita.
  static const cidadePadrao = Cidade(nome: 'São Paulo', estado: 'São Paulo', pais: 'Brasil', latitude: -23.5475, longitude: -46.63611);
  static const maxRecentes = 6;

  Cidade? cidade;
  Previsao? previsao;
  bool carregando = false;
  bool localizando = false;
  String? erro;
  List<Cidade> favoritos = [];
  List<Cidade> recentes = [];
  bool fahrenheit = false;

  // Se a pessoa trocar de cidade rápido, só a última resposta vale.
  int _pedido = 0;

  bool get ehFavorita => cidade != null && favoritos.contains(cidade);

  Future<void> iniciar() async {
    favoritos = await _armazenamento.favoritos();
    recentes = await _armazenamento.recentes();
    fahrenheit = await _armazenamento.fahrenheit();
    notifyListeners();
    await abrir(await _armazenamento.ultima() ?? cidadePadrao, registrar: false);
  }

  /// Sugestões para a busca. Em caso de erro devolve lista vazia:
  /// a mensagem de erro aparece só quando a pessoa confirma a busca.
  Future<List<Cidade>> sugestoes(String termo) async {
    try {
      return await _api.buscarCidades(termo);
    } catch (_) {
      return const [];
    }
  }

  Future<void> abrir(Cidade nova, {bool registrar = true}) async {
    final pedido = ++_pedido;
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final p = await _api.previsao(nova);
      if (pedido != _pedido) return;
      cidade = nova;
      previsao = p;
      await _armazenamento.salvarUltima(nova);
      if (registrar) await _registrarRecente(nova);
    } on ClimaException catch (e) {
      if (pedido == _pedido) erro = e.mensagem;
    } catch (_) {
      if (pedido == _pedido) erro = 'Não foi possível carregar o clima agora. Tente de novo.';
    } finally {
      if (pedido == _pedido) {
        carregando = false;
        notifyListeners();
      }
    }
  }

  /// Busca pelo nome digitado e abre o primeiro resultado.
  Future<void> buscar(String termo) async {
    final t = termo.trim();
    if (t.isEmpty) return;
    final pedido = ++_pedido;
    carregando = true;
    erro = null;
    notifyListeners();
    try {
      final resultados = await _api.buscarCidades(t);
      if (pedido != _pedido) return;
      if (resultados.isEmpty) {
        _falhar('Não encontramos "$t". Confira o nome e tente de novo.');
        return;
      }
      await abrir(resultados.first);
    } on ClimaException catch (e) {
      if (pedido == _pedido) _falhar(e.mensagem);
    }
  }

  Future<void> usarLocalizacao() async {
    final pedido = ++_pedido;
    carregando = true;
    localizando = true;
    erro = null;
    notifyListeners();
    try {
      // Limite de segurança: aconteça o que acontecer, a espera termina.
      final p = await _localizador.posicao().timeout(const Duration(seconds: 30));
      localizando = false;
      final lugar = await _api.cidadeDaPosicao(p.latitude, p.longitude);
      if (pedido != _pedido) return;
      await abrir(lugar);
    } on ClimaException catch (e) {
      if (pedido == _pedido) _falhar(e.mensagem);
    } catch (_) {
      if (pedido == _pedido) {
        _falhar(
          'Não conseguimos descobrir sua localização. Confira se ela está ligada e liberada para este site, ou busque a cidade pelo nome.',
        );
      }
    } finally {
      if (localizando) {
        localizando = false;
        notifyListeners();
      }
    }
  }

  Future<void> atualizar() => cidade == null ? iniciar() : abrir(cidade!, registrar: false);

  Future<void> alternarFavorito() async {
    final c = cidade;
    if (c == null) return;
    favoritos = ehFavorita ? (favoritos.where((f) => f != c).toList()) : [c, ...favoritos];
    notifyListeners();
    await _armazenamento.salvarFavoritos(favoritos);
  }

  Future<void> removerRecente(Cidade c) async {
    recentes = recentes.where((r) => r != c).toList();
    notifyListeners();
    await _armazenamento.salvarRecentes(recentes);
  }

  Future<void> alternarUnidade() async {
    fahrenheit = !fahrenheit;
    notifyListeners();
    await _armazenamento.salvarFahrenheit(fahrenheit);
  }

  /// Usado depois que a tela já mostrou o erro (sem redesenhar).
  void limparErro() => erro = null;

  void _falhar(String mensagem) {
    erro = mensagem;
    carregando = false;
    notifyListeners();
  }

  Future<void> _registrarRecente(Cidade c) async {
    recentes = [c, ...recentes.where((r) => r != c)].take(maxRecentes).toList();
    await _armazenamento.salvarRecentes(recentes);
  }
}
