import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/home_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/product_card_skeleton.dart';
import '../widgets/product_card.dart';
import '../../data/models/product_model.dart';

/// Pantalla Principal (HomeScreen) rediseñada para coincidir pixel-perfect con el screenshot de Mercado Libre.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _controladorBusqueda;
  int _indiceTabActivo = 0; // Controla la pestaña activa en la barra de navegación inferior
  int _indiceCategoriaAppbarActiva = 0;

  // Lista de categorías para el sub-header amarillo
  final List<String> _categoriasAppbar = [
    'Todo',
    'Celulares',
    'Moda',
    'Belleza',
    'Vehículos',
    'Hogar',
  ];

  void _actualizarTabCategoriaActiva(String consulta) {
    final idx = _categoriasAppbar.indexWhere(
      (cat) => cat.toLowerCase() == consulta.toLowerCase().trim()
    );
    setState(() {
      _indiceCategoriaAppbarActiva = idx != -1 ? idx : -1;
    });
  }

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(homeNotifierProvider.notifier);
    _controladorBusqueda = TextEditingController(text: notifier.ultimaConsulta);
    final idx = _categoriasAppbar.indexWhere(
      (cat) => cat.toLowerCase() == notifier.ultimaConsulta.toLowerCase().trim()
    );
    _indiceCategoriaAppbarActiva = idx != -1 ? idx : (notifier.ultimaConsulta.isEmpty ? 0 : -1);
  }

  @override
  void dispose() {
    _controladorBusqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estadoBusqueda = ref.watch(homeNotifierProvider);
    final notifier = ref.read(homeNotifierProvider.notifier);
    final isSearching = notifier.ultimaConsulta.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0), // Fondo gris suave característico de ML
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(132), // Altura extendida para triple fila
        child: _construirAppBarPersonalizada(context, notifier),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isSearching) ...[
              // 1. Banner de Campaña (Día del Padre)
              _construirHeroBanner(),

              // 2. Banner de Meli+
              _construirMeliPlusBanner(),

              const SizedBox(height: 12),

              // 3. Iconos Rápidos Horizontales (Ofertas, Afiliados, etc.)
              _construirIconosRapidos(),

              const SizedBox(height: 16),

              // 4. Panel Dividido (Ofertas Relámpago a la izquierda | Laptop Destacada a la derecha)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: estadoBusqueda.when(
                  data: (productos) => _construirContenedorOfertasDual(context, productos),
                  error: (error, _) => _construirWidgetError(error.toString(), notifier),
                  loading: () => _construirSkeletonsCarga(),
                ),
              ),

              const SizedBox(height: 16),

              // 5. Banner de Video (Xtreme PC Gaming)
              _construirVideoCard(),

              const SizedBox(height: 30),
            ] else ...[
              // Encabezado de búsqueda activa
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resultados para "${notifier.ultimaConsulta}"',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoPrincipal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _controladorBusqueda.clear();
                          _indiceCategoriaAppbarActiva = 0;
                        });
                        notifier.buscar('');
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Limpiar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.azulLink,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
              // Resultados en cuadrícula
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: estadoBusqueda.when(
                  data: (productos) {
                    final consultaMinuscula = notifier.ultimaConsulta.toLowerCase();
                    final productosFiltrados = productos.where((p) {
                      return p.title.toLowerCase().contains(consultaMinuscula) ||
                             (p.category != null && p.category!.toLowerCase().contains(consultaMinuscula));
                    }).toList();

                    final listaParaMostrar = productosFiltrados.isNotEmpty ? productosFiltrados : productos;

                    if (listaParaMostrar.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_outlined, size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                'No encontramos publicaciones que coincidan con tu búsqueda.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: listaParaMostrar.length,
                      itemBuilder: (context, index) {
                        final prod = listaParaMostrar[index];
                        return ProductCard(
                          producto: prod,
                          onTap: () => context.push('/detalle', extra: prod),
                        );
                      },
                    );
                  },
                  error: (error, _) => _construirWidgetError(error.toString(), notifier),
                  loading: () => _construirSkeletonsCarga(),
                ),
              ),
              const SizedBox(height: 30),
            ]
          ],
        ),
      ),
    );
  }

  /// AppBar personalizada de 3 filas oficial
  Widget _construirAppBarPersonalizada(BuildContext context, HomeNotifier notifier) {
    return Container(
      color: AppColors.amarilloML,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila 1: Buscador y Campana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                // Caja del TextField redondeada
                Expanded(
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.blanco,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 2.0,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _controladorBusqueda,
                      onChanged: (texto) {
                        setState(() {}); // Reconstruye para mostrar/ocultar botón de limpiar
                      },
                      onSubmitted: (consulta) {
                        notifier.buscar(consulta);
                        _actualizarTabCategoriaActiva(consulta);
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar en Mercado Libre',
                        prefixIcon: const Icon(Icons.search, color: AppColors.grisDetalle, size: 18),
                        suffixIcon: _controladorBusqueda.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppColors.grisDetalle, size: 18),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  setState(() {
                                    _controladorBusqueda.clear();
                                    _indiceCategoriaAppbarActiva = 0;
                                  });
                                  notifier.buscar('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 7.0),
                      ),
                      style: const TextStyle(fontSize: 13.5, color: AppColors.textoPrincipal),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Icono de Campana con Badge Rojo de notificaciones
                InkWell(
                  onTap: () => context.push('/notificaciones'),
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_none_outlined,
                        color: AppColors.textoPrincipal,
                        size: 26,
                      ),
                      Positioned(
                        top: -3,
                        right: -3,
                        child: Container(
                          padding: const EdgeInsets.all(3.0),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: const Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Fila 2: Código Postal/Ubicación
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textoPrincipal),
                SizedBox(width: 4),
                Text(
                  'Ingresa tu código postal (CP 76344) >',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: AppColors.textoPrincipal,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Fila 3: Tabs de Categorías
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _categoriasAppbar.length,
              itemBuilder: (context, index) {
                final esActivo = index == _indiceCategoriaAppbarActiva;
                return Padding(
                  padding: const EdgeInsets.only(right: 18.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _indiceCategoriaAppbarActiva = index;
                      });
                      if (index == 0) {
                        _controladorBusqueda.clear();
                        notifier.buscar('');
                      } else {
                        final cat = _categoriasAppbar[index];
                        _controladorBusqueda.text = cat;
                        notifier.buscar(cat);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _categoriasAppbar[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: esActivo ? FontWeight.bold : FontWeight.normal,
                            color: AppColors.textoPrincipal,
                          ),
                        ),
                        const Spacer(),
                        // Línea negra inferior para el activo
                        if (esActivo)
                          Container(
                            height: 2.5,
                            width: 30,
                            decoration: BoxDecoration(
                              color: AppColors.textoPrincipal,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          )
                        else
                          const SizedBox(height: 2.5),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  /// Renderiza el Banner Hero cargando el archivo assets local generado
  Widget _construirHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          'assets/images/promo_banner.png',
          height: 140,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback con degradado estético si hay problemas con assets
            return Container(
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3F51B5), Color(0xFFE91E63)],
                ),
              ),
              child: const Center(
                child: Text(
                  'El regalo ideal para papá ¡Hasta 45% OFF!',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Banner de meli+ estilizado
  Widget _construirMeliPlusBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Eres ',
            style: TextStyle(fontSize: 13, color: AppColors.textoPrincipal),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4B1C9E), // Púrpura Meli+
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'meli+',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          const VerticalDivider(width: 1, color: Colors.grey, thickness: 1),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Descubre tus beneficios exclusivos',
              style: TextStyle(fontSize: 13, color: AppColors.textoPrincipal, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: AppColors.textoSecundario),
        ],
      ),
    );
  }

  /// Fila de Iconos Rápidos (Ofertas, Afiliados, Mercado Play, Cupones, Fútbol 2026)
  Widget _construirIconosRapidos() {
    final List<Map<String, dynamic>> items = [
      {'nombre': 'Ofertas', 'icono': Icons.percent, 'color': const Color(0xFFFFEB3B), 'badge': ''},
      {'nombre': 'Afiliados', 'icono': Icons.link, 'color': const Color(0xFF8BC34A), 'badge': 'GANA \$', 'badgeColor': const Color(0xFF00A650)},
      {'nombre': 'Mercado Play', 'icono': Icons.movie_creation_outlined, 'color': const Color(0xFFFF5722), 'badge': 'GRATIS', 'badgeColor': const Color(0xFF00A650)},
      {'nombre': 'Cupones', 'icono': Icons.confirmation_number_outlined, 'color': const Color(0xFF2196F3), 'badge': ''},
      {'nombre': 'Fútbol 2026', 'icono': Icons.emoji_events_outlined, 'color': const Color(0xFFFFC107), 'badge': 'NUEVO', 'badgeColor': const Color(0xFF2196F3)},
    ];

    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 76,
            margin: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Círculo de Fondo del Icono
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          item['icono'] as IconData,
                          color: (item['color'] as Color).withOpacity(0.8),
                          size: 24,
                        ),
                      ),
                    ),
                    // Etiqueta flotante superior (Badge) si existe
                    if ((item['badge'] as String).isNotEmpty)
                      Positioned(
                        bottom: -4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: item['badgeColor'] as Color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['nombre'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textoPrincipal, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construcción del Contenedor de Ofertas Dual
  Widget _construirContenedorOfertasDual(BuildContext context, List<Product> productos) {
    // Filtramos los productos simulados o de la API
    final mochila = productos.firstWhere(
      (p) => p.id.contains('mochila'),
      orElse: () => productos[0],
    );
    final muneca = productos.firstWhere(
      (p) => p.id.contains('muneca'),
      orElse: () => productos.length > 1 ? productos[1] : productos[0],
    );
    final mesa = productos.firstWhere(
      (p) => p.id.contains('mesa'),
      orElse: () => productos.length > 2 ? productos[2] : productos[0],
    );
    final laptop = productos.firstWhere(
      (p) => p.id.contains('laptop'),
      orElse: () => productos.length > 3 ? productos[3] : productos[0],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna Izquierda: Ofertas Relámpago (50% de ancho)
        Expanded(
          child: _construirOfertasRelampagoBox(context, [mochila, muneca, mesa]),
        ),
        const SizedBox(width: 12),
        // Columna Derecha: Laptop Destacada (50% de ancho)
        Expanded(
          child: _construirLaptopCardBox(context, laptop),
        ),
      ],
    );
  }

  /// Caja de "Ofertas Relámpago" con cabecera amarilla y 3 items verticales
  Widget _construirOfertasRelampagoBox(BuildContext context, List<Product> productosRelampago) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera Amarilla
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFE81F), // Amarillo un poco más intenso
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OFERTAS RELÁMPAGO',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2C2500),
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Terminan en ',
                      style: TextStyle(fontSize: 10.0, color: Color(0xFF2C2500)),
                    ),
                    Text(
                      '00 : 28 : 06',
                      style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold, color: Color(0xFF2C2500)),
                    ),
                  ],
                )
              ],
            ),
          ),

          // Items de productos (3 filas verticales)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: productosRelampago.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFEEEEEE)),
            itemBuilder: (context, index) {
              final prod = productosRelampago[index];
              return InkWell(
                onTap: () => context.push('/detalle', extra: prod),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    children: [
                      // Mini Imagen
                      ProductImage(
                        imageUrl: prod.secureThumbnail,
                        height: 54,
                        width: 54,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      // Precios y descuento
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Precio original tachado
                            if (prod.originalPrice != null)
                              Text(
                                '\$${prod.originalPrice!.round()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.grisDetalle,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            // Precio actual y Descuento
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '\$${prod.price.round()}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textoPrincipal,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${prod.porcentajeDescuento}% OFF',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.verdeExito,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            // Fuego indicador si es la mochila
                            if (prod.id.contains('mochila'))
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFECE6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.whatshot, color: Colors.deepOrange, size: 9),
                                    SizedBox(width: 2),
                                    Text('5', style: TextStyle(color: Colors.deepOrange, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Caja derecha: Laptop Huawei Destacada "Bajó de precio"
  Widget _construirLaptopCardBox(BuildContext context, Product laptop) {
    final formatoMoneda = NumberFormat.currency(
      locale: 'es_MX',
      symbol: '\$',
      decimalDigits: 0,
    );

    return InkWell(
      onTap: () => context.push('/detalle', extra: laptop),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la Laptop
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                  child: ProductImage(
                    imageUrl: laptop.secureThumbnail,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // Detalles del producto
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta Verde "BAJÓ DE PRECIO"
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_downward, color: AppColors.verdeExito, size: 10),
                        SizedBox(width: 2),
                        Text(
                          'BAJÓ DE PRECIO',
                          style: TextStyle(
                            color: AppColors.verdeExito,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Título
                  Text(
                    laptop.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textoPrincipal,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Precio anterior tachado
                  if (laptop.originalPrice != null)
                    Text(
                      formatoMoneda.format(laptop.originalPrice),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grisDetalle,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),

                  // Precio actual y botón de agregar al carrito flotante
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatoMoneda.format(laptop.price),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textoPrincipal,
                              ),
                            ),
                            const Text(
                              '+100 vendidos',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.grisDetalle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Botón circular agregar al carrito
                      InkWell(
                        onTap: () {
                          ref.read(cartNotifierProvider.notifier).agregarProducto(laptop);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.verdeExito,
                              duration: const Duration(seconds: 2),
                              content: Text('¡${laptop.title} agregado al carrito!'),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 28,
                          width: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue[200]!, width: 1),
                          ),
                          child: Icon(Icons.add_shopping_cart, size: 14, color: Colors.blue[600]),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Envío Gratis FULL
                  const Row(
                    children: [
                      Text(
                        'Envío gratis ',
                        style: TextStyle(
                          color: AppColors.verdeExito,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.bolt, color: AppColors.verdeExito, size: 12),
                      Text(
                        'FULL',
                        style: TextStyle(
                          color: AppColors.verdeExito,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Banner del canal de video "Xtreme PC Gaming"
  Widget _construirVideoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Imagen de fondo con opacidad baja
          Opacity(
            opacity: 0.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=600&auto=format&fit=crop',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Indicador de reproducción y visualizaciones
          const Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                SizedBox(width: 4),
                Text(
                  '10.8 mil vistas',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Título de la tarjeta
          const Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Text(
              'XTREME PC GAMING • Armado de PC Gamer de Alto Rendimiento',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra los skeletons de shimmer mientras carga
  Widget _construirSkeletonsCarga() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 200,
            color: Colors.white,
            child: const Center(child: CircularProgressIndicator(color: AppColors.azulLink)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: const ProductCardSkeleton(),
        ),
      ],
    );
  }

  /// Error widget con reintento
  Widget _construirWidgetError(String errorMsg, HomeNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
          const SizedBox(height: 8),
          Text(errorMsg, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => notifier.reintentar(), child: const Text('Reintentar')),
        ],
      ),
    );
  }

  /// Barra de Navegación Inferior idéntica al de la captura de pantalla
  Widget _construirBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.azulLink, // Azul para la pestaña Inicio activa
      unselectedItemColor: AppColors.textoSecundario,
      selectedFontSize: 10.0,
      unselectedFontSize: 10.0,
      currentIndex: _indiceTabActivo,
      onTap: (indice) {
        setState(() {
          _indiceTabActivo = indice;
        });
      },
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home, color: AppColors.azulLink),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Categorías',
        ),
        // Item Carrito con Badge número 3 en azul oscuro
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF3483FA), // Azul de notificación en el carrito
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 13,
                    minHeight: 13,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
          label: 'Carrito',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Videos',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Más',
        ),
      ],
    );
  }
}
