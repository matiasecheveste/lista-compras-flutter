// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'articulo.dart';

const _palabras = <Categoria, List<String>>{
  Categoria.almacen: [
    'yerba',
    'arroz',
    'fideo',
    'harina',
    'azucar',
    'aceite',
    'sal',
    'cafe',
    'galleta',
    'dulce de leche',
    'polenta',
    'lenteja',
    'atun',
  ],
  Categoria.frescos: [
    'leche',
    'queso',
    'manteca',
    'yogur',
    'huevo',
    'carne',
    'pollo',
    'pan',
    'tomate',
    'papa',
    'cebolla',
    'manzana',
    'banana',
    'lechuga',
    'zapallo',
  ],
  Categoria.bebidas: ['agua', 'refresco', 'jugo', 'cerveza', 'vino', 'soda'],
  Categoria.limpieza: ['detergente', 'jabon', 'lavandina', 'esponja', 'papel higienico', 'suavizante', 'desodorante'],
};

String _normalizar(String texto) {
  const tildes = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};
  return texto.toLowerCase().trim().split('').map((c) => tildes[c] ?? c).join();
}

/// Sugiere la categoría a partir del nombre: "Dulce de leche" va a Almacén (no a Frescos)
/// porque se prefiere la coincidencia más larga.
Categoria sugerirCategoria(String nombre) {
  final texto = _normalizar(nombre);
  if (texto.isEmpty) return Categoria.otros;
  Categoria? mejor;
  var largo = 0;
  for (final MapEntry(key: categoria, value: palabras) in _palabras.entries) {
    for (final palabra in palabras) {
      if (texto.contains(palabra) && palabra.length > largo) {
        mejor = categoria;
        largo = palabra.length;
      }
    }
  }
  return mejor ?? Categoria.otros;
}

/// Formato de pesos uruguayos sin decimales: $ 1.234
String formatearPesos(double monto) {
  final entero = monto.round().abs().toString();
  final grupos = <String>[];
  for (var fin = entero.length; fin > 0; fin -= 3) {
    grupos.insert(0, entero.substring(fin - 3 < 0 ? 0 : fin - 3, fin));
  }
  return '${monto < 0 ? '-' : ''}\$ ${grupos.join('.')}';
}
