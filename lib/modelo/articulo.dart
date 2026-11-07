// Lista de compras — Matías Nicolás Echeveste Cardozo

enum Categoria {
  almacen('Almacén'),
  frescos('Frescos'),
  bebidas('Bebidas'),
  limpieza('Limpieza'),
  otros('Otros');

  const Categoria(this.etiqueta);
  final String etiqueta;

  static Categoria desdeNombre(String nombre) =>
      Categoria.values.firstWhere((c) => c.name == nombre, orElse: () => Categoria.otros);
}

/// Artículo inmutable: los cambios se hacen con [copiarCon].
class Articulo {
  const Articulo({
    required this.id,
    required this.nombre,
    required this.categoria,
    this.cantidad = 1,
    this.precioUnitario = 0,
    this.comprado = false,
  });

  final String id;
  final String nombre;
  final Categoria categoria;
  final int cantidad;

  /// Precio estimado en pesos uruguayos.
  final double precioUnitario;
  final bool comprado;

  double get subtotal => cantidad * precioUnitario;

  Articulo copiarCon({String? nombre, Categoria? categoria, int? cantidad, double? precioUnitario, bool? comprado}) =>
      Articulo(
        id: id,
        nombre: nombre ?? this.nombre,
        categoria: categoria ?? this.categoria,
        cantidad: cantidad ?? this.cantidad,
        precioUnitario: precioUnitario ?? this.precioUnitario,
        comprado: comprado ?? this.comprado,
      );

  Map<String, Object> aJson() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria.name,
    'cantidad': cantidad,
    'precioUnitario': precioUnitario,
    'comprado': comprado,
  };

  factory Articulo.desdeJson(Map<String, dynamic> json) => Articulo(
    id: json['id'] as String,
    nombre: json['nombre'] as String,
    categoria: Categoria.desdeNombre(json['categoria'] as String? ?? ''),
    cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
    precioUnitario: (json['precioUnitario'] as num?)?.toDouble() ?? 0,
    comprado: json['comprado'] as bool? ?? false,
  );
}
