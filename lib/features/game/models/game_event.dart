import 'package:flutter/material.dart';

/// 事件類型枚舉
enum EventType {
  positive, // 正面事件（綠色）
  neutral, // 中性事件（橙色）
  negative, // 負面事件（紅色）
}

/// 事件選項
class EventOption {
  final String text; // 選項文字
  final bool isCorrect; // 是否為正確/最佳答案
  final int scoreReward; // 分數獎勵（正數）或懲罰（負數）

  EventOption({
    required this.text,
    required this.isCorrect,
    required this.scoreReward,
  });
}

/// 遊戲事件模型
class GameEvent {
  final String id; // 唯一識別碼
  final EventType type; // 事件類型
  final String title; // 標題
  final String description; // 描述
  final List<EventOption> options; // 選項列表
  final String correctFeedback; // 答對時的回饋文字
  final String wrongFeedback; // 答錯時的回饋文字（包含正確答案說明）

  GameEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.options,
    required this.correctFeedback,
    required this.wrongFeedback,
  });

  /// 取得事件類型對應的顏色
  Color getColor() {
    switch (type) {
      case EventType.positive:
        return Colors.green;
      case EventType.neutral:
        return Colors.orange;
      case EventType.negative:
        return Colors.red;
    }
  }

  /// 取得事件類型對應的圖示
  IconData getIcon() {
    switch (type) {
      case EventType.positive:
        return Icons.emoji_events; // 獎盃
      case EventType.neutral:
        return Icons.help_outline; // 問號
      case EventType.negative:
        return Icons.warning; // 警告
    }
  }

  /// 取得正確答案的索引
  int getCorrectAnswerIndex() {
    return options.indexWhere((option) => option.isCorrect);
  }
}
