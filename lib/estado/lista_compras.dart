// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../datos/repositorio.dart';
import '../modelo/articulo.dart';

enum Filtro { todos, pendientes, comprados }

/// Estado de la lista. Cada cambio notifica a la interfaz y se persiste.
class ListaCompras extends ChangeNotifier {
  ListaCompras(this._repositorio, {Random? azar}) : _azar = azar ?? Random.secure();

  final Repositorio _repositorio;
  final Random _azar;
  List<Articulo> _articulos = [];
  Filtro _filtro = Filtro.todos;
  bool _cargando = true;

  bool get cargando => _cargando;
  Filtro get filtro => _filtro;
  List<Articulo> get articulos => List.unmodifiable(_articulos);

  int get total => _articulos.length;
  int get comprados => _articulos.where((a) => a.comprado).length;
  double get progreso => total == 0 ? 0 : comprados / total;
  double get totalEstimado => _articulos.fold(0, (s, a) => s + a.subtotal);
  double get totalPendiente => _articulos.where((a) => !a.comprado).fold(0, (s, a) => s + a.subtotal);

  /// Artículos visibles según el filtro, agrupados por categoría en el orden del enum.
  Map<Categoria, List<Articulo>> get porCategoria {
    final visibles = _articulos.where(
      (a) => switch (_filtro) {
        Filtro.todos => true,
        Filtro.pendientes => !a.comprado,
        Filtro.comprados => a.comprado,
      },
    );
    final grupos = <Categoria, List<Articulo>>{};
    for (final categoria in Categoria.values) {
      final lista = visibles.where((a) => a.categoria == categoria).toList()
        ..sort(
          (a, b) => a.comprado == b.comprado
              ? a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase())
              : (a.comprado ? 1 : -1),
        );
      if (lista.isNotEmpty) grupos[categoria] = lista;
    }
    return grupos;
  }

  Future<void> cargar() async {
    _articulos = await _repositorio.cargar();
    _cargando = false;
    notifyListeners();
  }

  String _nuevoId() => List.generate(12, (_) => _azar.nextInt(36).toRadixString(36)).join();

  /// Agrega un artículo. Si ya hay uno pendiente con el mismo nombre, suma la cantidad.
  Articulo agregar({
    required String nombre,
    required Categoria categoria,
    int cantidad = 1,
    double precioUnitario = 0,
  }) {
    final limpio = nombre.trim();
    if (limpio.isEmpty) throw ArgumentError.value(nombre, 'nombre', 'no puede estar vacío');
    if (cantidad < 1) throw ArgumentError.value(cantidad, 'cantidad', 'debe ser al menos 1');
    final i = _articulos.indexWhere((a) => !a.comprado && a.nombre.toLowerCase() == limpio.toLowerCase());
    final Articulo resultado;
    if (i >= 0) {
      resultado = _articulos[i].copiarCon(
        cantidad: _articulos[i].cantidad + cantidad,
        precioUnitario: precioUnitario > 0 ? precioUnitario : null,
      );
      _articulos[i] = resultado;
    } else {
      resultado = Articulo(
        id: _nuevoId(),
        nombre: limpio,
        categoria: categoria,
        cantidad: cantidad,
        precioUnitario: precioUnitario,
      );
      _articulos.add(resultado);
    }
    _cambio();
    return resultado;
  }

  void alternarComprado(String id) => _actualizar(id, (a) => a.copiarCon(comprado: !a.comprado));

  void cambiarCantidad(String id, int delta) =>
      _actualizar(id, (a) => a.copiarCon(cantidad: max(1, a.cantidad + delta)));

  /// Quita el artículo y devuelve una función para deshacer la operación.
  VoidCallback quitar(String id) {
    final i = _articulos.indexWhere((a) => a.id == id);
    if (i < 0) return () {};
    final quitado = _articulos.removeAt(i);
    _cambio();
    return () {
      _articulos.insert(min(i, _articulos.length), quitado);
      _cambio();
    };
  }

  int limpiarComprados() {
    final antes = _articulos.length;
    _articulos.removeWhere((a) => a.comprado);
    final quitados = antes - _articulos.length;
    if (quitados > 0) _cambio();
    return quitados;
  }

  set filtro(Filtro valor) {
    if (valor == _filtro) return;
    _filtro = valor;
    notifyListeners();
  }

  void _actualizar(String id, Articulo Function(Articulo) cambio) {
    final i = _articulos.indexWhere((a) => a.id == id);
    if (i < 0) return;
    _articulos[i] = cambio(_articulos[i]);
    _cambio();
  }

  void _cambio() {
    notifyListeners();
    _repositorio.guardar(_articulos);
  }
}
