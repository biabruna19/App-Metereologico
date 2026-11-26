import 'package:app_meteorologico/providers/clima_provider.dart';
import 'package:app_meteorologico/services/clima_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dados_falsos.dart';

void main() {
  late ClienteFalso rede;
  ClimaProvider novo({LocalizadorFalso? loc}) => ClimaProvider(
    api: ClimaApi(cliente: rede.cliente),
    localizador: loc ?? LocalizadorFalso(),
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rede = ClienteFalso();
  });

  test('primeira visita abre São Paulo', () async {
    final p = novo();
    await p.iniciar();
    expect(p.cidade!.nome, 'São Paulo');
    expect(p.previsao, isNotNull);
    expect(p.carregando, isFalse);
    expect(p.recentes, isEmpty);
  });

  test('buscar cidade abre a previsão e guarda nos recentes', () async {
    final p = novo();
    await p.iniciar();
    await p.buscar('Recife');
    expect(p.cidade!.nome, 'Recife');
    expect(p.previsao!.atual.temperatura, 30.2);
    expect(p.recentes.map((c) => c.nome), ['Recife']);
  });

  test('nome com acento e espaço vai codificado na URL', () async {
    final p = novo();
    await p.sugestoes('Santa Maria');
    expect(rede.pedidos.last.queryParameters['name'], 'Santa Maria');
    expect(rede.pedidos.last.toString(), contains('Santa+Maria'));
  });

  test('cidade inexistente mostra mensagem clara', () async {
    final p = novo();
    await p.iniciar();
    await p.buscar('Xyzlândia');
    expect(p.erro, 'Não encontramos "Xyzlândia". Confira o nome e tente de novo.');
    expect(p.cidade!.nome, 'São Paulo', reason: 'a previsão anterior continua');
  });

  test('sem internet: mensagem amigável, sem "Exception"', () async {
    final p = novo();
    rede.falhar = true;
    await p.iniciar();
    expect(p.previsao, isNull);
    expect(p.erro, contains('Sem conexão'));
    expect(p.erro, isNot(contains('Exception')));
    rede.falhar = false;
    await p.atualizar();
    expect(p.previsao, isNotNull);
    expect(p.erro, isNull);
  });

  test('erro do servidor', () async {
    final p = novo();
    rede.status = 503;
    await p.iniciar();
    expect(p.erro, contains('erro 503'));
  });

  test('favoritos, recentes, unidade e última cidade ficam salvos no aparelho', () async {
    final p = novo();
    await p.iniciar();
    await p.buscar('Recife');
    await p.alternarFavorito();
    await p.alternarUnidade();
    expect(p.ehFavorita, isTrue);

    final depois = novo();
    await depois.iniciar();
    expect(depois.cidade!.nome, 'Recife', reason: 'abre a última cidade vista');
    expect(depois.favoritos.map((c) => c.nome), ['Recife']);
    expect(depois.recentes.map((c) => c.nome), ['Recife']);
    expect(depois.fahrenheit, isTrue);

    await depois.alternarFavorito();
    expect(depois.ehFavorita, isFalse);
    await depois.removerRecente(depois.recentes.first);
    expect(depois.recentes, isEmpty);
  });

  test('recentes: sem repetir e no máximo 6', () async {
    final p = novo();
    await p.iniciar();
    for (var i = 0; i < 8; i++) {
      await p.abrir(p.cidade!.copiaEm(i.toDouble()));
    }
    await p.buscar('Recife');
    await p.buscar('Recife');
    expect(p.recentes.length, ClimaProvider.maxRecentes);
    expect(p.recentes.first.nome, 'Recife');
    expect(p.recentes.where((c) => c.nome == 'Recife').length, 1);
  });

  test('minha localização encontra o nome do lugar', () async {
    final p = novo();
    await p.iniciar();
    await p.usarLocalizacao();
    expect(p.cidade!.nome, 'Campinas');
    expect(p.cidade!.regiao, 'São Paulo, Brasil');
  });

  test('localização negada', () async {
    final p = novo(loc: LocalizadorFalso(erro: const ClimaException('Sem permissão para usar sua localização.')));
    await p.iniciar();
    await p.usarLocalizacao();
    expect(p.erro, 'Sem permissão para usar sua localização.');
    expect(p.carregando, isFalse);
  });
}
