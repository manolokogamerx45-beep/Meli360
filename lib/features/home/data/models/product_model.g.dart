// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShippingModelImpl _$$ShippingModelImplFromJson(Map<String, dynamic> json) =>
    _$ShippingModelImpl(
      freeShipping: json['free_shipping'] as bool? ?? false,
    );

Map<String, dynamic> _$$ShippingModelImplToJson(_$ShippingModelImpl instance) =>
    <String, dynamic>{
      'free_shipping': instance.freeShipping,
    };

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      thumbnail: json['thumbnail'] as String,
      shipping:
          ShippingModel.fromJson(json['shipping'] as Map<String, dynamic>),
      category: json['category'] as String?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'thumbnail': instance.thumbnail,
      'shipping': instance.shipping,
      'category': instance.category,
    };
