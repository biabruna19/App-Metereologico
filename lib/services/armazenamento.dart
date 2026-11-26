import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cidade.dart';

/// Favoritos, buscas recentes e preferências ficam salvos no próprio aparelho
/// (no navegador, isso usa o localStorage). Antes o histórico ia para o
/// Supabase, mas nunca aparecia na tela e parava quando o projeto pausava.
class Armazenamento {
  static const _favoritos = 'favoritos';
  static const _recentes = 'recentes';
  static const _ultima = 'ultima_cidade';
  static const _fahrenheit = 'fahrenheit';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Cidade>> favoritos() => _lerLista(_favoritos);
  Future<List<Cidade>> recentes() => _lerLista(_recentes);
  Future<void> salvarFavoritos(List<Cidade> lista) => _salvarLista(_favoritos, lista);
  Future<void> salvarRecentes(List<Cidade> lista) => _salvarLista(_recentes, lista);

  Future<Cidade?> ultima() async {
    final texto = (await _prefs).getString(_ultima);
    if (texto == null) return null;
    try {
      return Cidade.fromJson(json.decode(texto) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> salvarUltima(Cidade cidade) async => (await _prefs).setString(_ultima, json.encode(cidade.toJson()));

  Future<bool> fahrenheit() async => (await _prefs).getBool(_fahrenheit) ?? false;
  Future<void> salvarFahrenheit(bool valor) async => (await _prefs).setBool(_fahrenheit, valor);

  Future<List<Cidade>> _lerLista(String chave) async {
    final itens = (await _prefs).getStringList(chave) ?? const [];
    final lista = <Cidade>[];
    for (final item in itens) {
      try {
        lista.add(Cidade.fromJson(json.decode(item) as Map<String, dynamic>));
      } catch (_) {
        // ignora itens salvos num formato antigo
      }
    }
    return lista;
  }

  Future<void> _salvarLista(String chave, List<Cidade> lista) async =>
      (await _prefs).setStringList(chave, lista.map((c) => json.encode(c.toJson())).toList());
}
