import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import '../game/volti_car_game.dart';
import '../models/game_event.dart';

class MainGameView extends StatefulWidget {
  const MainGameView({super.key});

  @override
  State<MainGameView> createState() => _MainGameViewState();
}

class _MainGameViewState extends State<MainGameView> {
  late final VoltiCarGame game;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    game = VoltiCarGame();
    // 設定事件觸發回調
    game.onEventTriggered = _showEventDialog;
  }

  @override
  void dispose() {
    // 恢复到横向，因为 SetupView 也是横向的
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  /// 顯示事件對話框
  void _showEventDialog(GameEvent event) {
    showDialog(
      context: context,
      barrierDismissible: false, // 不允許點擊外部關閉
      builder: (BuildContext context) {
        return _EventDialog(
          event: event,
          game: game,
        );
      },
    );
  }

  /// 處理返回（結束遊戲）
  Future<void> _handleBack() async {
    // 顯示確認對話框
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('結束遊戲'),
          content: const Text('確定要結束遊戲嗎？您的成績將會被保存。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('確定'),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      await game.endGame();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          // 添加返回按钮
          Positioned(
            top: 10,
            left: 1,
            child: SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.white,
                iconSize: 30,
                onPressed: _handleBack,
              ),
            ),
          ),
          // 添加遊戲信息顯示
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 分數顯示
                    Text(
                      '分數: ${game.scoreManager.currentScore}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // 連擊顯示
                    if (game.scoreManager.comboCount > 1)
                      Text(
                        'COMBO x${game.scoreManager.comboCount}',
                        style: TextStyle(
                          color: Colors.orange.shade300,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 事件對話框組件
class _EventDialog extends StatefulWidget {
  final GameEvent event;
  final VoltiCarGame game;

  const _EventDialog({
    required this.event,
    required this.game,
  });

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  String _feedbackMessage = '';
  int _scoreChange = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: widget.event.getColor(),
          width: 3,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題與圖示
              Row(
                children: [
                  Icon(
                    widget.event.getIcon(),
                    color: widget.event.getColor(),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.event.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.event.getColor(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 描述
              Text(
                widget.event.description,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),

              // 選項列表
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.event.options.length,
                itemBuilder: (context, index) {
                  final option = widget.event.options[index];
                  final isSelected = _selectedOptionIndex == index;
                  final isCorrect = option.isCorrect;

                  Color? buttonColor;
                  if (_hasAnswered) {
                    if (isCorrect) {
                      buttonColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      buttonColor = Colors.red;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: _hasAnswered
                          ? null
                          : () => _handleOptionSelected(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor ?? Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          if (_hasAnswered && isCorrect)
                            const Icon(Icons.check_circle, size: 24),
                          if (_hasAnswered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, size: 24),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // 回饋訊息
              if (_hasAnswered) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _scoreChange > 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _feedbackMessage,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _scoreChange > 0
                            ? '+$_scoreChange 分'
                            : '$_scoreChange 分',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _scoreChange > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      if (widget.game.scoreManager.comboCount > 1 &&
                          _scoreChange > 0)
                        Text(
                          '連擊 x${widget.game.scoreManager.comboCount}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.game.resumeGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '繼續遊戲',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionSelected(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedOptionIndex = index;
      _hasAnswered = true;

      final selectedOption = widget.event.options[index];
      final isCorrect = selectedOption.isCorrect;

      // 更新分數
      widget.game.scoreManager.addEventScore(
        selectedOption.scoreReward,
        isCorrect,
      );

      _scoreChange = selectedOption.scoreReward;

      // 如果答錯且有連擊倍率，計算實際得分
      if (isCorrect && widget.game.scoreManager.comboCount > 1) {
        _scoreChange = (selectedOption.scoreReward *
                widget.game.scoreManager.currentMultiplier)
            .round();
      }

      // 設定回饋訊息
      _feedbackMessage =
          isCorrect ? widget.event.correctFeedback : widget.event.wrongFeedback;
    });
  }
}
