/// Pequenas funções de formatação, sem depender de pacotes de data.
library;

const _diasSemana = ['Seg.', 'Ter.', 'Qua.', 'Qui.', 'Sex.', 'Sáb.', 'Dom.'];
const _diasSemanaLongos = ['segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', 'sexta-feira', 'sábado', 'domingo'];
const _meses = ['jan.', 'fev.', 'mar.', 'abr.', 'maio', 'jun.', 'jul.', 'ago.', 'set.', 'out.', 'nov.', 'dez.'];

/// "Hoje", "Amanhã", "Qua."
String nomeDoDia(String dataIso, int indice) {
  if (indice == 0) return 'Hoje';
  if (indice == 1) return 'Amanhã';
  return _diasSemana[DateTime.parse(dataIso).weekday - 1];
}

/// "quarta-feira, 26 de nov." ou, curto, "Qua., 26 de nov."
String dataPorExtenso(String iso, {bool curto = false}) {
  final d = DateTime.parse(iso.substring(0, 10));
  final dia = curto ? _diasSemana[d.weekday - 1] : _diasSemanaLongos[d.weekday - 1];
  return '$dia, ${d.day} de ${_meses[d.month - 1]}';
}

/// "2026-11-26T14:15" → "14:15"
String horaMinuto(String? iso) => iso == null || iso.length < 16 ? '--:--' : iso.substring(11, 16);

/// "2026-11-26T14:00" → "14h"
String horaCurta(String iso) => '${int.parse(iso.substring(11, 13))}h';

/// Direção de onde o vento vem: 45° → "NE".
String direcaoDoVento(double graus) {
  const nomes = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
  return nomes[((graus % 360) / 45).round() % 8];
}

/// Classificação do índice UV usada pela OMS.
String nivelUv(double uv) {
  if (uv < 3) return 'Baixo';
  if (uv < 6) return 'Moderado';
  if (uv < 8) return 'Alto';
  if (uv < 11) return 'Muito alto';
  return 'Extremo';
}

double converter(double celsius, bool fahrenheit) => fahrenheit ? celsius * 9 / 5 + 32 : celsius;

/// "27°" ou, com unidade, "27°C" / "81°F".
String temperatura(double celsius, bool fahrenheit, {bool unidade = false}) {
  final valor = converter(celsius, fahrenheit).round();
  // evita "-0°"
  final texto = valor == 0 ? '0' : '$valor';
  return unidade ? '$texto°${fahrenheit ? 'F' : 'C'}' : '$texto°';
}
