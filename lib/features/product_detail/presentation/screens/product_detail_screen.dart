import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/data/models/product_model.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

/// Pantalla del Detalle del Producto al estilo de Mercado Libre.
class ProductDetailScreen extends ConsumerWidget {
  final Product producto;

  const ProductDetailScreen({
    super.key,
    required this.producto,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatoMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    // Simulamos las cuotas mensuales sin interés (común en e-commerce)
    final cuotaMensual = producto.price / 12;
    final formatoCuota = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoPrincipal),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: AppColors.textoPrincipal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textoPrincipal),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textoPrincipal),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Condición y vendidos
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Nuevo  |  +100 vendidos',
                    style: TextStyle(
                      color: AppColors.grisDetalle,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Calificación simulada de 5 estrellas
                  const Icon(Icons.star, color: Color(0xFFF1C40F), size: 14),
                  const Icon(Icons.star, color: Color(0xFFF1C40F), size: 14),
                  const Icon(Icons.star, color: Color(0xFFF1C40F), size: 14),
                  const Icon(Icons.star, color: Color(0xFFF1C40F), size: 14),
                  const Icon(Icons.star, color: Color(0xFFF1C40F), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '48',
                    style: TextStyle(color: Colors.blue[600], fontSize: 12),
                  ),
                ],
              ),
            ),

            // Título largo del producto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                producto.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textoPrincipal,
                  height: 1.3,
                ),
              ),
            ),

            // Imagen Principal con ProductImage inteligente
            Container(
              color: AppColors.blanco,
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ProductImage(
                imageUrl: producto.secureThumbnail,
                fit: BoxFit.contain,
              ),
            ),

            const Divider(height: 1, color: AppColors.fondoGeneral),

            // Contenedor de Precios y Formas de Pago
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descuento y precio anterior
                  if (producto.originalPrice != null && producto.porcentajeDescuento > 0) ...[
                    Text(
                      formatoMoneda.format(producto.originalPrice),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.grisDetalle,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          formatoMoneda.format(producto.price),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: AppColors.textoPrincipal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${producto.porcentajeDescuento}% OFF',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.verdeExito,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      formatoMoneda.format(producto.price),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textoPrincipal,
                      ),
                    ),
                  ],

                  const SizedBox(height: 6),

                  // Simulación de cuotas sin interés
                  Row(
                    children: [
                      const Text(
                        'en ',
                        style: TextStyle(color: AppColors.textoPrincipal, fontSize: 15),
                      ),
                      Text(
                        '12x de ${formatoCuota.format(cuotaMensual)} sin interés',
                        style: const TextStyle(
                          color: AppColors.verdeExito,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ver los medios de pago',
                    style: TextStyle(color: AppColors.azulLink, fontSize: 13),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.fondoGeneral),

            // Información de Envío y Devolución
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Fila de Envío
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.local_shipping_outlined,
                        color: producto.shipping.freeShipping
                            ? AppColors.verdeExito
                            : AppColors.textoSecundario,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.shipping.freeShipping ? 'Envío gratis' : 'Envío estándar disponible',
                              style: TextStyle(
                                color: producto.shipping.freeShipping
                                    ? AppColors.verdeExito
                                    : AppColors.textoPrincipal,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Text(
                              'Llega gratis mañana o el miércoles',
                              style: TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                            const Text(
                              'Enviar a Emmanuel - Calle Falsa 123',
                              style: TextStyle(color: AppColors.azulLink, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Fila de Devolución
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.keyboard_return, color: AppColors.verdeExito, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Devolución gratis',
                              style: TextStyle(
                                color: AppColors.verdeExito,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Tienes 30 días desde que lo recibes.',
                              style: TextStyle(
                                color: AppColors.textoSecundario,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.fondoGeneral),

            // Stock disponible
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stock disponible',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textoPrincipal,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Cantidad: ',
                        style: TextStyle(color: AppColors.textoPrincipal),
                      ),
                      Text(
                        '1 unidad ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '(10 disponibles)',
                        style: TextStyle(color: AppColors.grisDetalle, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Botones de Acción de Compra (CTAs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Botón Comprar ahora (Azul oscuro)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final item = CartItem(product: producto, quantity: 1);
                        context.push(
                          '/checkout',
                          extra: {
                            'items': [item],
                            'total': producto.price,
                            'clearCartOnSuccess': false,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.azulLink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: const Text('Comprar ahora'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Botón Agregar al carrito (Azul claro de fondo, letras azules)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(cartNotifierProvider.notifier).agregarProducto(producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.verdeExito,
                            duration: const Duration(seconds: 2),
                            content: Text('¡${producto.title} agregado al carrito!'),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.azulLink,
                        side: const BorderSide(color: AppColors.azulLink, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        backgroundColor: AppColors.azulLink.withOpacity(0.08),
                      ),
                      child: const Text(
                        'Agregar al carrito',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
