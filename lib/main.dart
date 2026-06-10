import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  // Inicialización de la aplicación móvil de Mercado Libre envuelta en ProviderScope
  runApp(
    const ProviderScope(
      child: MercadoLibreApp(),
    ),
  );
}
