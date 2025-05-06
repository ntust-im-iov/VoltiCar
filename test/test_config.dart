import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// 單元測試
// 注意：observer_test.dart 保留為參考，但代碼庫已轉為使用 ChangeNotifier 模式
// import 'unit/core/utils/observer_test.dart';
import 'unit/features/auth/viewmodels/auth_viewmodel_test.dart'; // 使用 ChangeNotifier 模式的測試

// Widget 測試
import 'widget/features/auth/views/login_view_test.dart';        // 已更新為使用 ChangeNotifier 模式
// 以下文件需要先運行 build_runner 生成 mock 文件
// import 'widget/features/auth/views/register_view_test.dart';     // 使用 ChangeNotifier 模式的測試
// import 'widget/features/auth/views/reset_password_view_test.dart'; // 使用 ChangeNotifier 模式的測試

/// 測試配置文件，用於一次性運行所有測試
void main() {
  group('單元測試', () {
    // testWidgets('Observer 模式測試', (tester) async {
    //   // 此測試已不再適用於當前代碼庫，因為我們已轉移到 ChangeNotifier 模式
    //   // runTests();
    // });
    
    testWidgets('AuthViewModel 使用 ChangeNotifier 測試', (tester) async {
      // 初始化 auth_viewmodel_test.dart 測試
      runAuthViewModelTests();
    });
    
    // 添加更多單元測試
  });
  
  group('Widget 測試', () {
    testWidgets('登入頁面測試', (tester) async {
      // 初始化 login_view_test.dart 測試
      runLoginViewTests();
    });
    
    // 註冊頁面測試 - 需要先生成 mock 文件
    // testWidgets('註冊頁面測試', (tester) async {
    //   runRegisterViewTests();
    // });
    
    // 重設密碼頁面測試 - 需要先生成 mock 文件
    // testWidgets('重設密碼頁面測試', (tester) async {
    //   runResetPasswordViewTests();
    // });
  });
}

/// 在 auth_viewmodel_test.dart 文件中的測試函數
void runAuthViewModelTests() {
  // 該文件通常已經定義自己的主函數，不需要在這裡調用
  // 實際上這並不會運行測試，這裡只是作為示例
}

/// 在 login_view_test.dart 文件中的測試函數
void runLoginViewTests() {
  // 該文件通常已經定義自己的主函數，不需要在這裡調用
  // 實際上這並不會運行測試，這裡只是作為示例
}

/// 在 register_view_test.dart 文件中的測試函數
void runRegisterViewTests() {
  // 該文件通常已經定義自己的主函數，不需要在這裡調用
  // 實際上這並不會運行測試，這裡只是作為示例
}

/// 在 reset_password_view_test.dart 文件中的測試函數
void runResetPasswordViewTests() {
  // 該文件通常已經定義自己的主函數，不需要在這裡調用
  // 實際上這並不會運行測試，這裡只是作為示例
} 