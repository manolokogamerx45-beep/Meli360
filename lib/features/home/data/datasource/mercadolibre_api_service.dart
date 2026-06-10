import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product_model.dart';
import '../models/search_result_model.dart';

part 'mercadolibre_api_service.g.dart';

/// Proveedor para la instancia global de Dio con interceptores configurados.
@riverpod
Dio dio(DioRef ref) {
  final dioInstance = Dio(
    BaseOptions(
      baseUrl: 'https://api.mercadolibre.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Agregar interceptor de logging básico
  dioInstance.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false, // Evitamos imprimir todo el JSON en consola
      error: true,
    ),
  );

  return dioInstance;
}

/// Proveedor para el servicio de la API de Mercado Libre.
@riverpod
MercadoLibreApiService mercadoLibreApiService(MercadoLibreApiServiceRef ref) {
  final dioClient = ref.watch(dioProvider);
  return MercadoLibreApiService(dioClient);
}

/// Cliente de la API de Mercado Libre que gestiona la comunicación HTTP.
class MercadoLibreApiService {
  final Dio _dio;

  MercadoLibreApiService(this._dio);

  /// Realiza la búsqueda de productos según la consulta (`query`).
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/sites/MLM/search', // MLM = México
        queryParameters: {
          'q': query,
          'limit': 15, // Mostramos 15 para un diseño más rico en el feed horizontal
        },
      );

      if (response.statusCode == 200) {
        final searchResult = SearchResult.fromJson(response.data);
        return searchResult.results;
      } else {
        throw Exception('Error del servidor: código de respuesta ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_traducirErrorDeRed(e));
    } catch (e) {
      throw Exception('Ocurrió un error inesperado al cargar los datos.');
    }
  }

  /// Traduce los errores técnicos de Dio a mensajes comprensibles en español.
  String _traducirErrorDeRed(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Tiempo de espera agotado. Por favor, verifica tu conexión a Internet.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return 'Respuesta fallida del servidor (Código $status). Inténtalo más tarde.';
      case DioExceptionType.connectionError:
        return 'No se pudo conectar al servidor. Comprueba si estás conectado a una red activa.';
      default:
        return 'Error de conexión. Inténtalo de nuevo.';
    }
  }
}
