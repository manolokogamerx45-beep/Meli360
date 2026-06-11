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

                        // Estatus de Envío con Timeline Stepper
                        const SizedBox(height: 8),
                        _buildVisualTimeline(order.status),
                        if (order.repartidor != null) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Repartidor asignado: ${order.repartidor}',
                              style: const TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        
                        // Mostrar ticket de código de seguridad de entrega
                        if (order.keyword != null && !order.status.contains('Entregado')) ...[
                          _buildTicketPINCard(order.keyword!),
                          const SizedBox(height: 16),
                        ] else if (order.status.contains('Entregado')) ...[
                          _buildSuccessDeliveryBanner(),
                          const SizedBox(height: 16),
                        ],

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

  Widget _buildVisualTimeline(String status) {
    int activeIndex = 0;
    if (status.contains('Aceptado')) activeIndex = 1;
    if (status.contains('camino')) activeIndex = 2;
    if (status.contains('Entregado')) activeIndex = 3;

    final steps = ['Preparando', 'Aceptado', 'En camino', 'Entregado'];
    final icons = [
      Icons.storefront_rounded,
      Icons.assignment_turned_in_rounded,
      Icons.directions_bike_rounded,
      Icons.inventory_2_rounded
    ];
    
    final Color activeColor = status.contains('Entregado')
        ? AppColors.verdeExito
        : status.contains('camino')
            ? AppColors.azulLink
            : Colors.orange;

    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= activeIndex;
        final isCompleted = index < activeIndex;
        final stepColor = isActive ? (index == activeIndex ? activeColor : AppColors.azulLink) : Colors.grey[300]!;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive ? stepColor.withOpacity(0.1) : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: stepColor,
                          width: isActive ? 2.5 : 1.5,
                        ),
                        boxShadow: isActive && index == activeIndex ? [
                          BoxShadow(
                            color: stepColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ] : null,
                      ),
                      child: Icon(
                        icons[index],
                        color: stepColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: index == activeIndex ? FontWeight.bold : FontWeight.w500,
                        color: index == activeIndex ? Colors.black87 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 3)
                Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isCompleted ? AppColors.azulLink : Colors.grey[200],
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTicketPINCard(String pin) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9E6), Color(0xFFFFF5D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD966), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              left: -10,
              top: 50,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -10,
              top: 50,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.vpn_key_rounded, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'CÓDIGO DE SEGURIDAD',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8A6D3B),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      20,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.orange.withOpacity(0.3),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: Text(
                      pin,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: Color(0xFFD67C00),
                        letterSpacing: 4.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Proporciona este código al repartidor al recibir tu paquete para validar la entrega.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF9E7A2F),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessDeliveryBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF81C784), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: AppColors.verdeExito, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¡Entrega confirmada!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Text(
                  'Tu compra ha sido entregada con éxito. ¡Que la disfrutes!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
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
