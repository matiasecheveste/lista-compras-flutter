// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter/material.dart';

import '../estado/lista_compras.dart';
import '../modelo/articulo.dart';
import '../modelo/sugerencias.dart';
import 'hoja_agregar.dart';

const iconosCategoria = <Categoria, IconData>{
  Categoria.almacen: Icons.kitchen_outlined,
  Categoria.frescos: Icons.egg_outlined,
  Categoria.bebidas: Icons.local_drink_outlined,
  Categoria.limpieza: Icons.cleaning_services_outlined,
  Categoria.otros: Icons.category_outlined,
};

class PantallaLista extends StatelessWidget {
  const PantallaLista({super.key, required this.lista});

  final ListaCompras lista;

  Future<void> _agregar(BuildContext context) async {
    final datos = await showModalBottomSheet<DatosArticulo>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const HojaAgregar(),
    );
    if (datos == null) return;
    lista.agregar(
      nombre: datos.nombre,
      categoria: datos.categoria,
      cantidad: datos.cantidad,
      precioUnitario: datos.precio,
    );
  }

  void _quitar(BuildContext context, Articulo articulo) {
    final deshacer = lista.quitar(articulo.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Se quitó «${articulo.nombre}»'),
          action: SnackBarAction(label: 'Deshacer', onPressed: deshacer),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: lista,
      builder: (context, _) {
        final grupos = lista.porCategoria;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Lista de compras'),
            actions: [
              if (lista.comprados > 0)
                IconButton(
                  tooltip: 'Quitar los comprados',
                  icon: const Icon(Icons.playlist_remove),
                  onPressed: () {
                    final n = lista.limpiarComprados();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(n == 1 ? 'Se quitó 1 artículo comprado' : 'Se quitaron $n artículos comprados'),
                      ),
                    );
                  },
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _agregar(context),
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          ),
          body: lista.cargando
              ? const Center(child: CircularProgressIndicator())
              // En pantallas anchas (web, tabletas) la lista no se estira más de 720 px.
              : Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      children: [
                        _Resumen(lista: lista),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SegmentedButton<Filtro>(
                            segments: const [
                              ButtonSegment(value: Filtro.todos, label: Text('Todos')),
                              ButtonSegment(value: Filtro.pendientes, label: Text('Pendientes')),
                              ButtonSegment(value: Filtro.comprados, label: Text('Comprados')),
                            ],
                            selected: {lista.filtro},
                            onSelectionChanged: (s) => lista.filtro = s.first,
                          ),
                        ),
                        Expanded(
                          child: grupos.isEmpty
                              ? const _Vacia()
                              : ListView(
                                  padding: const EdgeInsets.only(bottom: 96),
                                  children: [
                                    for (final MapEntry(key: categoria, value: articulos) in grupos.entries) ...[
                                      ListTile(
                                        dense: true,
                                        leading: Icon(iconosCategoria[categoria]),
                                        title: Text(categoria.etiqueta, style: Theme.of(context).textTheme.titleSmall),
                                      ),
                                      for (final a in articulos)
                                        _FilaArticulo(
                                          key: ValueKey(a.id),
                                          articulo: a,
                                          lista: lista,
                                          alQuitar: () => _quitar(context, a),
                                        ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({required this.lista});

  final ListaCompras lista;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${lista.comprados} de ${lista.total} comprados', style: texto.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: lista.progreso, semanticsLabel: 'Progreso de la compra'),
            const SizedBox(height: 8),
            Text(
              'Total estimado: ${formatearPesos(lista.totalEstimado)} · Falta: ${formatearPesos(lista.totalPendiente)}',
              style: texto.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaArticulo extends StatelessWidget {
  const _FilaArticulo({super.key, required this.articulo, required this.lista, required this.alQuitar});

  final Articulo articulo;
  final ListaCompras lista;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final a = articulo;
    return Dismissible(
      key: ValueKey('deslizar-${a.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => alQuitar(),
      child: CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        value: a.comprado,
        onChanged: (_) => lista.alternarComprado(a.id),
        title: Text(a.nombre, style: a.comprado ? const TextStyle(decoration: TextDecoration.lineThrough) : null),
        subtitle: a.precioUnitario > 0
            ? Text('${a.cantidad} × ${formatearPesos(a.precioUnitario)} = ${formatearPesos(a.subtotal)}')
            : null,
        secondary: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Uno menos de ${a.nombre}',
              onPressed: a.cantidad > 1 ? () => lista.cambiarCantidad(a.id, -1) : null,
              icon: const Icon(Icons.remove),
            ),
            Text('${a.cantidad}', semanticsLabel: 'Cantidad ${a.cantidad}'),
            IconButton(
              tooltip: 'Uno más de ${a.nombre}',
              onPressed: () => lista.cambiarCantidad(a.id, 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class _Vacia extends StatelessWidget {
  const _Vacia();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Text('No hay artículos. Tocá «Agregar» para empezar la lista.', textAlign: TextAlign.center),
    ),
  );
}
