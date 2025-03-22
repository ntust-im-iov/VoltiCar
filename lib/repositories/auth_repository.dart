import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  
  // 模擬API延遲
  final _delay = const Duration(milliseconds: 1500);
  
  // 註冊
  Future<User?> register(String username, String email, String password) async {
    // 模擬網絡延遲
    await Future.delayed(_delay);
    
    // 這裡模擬API請求和驗證
    // 在實際應用中，需要檢查用戶名是否已存在等
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
    );
    
    // 保存用戶
    await _saveUser(user);
    
    return user;
  }
  
  // 登錄
  Future<User?> login(String username, String password) async {
    // 模擬網絡延遲
    await Future.delayed(_delay);
    
    // 這裡模擬API請求
    if (username == 'admin' && password == 'admin123') {
      // 模擬用戶數據
      final user = User(
        id: '1',
        username: username,
        email: 'admin@volticar.com',
      );
      
      // 保存用戶
      await _saveUser(user);
      
      return user;
    }
    
    return null;
  }
  
  // 登出
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }
  
  // 檢查是否已登錄
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    
    // 模擬網絡延遲
    await Future.delayed(_delay);
    
    return userJson != null;
  }
  
  // 重設密碼
  Future<bool> resetPassword(String email, String newPassword) async {
    // 模擬網絡延遲
    await Future.delayed(_delay);
    
    // 這裡模擬API請求
    // 在實際應用中，需要確認電子郵件是否存在等
    return true;
  }
  
  // 取得用戶ID
  Future<String?> getUserId() async {
    return await _authService.getUserId();
  }
  
  // 保存用戶方法
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(user.toJson()));
  }
} 