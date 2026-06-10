import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/product_card.dart';

class CategoryProductsScreen extends ConsumerWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estadoProductos = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textoPrincipal),
          onPressed: () => context.pop(),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: AppColors.textoPrincipal,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: estadoProductos.when(
        data: (productos) {
          final productosFiltrados = productos.where(
            (p) => p.category?.toLowerCase() == categoryId.toLowerCase(),
          ).toList();

          if (productosFiltrados.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No hay productos disponibles en $categoryName por el momento.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textoSecundario),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.67,
            ),
            itemCount: productosFiltrados.length,
            itemBuilder: (context, index) {
              final prod = productosFiltrados[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ProductCard(
                  producto: prod,
                  onTap: () => context.push('/detalle', extra: prod),
                ),
              );
            },
          );
        },
        error: (err, _) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.azulLink)),
      ),
    );
  }
}
