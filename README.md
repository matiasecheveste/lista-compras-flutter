# Lista de compras — Flutter

Aplicación de lista de compras hecha con **Flutter 3.41 y Dart 3.11**, para Android, iOS y web. Agrupa los artículos por categoría, sugiere la categoría mientras se escribe y calcula el total estimado en pesos uruguayos. Los datos se guardan en el dispositivo.

**Demo web:** se publica en GitHub Pages desde la CI.

## Funcionalidades

- Agregar artículos con cantidad y precio unitario. Si un artículo pendiente se repite, se suman las cantidades en lugar de duplicarlo.
- **Sugerencia automática de categoría**:
  - "Leche" va a Frescos y "Jabón en polvo" a Limpieza.
  - No distingue tildes ni mayúsculas.
  - Gana la coincidencia más larga: "Dulce de leche" va a Almacén, no a Frescos.
- Marcar como comprado, filtrar (todos / pendientes / comprados) y ver el progreso de la compra.
- Deslizar para quitar, con **Deshacer** que restaura el artículo en su posición original.
- Total estimado y monto que falta, con formato `$ 1.234`.
- Tema claro y oscuro (Material 3).

## Arquitectura

```
lib/
  modelo/      Articulo (inmutable, con serialización JSON), categorías, sugerencias, formato de moneda
  datos/       interfaz Repositorio: shared_preferences en la app, memoria en las pruebas
  estado/      ListaCompras (ChangeNotifier): reglas, filtros, agrupación y persistencia
  pantallas/   interfaz con ListenableBuilder, formulario validado en una hoja inferior
```

El estado no depende de ningún paquete externo: `ChangeNotifier` + `ListenableBuilder` del propio Flutter. La persistencia es una interfaz, así que las pruebas usan un repositorio en memoria y verifican cuántas veces se guardó. Si los datos guardados están dañados, la aplicación empieza con la lista vacía en lugar de cerrarse.

## Pruebas

**17 pruebas**:

- **Unitarias**: modelo y serialización, sugerencias, formato de moneda, reglas de la lista (suma de repetidos, validaciones, deshacer, agrupación y orden, filtros) y persistencia con `SharedPreferences` simulado.
- **De widgets**: lista vacía, alta completa con categoría sugerida y precio con coma decimal, validación del formulario, marcar, filtrar, deslizar para quitar, deshacer y botones de cantidad.

```bash
flutter pub get
flutter test
flutter run -d chrome
```

## Integración continua

GitHub Actions ejecuta:

1. `dart format`, `flutter analyze` (con `strict-casts` y `strict-raw-types`) y las pruebas.
2. Compila la versión web y la **publica en GitHub Pages**.
3. Compila un **APK de Android** de *release* y lo guarda como artefacto.

## Autor

Matías Nicolás Echeveste Cardozo — licencia MIT.
