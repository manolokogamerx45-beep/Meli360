import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../home/data/models/product_model.dart';

part 'orders_provider.g.dart';

class OrderModel {
  final String id;
  final List<CartItem> items;
  final double total;
  final String fecha;
  final String status;

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.fecha,
    required this.status,
  });
}

@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  final _dio = Dio();
  WebSocketChannel? _channel;

  @override
  List<OrderModel> build() {
    // Carga inicial y escucha de WebSocket
    _cargarOrdenes();
    _conectarWebSocket();

    ref.onDispose(() {
      _channel?.sink.close();
    });

    return [];
  }

  // Cargar órdenes desde la API
  Future<void> _cargarOrdenes() async {
    try {
      final response = await _dio.get('http://192.168.2.199:3000/api/orders');
      if (response.statusCode == 200) {
        final List data = response.data;
        state = data.map((json) => _parseOrder(json)).toList();
      }
    } catch (e) {
      print('[OrdersNotifier HTTP Error] No se pudieron cargar las órdenes: $e');
    }
  }

  // Escuchar WebSocket en tiempo real
  void _conectarWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://192.168.2.199:3000'));
      _channel!.stream.listen((message) {
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
        print('[OrdersNotifier WS Error] $err');
      }, onDone: () {
        print('[OrdersNotifier WS Done] Conexión cerrada');
      });
    } catch (e) {
      print('[OrdersNotifier WS Connect Error] $e');
    }
  }

  OrderModel _parseOrder(Map<String, dynamic> json) {
    final itemsList = json['items'] as List;
    final items = itemsList.map((i) {
      return CartItem(
        product: Product(
          id: i['product']['id'] as String,
          title: i['product']['title'] as String,
          price: (i['product']['price'] as num).toDouble(),
          originalPrice: i['product']['original_price'] != null 
              ? (i['product']['original_price'] as num).toDouble() 
              : null,
          thumbnail: i['product']['thumbnail'] as String,
          shipping: ShippingModel(
            freeShipping: i['product']['shipping']['free_shipping'] as bool? ?? false
          ),
          category: i['product']['category'] as String?,
        ),
        quantity: i['quantity'] as int,
      );
    }).toList();

    return OrderModel(
      id: json['id'] as String,
      items: items,
      total: (json['total'] as num).toDouble(),
      fecha: json['fecha'] as String,
      status: json['status'] as String,
    );
  }

  String crearPedido(List<CartItem> items, double total) {
    final now = DateTime.now();
    final fechaFormateada = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final orderId = "PED-${now.millisecondsSinceEpoch.toString().substring(7)}";
    
    // Crear objeto local optimista
    final nuevoPedido = OrderModel(
      id: orderId,
      items: List<CartItem>.from(items),
      total: total,
      fecha: fechaFormateada,
      status: "Preparando envío",
    );
    state = [nuevoPedido, ...state];

    // Serializar a JSON para subir al backend
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
      'status': "Preparando envío"
    };

    // Subir al backend en segundo plano
    _enviarAlServidor(orderData);

    return orderId;
  }

  Future<void> _enviarAlServidor(Map<String, dynamic> data) async {
    try {
      await _dio.post('http://192.168.2.199:3000/api/orders', data: data);
    } catch (e) {
      print('[OrdersNotifier Error] No se pudo sincronizar pedido con el servidor: $e');
    }
  }
}
