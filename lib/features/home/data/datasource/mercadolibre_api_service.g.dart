// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mercadolibre_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'602665c911dd2e618dc837c0cf6e683036379ed3';

/// Proveedor para la instancia global de Dio con interceptores configurados.
///
/// Copied from [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$mercadoLibreApiServiceHash() =>
    r'6de55117d29a9428944925415eeb5a929db45ad9';

/// Proveedor para el servicio de la API de Mercado Libre.
///
/// Copied from [mercadoLibreApiService].
@ProviderFor(mercadoLibreApiService)
final mercadoLibreApiServiceProvider =
    AutoDisposeProvider<MercadoLibreApiService>.internal(
  mercadoLibreApiService,
  name: r'mercadoLibreApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mercadoLibreApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MercadoLibreApiServiceRef
    = AutoDisposeProviderRef<MercadoLibreApiService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
