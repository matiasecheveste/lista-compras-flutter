// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/datos/repositorio.dart';
import 'package:lista_compras/estado/lista_compras.dart';
import 'package:lista_compras/main.dart';
import 'package:lista_compras/modelo/articulo.dart';

Future<ListaCompras> montar(WidgetTester tester, [List<Articulo> iniciales = const []]) async {
  final lista = ListaCompras(RepositorioMemoria(iniciales));
  await lista.cargar();
  await tester.pumpWidget(AppListaCompras(lista: lista));
  await tester.pumpAndSettle();
  return lista;
}

void main() {
  testWidgets('muestra el mensaje de lista vacía', (tester) async {
    await montar(tester);
    expect(find.textContaining('No hay artículos'), findsOneWidget);
    expect(find.text('0 de 0 comprados'), findsOneWidget);
  });

  testWidgets('agrega un artículo con categoría sugerida y precio', (tester) async {
    final lista = await montar(tester);

    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Artículo'), 'Yerba');
    await tester.enterText(find.widgetWithText(TextFormField, 'Cantidad'), '2');
    await tester.enterText(find.widgetWithText(TextFormField, 'Precio unitario'), '215,50');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(DropdownButtonFormField<Categoria>, 'Almacén'), findsOneWidget);

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(lista.articulos.single.categoria, Categoria.almacen);
    expect(find.text('Yerba'), findsOneWidget);
    expect(find.text(r'2 × $ 216 = $ 431'), findsOneWidget);
    expect(find.textContaining(r'Total estimado: $ 431'), findsOneWidget);
  });

  testWidgets('valida el formulario', (tester) async {
    await montar(tester);
    await tester.tap(find.text('Agregar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Cantidad'), '0');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Escribí qué hay que comprar'), findsOneWidget);
    expect(find.text('Entre 1 y 999'), findsOneWidget);
  });

  testWidgets('marca como comprado, filtra y deshace un borrado', (tester) async {
    final lista = await montar(tester, const [
      Articulo(id: 'a', nombre: 'Arroz', categoria: Categoria.almacen),
      Articulo(id: 'b', nombre: 'Agua', categoria: Categoria.bebidas),
    ]);

    await tester.tap(find.text('Arroz'));
    await tester.pumpAndSettle();
    expect(find.text('1 de 2 comprados'), findsOneWidget);

    await tester.tap(find.text('Pendientes'));
    await tester.pumpAndSettle();
    expect(find.text('Arroz'), findsNothing);
    expect(find.text('Agua'), findsOneWidget);

    await tester.drag(find.text('Agua'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(lista.total, 1);
    expect(find.text('Se quitó «Agua»'), findsOneWidget);

    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(lista.total, 2);
    expect(find.text('Agua'), findsOneWidget);
  });

  testWidgets('cambia cantidades con los botones', (tester) async {
    final lista = await montar(tester, const [Articulo(id: 'h', nombre: 'Huevos', categoria: Categoria.frescos)]);
    await tester.tap(find.byTooltip('Uno más de Huevos'));
    await tester.tap(find.byTooltip('Uno más de Huevos'));
    await tester.pump();
    expect(lista.articulos.single.cantidad, 3);
    await tester.tap(find.byTooltip('Uno menos de Huevos'));
    await tester.pump();
    expect(lista.articulos.single.cantidad, 2);
  });
}
