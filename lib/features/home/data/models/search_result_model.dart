import 'package:freezed_annotation/freezed_annotation.dart';
import 'product_model.dart';

part 'search_result_model.freezed.dart';
part 'search_result_model.g.dart';

/// Modelo que representa la respuesta completa de la API de búsqueda de Mercado Libre.
@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    @Default([]) List<Product> results,
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) => _$SearchResultFromJson(json);
}
