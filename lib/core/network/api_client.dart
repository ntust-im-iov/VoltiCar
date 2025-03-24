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
    
    _logger.i('ApiClient 初始化');
    _logger.i('Base URL: ${ApiConstants.baseUrl}');
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          _logger.i('=== 發送請求 ===');
          _logger.i('URL: ${options.uri}');
          _logger.i('Method: ${options.method}');
          _logger.i('Headers: ${options.headers}');
          _logger.i('Data: ${options.data}');
          
          // 添加認證 token
          final token = await _getToken();
          if (token != null) {
            options.headers[ApiConstants.authHeader] = '${ApiConstants.bearerPrefix}$token';
            _logger.i('已添加認證 Token');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i('=== 收到響應 ===');
          _logger.i('Status Code: ${response.statusCode}');
          _logger.i('Data: ${response.data}');
          handler.next(response);
        },
        onError: (DioException e, handler) async {
          _logger.e('=== 請求錯誤 ===');
          _logger.e('Type: ${e.type}');
          _logger.e('Message: ${e.message}');
          _logger.e('Response: ${e.response?.data}');
          
          // 處理401未授權錯誤
          if (e.response?.statusCode == 401) {
            _logger.e('收到401未授權響應，嘗試刷新令牌...');
            
            // 嘗試刷新令牌
            final bool refreshSuccess = await refreshToken();
            
            if (refreshSuccess) {
              _logger.i('令牌刷新成功，重試原始請求');
              
              // 獲取新令牌
              final newToken = await _getToken();
              
              if (newToken != null) {
                // 使用新令牌重新發送原始請求
                final opts = Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                opts.headers?[ApiConstants.authHeader] = '${ApiConstants.bearerPrefix}$newToken';
                
                try {
                  final response = await _dio.request(
                    e.requestOptions.path,
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters,
                    options: opts,
                  );
                  
                  // 向下傳遞成功的響應
                  handler.resolve(response);
                  return;
                } catch (retryError) {
                  _logger.e('使用刷新令牌重試請求失敗: $retryError');
                }
              }
            }
            
            // 如果刷新失敗或重試失敗，執行登出處理
            _logger.e('刷新令牌或重試請求失敗，執行登出處理');
            _handleUnauthorized();
          }
          
          handler.next(e);
        },
      ),
    );
  }
  
  Future<String?> _getToken() async {
    try {
      return await _secureStorage.read(key: 'access_token');
    } catch (e) {
      _logger.e('Error reading token: $e');
      return null;
    }
  }
  
  Future<void> _handleUnauthorized() async {
    try {
      await _secureStorage.delete(key: 'access_token');
      // TODO: 通知 UI 層處理登出邏輯
    } catch (e) {
      _logger.e('Error handling unauthorized: $e');
    }
  }
  
  Future<bool> refreshToken() async {
    try {
      _logger.i('嘗試刷新令牌...');
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      
      if (refreshToken == null) {
        _logger.e('沒有可用的刷新令牌');
        return false;
      }
      
      final response = await _dio.post(
        '/users/token/refresh',
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          headers: {
            ApiConstants.contentTypeHeader: ApiConstants.contentType,
            ApiConstants.acceptHeader: ApiConstants.contentType,
          },
        ),
      );
      
      if (response.statusCode == 200 && response.data['access_token'] != null) {
        await _secureStorage.write(
          key: 'access_token',
          value: response.data['access_token'],
        );
        
        if (response.data['refresh_token'] != null) {
          await _secureStorage.write(
            key: 'refresh_token',
            value: response.data['refresh_token'],
          );
        }
        
        _logger.i('令牌刷新成功');
        return true;
      }
      
      _logger.e('令牌刷新失敗');
      return false;
    } catch (e) {
      _logger.e('刷新令牌時發生錯誤: $e');
      return false;
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