/// Uma cidade encontrada na busca (ou a posição atual do aparelho).
class Cidade {
  final String nome;
  final String? estado;
  final String? pais;
  final double latitude;
  final double longitude;

  const Cidade({required this.nome, this.estado, this.pais, required this.latitude, required this.longitude});

  /// "Pernambuco, Brasil"
  String get regiao => [estado, pais].whereType<String>().where((t) => t.isNotEmpty).join(', ');

  /// Duas cidades com as mesmas coordenadas (arredondadas) são a mesma.
  String get chave => '${latitude.toStringAsFixed(2)},${longitude.toStringAsFixed(2)}';

  factory Cidade.daBusca(Map<String, dynamic> json) => Cidade(
    nome: json['name'] as String,
    estado: json['admin1'] as String?,
    pais: json['country'] as String?,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
  );

  factory Cidade.fromJson(Map<String, dynamic> json) => Cidade(
    nome: json['nome'] as String,
    estado: json['estado'] as String?,
    pais: json['pais'] as String?,
    latitude: (json['lat'] as num).toDouble(),
    longitude: (json['lon'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'nome': nome, 'estado': estado, 'pais': pais, 'lat': latitude, 'lon': longitude};

  @override
  bool operator ==(Object other) => other is Cidade && other.chave == chave;

  @override
  int get hashCode => chave.hashCode;

  @override
  String toString() => regiao.isEmpty ? nome : '$nome, $regiao';
}
