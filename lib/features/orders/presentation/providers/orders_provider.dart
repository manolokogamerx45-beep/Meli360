import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../cart/presentation/providers/cart_provider.dart';

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
  @override
  List<OrderModel> build() {
    // Inicializamos con un pedido mock anterior para que no aparezca vacío
    return [];
  }

  String crearPedido(List<CartItem> items, double total) {
    final now = DateTime.now();
    final fechaFormateada = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    final orderId = "PED-${now.millisecondsSinceEpoch.toString().substring(7)}";
    
    final nuevoPedido = OrderModel(
      id: orderId,
      items: List<CartItem>.from(items),
      total: total,
      fecha: fechaFormateada,
      status: "Preparando envío",
    );

    state = [nuevoPedido, ...state];
    return orderId;
  }
}
