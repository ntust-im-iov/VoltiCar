import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import 'package:logger/logger.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true
    )
  );
  
  factory ApiClient() {
    return _instance;
  }
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        ApiConstants.contentTypeHeader: ApiConstants.contentType,
        ApiConstants.acceptHeader: ApiConstants.contentType,
      },
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 添加認證 token
          final token = await _getToken();
          if (token != null) {
            options.headers[ApiConstants.authHeader] = '${ApiConstants.bearerPrefix}$token';
          }

          _logger.i('發送請求: ${options.method} ${options.uri}');
          _logger.i('請求頭: ${options.headers}');
          _logger.i('請求數據: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('收到響應: ${response.statusCode}');
          _logger.i('響應頭: ${response.headers}');
          _logger.i('響應數據: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logger.e('請求錯誤: ${e.type}');
          _logger.e('錯誤消息: ${e.message}');
          _logger.e('請求URL: ${e.requestOptions.uri}');
          _logger.e('請求方法: ${e.requestOptions.method}');
          _logger.e('請求頭: ${e.requestOptions.headers}');
          _logger.e('請求數據: ${e.requestOptions.data}');
          
          if (e.response != null) {
            _logger.e('錯誤狀態碼: ${e.response?.statusCode}');
            _logger.e('錯誤響應數據: ${e.response?.data}');
            _logger.e('錯誤響應頭: ${e.response?.headers}');

            // 處理特定的錯誤狀態碼
            switch (e.response?.statusCode) {
              case 400:
                _logger.e('Bad Request: 請檢查請求參數');
                break;
              case 401:
                _logger.e('Unauthorized: 未授權的訪問');
                await _handleUnauthorized();
                break;
              case 403:
                _logger.e('Forbidden: 禁止訪問');
                break;
              case 404:
                _logger.e('Not Found: 資源不存在');
                break;
              case 500:
                _logger.e('Internal Server Error: 服務器錯誤');
                break;
              default:
                _logger.e('未處理的錯誤狀態碼: ${e.response?.statusCode}');
            }
          } else {
            _logger.e('沒有收到響應數據');
            if (e.type == DioExceptionType.connectionTimeout) {
              _logger.e('連接超時');
            } else if (e.type == DioExceptionType.receiveTimeout) {
              _logger.e('接收數據超時');
            } else if (e.type == DioExceptionType.sendTimeout) {
              _logger.e('發送數據超時');
            }
          }
          
          return handler.next(e);
        },
      ),
    );
  }
  
  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      _logger.e('Error reading token: $e');
      return null;
    }
  }
  
  Future<void> _handleUnauthorized() async {
    try {
      await _secureStorage.delete(key: 'auth_token');
      // TODO: 通知 UI 層處理登出邏輯
    } catch (e) {
      _logger.e('Error handling unauthorized: $e');
    }
  }
  
  // HTTP GET 請求
  Future<Response> get(String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('GET request error: $e');
      rethrow;
    }
  }
  
  // HTTP POST 請求
  Future<Response> post(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('POST request error: $e');
      rethrow;
    }
  }
  
  // HTTP PUT 請求
  Future<Response> put(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('PUT request error: $e');
      rethrow;
    }
  }
  
  // HTTP DELETE 請求
  Future<Response> delete(String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      _logger.e('DELETE request error: $e');
      rethrow;
    }
  }
} 