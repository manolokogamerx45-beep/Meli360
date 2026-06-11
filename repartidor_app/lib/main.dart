import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// --- CONFIGURACIÓN GLOBAL ---
class AppConfig {
  static String repartidorNombre = 'Repartidor de Prueba';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RepartidorApp());
}

class RepartidorApp extends StatelessWidget {
  const RepartidorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repartidor Meli360',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4B1C9E), // Color Meli+
          primary: const Color(0xFF4B1C9E),
          secondary: const Color(0xFF00A650), // Verde éxito de ML
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// --- MODELOS DE DATOS ---
class OrderItem {
  final String title;
  final int quantity;
  final double price;

  OrderItem({required this.title, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      title: json['product']['title'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      price: (json['product']['price'] as num? ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final String fecha;
  final String status;
  final String? repartidor;
  final int? timestamp;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.fecha,
    required this.status,
    this.repartidor,
    this.timestamp,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    return Order(
      id: json['id'] as String? ?? '',
      items: parsedItems,
      total: (json['total'] as num? ?? 0).toDouble(),
      fecha: json['fecha'] as String? ?? '',
      status: json['status'] as String? ?? '',
      repartidor: json['repartidor'] as String?,
      timestamp: json['timestamp'] as int?,
    );
  }
}

// --- PANTALLA 1: CONFIGURACIÓN E INICIO ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controladorNombre;

  @override
  void initState() {
    super.initState();
    _controladorNombre = TextEditingController(text: 'Juan El Repartidor');
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4B1C9E), Color(0xFF3483FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.all(24.0),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.delivery_dining, size: 72, color: Color(0xFF4B1C9E)),
                      const SizedBox(height: 16),
                      const Text(
                        'Repartidor Meli360',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C2500)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ingresa tu perfil de repartidor para conectarte a la nube de Firebase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _controladorNombre,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Repartidor',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              AppConfig.repartidorNombre = _controladorNombre.text.trim();

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const OrdersListScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4B1C9E),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ingresar al Panel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA 2: PEDIDOS DISPONIBLES EN TIEMPO REAL ---
class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Order> _ordenes = [];
  bool _cargando = true;
  String? _error;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _escucharFirestore();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // Escucha de Firestore para sincronización en tiempo real
  void _escucharFirestore() {
    setState(() {
      _cargando = true;
      _error = null;
    });

    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        return Order.fromJson(data);
      }).toList();

      // Ordenar localmente por timestamp descendente
      list.sort((a, b) {
        final aTime = a.timestamp ?? 0;
        final bTime = b.timestamp ?? 0;
        return bTime.compareTo(aTime);
      });

