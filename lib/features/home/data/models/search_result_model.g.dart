// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SearchResultImpl _$$SearchResultImplFromJson(Map<String, dynamic> json) =>
    _$SearchResultImpl(
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$SearchResultImplToJson(_$SearchResultImpl instance) =>
    <String, dynamic>{
      'results': instance.results,
    };
