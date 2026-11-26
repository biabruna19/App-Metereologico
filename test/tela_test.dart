import 'package:app_meteorologico/main.dart';
import 'package:app_meteorologico/providers/clima_provider.dart';
import 'package:app_meteorologico/screens/home_screen.dart';
import 'package:app_meteorologico/services/clima_api.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dados_falsos.dart';

void main() {
  late ClienteFalso rede;
  late ClimaProvider prov;

  Future<void> abrirApp(WidgetTester tester, {Size tamanho = const Size(420, 900)}) async {
    tester.view.physicalSize = tamanho;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: prov,
        child: const ClimaBrasilApp(home: HomeScreen(iniciar: false)),
      ),
    );
    await prov.iniciar();
    await tester.pumpAndSettle();
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rede = ClienteFalso();
    prov = ClimaProvider(
      api: ClimaApi(cliente: rede.cliente),
      localizador: LocalizadorFalso(),
    );
  });

  testWidgets('mostra o tempo atual, os detalhes e a semana', (tester) async {
    await abrirApp(tester);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('27°C'), findsOneWidget);
    expect(find.text('Parcialmente nublado'), findsOneWidget);
    expect(find.textContaining('Sensação 29°'), findsOneWidget);
    expect(find.text('64%'), findsOneWidget); // umidade
    expect(find.text('Vindo do NE'), findsOneWidget);
    expect(find.text('Muito alto'), findsOneWidget); // UV 9,4
    expect(find.text('05:12'), findsOneWidget);
    expect(find.text('PRÓXIMAS 24 HORAS'), findsOneWidget);
    expect(find.text('Agora'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Amanhã'), 300, scrollable: find.byType(Scrollable).first);
    expect(find.text('PRÓXIMOS 7 DIAS'), findsOneWidget);
    expect(find.text('Hoje'), findsOneWidget);
  });

  testWidgets('sugestões aparecem enquanto digita e abrem a cidade', (tester) async {
    await abrirApp(tester);
    await tester.enterText(find.byType(TextField), 'Santa');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Santa Maria'), findsOneWidget);
    expect(find.text('Paraíba, Brasil'), findsOneWidget);
    await tester.tap(find.text('Santa Maria'));
    await tester.pumpAndSettle();
    expect(find.text('Rio Grande do Sul, Brasil'), findsOneWidget);
    // vira um atalho de "recentes"
    expect(find.widgetWithText(InputChip, 'Santa Maria'), findsOneWidget);
  });

  testWidgets('favoritar cria um atalho com estrela', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.byTooltip('Salvar nos favoritos'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Tirar dos favoritos'), findsOneWidget);
    expect(find.widgetWithText(InputChip, 'São Paulo'), findsOneWidget);
  });

  testWidgets('troca para Fahrenheit', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('°F'));
    await tester.pumpAndSettle();
    expect(find.text('81°F'), findsOneWidget);
  });

  testWidgets('cidade não encontrada aparece como aviso, sem apagar a previsão', (tester) async {
    await abrirApp(tester);
    await tester.enterText(find.byType(TextField), 'Xyz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(find.text('Não encontramos "Xyz". Confira o nome e tente de novo.'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
  });

  testWidgets('sem internet mostra o botão de tentar de novo', (tester) async {
    rede.falhar = true;
    await abrirApp(tester);
    expect(find.textContaining('Sem conexão'), findsOneWidget);
    rede.falhar = false;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('São Paulo'), findsOneWidget);
  });

  testWidgets('tela larga usa duas colunas sem estourar', (tester) async {
    await abrirApp(tester, tamanho: const Size(1366, 900));
    final atual = tester.getTopLeft(find.text('São Paulo'));
    final horas = tester.getTopLeft(find.text('PRÓXIMAS 24 HORAS'));
    expect(horas.dx, greaterThan(atual.dx + 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('celular pequeno (320 px) sem estouro', (tester) async {
    await abrirApp(tester, tamanho: const Size(320, 640));
    expect(tester.takeException(), isNull);
  });
}