      if (mounted) {
        setState(() {
          _ordenes = list;
          _cargando = false;
        });
      }
    }, onError: (err) {
      if (mounted) {
        setState(() {
          _error = 'Error al conectar con Firebase: $err';
          _cargando = false;
        });
      }
    });
  }

  // Actualiza aceptación del pedido directamente en Firestore
  Future<void> _aceptarPedido(Order orden) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orden.id).update({
        'status': 'Aceptado por repartidor',
        'repartidor': AppConfig.repartidorNombre,
      });

      if (mounted) {
        final actual = Order(
          id: orden.id,
          items: orden.items,
          total: orden.total,
          fecha: orden.fecha,
          status: 'Aceptado por repartidor',
          repartidor: AppConfig.repartidorNombre,
          timestamp: orden.timestamp,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveDeliveryScreen(orden: actual),
          ),
        );
      }
    } catch (e) {
      _mostrarAlerta('Error', 'No se pudo aceptar el pedido: $e');
    }
  }

  void _mostrarAlerta(String titulo, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar pedidos disponibles (sin repartidor asignado)
    final disponibles = _ordenes.where((o) => o.repartidor == null).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B1C9E),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pedidos Disponibles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Repartidor: ${AppConfig.repartidorNombre}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _escucharFirestore();
            },
          )
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          },
                          child: const Text('Volver a Configuración'),
                        )
                      ],
                    ),
                  ),
                )
              : disponibles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_bike_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No hay pedidos disponibles por ahora',
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text('Las nuevas compras aparecerán aquí en tiempo real.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: disponibles.length,
                      itemBuilder: (context, index) {
                        final orden = disponibles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE81F),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        orden.id,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF2C2500)),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Total: \$${orden.total.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text('Artículos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                                ...orden.items.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                                      child: Text(
                                        '• ${item.quantity}x ${item.title}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    )),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(orden.fecha, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: () => _aceptarPedido(orden),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Aceptar Entrega'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00A650),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// --- PANTALLA 3: PEDIDO ACTIVO / CONTROL DE ENTREGA ---
class ActiveDeliveryScreen extends StatefulWidget {
  final Order orden;

  const ActiveDeliveryScreen({super.key, required this.orden});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  late Order _ordenActual;
  bool _actualizando = false;
  StreamSubscription<DocumentSnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _ordenActual = widget.orden;
    _escucharDocumento();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _escucharDocumento() {
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .doc(_ordenActual.id)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final updated = Order.fromJson(snapshot.data()!);
        if (mounted) {
          setState(() {
            _ordenActual = updated;
          });
        }
      }
    }, onError: (err) {
      print('[ActiveDeliveryScreen Firestore Error] $err');
    });
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    setState(() {
      _actualizando = true;
    });

    try {
      await FirebaseFirestore.instance.collection('orders').doc(_ordenActual.id).update({
        'status': nuevoEstado,
      });

      if (mounted) {
        setState(() {
          _actualizando = false;
        });

        // Si se marca como entregado, volvemos a la lista
        if (nuevoEstado == 'Entregado') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Pedido entregado con éxito! Volviendo al panel.'),
              backgroundColor: Color(0xFF00A650),
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _actualizando = false;
        });
      }
      _mostrarError('Error al actualizar: $e');
    }
  }

  void _mostrarError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _ordenActual.status;

    // Determinar qué botón mostrar según el estado actual
    Widget actionButton;
    if (status == 'Aceptado por repartidor') {
      actionButton = ElevatedButton.icon(
        onPressed: _actualizando ? null : () => _actualizarEstado('En camino'),
        icon: const Icon(Icons.directions_bike),
        label: const Text('Iniciar Viaje (En camino)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3483FA),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (status == 'En camino') {
      actionButton = ElevatedButton.icon(
        onPressed: _actualizando ? null : () => _actualizarEstado('Entregado'),
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Marcar como Entregado'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A650),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else {
      actionButton = const Center(
        child: Text(
          'Entregado',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00A650)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B1C9E),
        foregroundColor: Colors.white,
        title: Text('Pedido ${_ordenActual.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Estado
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Estado del pedido: ', style: TextStyle(fontSize: 16)),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: status == 'Entregado'
                                ? const Color(0xFF00A650)
                                : status == 'En camino'
                                    ? const Color(0xFF3483FA)
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: status == 'Aceptado por repartidor'
                          ? 0.33
                          : status == 'En camino'
                              ? 0.66
                              : 1.0,
                      backgroundColor: Colors.grey[200],
                      color: status == 'Entregado'
                          ? const Color(0xFF00A650)
                          : const Color(0xFF3483FA),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Información del Envío', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_pin_circle_outlined, color: Colors.blue),
                      title: Text('Emmanuel - Calle Falsa 123'),
                      subtitle: Text('Querétaro, Qro. CP 76344'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.phone_iphone, color: Colors.blue),
                      title: Text('+52 442 987 6543'),
                      subtitle: Text('Contacto de cliente'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Detalle de Artículos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ..._ordenActual.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('${item.quantity}x ${item.title}', style: const TextStyle(fontSize: 14)),
                              ),
                              Text('\$${(item.price * item.quantity).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Text('Total cobrado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(
                          '\$${_ordenActual.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Acción del repartidor
            if (_actualizando)
              const Center(child: CircularProgressIndicator())
            else
              actionButton,
          ],
        ),
      ),
    );
  }
}
