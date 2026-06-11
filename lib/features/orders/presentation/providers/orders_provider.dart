import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../../firebase_options.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/data/models/product_model.dart';

part 'orders_provider.g.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String fecha;
  final String status;
  final String? repartidor;
  final int? timestamp;
  final String? keyword; // Palabra clave/PIN de entrega

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.fecha,
    required this.status,
    this.repartidor,
    this.timestamp,
    this.keyword,
  });
}

@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;
  WebSocketChannel? _wsChannel;
  final _dio = Dio();
  bool _useFirebase = false;
  bool _isDisposed = false;

  @override
  List<OrderModel> build() {
    _isDisposed = false;
    // Verificar si Firebase está configurado
    try {
      DefaultFirebaseOptions.currentPlatform;
      _useFirebase = true;
    } catch (_) {
      _useFirebase = false;
    }

    if (_useFirebase) {
      _escucharFirestore();
    } else {
      _cargarOrdenesHttp();
      _conectarWebSocketLocal();
    }

    ref.onDispose(() {
      _isDisposed = true;
      _firestoreSubscription?.cancel();
      _wsChannel?.sink.close();
    });

    return [];
  }

  // --- MODO FIREBASE ---
  void _escucharFirestore() {
    _firestoreSubscription = FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      if (_isDisposed) return;
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Pasar doc.id para que el OrderModel tenga siempre su ID correcto
        return _parseOrder(data, docId: doc.id);
      }).toList();

      // Ordenar localmente por timestamp descendente
      orders.sort((a, b) {
        final aTime = a.timestamp ?? 0;
        final bTime = b.timestamp ?? 0;
        return bTime.compareTo(aTime);
      });

      state = orders;
    }, onError: (error) {
      print('[OrdersNotifier Firestore Error] $error');
    });
  }

  // --- MODO LOCAL FALLBACK (HTTP + WS) ---
  Future<void> _cargarOrdenesHttp() async {
    try {
      final response = await _dio.get('http://192.168.2.199:3000/api/orders');
      if (response.statusCode == 200 && !_isDisposed) {
        final List data = response.data;
        state = data.map((json) => _parseOrder(json)).toList();
      }
    } catch (e) {
      print('[OrdersNotifier HTTP Fallback Error] $e');
    }
  }

  void _conectarWebSocketLocal() {
    if (_isDisposed) return;
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse('ws://192.168.2.199:3000'));
      _wsChannel!.stream.listen((message) {
        if (_isDisposed) return;
        final payload = jsonDecode(message);
        final String type = payload['type'];
        final data = payload['data'];

        if (type == 'init') {
          final List list = data;
          state = list.map((json) => _parseOrder(json)).toList();
        } else if (type == 'new_order') {
          final nuevaOrden = _parseOrder(data);
          if (!state.any((o) => o.id == nuevaOrden.id)) {
            state = [nuevaOrden, ...state];
          }
        } else if (type == 'order_updated') {
          final ordenActualizada = _parseOrder(data);
          state = state.map((o) {
            if (o.id == ordenActualizada.id) {
              return ordenActualizada;
            }
            return o;
          }).toList();
        }
      }, onError: (err) {
        print('[OrdersNotifier WS Fallback Error] $err. Reconectando...');
        _reconectarWebSocket();
      }, onDone: () {
        print('[OrdersNotifier WS Fallback Done] Conexión cerrada. Reconectando...');
        _reconectarWebSocket();
      });
    } catch (e) {
      print('[OrdersNotifier WS Fallback Connect Error] $e. Reconectando...');
      _reconectarWebSocket();
    }
  }

  void _reconectarWebSocket() {
    if (_isDisposed) return;
    Future.delayed(const Duration(seconds: 5), () {
      _conectarWebSocketLocal();
    });
  }

  OrderModel _parseOrder(Map<String, dynamic> json, {String? docId}) {
    final itemsList = json['items'] as List? ?? [];
    final items = itemsList.map((i) {
      final productData = i['product'] as Map<String, dynamic>? ?? {};
      final shippingData = productData['shipping'] as Map<String, dynamic>? ?? {};
      return CartItem(
        product: Product(
          id: productData['id'] as String? ?? '',
          title: productData['title'] as String? ?? '',
          price: (productData['price'] as num? ?? 0).toDouble(),
          originalPrice: productData['original_price'] != null 
              ? (productData['original_price'] as num).toDouble() 
              : null,
          thumbnail: productData['thumbnail'] as String? ?? '',
          shipping: ShippingModel(
            freeShipping: shippingData['free_shipping'] as bool? ?? false
          ),
          category: productData['category'] as String?,
        ),
        quantity: i['quantity'] as int? ?? 1,
      );
    }).toList();

    // Normalizar repartidor: campo ausente o string vacío = null (no asignado)
    final repartidorRaw = json['repartidor'] as String?;
    final repartidor = (repartidorRaw == null || repartidorRaw.trim().isEmpty) ? null : repartidorRaw;

    return OrderModel(
      id: docId ?? json['id'] as String? ?? '',
      items: items,
      total: (json['total'] as num? ?? 0).toDouble(),
      fecha: json['fecha'] as String? ?? '',
      status: json['status'] as String? ?? 'Preparando envío',
      repartidor: repartidor,
      timestamp: json['timestamp'] as int?,
      keyword: json['keyword'] as String?,
    );
  }

  String crearPedido(List<CartItem> items, double total) {
    final now = DateTime.now();
    final fechaFormateada = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final orderId = "PED-${now.millisecondsSinceEpoch.toString().substring(7)}";
    final timestamp = now.millisecondsSinceEpoch;
    
    // Generar palabra clave de 4 dígitos
    final random = Random();
    final keyword = (1000 + random.nextInt(9000)).toString();
    
    // Serializar a JSON para subir
    final payloadItems = items.map((i) => {
      'quantity': i.quantity,
      'product': {
        'id': i.product.id,
        'title': i.product.title,
        'price': i.product.price,
        'original_price': i.product.originalPrice,
        'thumbnail': i.product.thumbnail,
        'shipping': {
          'free_shipping': i.product.shipping.freeShipping,
        },
        'category': i.product.category,
      }
    }).toList();

    final orderData = {
      'id': orderId,
      'items': payloadItems,
      'total': total,
      'fecha': fechaFormateada,
      'status': "Preparando envío",
      'repartidor': null,
      'timestamp': timestamp,
      'keyword': keyword,
    };

    if (_useFirebase) {
      // Subir a Firestore
      FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .set(orderData)
          .catchError((e) {
        print('[OrdersNotifier Firestore Error] No se pudo crear el pedido: $e');
      });
    } else {
      // Crear objeto local optimista
      final nuevoPedido = OrderModel(
        id: orderId,
        items: List<CartItem>.from(items),
        total: total,
        fecha: fechaFormateada,
        status: "Preparando envío",
        repartidor: null,
        timestamp: timestamp,
        keyword: keyword,
      );
      state = [nuevoPedido, ...state];
      // Subir al servidor local HTTP
      _enviarAlServidorHttp(orderData);
    }

    return orderId;
  }

  Future<void> _enviarAlServidorHttp(Map<String, dynamic> data) async {
    try {
      await _dio.post('http://192.168.2.199:3000/api/orders', data: data);
    } catch (e) {
      print('[OrdersNotifier Error] No se pudo sincronizar pedido con el servidor local: $e');
    }
  }
}

