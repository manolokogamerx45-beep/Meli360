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
  static String serverIp = '127.0.0.1'; // Por defecto tu IP local (usando adb reverse)
  static String repartidorNombre = 'Juan El Repartidor';

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
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
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
  final String? keyword; // Palabra clave o PIN de entrega

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.fecha,
    required this.status,
    this.repartidor,
    this.timestamp,
    this.keyword,
  });

  factory Order.fromJson(Map<String, dynamic> json, {String? docId}) {
    var itemsList = json['items'] as List? ?? [];
    List<OrderItem> parsedItems = itemsList.map((i) => OrderItem.fromJson(i)).toList();

    // Normalizar repartidor: string vacío se trata como null (no asignado)
    final repartidorRaw = json['repartidor'] as String?;
    final repartidor = (repartidorRaw == null || repartidorRaw.trim().isEmpty) ? null : repartidorRaw;

    return Order(
      id: docId ?? json['id'] as String? ?? '',
      items: parsedItems,
      total: (json['total'] as num? ?? 0).toDouble(),
      fecha: json['fecha'] as String? ?? '',
      status: json['status'] as String? ?? '',
      repartidor: repartidor,
      timestamp: json['timestamp'] as int?,
      keyword: json['keyword'] as String?,
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
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3B1078), Color(0xFF2862F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isTablet ? 480 : double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 12,
                shadowColor: Colors.black.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B1C9E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.delivery_dining_rounded, size: 80, color: Color(0xFF4B1C9E)),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Repartidor Meli360',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.useFirebase 
                            ? 'Conectado a la nube de Firebase' 
                            : 'Conectando vía servidor de desarrollo local',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: widget.useFirebase ? const Color(0xFF00A650) : Colors.amber[800],
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                        TextFormField(
                          controller: _controladorNombre,
                          decoration: InputDecoration(
                            labelText: 'Nombre del Repartidor',
                            prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF4B1C9E)),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF4B1C9E), width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Por favor ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        if (!widget.useFirebase) ...[
                          const SizedBox(height: 18),
                          TextFormField(
                            controller: _controladorIp,
                            decoration: InputDecoration(
                              labelText: 'IP del Servidor (PC)',
                              helperText: 'Ej: 192.168.2.199 o localhost',
                              prefixIcon: const Icon(Icons.computer_rounded, color: Color(0xFF4B1C9E)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF4B1C9E), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                  return 'Por favor ingresa la IP';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
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
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
  
  // Selección en tablet
  Order? _selectedOrder;
  final TextEditingController _pinController = TextEditingController();
  bool _isDisposed = false;

  // Firebase
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  // Local Server
  WebSocketChannel? _wsChannel;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    if (widget.useFirebase) {
      _escucharFirestore();
    } else {
      _cargarOrdenesInicialesHttp();
      _conectarWebSocketLocal();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _firestoreSubscription?.cancel();
    _wsChannel?.sink.close();
    _pinController.dispose();
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
      if (_isDisposed) return;
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        // Pasamos doc.id para que el Order tenga siempre su ID correcto
        return Order.fromJson(data, docId: doc.id);
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
          // Actualizar objeto seleccionado si cambió en Firestore
          if (_selectedOrder != null) {
            final match = list.where((o) => o.id == _selectedOrder!.id);
            _selectedOrder = match.isNotEmpty ? match.first : null;
          }
        });
      }
    }, onError: (err) {
      if (mounted && !_isDisposed) {
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
      if (response.statusCode == 200 && !_isDisposed) {
        final List decoded = json.decode(response.body);
        setState(() {
          _ordenes = decoded.map((o) => Order.fromJson(o)).toList();
          _cargando = false;
        });
      } else if (!_isDisposed) {
        setState(() {
          _error = 'Error de servidor local: ${response.statusCode}';
          _cargando = false;
        });
      }
    } catch (e) {
      if (!_isDisposed) {
        setState(() {
          _error = 'Error de conexión local: $e\n¿Está el servidor encendido en la IP correcta?';
          _cargando = false;
        });
      }
    }
  }

  // Conexión WebSocket para sincronización local en tiempo real con auto-reconexión
  void _conectarWebSocketLocal() {
    if (_isDisposed) return;
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(AppConfig.wsUrl));
      _wsChannel!.stream.listen((message) {
        if (_isDisposed) return;
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
            if (_selectedOrder != null && _selectedOrder!.id == ordenActualizada.id) {
              _selectedOrder = ordenActualizada;
            }
          }
        });
      }, onError: (err) {
        print('[WS Fallback Error] $err. Reconectando...');
        _reconectarWebSocket();
      }, onDone: () {
        print('[WS Connect Fallback Done]. Reconectando...');
        _reconectarWebSocket();
      });
    } catch (e) {
      print('[WS Connect Fallback Connect Error] $e. Reconectando...');
      _reconectarWebSocket();
    }
  }

  void _reconectarWebSocket() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 5), () {
      if (widget.useFirebase) return;
      _conectarWebSocketLocal();
    });
  }

  // Actualiza aceptación del pedido
  Future<void> _aceptarPedido(Order orden) async {
    if (widget.useFirebase) {
      try {
        await FirebaseFirestore.instance.collection('orders').doc(orden.id).update({
          'status': 'Aceptado por repartidor',
          'repartidor': AppConfig.repartidorNombre,
        });
        setState(() {
          final actual = Order(
            id: orden.id,
            items: orden.items,
            total: orden.total,
            fecha: orden.fecha,
            status: 'Aceptado por repartidor',
            repartidor: AppConfig.repartidorNombre,
            timestamp: orden.timestamp,
            keyword: orden.keyword,
          );
          _selectedOrder = actual;
        });
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
          setState(() {
            _selectedOrder = actual;
          });
        } else {
          _mostrarAlerta('Error', 'No se pudo aceptar el pedido: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarAlerta('Error de red', 'Error al comunicar con el servidor local: $e');
      }
    }
  }

  Future<void> _actualizarEstado(Order orden, String nuevoEstado) async {
    // Si se va a marcar como entregado, validar el PIN de seguridad
    if (nuevoEstado == 'Entregado') {
      if (_pinController.text.trim().isEmpty) {
        _mostrarAlerta('PIN Requerido', 'Debes ingresar la palabra clave obligatoriamente para entregar el paquete.');
        return;
      }
      if (orden.keyword != null && _pinController.text.trim() != orden.keyword!.trim()) {
        _mostrarAlerta('PIN de Seguridad Incorrecto', 'El código de seguridad ingresado es incorrecto. Por favor, pídeselo al cliente Emmanuel.');
        return;
      }
    }

    if (widget.useFirebase) {
      try {
        await FirebaseFirestore.instance.collection('orders').doc(orden.id).update({
          'status': nuevoEstado,
        });
        _pinController.clear();
        if (nuevoEstado == 'Entregado') {
          _mostrarSuccessDialog(orden);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Estado actualizado a: $nuevoEstado'),
              backgroundColor: const Color(0xFF00A650),
            ),
          );
        }
      } catch (e) {
        _mostrarAlerta('Error', 'No se pudo actualizar el estado: $e');
      }
    } else {
      try {
        final response = await http.patch(
          Uri.parse('${AppConfig.httpUrl}/api/orders/${orden.id}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'status': nuevoEstado,
          }),
        );

        if (response.statusCode == 200) {
          _pinController.clear();
          if (nuevoEstado == 'Entregado') {
            _mostrarSuccessDialog(orden);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Estado actualizado a: $nuevoEstado'),
                backgroundColor: const Color(0xFF00A650),
              ),
            );
          }
        } else {
          _mostrarAlerta('Error', 'No se pudo actualizar estado local: ${response.statusCode}');
        }
      } catch (e) {
        _mostrarAlerta('Error de red', 'Error al comunicar con el servidor local: $e');
      }
    }
  }

  void _mostrarSuccessDialog(Order orden) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeliverySuccessDialog(
        order: orden,
        onDismiss: () {
          setState(() {
            _selectedOrder = null;
          });
        },
      ),
    );
  }

  void _mostrarAlerta(String titulo, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(msg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF4B1C9E)))
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    // Clasificar órdenes
    final disponibles = _ordenes.where((o) => o.repartidor == null).toList();
    final misEntregas = _ordenes.where((o) => o.repartidor == AppConfig.repartidorNombre && o.status != 'Entregado').toList();
    final entregados = _ordenes.where((o) => o.repartidor == AppConfig.repartidorNombre && o.status == 'Entregado').toList();

    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B1C9E),
          foregroundColor: Colors.white,
          elevation: 4,
          title: Row(
            children: [
              const Icon(Icons.tablet_android_rounded),
              const SizedBox(width: 12),
              const Text('Meli360 Repartos - Edición Tablet', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('Repartidor: ${AppConfig.repartidorNombre}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
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
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Row(
                children: [
                  // PANEL IZQUIERDO: Listado
                  Container(
                    width: 380,
                    color: Colors.white,
                    child: Column(
                      children: [
                        // Cabecera perfil
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFF4B1C9E).withOpacity(0.05),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF4B1C9E),
                                foregroundColor: Colors.white,
                                child: Text(AppConfig.repartidorNombre.substring(0, 1).toUpperCase()),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppConfig.repartidorNombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Text('Conductor Autorizado', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Listado en Tablet con 3 pestañas
                        Expanded(
                          child: DefaultTabController(
                            length: 3,
                            child: Column(
                              children: [
                                const TabBar(
                                  labelColor: Color(0xFF4B1C9E),
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Color(0xFF4B1C9E),
                                  indicatorWeight: 3,
                                  labelPadding: EdgeInsets.symmetric(horizontal: 4),
                                  tabs: [
                                    Tab(text: 'Disponibles', icon: Icon(Icons.all_inbox_rounded, size: 20)),
                                    Tab(text: 'En Curso', icon: Icon(Icons.directions_bike_rounded, size: 20)),
                                    Tab(text: 'Entregados', icon: Icon(Icons.check_circle_rounded, size: 20)),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _buildSidebarList(disponibles, 'No hay pedidos disponibles.'),
                                      _buildSidebarList(misEntregas, 'No tienes entregas en curso.'),
                                      _buildSidebarList(entregados, 'Aún no has completado entregas.'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xFFE5E5E5)),
                  // PANEL DERECHO: Detalles
                  Expanded(
                    child: _buildDetailsPane(),
                  ),
                ],
              ),
      );
    }

    // DISEÑO CELULAR CON TABBAR DE 3 PESTAÑAS
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF4B1C9E),
          foregroundColor: Colors.white,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Repartos Meli360', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(
                'Repartidor: ${AppConfig.repartidorNombre}', 
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
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Disponibles', icon: Icon(Icons.all_inbox_rounded)),
              Tab(text: 'En Curso', icon: Icon(Icons.directions_bike_rounded)),
              Tab(text: 'Entregados', icon: Icon(Icons.check_circle_rounded)),
            ],
          ),
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
                : TabBarView(
                    children: [
                      _buildCelularList(disponibles, 'No hay pedidos disponibles por ahora.', true),
                      _buildCelularList(misEntregas, 'No tienes entregas en curso.', false),
                      _buildCelularList(entregados, 'No has entregado ningún paquete todavía.', false),
                    ],
                  ),
      ),
    );
  }

  void _aceptarPedidoCelular(Order orden) async {
    await _aceptarPedido(orden);
    if (mounted && _selectedOrder != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActiveDeliveryScreen(
            orden: _selectedOrder!, 
            useFirebase: widget.useFirebase,
          ),
        ),
      );
    }
  }

  Widget _buildCelularList(List<Order> list, String emptyMessage, bool mostrarBotonAceptar) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final orden = list[index];
        final Color statusColor = orden.status.contains('Entregado')
            ? const Color(0xFF00A650)
            : orden.status.contains('camino')
                ? const Color(0xFF3483FA)
                : Colors.orange;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
            border: Border.all(color: const Color(0xFFEBEFF5), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () {
                if (orden.repartidor != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ActiveDeliveryScreen(
                        orden: orden, 
                        useFirebase: widget.useFirebase,
                      ),
                    ),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE81F).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFFFE81F), width: 1),
                          ),
                          child: Text(
                            orden.id,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8A6D3B)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            orden.status,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${orden.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text(
                          'Destinatario: ',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                        const Text(
                          'Emmanuel (Calle Falsa 123)',
                          style: TextStyle(fontSize: 13, color: Color(0xFF1F1F1F), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text(
                          'Artículos del pedido:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 22.0, top: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: orden.items.map((item) => Text(
                          '${item.quantity}x ${item.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFEBEFF5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          orden.fecha, 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        if (mostrarBotonAceptar)
                          SizedBox(
                            height: 36,
                            child: ElevatedButton.icon(
                              onPressed: () => _aceptarPedidoCelular(orden),
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Aceptar Pedido'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00A650),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSidebarList(List<Order> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_rounded, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final order = list[index];
        final isSelected = _selectedOrder != null && _selectedOrder!.id == order.id;
        final Color statusColor = order.status.contains('Entregado')
            ? const Color(0xFF00A650)
            : order.status.contains('camino')
                ? const Color(0xFF3483FA)
                : Colors.orange;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4B1C9E).withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              if (!isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
            ],
            border: Border.all(
              color: isSelected ? const Color(0xFF4B1C9E) : const Color(0xFFEBEFF5),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Row(
              children: [
                if (isSelected)
                  Container(
                    width: 4.5,
                    height: 82,
                    color: const Color(0xFF4B1C9E),
                  ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedOrder = order;
                        _pinController.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F1F1F)),
                              ),
                              const Spacer(),
                              Text(
                                '\$${order.total.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F1F1F)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${order.items.length} artículo(s) • ${order.fecha}',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  order.status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (isSelected && !order.status.contains('Entregado'))
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF4B1C9E)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailsPane() {
    if (_selectedOrder == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4B1C9E).withOpacity(0.04),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_bike_rounded, size: 100, color: const Color(0xFF4B1C9E).withOpacity(0.2)),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay pedido seleccionado',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 6),
            const Text(
              'Selecciona un pedido de la lista para ver su información y gestionar la entrega.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final order = _selectedOrder!;
    final status = order.status;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Identificación del Pedido
          Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE81F),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.id,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2C2500)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Detalles de Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(
                        'Total: \$${order.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Glowing timeline progress
                  _buildStepperTimeline(status),
                  const SizedBox(height: 20),
                  SimulatedRouteMap(status: status),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna izquierda de detalles
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Dirección y Cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                              leading: Icon(Icons.person_pin_circle_rounded, color: Color(0xFF3483FA)),
                              title: Text('Emmanuel - Calle Falsa 123', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Querétaro, Qro. CP 76344'),
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.phone_iphone_rounded, color: Color(0xFF3483FA)),
                              title: Text('+52 442 987 6543'),
                              subtitle: Text('Contacto de cliente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Artículos del Pedido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${item.quantity}x  ${item.title}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Text(
                                  '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // Columna derecha de acciones
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Acción de Despacho', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gestionar Estado:',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            _buildActionButtonPanel(order, status),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepperTimeline(String status) {
    int activeIndex = 0;
    if (status.contains('Aceptado')) activeIndex = 1;
    if (status.contains('camino')) activeIndex = 2;
    if (status.contains('Entregado')) activeIndex = 3;

    final steps = ['Preparando', 'Aceptado', 'En camino', 'Entregado'];
    final icons = [Icons.storefront_rounded, Icons.assignment_turned_in_rounded, Icons.directions_bike_rounded, Icons.check_circle_rounded];

    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= activeIndex;
        final color = isActive 
            ? (index == 3 ? const Color(0xFF00A650) : const Color(0xFF4B1C9E)) 
            : Colors.grey[300]!;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(icons[index], color: color, size: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 3)
                Container(
                  width: 30,
                  height: 3,
                  color: index < activeIndex 
                      ? const Color(0xFF4B1C9E) 
                      : Colors.grey[200],
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildActionButtonPanel(Order order, String status) {
    if (order.repartidor == null) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _aceptarPedido(order),
          icon: const Icon(Icons.check),
          label: const Text('Aceptar Pedido'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A650),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }

    if (status == 'Aceptado por repartidor') {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () => _actualizarEstado(order, 'En camino'),
          icon: const Icon(Icons.directions_bike_rounded),
          label: const Text('Iniciar Viaje (En camino)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3483FA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    }

    if (status == 'En camino') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD966), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'CONFIRMACIÓN DE SEGURIDAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A6D3B),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Solicita la palabra clave de 4 dígitos al cliente para autorizar y finalizar la entrega.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9E7A2F), height: 1.3),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.0,
                color: Color(0xFFD67C00),
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                hintStyle: TextStyle(color: Colors.orange.withOpacity(0.3), letterSpacing: 8.0),
                fillColor: Colors.white.withOpacity(0.9),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD966)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _actualizarEstado(order, 'Entregado'),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Completar Entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A650),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        children: [
          Icon(Icons.check_circle_rounded, size: 48, color: Color(0xFF00A650)),
          SizedBox(height: 8),
          Text(
            'Entregado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF00A650)),
          ),
        ],
      ),
    );
  }
}

// --- PANTALLA 3: PEDIDO ACTIVO / CONTROL DE ENTREGA EN CELULAR ---
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
  final TextEditingController _pinController = TextEditingController();
  
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
    _pinController.dispose();
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
    // Si se va a marcar como entregado, validar el PIN de seguridad
    if (nuevoEstado == 'Entregado') {
      if (_pinController.text.trim().isEmpty) {
        _mostrarErrorDialog('PIN Requerido', 'Debes ingresar la palabra clave obligatoriamente para entregar el paquete.');
        return;
      }
      if (_ordenActual.keyword != null && _pinController.text.trim() != _ordenActual.keyword!.trim()) {
        _mostrarErrorDialog('PIN de Seguridad Incorrecto', 'El código de seguridad ingresado es incorrecto. Por favor, pídeselo al cliente Emmanuel.');
        return;
      }
    }

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

          if (nuevoEstado == 'Entregado') {
            _mostrarSuccessDialog(_ordenActual);
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
          final updated = Order.fromJson(json.decode(response.body));
          if (mounted) {
            setState(() {
              _ordenActual = updated;
              _actualizando = false;
            });
          }

          if (nuevoEstado == 'Entregado') {
            _mostrarSuccessDialog(updated);
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

  void _mostrarErrorDialog(String titulo, String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(msg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, color: const Color(0xFF4B1C9E)))
          ),
        ],
      ),
    );
  }

  void _mostrarSuccessDialog(Order orden) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DeliverySuccessDialog(
        order: orden,
        onDismiss: () {
          Navigator.pop(context); // Close ActiveDeliveryScreen
        },
      ),
    );
  }

  Widget _buildStepperTimeline(String status) {
    int activeIndex = 0;
    if (status.contains('Aceptado')) activeIndex = 1;
    if (status.contains('camino')) activeIndex = 2;
    if (status.contains('Entregado')) activeIndex = 3;

    final steps = ['Preparando', 'Aceptado', 'En camino', 'Entregado'];
    final icons = [Icons.storefront_rounded, Icons.assignment_turned_in_rounded, Icons.directions_bike_rounded, Icons.check_circle_rounded];

    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= activeIndex;
        final color = isActive 
            ? (index == 3 ? const Color(0xFF00A650) : const Color(0xFF4B1C9E)) 
            : Colors.grey[300]!;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: Icon(icons[index], color: color, size: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 3)
                Container(
                  width: 30,
                  height: 3,
                  color: index < activeIndex 
                      ? const Color(0xFF4B1C9E) 
                      : Colors.grey[200],
                ),
            ],
          ),
        );
      }),
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
      actionButton = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9E6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD966), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Text(
                  'CONFIRMACIÓN DE SEGURIDAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8A6D3B),
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Solicita la palabra clave de 4 dígitos al cliente para autorizar y finalizar la entrega.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9E7A2F), height: 1.3),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.0,
                color: Color(0xFFD67C00),
              ),
              decoration: InputDecoration(
                counterText: '',
                hintText: '••••',
                hintStyle: TextStyle(color: Colors.orange.withOpacity(0.3), letterSpacing: 8.0),
                fillColor: Colors.white.withOpacity(0.9),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFFFD966)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _actualizando ? null : () => _actualizarEstado('Entregado'),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('Completar Entrega'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A650),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 2,
                ),
              ),
            ),
          ],
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
                    _buildStepperTimeline(status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SimulatedRouteMap(status: status),
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

// --- CLASES Y COMPONENTES DE MAPA SIMULADO Y PANTALLA DE ÉXITO ---

class SimulatedRouteMap extends StatefulWidget {
  final String status;
  const SimulatedRouteMap({super.key, required this.status});

  @override
  State<SimulatedRouteMap> createState() => _SimulatedRouteMapState();
}

class _SimulatedRouteMapState extends State<SimulatedRouteMap> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = 0.15;
    String distanceText = '1.8 km';
    String timeText = 'Preparando salida';
    
    if (widget.status.contains('Aceptado')) {
      progress = 0.15;
      distanceText = '1.8 km';
      timeText = 'Preparando salida';
    } else if (widget.status.contains('camino')) {
      progress = 0.55;
      distanceText = '0.8 km';
      timeText = '3 mins aprox.';
    } else if (widget.status.contains('Entregado')) {
      progress = 1.0;
      distanceText = '0 km';
      timeText = 'Entregado';
    }

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF12121A), // Tech dark color
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4B1C9E).withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Grid background pattern
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: TechGridPainter(
                    animationValue: widget.status.contains('camino') ? _animationController.value : 0.0,
                  ),
                );
              },
            ),
          ),
          // Route and markers
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double currentProgress = progress;
                if (widget.status.contains('camino')) {
                  currentProgress = 0.35 + (_animationController.value * 0.3); // moves back/forth
                }
                return CustomPaint(
                  painter: RoutePainter(
                    progress: currentProgress,
                    status: widget.status,
                    pulseValue: _animationController.value,
                  ),
                );
              },
            ),
          ),
          // HUD overlay
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12, width: 0.8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.status.contains('Entregado')
                          ? const Color(0xFF00A650)
                          : widget.status.contains('camino')
                              ? const Color(0xFF3483FA)
                              : Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.status.contains('Entregado')
                              ? const Color(0xFF00A650)
                              : widget.status.contains('camino')
                                  ? const Color(0xFF3483FA)
                                  : Colors.amber).withOpacity(0.6),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.status.contains('Entregado') 
                      ? 'Entrega finalizada' 
                      : widget.status.contains('camino') 
                        ? 'Ruta activa en tiempo real' 
                        : 'Esperando salida',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '$distanceText • $timeText',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TechGridPainter extends CustomPainter {
  final double animationValue;
  TechGridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF232335).withOpacity(0.4)
      ..strokeWidth = 0.5;

    const double gridSpacing = 20.0;
    final double offset = (animationValue * gridSpacing) % gridSpacing;

    for (double x = offset; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = offset; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TechGridPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class RoutePainter extends CustomPainter {
  final double progress;
  final String status;
  final double pulseValue;

  RoutePainter({required this.progress, required this.status, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final startPoint = Offset(size.width * 0.15, size.height * 0.7);
    final controlPoint1 = Offset(size.width * 0.35, size.height * 0.2);
    final controlPoint2 = Offset(size.width * 0.65, size.height * 0.8);
    final endPoint = Offset(size.width * 0.85, size.height * 0.3);

    final path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, endPoint.dx, endPoint.dy);

    final roadPaint = Paint()
      ..color = const Color(0xFF323244)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, roadPaint);

    final innerRoadPaint = Paint()
      ..color = const Color(0xFF1E1E2A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, innerRoadPaint);

    final pathMetrics = path.computeMetrics();
    Path activePath = Path();
    Offset currentBikePos = startPoint;

    for (var metric in pathMetrics) {
      final double extractLength = metric.length * progress;
      activePath.addPath(metric.extractPath(0, extractLength), Offset.zero);
      final tangent = metric.getTangentForOffset(extractLength);
      if (tangent != null) {
        currentBikePos = tangent.position;
      }
    }

    final Color routeColor = status.contains('Entregado')
        ? const Color(0xFF00A650)
        : const Color(0xFF3483FA);

    final activePaint = Paint()
      ..color = routeColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(activePath, activePaint);

    final activeCorePaint = Paint()
      ..color = routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(activePath, activeCorePaint);

    // Start Node
    final startPaint = Paint()
      ..color = const Color(0xFFE3E3E3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPoint, 8, startPaint);
    final startInnerPaint = Paint()
      ..color = const Color(0xFF4B1C9E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(startPoint, 4, startInnerPaint);

    // End Node
    final endPulsePaint = Paint()
      ..color = const Color(0xFF00A650).withOpacity(0.2 * (1.0 - pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 12 + (16 * pulseValue), endPulsePaint);

    final endPaint = Paint()
      ..color = const Color(0xFF00A650)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 8, endPaint);
    final endInnerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(endPoint, 3, endInnerPaint);

    // Rider Node
    if (!status.contains('Entregado') || progress < 1.0) {
      final bikeGlowPaint = Paint()
        ..color = const Color(0xFF3483FA).withOpacity(0.3 * (1.0 - pulseValue))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentBikePos, 14 + (8 * pulseValue), bikeGlowPaint);

      final bikePaint = Paint()
        ..color = const Color(0xFF3483FA)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentBikePos, 8, bikePaint);

      final bikeCorePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentBikePos, 3, bikeCorePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.pulseValue != pulseValue;
  }
}

class DeliverySuccessDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onDismiss;

  const DeliverySuccessDialog({super.key, required this.order, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 20,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00A650), Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: -20,
                    top: -20,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Positioned(
                    right: -30,
                    bottom: -10,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 48,
                          color: Color(0xFF00A650),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '¡ENTREGA EXITOSA!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  const Text(
                    '¡Buen trabajo, Juan!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Has validado la entrega correctamente con el cliente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF4B1C9E),
                          label: 'Tiempo total',
                          value: '14 mins',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.star_rounded,
                          iconColor: Colors.amber,
                          label: 'Calificación',
                          value: '5.0 ★',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.monetization_on_outlined,
                          iconColor: const Color(0xFF00A650),
                          label: 'Ganancia extra',
                          value: r'+$45.00 MXN',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.offline_pin_rounded,
                          iconColor: const Color(0xFF3483FA),
                          label: 'ID Pedido',
                          value: order.id.length > 8 ? order.id.substring(0, 8) : order.id,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        onDismiss();            // Additional actions
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A650),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Listo, continuar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEBEFF5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1F1F1F)),
          ),
        ],
      ),
    );
  }
}
