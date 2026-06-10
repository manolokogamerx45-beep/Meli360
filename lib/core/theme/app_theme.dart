import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clase contenedora de colores oficiales de la réplica de Mercado Libre.
class AppColors {
  static const Color amarilloML = Color(0xFFFFE600);
  static const Color verdeExito = Color(0xFF00A650);
  static const Color fondoGeneral = Color(0xFFEBEBEB);
  static const Color textoPrincipal = Color(0xFF333333);
  static const Color textoSecundario = Color(0xFF666666);
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisDetalle = Color(0xFF999999);
  static const Color azulLink = Color(0xFF3483FA);
}

/// Clase encargada de proveer la configuración de `ThemeData` para la app.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.amarilloML,
      scaffoldBackgroundColor: AppColors.fondoGeneral,
      
      // Configuración de la AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textoPrincipal),
      ),

      // Configuración de Tipografía
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textoPrincipal,
          fontSize: 15,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textoSecundario,
          fontSize: 13,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppColors.verdeExito,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Configuración de Tarjetas (Cards)
      cardTheme: CardThemeData(
        color: AppColors.blanco,
        elevation: 0.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),

      // Configuración de los Campos de Texto (Buscador)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blanco,
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        hintStyle: const TextStyle(color: AppColors.grisDetalle, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide.none,
        ),
      ),

      // Configuración de Botones
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azulLink,
          foregroundColor: AppColors.blanco,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.amarilloML,
        primary: AppColors.amarilloML,
        secondary: AppColors.azulLink,
        background: AppColors.fondoGeneral,
        surface: AppColors.blanco,
      ),
    );
  }
}
