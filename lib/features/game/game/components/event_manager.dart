import 'package:flame/components.dart';
import 'dart:math' as math;
import 'event_block.dart';
import '../../data/event_database.dart';
import '../../models/game_event.dart';

/// 事件管理器 - 負責隨機生成事件方塊
class EventManager extends Component with HasGameRef {
  final math.Random _random = math.Random();
  final Function(GameEvent) onEventTriggered; // 事件觸發回調（傳遞事件資料）
  final Function()? onAllEventsCompleted; // 所有事件完成回調

  double _timeSinceLastEvent = 0.0;
  double _nextEventDelay = 0.0;

  // 生成間隔設定（秒）- 固定難度
  static const double minEventDelay = 4.0;
  static const double maxEventDelay = 7.0;

  bool isActive = true; // 是否繼續生成事件

  // 已使用的事件 ID 列表
  final List<String> _usedEventIds = [];

  EventManager({
    required this.onEventTriggered,
    this.onAllEventsCompleted,
  }) {
    _scheduleNextEvent();
  }

  void _scheduleNextEvent() {
    _nextEventDelay =
        minEventDelay + _random.nextDouble() * (maxEventDelay - minEventDelay);
    _timeSinceLastEvent = 0.0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (!isActive) return;

    _timeSinceLastEvent += dt;

    // 當達到下次事件的延遲時間時，生成新事件
    if (_timeSinceLastEvent >= _nextEventDelay) {
      _spawnEvent();
      _scheduleNextEvent();
    }
  }

  void _spawnEvent() {
    // 從資料庫隨機選取一個未使用的事件
    final GameEvent? event = EventDatabase.getRandomUnusedEvent(_usedEventIds);

    // 如果沒有可用事件（所有事件都已使用），觸發遊戲結束
    if (event == null) {
      isActive = false; // 停止生成事件
      onAllEventsCompleted?.call();
      return;
    }

    // 記錄已使用的事件 ID
    _usedEventIds.add(event.id);

    // 在螢幕右側隨機高度生成事件方塊
    final double randomY = game.size.y * 0.3 +
        _random.nextDouble() * (game.size.y * 0.4); // 在中間範圍內隨機

    final eventBlock = EventBlock(
      position: Vector2(game.size.x + 20, randomY),
      event: event,
      onBlockCollision: onEventTriggered,
    );

    game.add(eventBlock);
  }

  /// 停止生成新事件
  void pause() {
    isActive = false;
  }

  /// 恢復生成事件
  void resume() {
    isActive = true;
  }
}
