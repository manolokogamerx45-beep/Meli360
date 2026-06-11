import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  const OrderModel({
    required this.id,
    required this.items,
    required this.total,
    required this.fecha,
    required this.status,
    this.repartidor,
    this.timestamp,
  });
}

@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  List<OrderModel> build() {
    _escucharFirestore();

    ref.onDispose(() {
      _subscription?.cancel();
    });

    return [];
  }

  // Escuchar Firestore en tiempo real
  void _escucharFirestore() {
    _subscription = FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .listen((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _parseOrder(data);
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

  OrderModel _parseOrder(Map<String, dynamic> json) {
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

    return OrderModel(
      id: json['id'] as String? ?? '',
      items: items,
      total: (json['total'] as num? ?? 0).toDouble(),
      fecha: json['fecha'] as String? ?? '',
      status: json['status'] as String? ?? 'Preparando envío',
      repartidor: json['repartidor'] as String?,
      timestamp: json['timestamp'] as int?,
    );
  }

  String crearPedido(List<CartItem> items, double total) {
    final now = DateTime.now();
    final fechaFormateada = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final orderId = "PED-${now.millisecondsSinceEpoch.toString().substring(7)}";
    final timestamp = now.millisecondsSinceEpoch;
    
    // Serializar a JSON para subir a Firestore
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
    };

    // Subir a Firestore
    FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .set(orderData)
        .catchError((e) {
      print('[OrdersNotifier Firestore Error] No se pudo crear el pedido: $e');
    });

    return orderId;
  }
}

