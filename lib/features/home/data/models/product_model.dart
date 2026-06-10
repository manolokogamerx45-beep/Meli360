import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

/// Modelo de Envío para mapear el estado de "Envío gratis".
@freezed
class ShippingModel with _$ShippingModel {
  const factory ShippingModel({
    @JsonKey(name: 'free_shipping', defaultValue: false) required bool freeShipping,
  }) = _ShippingModel;

  factory ShippingModel.fromJson(Map<String, dynamic> json) => _$ShippingModelFromJson(json);
}

/// Modelo de Producto de Mercado Libre.
@freezed
class Product with _$Product {
  const Product._(); // Constructor privado para permitir métodos/getters personalizados.

  const factory Product({
    required String id,
    required String title,
    required double price,
    @JsonKey(name: 'original_price') double? originalPrice,
    required String thumbnail,
    required ShippingModel shipping,
    String? category,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  /// Devuelve el thumbnail asegurando que use protocolo HTTPS y optimizando para móviles si es de Unsplash.
  String get secureThumbnail {
    String url = thumbnail;
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }
    if (url.contains('images.unsplash.com') && !url.contains('?')) {
      url = '$url?w=350&q=70&fit=crop';
    }
    return url;
  }

  /// Calcula el porcentaje de descuento si existe un precio original superior.
  int get porcentajeDescuento {
    if (originalPrice != null && originalPrice! > price) {
      final calculo = ((originalPrice! - price) / originalPrice!) * 100;
      return calculo.round();
    }
    return 0;
  }
}
