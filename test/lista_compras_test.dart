// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/datos/repositorio.dart';
import 'package:lista_compras/estado/lista_compras.dart';
import 'package:lista_compras/modelo/articulo.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late RepositorioMemoria repositorio;
  late ListaCompras lista;

  setUp(() async {
    repositorio = RepositorioMemoria();
    lista = ListaCompras(repositorio);
    await lista.cargar();
  });

  test('agrega artículos, calcula totales y persiste cada cambio', () {
    lista.agregar(nombre: 'Yerba', categoria: Categoria.almacen, cantidad: 2, precioUnitario: 210);
    final leche = lista.agregar(nombre: 'Leche', categoria: Categoria.frescos, cantidad: 3, precioUnitario: 42);
    lista.alternarComprado(leche.id);

    expect(lista.total, 2);
    expect(lista.comprados, 1);
    expect(lista.progreso, 0.5);
    expect(lista.totalEstimado, 546);
    expect(lista.totalPendiente, 420);
    expect(repositorio.guardados, 3);
  });

  test('un artículo pendiente repetido suma cantidades en lugar de duplicarse', () {
    lista.agregar(nombre: 'Pan', categoria: Categoria.frescos);
    lista.agregar(nombre: '  pan ', categoria: Categoria.frescos, cantidad: 2);
    expect(lista.total, 1);
    expect(lista.articulos.single.cantidad, 3);
  });

  test('rechaza nombres vacíos y cantidades no positivas', () {
    expect(() => lista.agregar(nombre: '  ', categoria: Categoria.otros), throwsArgumentError);
    expect(() => lista.agregar(nombre: 'Sal', categoria: Categoria.almacen, cantidad: 0), throwsArgumentError);
  });

  test('quitar devuelve una función que deshace en la misma posición', () {
    lista.agregar(nombre: 'A', categoria: Categoria.otros);
    final b = lista.agregar(nombre: 'B', categoria: Categoria.otros);
    lista.agregar(nombre: 'C', categoria: Categoria.otros);

    final deshacer = lista.quitar(b.id);
    expect(lista.articulos.map((a) => a.nombre), ['A', 'C']);
    deshacer();
    expect(lista.articulos.map((a) => a.nombre), ['A', 'B', 'C']);
  });

  test('agrupa por categoría, filtra y deja los comprados al final', () {
    final arroz = lista.agregar(nombre: 'Arroz', categoria: Categoria.almacen);
    lista.agregar(nombre: 'Aceite', categoria: Categoria.almacen);
    lista.agregar(nombre: 'Detergente', categoria: Categoria.limpieza);
    lista.alternarComprado(arroz.id);

    expect(lista.porCategoria.keys, [Categoria.almacen, Categoria.limpieza]);
    expect(lista.porCategoria[Categoria.almacen]!.map((a) => a.nombre), ['Aceite', 'Arroz']);

    lista.filtro = Filtro.comprados;
    expect(lista.porCategoria.keys, [Categoria.almacen]);
    lista.filtro = Filtro.pendientes;
    expect(lista.porCategoria.values.expand((l) => l).map((a) => a.nombre), ['Aceite', 'Detergente']);

    expect(lista.limpiarComprados(), 1);
    expect(lista.total, 2);
  });

  test('la cantidad nunca baja de 1', () {
    final a = lista.agregar(nombre: 'Huevos', categoria: Categoria.frescos);
    lista.cambiarCantidad(a.id, -5);
    expect(lista.articulos.single.cantidad, 1);
    lista.cambiarCantidad(a.id, 11);
    expect(lista.articulos.single.cantidad, 12);
  });

  group('RepositorioPreferencias', () {
    test('guarda y vuelve a cargar la lista', () async {
      SharedPreferences.setMockInitialValues({});
      final repo = RepositorioPreferencias();
      await repo.guardar([
        const Articulo(id: '1', nombre: 'Café', categoria: Categoria.almacen, cantidad: 2, precioUnitario: 320),
      ]);
      final cargados = await repo.cargar();
      expect(cargados.single.nombre, 'Café');
      expect(cargados.single.subtotal, 640);
    });

    test('si los datos guardados están dañados empieza con la lista vacía', () async {
      SharedPreferences.setMockInitialValues({RepositorioPreferencias.clave: '{no es json'});
      expect(await RepositorioPreferencias().cargar(), isEmpty);
    });
  });
}
