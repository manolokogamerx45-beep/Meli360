import 'package:go_router/go_router.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/product_detail/presentation/screens/product_detail_screen.dart';
import '../../features/navigation/presentation/screens/main_navigation_screen.dart';
import '../../features/notifications/presentation/screens/notificaciones_screen.dart';
import '../../features/categories/presentation/screens/category_products_screen.dart';
import '../../features/orders/presentation/screens/mis_compras_screen.dart';
import '../../features/cart/presentation/screens/checkout_screen.dart';
import '../../features/cart/presentation/providers/cart_provider.dart';

/// Enrutador global de la aplicación que administra las rutas de navegación.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/detalle',
      builder: (context, state) {
        // Obtenemos el producto pasado como argumento extra
        final producto = state.extra as Product;
        return ProductDetailScreen(producto: producto);
      },
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => const NotificacionesScreen(),
    ),
    GoRoute(
      path: '/categoria/:id',
      builder: (context, state) {
        final categoryId = state.pathParameters['id']!;
        final categoryName = state.uri.queryParameters['name'] ?? categoryId;
        return CategoryProductsScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),
    GoRoute(
      path: '/mis-compras',
      builder: (context, state) => const MisComprasScreen(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        final items = params['items'] as List<CartItem>;
        final total = params['total'] as double;
        final clearCartOnSuccess = params['clearCartOnSuccess'] as bool;
        
        return CheckoutScreen(
          items: items,
          total: total,
          clearCartOnSuccess: clearCartOnSuccess,
        );
      },
    ),
  ],
);
