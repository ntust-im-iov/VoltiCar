import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final Logger _logger = Logger();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();

  Future<User?> register(User user) async {
    try {
      await _saveAuthState(user.id);
      return user;
    } catch (e) {
      _logger.e('Registration error: $e');
      rethrow;
    }
  }

  Future<User?> login(String username, String password) async {
    try {
      if (username == 'admin' && password == 'admin123') {
        const userId = '1';
        await _saveAuthState(userId);
        
        return User(
          id: userId,
          username: username,
          email: 'admin@volticar.com',
        );
      }
      
      return null;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }
  
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      return true;
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await _secureStorage.delete(key: 'user_id');
    } catch (e) {
      _logger.e('Logout error: $e');
      rethrow;
    }
  }
  
  Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      _logger.e('Check login status error: $e');
      return false;
    }
  }
  
  Future<void> _saveAuthState(String userId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await _secureStorage.write(key: 'user_id', value: userId);
    } catch (e) {
      _logger.e('Save auth state error: $e');
      rethrow;
    }
  }
  
  Future<String?> getUserId() async {
    try {
      return await _secureStorage.read(key: 'user_id');
    } catch (e) {
      _logger.e('Get user ID error: $e');
      return null;
    }
  }
} 