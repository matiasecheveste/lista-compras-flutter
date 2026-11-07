// Lista de compras — Matías Nicolás Echeveste Cardozo
import 'package:flutter/material.dart';

import 'datos/repositorio.dart';
import 'estado/lista_compras.dart';
import 'pantallas/pantalla_lista.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final lista = ListaCompras(RepositorioPreferencias())..cargar();
  runApp(AppListaCompras(lista: lista));
}

class AppListaCompras extends StatelessWidget {
  const AppListaCompras({super.key, required this.lista});

  final ListaCompras lista;

  @override
  Widget build(BuildContext context) {
    const semilla = Color(0xFF0F766E);
    return MaterialApp(
      title: 'Lista de compras',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: semilla, useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: semilla, brightness: Brightness.dark, useMaterial3: true),
      home: PantallaLista(lista: lista),
    );
  }
}
