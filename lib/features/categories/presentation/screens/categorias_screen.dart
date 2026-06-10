import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categorias = [
      {'id': 'tecnologia', 'nombre': 'Tecnología', 'icono': Icons.devices, 'color': const Color(0xFFEBF5FB), 'iconColor': const Color(0xFF2980B9), 'sub': 'Celulares, Laptops, Smartwatches'},
      {'id': 'moda', 'nombre': 'Moda', 'icono': Icons.checkroom, 'color': const Color(0xFFFDEDEC), 'iconColor': const Color(0xFFCB4335), 'sub': 'Ropa, Calzado, Accesorios'},
      {'id': 'hogar', 'nombre': 'Hogar y Muebles', 'icono': Icons.chair_outlined, 'color': const Color(0xFFFEF9E7), 'iconColor': const Color(0xFFD4AC0D), 'sub': 'Cocina, Decoración, Jardín'},
      {'id': 'deportes', 'nombre': 'Deportes y Fitness', 'icono': Icons.directions_run, 'color': const Color(0xFFE8F8F5), 'iconColor': const Color(0xFF16A085), 'sub': 'Ropa Deportiva, Bicicletas, Pesas'},
      {'id': 'juguetes', 'nombre': 'Juguetes y Bebés', 'icono': Icons.child_friendly, 'color': const Color(0xFFF5EEF8), 'iconColor': const Color(0xFF8E44AD), 'sub': 'Juguetes, Muñecas, Pañaleras'},
      {'id': 'belleza', 'nombre': 'Belleza', 'icono': Icons.face_retouching_natural, 'color': const Color(0xFFFDF2E9), 'iconColor': const Color(0xFFDC7633), 'sub': 'Cuidado Personal, Perfumes'},
      {'id': 'herramientas', 'nombre': 'Herramientas', 'icono': Icons.construction, 'color': const Color(0xFFF2F4F4), 'iconColor': const Color(0xFF7F8C8D), 'sub': 'Eléctricas, Iluminación, Pinturas'},
      {'id': 'vehiculos', 'nombre': 'Vehículos', 'icono': Icons.directions_car, 'color': const Color(0xFFFBEEE6), 'iconColor': const Color(0xFFBA4A00), 'sub': 'Accesorios, Llantas, Limpieza'},
      {'id': 'supermercado', 'nombre': 'Supermercado', 'icono': Icons.local_grocery_store_outlined, 'color': const Color(0xFFEAF2F8), 'iconColor': const Color(0xFF2471A3), 'sub': 'Bebidas, Alimentos, Limpieza'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        title: const Text(
          'Categorías',
          style: TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textoPrincipal),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          // Banner de campañas en categorías
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Meli+ Incluido',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Envíos GRATIS en millones de productos',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sin mínimo de compra en miles de categorías',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.local_shipping, color: Colors.white, size: 48),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Explora por departamentos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
            ),
          ),

          // Lista de categorías
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categorias.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final cat = categorias[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cat['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      cat['icono'] as IconData,
                      color: cat['iconColor'] as Color,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    cat['nombre'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textoPrincipal),
                  ),
                  subtitle: Text(
                    cat['sub'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.textoSecundario),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.grisDetalle, size: 20),
                  onTap: () {
                    context.push('/categoria/${cat['id']}?name=${Uri.encodeComponent(cat['nombre'] as String)}');
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
