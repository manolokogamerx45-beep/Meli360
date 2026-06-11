import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// --- CONFIGURACIÓN GLOBAL ---
class AppConfig {
  static String serverIp = '192.168.2.199'; // Por defecto tu IP local
  static String repartidorNombre = 'Repartidor de Prueba';

  static String get httpUrl => 'http://$serverIp:3000';
  static String get wsUrl => 'ws://$serverIp:3000';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool useFirebase = false;
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    await Firebase.initializeApp(options: options);
    useFirebase = true;
    print('[Firebase] Inicializado correctamente en Repartidor');
  } catch (e) {
    print('[Firebase Warning] No se pudo inicializar Firebase. Se usará el servidor local de respaldo: $e');
  }
  runApp(RepartidorApp(useFirebase: useFirebase));
}

class RepartidorApp extends StatelessWidget {
  final bool useFirebase;
  const RepartidorApp({super.key, required this.useFirebase});

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
      home: LoginScreen(useFirebase: useFirebase),
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
  final bool useFirebase;
  const LoginScreen({super.key, required this.useFirebase});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controladorNombre;
  late final TextEditingController _controladorIp;

  @override
  void initState() {
    super.initState();
    _controladorNombre = TextEditingController(text: AppConfig.repartidorNombre);
    _controladorIp = TextEditingController(text: AppConfig.serverIp);
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    _controladorIp.dispose();
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
                      Text(
                        widget.useFirebase 
                          ? 'Ingresa tu perfil de repartidor para conectarte a la nube de Firebase.'
                          : 'Conexión local: Ingresa tu nombre y la dirección IP de tu servidor local.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
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
                      if (!widget.useFirebase) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _controladorIp,
                          decoration: const InputDecoration(
                            labelText: 'IP del Servidor (PC)',
                            helperText: 'Ej: 192.168.1.75 o localhost',
                            prefixIcon: Icon(Icons.computer),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa la IP';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              AppConfig.repartidorNombre = _controladorNombre.text.trim();
                              if (!widget.useFirebase) {
                                AppConfig.serverIp = _controladorIp.text.trim();
                              }

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrdersListScreen(useFirebase: widget.useFirebase),
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
  final bool useFirebase;
  const OrdersListScreen({super.key, required this.useFirebase});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  List<Order> _ordenes = [];
  bool _cargando = true;
  String? _error;
  
  // Firebase
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  // Local Server
  WebSocketChannel? _wsChannel;

  @override
  void initState() {
    super.initState();
    if (widget.useFirebase) {
      _escucharFirestore();
    } else {
      _cargarOrdenesInicialesHttp();
      _conectarWebSocketLocal();
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  // Escucha de Firestore para sincronización en tiempo real
  void _escucharFirestore() {
    setState(() {
      _cargando = true;
      _error = null;
    });

    _firestoreSubscription = FirebaseFirestore.instance
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

  // Carga inicial por HTTP (Fallback local)
  Future<void> _cargarOrdenesInicialesHttp() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.httpUrl}/api/orders'));
      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);
        setState(() {
          _ordenes = decoded.map((o) => Order.fromJson(o)).toList();
          _cargando = false;
        });
      } else {
        setState(() {
          _error = 'Error de servidor local: ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión local: $e\n¿Está el servidor encendido en la IP correcta?';
        _cargando = false;
      });
    }
  }

  // Conexión WebSocket para sincronización local en tiempo real
  void _conectarWebSocketLocal() {
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
      _wsChannel!.stream.listen((message) {
        final payload = json.decode(message);
        final String type = payload['type'];
        final data = payload['data'];

        setState(() {
          if (type == 'init') {
            final List list = data;
            _ordenes = list.map((o) => Order.fromJson(o)).toList();
          } else if (type == 'new_order') {
            final nuevaOrden = Order.fromJson(data);
            if (!_ordenes.any((o) => o.id == nuevaOrden.id)) {
              _ordenes.insert(0, nuevaOrden);
            }
          } else if (type == 'order_updated') {
            final ordenActualizada = Order.fromJson(data);
            final index = _ordenes.indexWhere((o) => o.id == ordenActualizada.id);
            if (index != -1) {
              _ordenes[index] = ordenActualizada;
            } else {
              _ordenes.add(ordenActualizada);
            }
          }
        });
      }, onError: (err) {
        print('[WS Fallback Error] $err');
      });
    } catch (e) {
      print('[WS Connect Fallback Error] $e');
    }
  }

  // Actualiza aceptación del pedido
  Future<void> _aceptarPedido(Order orden) async {
    if (widget.useFirebase) {
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
              builder: (context) => ActiveDeliveryScreen(orden: actual, useFirebase: true),
            ),
          );
        }
      } catch (e) {
        _mostrarAlerta('Error', 'No se pudo aceptar el pedido en Firebase: $e');
      }
    } else {
      // Local HTTP PATCH
      try {
        final response = await http.patch(
          Uri.parse('${AppConfig.httpUrl}/api/orders/${orden.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'status': 'Aceptado por repartidor',
            'repartidor': AppConfig.repartidorNombre,
          }),
        );

        if (response.statusCode == 200) {
          final actual = Order.fromJson(json.decode(response.body));
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActiveDeliveryScreen(orden: actual, useFirebase: false),
              ),
            );
          }
        } else {
          _mostrarAlerta('Error', 'No se pudo aceptar el pedido en servidor local: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarAlerta('Error de red', 'Error al comunicar con el servidor local: $e');
      }
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
            Text(
              widget.useFirebase 
                ? 'Nube Firebase | Repartidor: ${AppConfig.repartidorNombre}' 
                : 'Servidor Local | Repartidor: ${AppConfig.repartidorNombre}', 
              style: const TextStyle(fontSize: 11, color: Colors.white70)
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (widget.useFirebase) {
                _escucharFirestore();
              } else {
                setState(() {
                  _cargando = true;
                  _error = null;
                });
                _cargarOrdenesInicialesHttp();
              }
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
                            Navigator.pushReplacement(
                              context, 
                              MaterialPageRoute(builder: (context) => LoginScreen(useFirebase: widget.useFirebase))
                            );
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
  final bool useFirebase;

  const ActiveDeliveryScreen({super.key, required this.orden, required this.useFirebase});

  @override
  State<ActiveDeliveryScreen> createState() => _ActiveDeliveryScreenState();
}

class _ActiveDeliveryScreenState extends State<ActiveDeliveryScreen> {
  late Order _ordenActual;
  bool _actualizando = false;
  
  // Firebase
  StreamSubscription<DocumentSnapshot>? _firestoreSubscription;

  // Local WS
  WebSocketChannel? _wsChannel;

  @override
  void initState() {
    super.initState();
    _ordenActual = widget.orden;
    if (widget.useFirebase) {
      _escucharFirestore();
    } else {
      _conectarWebSocketLocal();
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _wsChannel?.sink.close();
    super.dispose();
  }

  void _escucharFirestore() {
    _firestoreSubscription = FirebaseFirestore.instance
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
    });
  }

  void _conectarWebSocketLocal() {
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
      _wsChannel!.stream.listen((message) {
        final payload = json.decode(message);
        final String type = payload['type'];
        final data = payload['data'];

        if (type == 'order_updated') {
          final ordenActualizada = Order.fromJson(data);
          if (ordenActualizada.id == _ordenActual.id) {
            setState(() {
              _ordenActual = ordenActualizada;
            });
          }
        }
      });
    } catch (e) {
      print('[WS Active Fallback Error] $e');
    }
  }

  Future<void> _actualizarEstado(String nuevoEstado) async {
    setState(() {
      _actualizando = true;
    });

    if (widget.useFirebase) {
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
        _mostrarError('Error al actualizar en Firebase: $e');
      }
    } else {
      // Local Server Update
      try {
        final response = await http.patch(
          Uri.parse('${AppConfig.httpUrl}/api/orders/${_ordenActual.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'status': nuevoEstado,
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            setState(() {
              _ordenActual = Order.fromJson(json.decode(response.body));
              _actualizando = false;
            });
          }

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
        } else {
          if (mounted) {
            setState(() {
              _actualizando = false;
            });
          }
          _mostrarError('Error al actualizar estado local: ${response.statusCode}');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _actualizando = false;
          });
        }
        _mostrarError('Error de conexión local: $e');
      }
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
