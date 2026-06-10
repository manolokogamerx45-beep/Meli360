import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class NotificacionesScreen extends StatelessWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> notificaciones = [
      {
        'titulo': '¡Tu envío está en camino! 🚚',
        'cuerpo': 'La Laptop Huawei Matebook D 14 ya fue despachada y llegará hoy antes de las 8:00 PM.',
        'fecha': 'Hace 10 min',
        'icono': Icons.local_shipping,
        'color': const Color(0xFFE8F8F0),
        'iconColor': AppColors.verdeExito,
        'leida': false
      },
      {
        'titulo': '¡Bajó de precio! 📉',
        'cuerpo': 'El artículo Muñeca Bebé Realista de Silicona que guardaste tiene ahora un 50% de descuento especial.',
        'fecha': 'Hace 2 horas',
        'icono': Icons.trending_down,
        'color': const Color(0xFFEBF5FB),
        'iconColor': AppColors.azulLink,
        'leida': false
      },
      {
        'titulo': 'Regalo del Día del Padre 🎁',
        'cuerpo': '¡Encuentra el regalo ideal para papá con hasta 45% OFF y envíos gratis FULL en menos de 24 horas!',
        'fecha': 'Ayer',
        'icono': Icons.card_giftcard,
        'color': const Color(0xFFFEF9E7),
        'iconColor': Colors.amber[700]!,
        'leida': true
      },
      {
        'titulo': '¡Suscripción mensual Meli+ activa! 💜',
        'cuerpo': 'Tu pago fue confirmado con éxito. Sigue disfrutando de Disney+, Deezer y envíos gratis ilimitados.',
        'fecha': 'Hace 3 días',
        'icono': Icons.star,
        'color': const Color(0xFFF5EEF8),
        'iconColor': const Color(0xFF4B1C9E),
        'leida': true
      }
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: AppColors.amarilloML,
        elevation: 0,
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: AppColors.textoPrincipal, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        itemCount: notificaciones.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, index) {
          final notif = notificaciones[index];
          return Card(
            elevation: notif['leida'] ? 0.5 : 2,
            margin: const EdgeInsets.only(bottom: 12),
            color: notif['leida'] ? Colors.white : const Color(0xFFFAFAFA),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: notif['leida']
                  ? BorderSide.none
                  : const BorderSide(color: AppColors.azulLink, width: 0.8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                // Marcar como leída
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono flotante con color personalizado
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: notif['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notif['icono'] as IconData,
                        color: notif['iconColor'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Título, cuerpo y fecha
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notif['titulo'] as String,
                                  style: TextStyle(
                                    fontWeight: notif['leida'] ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 14,
                                    color: AppColors.textoPrincipal,
                                  ),
                                ),
                              ),
                              Text(
                                notif['fecha'] as String,
                                style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            notif['cuerpo'] as String,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textoSecundario,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
