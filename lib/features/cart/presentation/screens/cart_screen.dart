import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image.dart';
import '../providers/cart_provider.dart';
import '../../../orders/presentation/providers/orders_provider.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartNotifierProvider);
    final notifier = ref.read(cartNotifierProvider.notifier);

    final formatMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    double total = cartItems.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
    double originalTotal = cartItems.fold(0.0, (sum, item) => sum + ((item.product.originalPrice ?? item.product.price) * item.quantity));
    double ahorroTotal = originalTotal - total;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        title: const Text(
          'Carrito',
          style: TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                // Banner de Envío Gratis si aplica
                Container(
                  color: const Color(0xFFE8F8F0),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Row(
                    children: [
                      Icon(Icons.bolt, color: AppColors.verdeExito, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '¡Tienes envío gratis FULL en tu compra!',
                          style: TextStyle(
                            color: AppColors.verdeExito,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      final prod = item.product;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Mini Thumbnail
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: ProductImage(
                                      imageUrl: prod.secureThumbnail,
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Detalles de Producto
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textoPrincipal,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (prod.shipping.freeShipping)
                                          const Text(
                                            'Envío gratis FULL',
                                            style: TextStyle(
                                              color: AppColors.verdeExito,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Text(
                                              formatMoneda.format(prod.price),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textoPrincipal,
                                              ),
                                            ),
                                            if (prod.originalPrice != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                formatMoneda.format(prod.originalPrice),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.grisDetalle,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ]
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20, color: Color(0xFFEEEEEE)),
                              // Controles de cantidad
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () => notifier.removerProducto(prod.id),
                                    style: TextButton.styleFrom(
                                      foregroundColor: AppColors.azulLink,
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: const Text('Eliminar', style: TextStyle(fontSize: 12)),
                                  ),
                                  const Spacer(),
                                  // Botón menos
                                  GestureDetector(
                                    onTap: () => notifier.actualizarCantidad(prod.id, item.quantity - 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[350]!),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          bottomLeft: Radius.circular(4),
                                        ),
                                      ),
                                      child: const Icon(Icons.remove, size: 14, color: AppColors.textoPrincipal),
                                    ),
                                  ),
                                  // Cantidad
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(color: Colors.grey[350]!),
                                        bottom: BorderSide(color: Colors.grey[350]!),
                                      ),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  // Botón más
                                  GestureDetector(
                                    onTap: () => notifier.actualizarCantidad(prod.id, item.quantity + 1),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[350]!),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          bottomRight: Radius.circular(4),
                                        ),
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: AppColors.textoPrincipal),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Panel de Resumen de Compra
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ahorroTotal > 0) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Ahorras', style: TextStyle(color: AppColors.verdeExito, fontSize: 13)),
                              Text(formatMoneda.format(ahorroTotal), style: const TextStyle(color: AppColors.verdeExito, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total con envío gratis',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textoPrincipal),
                            ),
                            Text(
                              formatMoneda.format(total),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textoPrincipal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push(
                                '/checkout',
                                extra: {
                                  'items': cartItems,
                                  'total': total,
                                  'clearCartOnSuccess': true,
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.azulLink,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Continuar compra', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Tu carrito está vacío',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Explora miles de productos en Mercado Libre y agrega tus favoritos!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Ir a la pestaña Home (Inicio)
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulLink,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Buscar productos', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
