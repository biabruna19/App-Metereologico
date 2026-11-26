import 'package:app_meteorologico/models/cidade.dart';
import 'package:app_meteorologico/models/previsao.dart';
import 'package:app_meteorologico/util/condicao.dart';
import 'package:app_meteorologico/util/formatos.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dados_falsos.dart';

void main() {
  group('Previsao', () {
    final p = Previsao.fromJson(previsaoFalsa());

    test('lê o tempo atual com umidade de verdade', () {
      expect(p.atual.temperatura, 27.4);
      expect(p.atual.umidade, 64);
      expect(p.atual.sensacao, 29.1);
      expect(p.atual.dia, isTrue);
    });

    test('próximas 24 horas começam na hora atual da cidade, não à meia-noite', () {
      final h = p.proximas24;
      expect(h.length, 24);
      expect(h.first.hora, '2026-11-26T14:00');
      expect(h.last.hora, '2026-11-27T13:00');
    });

    test('lê os 7 dias, aceitando valores vazios', () {
      expect(p.dias.length, 7);
      expect(p.hoje!.maxima, 29.8);
      expect(p.hoje!.nascer, '2026-11-26T05:12');
      expect(p.dias[1].nascer, isNull);
    });
  });

  group('Condicao', () {
    test('conhece todos os códigos da Open-Meteo', () {
      const codigos = [0, 1, 2, 3, 45, 48, 51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 71, 73, 75, 77, 80, 81, 82, 85, 86, 95, 96, 99];
      for (final c in codigos) {
        expect(Condicao.doCodigo(c).descricao, isNot('Tempo instável'), reason: 'código $c');
      }
    });

    test('pancadas de chuva (antes "Desconhecido")', () {
      expect(Condicao.doCodigo(81).descricao, 'Pancadas de chuva');
      expect(Condicao.doCodigo(81).grupo, Grupo.chuva);
    });

    test('ícone e fundo mudam à noite', () {
      final c = Condicao.doCodigo(0);
      expect(c.icone(dia: true), isNot(c.icone(dia: false)));
      expect(c.fundo(dia: true), isNot(c.fundo(dia: false)));
    });
  });

  group('formatos', () {
    test('temperatura em °C e °F', () {
      expect(temperatura(27.4, false, unidade: true), '27°C');
      expect(temperatura(27.4, true, unidade: true), '81°F');
      expect(temperatura(-0.3, false), '0°');
    });

    test('direção do vento', () {
      expect(direcaoDoVento(0), 'N');
      expect(direcaoDoVento(45), 'NE');
      expect(direcaoDoVento(90), 'L');
      expect(direcaoDoVento(350), 'N');
      expect(direcaoDoVento(225), 'SO');
    });

    test('nível do UV', () {
      expect(nivelUv(2), 'Baixo');
      expect(nivelUv(5), 'Moderado');
      expect(nivelUv(7), 'Alto');
      expect(nivelUv(9.4), 'Muito alto');
      expect(nivelUv(11.2), 'Extremo');
    });

    test('dias da semana e datas', () {
      expect(nomeDoDia('2026-11-26', 0), 'Hoje');
      expect(nomeDoDia('2026-11-27', 1), 'Amanhã');
      expect(nomeDoDia('2026-11-28', 2), 'Sáb.');
      expect(dataPorExtenso('2026-11-26T14:20'), 'quinta-feira, 26 de nov.');
      expect(dataPorExtenso('2026-11-26T14:20', curto: true), 'Qui., 26 de nov.');
      expect(horaCurta('2026-11-26T09:00'), '9h');
      expect(horaMinuto(null), '--:--');
    });
  });

  test('Cidade: igualdade pelas coordenadas e ida e volta em JSON', () {
    const a = Cidade(nome: 'Recife', estado: 'Pernambuco', pais: 'Brasil', latitude: -8.0539, longitude: -34.8811);
    final b = Cidade.fromJson(a.toJson());
    expect(b, a);
    expect(b.regiao, 'Pernambuco, Brasil');
    expect(const Cidade(nome: 'X', latitude: 1, longitude: 2).regiao, '');
  });
}
