// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../modelo/articulo.dart';
import '../modelo/sugerencias.dart';

typedef DatosArticulo = ({String nombre, Categoria categoria, int cantidad, double precio});

/// Formulario para agregar un artículo. Sugiere la categoría mientras se escribe el nombre,
/// salvo que el usuario la haya elegido a mano.
class HojaAgregar extends StatefulWidget {
  const HojaAgregar({super.key});

  @override
  State<HojaAgregar> createState() => _HojaAgregarState();
}

class _HojaAgregarState extends State<HojaAgregar> {
  final _formulario = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _cantidad = TextEditingController(text: '1');
  final _precio = TextEditingController();
  Categoria _categoria = Categoria.otros;
  bool _categoriaElegida = false;

  @override
  void dispose() {
    _nombre.dispose();
    _cantidad.dispose();
    _precio.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!_formulario.currentState!.validate()) return;
    Navigator.of(context).pop<DatosArticulo>((
      nombre: _nombre.text.trim(),
      categoria: _categoria,
      cantidad: int.parse(_cantidad.text),
      precio: double.tryParse(_precio.text.replaceAll(',', '.')) ?? 0,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.viewInsetsOf(context).bottom + 16),
      child: Form(
        key: _formulario,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Agregar artículo', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombre,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Artículo', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Escribí qué hay que comprar' : null,
              onChanged: (v) {
                if (!_categoriaElegida) setState(() => _categoria = sugerirCategoria(v));
              },
              onFieldSubmitted: (_) => _guardar(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cantidad,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'Cantidad', border: OutlineInputBorder()),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return n == null || n < 1 || n > 999 ? 'Entre 1 y 999' : null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Precio unitario',
                      prefixText: '\$ ',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return null;
                      final n = double.tryParse(v.replaceAll(',', '.'));
                      return n == null || n < 0 ? 'Precio no válido' : null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Categoria>(
              initialValue: _categoria,
              key: ValueKey(_categoria),
              decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
              items: [for (final c in Categoria.values) DropdownMenuItem(value: c, child: Text(c.etiqueta))],
              onChanged: (c) => setState(() {
                _categoria = c ?? Categoria.otros;
                _categoriaElegida = true;
              }),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: _guardar, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
