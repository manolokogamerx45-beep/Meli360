import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../categories/presentation/screens/categorias_screen.dart';
import '../../../cart/presentation/screens/cart_screen.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../videos/presentation/screens/videos_screen.dart';
import '../../../profile/presentation/screens/mas_screen.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

/// La pantalla de navegación principal (Shell) que maneja las 5 pestañas
/// inferiores de Mercado Libre y el estado del badge del carrito.
class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _indiceTabActivo = 0;

  // Lógica de notificaciones flotantes en tiempo real
  final Map<String, String> _orderStatuses = {};
  bool _firstLoadDone = false;
  OverlayEntry? _notificationOverlay;
  Timer? _notificationTimer;

  final List<Widget> _pantallas = const [
    HomeScreen(),
    CategoriasScreen(),
    CarritoScreen(),
    VideosScreen(),
    MasScreen(),
  ];

  @override
  void dispose() {
    _notificationOverlay?.remove();
    _notificationTimer?.cancel();
    super.dispose();
  }

  void _mostrarNotificacionFlotante(OrderModel order) {
    _notificationOverlay?.remove();
    _notificationOverlay = null;
    _notificationTimer?.cancel();

    String title = "Mercado Envíos";
    String body = "Tu paquete ${order.id} cambió a: ${order.status}";
    IconData icon = Icons.local_shipping;
    Color color = const Color(0xFF3483FA); // Azul de ML

    if (order.status.contains('Aceptado')) {
      title = "¡Tu pedido fue aceptado!";
      body = "El repartidor ${order.repartidor ?? ''} está preparando tu entrega.";
      icon = Icons.assignment_turned_in;
    } else if (order.status.contains('camino')) {
      title = "¡Paquete en camino!";
      body = "El repartidor va rumbo a tu domicilio.";
      icon = Icons.directions_bike;
    } else if (order.status.contains('Entregado')) {
      title = "¡Entregado!";
      body = "Tu paquete ${order.id} fue entregado con éxito.";
      icon = Icons.check_circle;
      color = const Color(0xFF00A650); // Verde ML
    }

    _notificationOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -80.0, end: 0.0),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value),
                child: child,
              );
            },
            child: GestureDetector(
              onTap: () {
                _notificationOverlay?.remove();
                _notificationOverlay = null;
                _notificationTimer?.cancel();
                context.push('/mis-compras');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: color.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF2C2500),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            body,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Navigator.of(context).overlay;
    if (overlay != null) {
      overlay.insert(_notificationOverlay!);
      _notificationTimer = Timer(const Duration(seconds: 5), () {
        _notificationOverlay?.remove();
        _notificationOverlay = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios en el listado de compras
    ref.listen<List<OrderModel>>(ordersNotifierProvider, (previous, next) {
      if (!_firstLoadDone) {
        for (var o in next) {
          _orderStatuses[o.id] = o.status;
        }
        _firstLoadDone = true;
        return;
      }

      for (var order in next) {
        final previousStatus = _orderStatuses[order.id];
        if (previousStatus != null && previousStatus != order.status) {
          _mostrarNotificacionFlotante(order);
          _orderStatuses[order.id] = order.status;
        } else if (previousStatus == null) {
          _orderStatuses[order.id] = order.status;
        }
      }
    });
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
