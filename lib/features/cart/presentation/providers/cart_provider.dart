import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../home/data/models/product_model.dart';

part 'cart_provider.g.dart';

class CartItem {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

@Riverpod(keepAlive: true)
class CartNotifier extends _$CartNotifier {
  @override
  List<CartItem> build() {
    // Inicializamos con un par de artículos mock por defecto para que la app se vea completa
    return [];
  }

  void agregarProducto(Product product, {int cantidad = 1}) {
    final stateList = List<CartItem>.from(state);
    final index = stateList.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      stateList[index] = stateList[index].copyWith(
        quantity: stateList[index].quantity + cantidad,
      );
    } else {
      stateList.add(CartItem(product: product, quantity: cantidad));
    }
    state = stateList;
  }

  void removerProducto(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void actualizarCantidad(String productId, int nuevaCantidad) {
    if (nuevaCantidad <= 0) {
      removerProducto(productId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: nuevaCantidad);
      }
      return item;
    }).toList();
  }

  void limpiarCarrito() {
    state = [];
  }
}
