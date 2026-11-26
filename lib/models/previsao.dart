/// Dados que vêm da Open-Meteo, já no horário local da cidade.
/// As horas chegam como texto ("2026-11-26T14:00"), sem fuso, por isso as
/// comparações são feitas pelo texto e não pelo relógio do aparelho.
class Atual {
  final String hora;
  final double temperatura;
  final double sensacao;
  final int umidade;
  final double vento;
  final double direcaoVento;
  final double precipitacao;
  final int codigo;
  final bool dia;

  const Atual({
    required this.hora,
    required this.temperatura,
    required this.sensacao,
    required this.umidade,
    required this.vento,
    required this.direcaoVento,
    required this.precipitacao,
    required this.codigo,
    required this.dia,
  });
}

class Hora {
  final String hora;
  final double temperatura;
  final int? chanceChuva;
  final int codigo;
  final bool dia;

  const Hora({required this.hora, required this.temperatura, this.chanceChuva, required this.codigo, required this.dia});
}

class Dia {
  final String data;
  final int codigo;
  final double maxima;
  final double minima;
  final int? chanceChuva;
  final String? nascer;
  final String? por;
  final double? uv;

  const Dia({
    required this.data,
    required this.codigo,
    required this.maxima,
    required this.minima,
    this.chanceChuva,
    this.nascer,
    this.por,
    this.uv,
  });
}

class Previsao {
  final Atual atual;
  final List<Hora> horas;
  final List<Dia> dias;

  const Previsao({required this.atual, required this.horas, required this.dias});

  Dia? get hoje => dias.isEmpty ? null : dias.first;

  /// As próximas 24 horas a partir da hora atual da cidade
  /// (a versão anterior mostrava sempre de 00:00 às 23:00).
  List<Hora> get proximas24 {
    if (horas.isEmpty) return const [];
    final agora = atual.hora.length >= 13 ? atual.hora.substring(0, 13) : atual.hora;
    var inicio = horas.indexWhere((h) => h.hora.compareTo(agora) >= 0 || h.hora.startsWith(agora));
    if (inicio < 0) inicio = 0;
    return horas.skip(inicio).take(24).toList();
  }

  factory Previsao.fromJson(Map<String, dynamic> json) {
    final c = json['current'] as Map<String, dynamic>;
    final h = (json['hourly'] ?? const {}) as Map<String, dynamic>;
    final d = (json['daily'] ?? const {}) as Map<String, dynamic>;

    List<T> lista<T>(Map<String, dynamic> m, String chave, T Function(dynamic) conv) =>
        ((m[chave] as List?) ?? const []).map(conv).toList();

    final hTempo = lista(h, 'time', (v) => v as String);
    final hTemp = lista(h, 'temperature_2m', _real);
    final hChuva = lista<int?>(h, 'precipitation_probability', _inteiro);
    final hCodigo = lista(h, 'weather_code', (v) => _inteiro(v) ?? 0);
    final hDia = lista(h, 'is_day', (v) => v == 1 || v == true);

    final dTempo = lista(d, 'time', (v) => v as String);
    final dCodigo = lista(d, 'weather_code', (v) => _inteiro(v) ?? 0);
    final dMax = lista(d, 'temperature_2m_max', _real);
    final dMin = lista(d, 'temperature_2m_min', _real);
    final dChuva = lista<int?>(d, 'precipitation_probability_max', _inteiro);
    final dNascer = lista<String?>(d, 'sunrise', (v) => v as String?);
    final dPor = lista<String?>(d, 'sunset', (v) => v as String?);
    final dUv = lista<double?>(d, 'uv_index_max', (v) => (v as num?)?.toDouble());

    T? em<T>(List<T?> l, int i) => i < l.length ? l[i] : null;

    return Previsao(
      atual: Atual(
        hora: c['time'] as String,
        temperatura: _real(c['temperature_2m']),
        sensacao: _real(c['apparent_temperature'] ?? c['temperature_2m']),
        umidade: _inteiro(c['relative_humidity_2m']) ?? 0,
        vento: _real(c['wind_speed_10m']),
        direcaoVento: _real(c['wind_direction_10m']),
        precipitacao: _real(c['precipitation']),
        codigo: _inteiro(c['weather_code']) ?? 0,
        dia: c['is_day'] == 1 || c['is_day'] == true,
      ),
      horas: [
        for (var i = 0; i < hTempo.length; i++)
          Hora(
            hora: hTempo[i],
            temperatura: em(hTemp, i) ?? 0,
            chanceChuva: em(hChuva, i),
            codigo: em(hCodigo, i) ?? 0,
            dia: em(hDia, i) ?? true,
          ),
      ],
      dias: [
        for (var i = 0; i < dTempo.length; i++)
          Dia(
            data: dTempo[i],
            codigo: em(dCodigo, i) ?? 0,
            maxima: em(dMax, i) ?? 0,
            minima: em(dMin, i) ?? 0,
            chanceChuva: em(dChuva, i),
            nascer: em(dNascer, i),
            por: em(dPor, i),
            uv: em(dUv, i),
          ),
      ],
    );
  }
}

double _real(dynamic v) => (v as num?)?.toDouble() ?? 0;
int? _inteiro(dynamic v) => (v as num?)?.round();
