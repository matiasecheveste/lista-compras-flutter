// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../modelo/articulo.dart';

/// Persistencia de la lista. La interfaz permite usar memoria en las pruebas.
abstract interface class Repositorio {
  Future<List<Articulo>> cargar();
  Future<void> guardar(List<Articulo> articulos);
}

class RepositorioMemoria implements Repositorio {
  RepositorioMemoria([List<Articulo>? iniciales]) : _articulos = [...?iniciales];
  List<Articulo> _articulos;
  int guardados = 0;

  @override
  Future<List<Articulo>> cargar() async => [..._articulos];

  @override
  Future<void> guardar(List<Articulo> articulos) async {
    _articulos = [...articulos];
    guardados++;
  }
}

class RepositorioPreferencias implements Repositorio {
  static const clave = 'lista_compras_v1';

  @override
  Future<List<Articulo>> cargar() async {
    final preferencias = await SharedPreferences.getInstance();
    final texto = preferencias.getString(clave);
    if (texto == null) return [];
    try {
      final lista = jsonDecode(texto) as List<dynamic>;
      return lista.map((e) => Articulo.desdeJson(e as Map<String, dynamic>)).toList();
    } on FormatException {
      return []; // datos dañados: se empieza de cero en lugar de cerrar la aplicación
    }
  }

  @override
  Future<void> guardar(List<Articulo> articulos) async {
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(clave, jsonEncode(articulos.map((a) => a.aJson()).toList()));
  }
}
