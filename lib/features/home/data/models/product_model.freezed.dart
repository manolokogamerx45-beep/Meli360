// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShippingModel _$ShippingModelFromJson(Map<String, dynamic> json) {
  return _ShippingModel.fromJson(json);
}

/// @nodoc
mixin _$ShippingModel {
  @JsonKey(name: 'free_shipping', defaultValue: false)
  bool get freeShipping => throw _privateConstructorUsedError;

  /// Serializes this ShippingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ShippingModelCopyWith<ShippingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShippingModelCopyWith<$Res> {
  factory $ShippingModelCopyWith(
          ShippingModel value, $Res Function(ShippingModel) then) =
      _$ShippingModelCopyWithImpl<$Res, ShippingModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'free_shipping', defaultValue: false) bool freeShipping});
}

/// @nodoc
class _$ShippingModelCopyWithImpl<$Res, $Val extends ShippingModel>
    implements $ShippingModelCopyWith<$Res> {
  _$ShippingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? freeShipping = null,
  }) {
    return _then(_value.copyWith(
      freeShipping: null == freeShipping
          ? _value.freeShipping
          : freeShipping // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShippingModelImplCopyWith<$Res>
    implements $ShippingModelCopyWith<$Res> {
  factory _$$ShippingModelImplCopyWith(
          _$ShippingModelImpl value, $Res Function(_$ShippingModelImpl) then) =
      __$$ShippingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'free_shipping', defaultValue: false) bool freeShipping});
}

/// @nodoc
class __$$ShippingModelImplCopyWithImpl<$Res>
    extends _$ShippingModelCopyWithImpl<$Res, _$ShippingModelImpl>
    implements _$$ShippingModelImplCopyWith<$Res> {
  __$$ShippingModelImplCopyWithImpl(
      _$ShippingModelImpl _value, $Res Function(_$ShippingModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? freeShipping = null,
  }) {
    return _then(_$ShippingModelImpl(
      freeShipping: null == freeShipping
          ? _value.freeShipping
          : freeShipping // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShippingModelImpl implements _ShippingModel {
  const _$ShippingModelImpl(
      {@JsonKey(name: 'free_shipping', defaultValue: false)
      required this.freeShipping});

  factory _$ShippingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShippingModelImplFromJson(json);

  @override
  @JsonKey(name: 'free_shipping', defaultValue: false)
  final bool freeShipping;

  @override
  String toString() {
    return 'ShippingModel(freeShipping: $freeShipping)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShippingModelImpl &&
            (identical(other.freeShipping, freeShipping) ||
                other.freeShipping == freeShipping));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, freeShipping);

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ShippingModelImplCopyWith<_$ShippingModelImpl> get copyWith =>
      __$$ShippingModelImplCopyWithImpl<_$ShippingModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShippingModelImplToJson(
      this,
    );
  }
}

abstract class _ShippingModel implements ShippingModel {
  const factory _ShippingModel(
      {@JsonKey(name: 'free_shipping', defaultValue: false)
      required final bool freeShipping}) = _$ShippingModelImpl;

  factory _ShippingModel.fromJson(Map<String, dynamic> json) =
      _$ShippingModelImpl.fromJson;

  @override
  @JsonKey(name: 'free_shipping', defaultValue: false)
  bool get freeShipping;

  /// Create a copy of ShippingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ShippingModelImplCopyWith<_$ShippingModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_price')
  double? get originalPrice => throw _privateConstructorUsedError;
  String get thumbnail => throw _privateConstructorUsedError;
  ShippingModel get shipping => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call(
      {String id,
      String title,
      double price,
      @JsonKey(name: 'original_price') double? originalPrice,
      String thumbnail,
      ShippingModel shipping,
      String? category});

  $ShippingModelCopyWith<$Res> get shipping;
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? originalPrice = freezed,
    Object? thumbnail = null,
    Object? shipping = null,
    Object? category = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      shipping: null == shipping
          ? _value.shipping
          : shipping // ignore: cast_nullable_to_non_nullable
              as ShippingModel,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ShippingModelCopyWith<$Res> get shipping {
    return $ShippingModelCopyWith<$Res>(_value.shipping, (value) {
      return _then(_value.copyWith(shipping: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
          _$ProductImpl value, $Res Function(_$ProductImpl) then) =
      __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      double price,
      @JsonKey(name: 'original_price') double? originalPrice,
      String thumbnail,
      ShippingModel shipping,
      String? category});

  @override
  $ShippingModelCopyWith<$Res> get shipping;
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
      _$ProductImpl _value, $Res Function(_$ProductImpl) _then)
      : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? price = null,
    Object? originalPrice = freezed,
    Object? thumbnail = null,
    Object? shipping = null,
    Object? category = freezed,
  }) {
    return _then(_$ProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      originalPrice: freezed == originalPrice
          ? _value.originalPrice
          : originalPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      thumbnail: null == thumbnail
          ? _value.thumbnail
          : thumbnail // ignore: cast_nullable_to_non_nullable
              as String,
      shipping: null == shipping
          ? _value.shipping
          : shipping // ignore: cast_nullable_to_non_nullable
              as ShippingModel,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl extends _Product {
  const _$ProductImpl(
      {required this.id,
      required this.title,
      required this.price,
      @JsonKey(name: 'original_price') this.originalPrice,
      required this.thumbnail,
      required this.shipping,
      this.category})
      : super._();

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double price;
  @override
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @override
  final String thumbnail;
  @override
  final ShippingModel shipping;
  @override
  final String? category;

  @override
  String toString() {
    return 'Product(id: $id, title: $title, price: $price, originalPrice: $originalPrice, thumbnail: $thumbnail, shipping: $shipping, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.thumbnail, thumbnail) ||
                other.thumbnail == thumbnail) &&
            (identical(other.shipping, shipping) ||
                other.shipping == shipping) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, price, originalPrice,
      thumbnail, shipping, category);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(
      this,
    );
  }
}

abstract class _Product extends Product {
  const factory _Product(
      {required final String id,
      required final String title,
      required final double price,
      @JsonKey(name: 'original_price') final double? originalPrice,
      required final String thumbnail,
      required final ShippingModel shipping,
      final String? category}) = _$ProductImpl;
  const _Product._() : super._();

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double get price;
  @override
  @JsonKey(name: 'original_price')
  double? get originalPrice;
  @override
  String get thumbnail;
  @override
  ShippingModel get shipping;
  @override
  String? get category;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
