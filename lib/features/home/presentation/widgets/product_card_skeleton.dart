import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Esqueleto de carga (Shimmer) para simular la tarjeta del producto durante la petición de red.
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12.0, top: 4.0, bottom: 4.0),
      child: Card(
        color: Colors.white,
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Área de Imagen
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0),
                  ),
                ),
              ),
              // Área de Detalles
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Esqueleto de descuento o precio anterior
                    Container(
                      height: 12,
                      width: 90,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    // Esqueleto de precio principal
                    Container(
                      height: 20,
                      width: 110,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 6),
                    // Esqueleto del título línea 1
                    Container(
                      height: 12,
                      width: 130,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    // Esqueleto del título línea 2
                    Container(
                      height: 12,
                      width: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    // Esqueleto de "Envío gratis"
                    Container(
                      height: 12,
                      width: 70,
                      color: Colors.white,
                    ),
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
