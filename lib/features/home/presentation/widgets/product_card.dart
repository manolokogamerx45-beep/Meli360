import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/product_image.dart';
import '../../data/models/product_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Tarjeta de producto individual estilizada al estilo de Mercado Libre.
class ProductCard extends StatelessWidget {
  final Product producto;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.producto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatoMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12.0, top: 4.0, bottom: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen del producto con ProductImage inteligente
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                    child: ProductImage(
                      imageUrl: producto.secureThumbnail,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              // Contenido informativo de la tarjeta
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Precio original y descuento (si aplica)
                    if (producto.originalPrice != null && producto.porcentajeDescuento > 0) ...[
                      Row(
                        children: [
                          Text(
                            formatoMoneda.format(producto.originalPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grisDetalle,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${producto.porcentajeDescuento}% OFF',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.verdeExito,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ] else ...[
                      // Espacio consistente para mantener alineadas las tarjetas
                      const SizedBox(height: 18),
                    ],

                    // Precio actual grande
                    Text(
                      formatoMoneda.format(producto.price),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Título (Máximo 2 líneas)
                    Text(
                      producto.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textoPrincipal,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Etiqueta de Envío Gratis
                    if (producto.shipping.freeShipping)
                      const Text(
                        'Envío gratis',
                        style: TextStyle(
                          color: AppColors.verdeExito,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const SizedBox(height: 15), // Mantiene la altura consistente
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
