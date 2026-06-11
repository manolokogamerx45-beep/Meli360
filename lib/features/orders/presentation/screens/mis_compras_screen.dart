import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image.dart';
import '../providers/orders_provider.dart';

class MisComprasScreen extends ConsumerWidget {
  const MisComprasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersNotifierProvider);

    final formatMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoPrincipal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mis compras',
          style: TextStyle(
            color: AppColors.textoPrincipal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: orders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              itemCount: orders.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final order = orders[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cabecera: ID y Fecha
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              order.id,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: AppColors.textoPrincipal,
                              ),
                            ),
                            Text(
                              order.fecha,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textoSecundario,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, color: Color(0xFFEEEEEE)),

                        // Estatus de Envío
                        Row(
                          children: [
                            const Icon(Icons.local_shipping_outlined, color: AppColors.verdeExito, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              order.status,
                              style: const TextStyle(
                                color: AppColors.verdeExito,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            if (order.repartidor != null) ...[
                              const Spacer(),
                              Text(
                                'Repartidor: ${order.repartidor}',
                                style: const TextStyle(
                                  color: AppColors.textoSecundario,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Barra de progreso de envío simulada
                        _buildProgressBar(order.status),

                        const SizedBox(height: 16),

                        // Lista de productos en la orden
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.items.length,
                          itemBuilder: (context, itemIdx) {
                            final item = order.items[itemIdx];
                            final prod = item.product;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: ProductImage(
                                      imageUrl: prod.secureThumbnail,
                                      height: 44,
                                      width: 44,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prod.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textoPrincipal,
                                          ),
                                        ),
                                        Text(
                                          'Cantidad: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textoSecundario,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatMoneda.format(prod.price * item.quantity),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textoPrincipal,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 20, color: Color(0xFFEEEEEE)),

                        // Total de la compra
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total pagado:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textoPrincipal,
                              ),
                            ),
                            Text(
                              formatMoneda.format(order.total),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildProgressBar(String status) {
    double progress = 0.25;
    if (status.contains('Aceptado')) {
      progress = 0.50;
    } else if (status.contains('camino')) {
      progress = 0.75;
    } else if (status.contains('Entregado')) {
      progress = 1.0;
    }

    return Container(
      height: 4,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.verdeExito,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Aún no tienes compras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando realices un pedido simulado desde el carrito, podrás darle seguimiento aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textoSecundario),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azulLink,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Comenzar a comprar', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
