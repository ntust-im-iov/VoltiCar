import 'package:flutter_test/flutter_test.dart';
import 'package:volticar_app/core/utils/observer.dart';

// 測試用的事件類
class TestEvent extends ViewEvent {
  final String message;
  const TestEvent(this.message);
}

// 測試用的觀察者類
class TestObserver implements EventObserver {
  String? lastMessage;
  
  @override
  void notify(ViewEvent event) {
    if (event is TestEvent) {
      lastMessage = event.message;
    }
  }
}

// 測試用的 ViewModel
class TestViewModel extends EventViewModel {
  void triggerEvent(String message) {
    notify(TestEvent(message));
  }
}

void main() {
  group('觀察者模式測試', () {
    late TestViewModel viewModel;
    late TestObserver observer;

    setUp(() {
      viewModel = TestViewModel();
      observer = TestObserver();
    });

    test('訂閱觀察者應能接收通知', () {
      // 安排
      viewModel.subscribe(observer);
      
      // 執行
      viewModel.triggerEvent('測試訊息');
      
      // 驗證
      expect(observer.lastMessage, equals('測試訊息'));
    });

    test('取消訂閱的觀察者不應接收通知', () {
      // 安排
      viewModel.subscribe(observer);
      viewModel.triggerEvent('第一條訊息');
      
      // 執行
      viewModel.unsubscribe(observer);
      viewModel.triggerEvent('第二條訊息');
      
      // 驗證
      expect(observer.lastMessage, equals('第一條訊息'));
    });

    test('多個觀察者應都能接收通知', () {
      // 安排
      final observer2 = TestObserver();
      viewModel.subscribe(observer);
      viewModel.subscribe(observer2);
      
      // 執行
      viewModel.triggerEvent('廣播訊息');
      
      // 驗證
      expect(observer.lastMessage, equals('廣播訊息'));
      expect(observer2.lastMessage, equals('廣播訊息'));
    });
  });
} 