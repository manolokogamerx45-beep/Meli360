import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MasScreen extends StatelessWidget {
  const MasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      body: CustomScrollView(
        slivers: [
          // Header del perfil con degradado amarillo corporativo
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.amarilloML,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.amarilloML, Color(0xFFFFCC00)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue[100],
                              child: const Text(
                                'E',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.azulLink,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Emmanuel',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textoPrincipal,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'CP 76344 • Nivel 3 Meli+',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textoPrincipal,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenedor de beneficios de Meli+
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF4B1C9E).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2EAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star, color: Color(0xFF4B1C9E)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meli+ activo',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4B1C9E),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Disney+ y envíos gratis incluidos',
                          style: TextStyle(color: AppColors.textoSecundario, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.grisDetalle),
                ],
              ),
            ),
          ),

          // Enlaces rápidos / Opciones del Perfil
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  Icons.shopping_bag_outlined,
                  'Mis compras',
                  'Tus pedidos y rastreos',
                  onTap: () => context.push('/mis-compras'),
                ),
                _buildMenuCard(Icons.favorite_border, 'Favoritos', 'Productos guardados'),
                _buildMenuCard(Icons.confirmation_number_outlined, 'Cupones', 'Tus descuentos activos'),
                _buildMenuCard(Icons.location_on_outlined, 'Direcciones', 'CP 76344 y envíos'),
                _buildMenuCard(Icons.credit_card, 'Tarjetas', 'Tus métodos de pago'),
                _buildMenuCard(Icons.star_outline, 'Suscripciones', 'Administra Meli+'),
              ]),
            ),
          ),

          // Sección de Configuración y Legal
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildListTile(Icons.settings_outlined, 'Configuración de cuenta'),
                  const Divider(height: 1),
                  _buildListTile(Icons.notifications_none_outlined, 'Notificaciones'),
                  const Divider(height: 1),
                  _buildListTile(Icons.security_outlined, 'Privacidad y seguridad'),
                  const Divider(height: 1),
                  _buildListTile(Icons.help_outline, 'Ayuda y soporte'),
                ],
              ),
            ),
          ),

          // Botón Cerrar Sesión simulado
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Cerrar sesión de Emmanuel',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textoPrincipal, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textoPrincipal),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: AppColors.textoSecundario),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textoPrincipal, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textoPrincipal),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grisDetalle, size: 18),
      onTap: () {},
    );
  }
}
