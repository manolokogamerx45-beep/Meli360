import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('[Firebase] Inicializado correctamente en Cliente');
  } catch (e) {
    print('[Firebase Warning] No se pudo inicializar Firebase. Se usará el servidor local de respaldo: $e');
  }

  // Inicialización de la aplicación móvil de Mercado Libre envuelta en ProviderScope
  runApp(
    const ProviderScope(
      child: MercadoLibreApp(),
    ),
  );
}

