import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Clase principal de la Aplicación que configura MaterialApp y el tema con soporte de rutas.
class MercadoLibreApp extends StatelessWidget {
  const MercadoLibreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mercado Libre Clone',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
