import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../categories/presentation/screens/categorias_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../videos/presentation/screens/videos_screen.dart';
import '../../../profile/presentation/screens/mas_screen.dart';

/// La pantalla de navegación principal (Shell) que maneja las 5 pestañas
/// inferiores de Mercado Libre y el estado del badge del carrito.
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _indiceTabActivo = 0;

  final List<Widget> _pantallas = const [
    HomeScreen(),
    CategoriasScreen(),
    CarritoScreen(),
    VideosScreen(),
    MasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Escuchamos la cantidad total de artículos en el carrito
    final cartItems = ref.watch(cartNotifierProvider);
    final totalCartQty = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      body: IndexedStack(
        index: _indiceTabActivo,
        children: _pantallas,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.azulLink, // Azul para la pestaña activa
        unselectedItemColor: AppColors.textoSecundario,
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        currentIndex: _indiceTabActivo,
        onTap: (indice) {
          setState(() {
            _indiceTabActivo = indice;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home, color: AppColors.azulLink),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Categorías',
          ),
          // Item Carrito con Badge numérico dinámico basado en Riverpod
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (totalCartQty > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3483FA), // Azul de notificación en el carrito
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 13,
                        minHeight: 13,
                      ),
                      child: Text(
                        '$totalCartQty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            label: 'Videos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}
