import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/data/models/product_model.dart';

class VideosScreen extends ConsumerStatefulWidget {
  const VideosScreen({super.key});

  @override
  ConsumerState<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends ConsumerState<VideosScreen> {
  final PageController _pageController = PageController();
  int _currentVideoIndex = 0;

  final List<Map<String, dynamic>> _mockVideos = [
    {
      'canal': '@TechGamer_Mx',
      'descripcion': '¡El armado definitivo de la PC Gamer con componentes Xtreme! Corre cualquier juego a +120 FPS. 🎮🔥 #pcgamer #gaming',
      'likes': '24.5k',
      'comentarios': '890',
      'compartidos': '1.2k',
      'videoUrl': 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600&auto=format&fit=crop',
      'productId': 'mock-laptop'
    },
    {
      'canal': '@AudifonosReviews',
      'descripcion': 'Probando los Audífonos F9-5 TWS Bluetooth en el gimnasio. Cancelación de ruido pasiva y batería eterna por menos de \$250 pesos. 🎧⚡ #review #audio',
      'likes': '12.8k',
      'comentarios': '452',
      'compartidos': '612',
      'videoUrl': 'https://images.unsplash.com/photo-1484704849700-f032a568e944?q=80&w=600&auto=format&fit=crop',
      'productId': 'mock-audifonos'
    },
    {
      'canal': '@MeliModa_Estilo',
      'descripcion': 'Esta mochila escolar de cerezas es súper impermeable y tiene compartimentos secretos para tu laptop. ¡Aprovecha el 53% de descuento! 🎒🌸 #regresoclases #moda',
      'likes': '35.1k',
      'comentarios': '1.1k',
      'compartidos': '2.4k',
      'videoUrl': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=600&auto=format&fit=crop',
      'productId': 'mock-mochila'
    },
    {
      'canal': '@HomeOffice_Style',
      'descripcion': 'La mesa de centro plegable ideal para desayunar o trabajar en la cama y sofá. Estable, ligera y muy económica. 💻☕ #homeoffice #decoracion',
      'likes': '8.9k',
      'comentarios': '231',
      'compartidos': '410',
      'videoUrl': 'https://images.unsplash.com/photo-1517502884422-41eaaced0168?q=80&w=600&auto=format&fit=crop',
      'productId': 'mock-mesa'
    }
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoProductos = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: estadoProductos.when(
        data: (productos) => PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _mockVideos.length,
          onPageChanged: (index) {
            setState(() {
              _currentVideoIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final video = _mockVideos[index];
            final product = productos.firstWhere(
              (p) => p.id == video['productId'],
              orElse: () => productos[0],
            );

            return _buildVideoPage(video, product);
          },
        ),
        error: (err, _) => Center(
          child: Text(
            'Error al cargar productos: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.amarilloML),
        ),
      ),
    );
  }

  Widget _buildVideoPage(Map<String, dynamic> video, Product product) {
    return Stack(
      children: [
        // 1. Imagen de fondo del video (Simulado)
        Positioned.fill(
          child: Image.network(
            video['videoUrl'] as String,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white30),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.grey[900],
              child: const Icon(Icons.videocam_off, color: Colors.white30, size: 64),
            ),
          ),
        ),
        // Sombra degradada para legibilidad del texto
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // Botón superior de Cerrar / Regresar
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 16,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.slow_motion_video, color: AppColors.amarilloML, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Mercado Play • Clips',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 2. Iconos de Acción a la derecha
        Positioned(
          right: 16,
          bottom: 120,
          child: Column(
            children: [
              _buildActionButton(Icons.favorite, video['likes'] as String, Colors.redAccent),
              const SizedBox(height: 18),
              _buildActionButton(Icons.comment, video['comentarios'] as String, Colors.white),
              const SizedBox(height: 18),
              _buildActionButton(Icons.reply, video['compartidos'] as String, Colors.white),
              const SizedBox(height: 24),
              // Círculo de perfil rotante simulación
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.amarilloML,
                  child: Text(
                    video['canal'].toString().substring(1, 3).toUpperCase(),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textoPrincipal),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Información del canal y Producto Flotante en la parte inferior izquierda
        Positioned(
          left: 16,
          right: 80,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de Canal
              Text(
                video['canal'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              // Descripción
              Text(
                video['descripcion'] as String,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),

              // Tarjeta de Producto Superpuesta
              GestureDetector(
                onTap: () => context.push('/detalle', extra: product),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Imagen producto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: ProductImage(
                          imageUrl: product.secureThumbnail,
                          height: 50,
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Título y Precio
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoPrincipal,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  '\$${product.price.round()}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoPrincipal,
                                  ),
                                ),
                                if (product.porcentajeDescuento > 0) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${product.porcentajeDescuento}% OFF',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.verdeExito,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Botón Ver
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.azulLink,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Ver',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String count, Color iconColor) {
    return Column(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
