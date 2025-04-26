import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// 單元測試
import 'unit/core/utils/observer_test.dart';
// import 'unit/features/auth/viewmodels/auth_viewmodel_test.dart'; // 需先運行 build_runner 生成 mock

// Widget 測試
// import 'widget/features/auth/views/login_view_test.dart'; // 需修改 mockito 問題

/// 測試配置文件，用於一次性運行所有測試
void main() {
  group('單元測試', () {
    testWidgets('Observer 模式測試', (tester) async {
      // 初始化 observer_test.dart 測試
      runTests();
    });
    
    // 添加更多單元測試
  });
  
  // Widget 測試需要額外設置，最好單獨運行
}

/// 在 observer_test.dart 文件中的測試函數
void runTests() {
  // 該文件通常已經定義自己的主函數，不需要在這裡調用
  // 實際上這並不會運行測試，這裡只是作為示例
} 