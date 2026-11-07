// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/modelo/articulo.dart';
import 'package:lista_compras/modelo/sugerencias.dart';

void main() {
  group('sugerirCategoria', () {
    test('reconoce productos comunes sin importar tildes ni mayúsculas', () {
      expect(sugerirCategoria('Yerba Canarias'), Categoria.almacen);
      expect(sugerirCategoria('LECHE descremada'), Categoria.frescos);
      expect(sugerirCategoria('Jabón en polvo'), Categoria.limpieza);
      expect(sugerirCategoria('agua con gas'), Categoria.bebidas);
      expect(sugerirCategoria('pilas AA'), Categoria.otros);
      expect(sugerirCategoria('   '), Categoria.otros);
    });

    test('prefiere la coincidencia más larga', () {
      // "dulce de leche" contiene "leche", pero es de almacén.
      expect(sugerirCategoria('Dulce de leche repostero'), Categoria.almacen);
    });
  });

  test('formatearPesos usa punto como separador de miles', () {
    expect(formatearPesos(0), r'$ 0');
    expect(formatearPesos(950), r'$ 950');
    expect(formatearPesos(1234.6), r'$ 1.235');
    expect(formatearPesos(1250000), r'$ 1.250.000');
    expect(formatearPesos(-3500), r'-$ 3.500');
  });

  test('Articulo se serializa y deserializa sin pérdida', () {
    const original = Articulo(
      id: 'a1',
      nombre: 'Queso',
      categoria: Categoria.frescos,
      cantidad: 2,
      precioUnitario: 389.9,
      comprado: true,
    );
    final copia = Articulo.desdeJson(original.aJson());
    expect(copia.aJson(), original.aJson());
    expect(copia.subtotal, closeTo(779.8, 0.001));
    // Una categoría desconocida (datos viejos) no rompe la carga.
    expect(Articulo.desdeJson({'id': 'x', 'nombre': 'X', 'categoria': 'ferreteria'}).categoria, Categoria.otros);
  });
}
