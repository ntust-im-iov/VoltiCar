import 'package:flutter/material.dart';

/// 頂層通知工具類
/// 可以在應用的最頂層顯示通知訊息
class TopNotificationUtils {
  /// 顯示頂層通知
  /// 
  /// [context] - 建構內容
  /// [message] - 通知訊息
  /// [isLevelError] - 是否為等級限制錯誤（影響樣式）
  /// [isSuccess] - 是否為成功訊息（影響樣式）
  /// [duration] - 顯示時長，預設3秒
  static void showTopNotification(
    BuildContext context, {
    required String message,
    bool isLevelError = false,
    bool isSuccess = false,
    Duration? duration,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => TopNotificationWidget(
        message: message,
        isLevelError: isLevelError,
        isSuccess: isSuccess,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    // 自動移除通知
    final autoRemoveDuration = duration ?? 
        Duration(milliseconds: isLevelError ? 4000 : 3000);
    
    Future.delayed(autoRemoveDuration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}

/// 頂層通知組件
class TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isLevelError;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const TopNotificationWidget({
    super.key,
    required this.message,
    required this.isLevelError,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isSuccess 
                            ? Colors.green 
                            : (widget.isLevelError ? Colors.orange : Colors.red),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.isSuccess
                                ? Icons.check_circle_outline
                                : (widget.isLevelError 
                                    ? Icons.lock_outline 
                                    : Icons.error_outline),
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isLevelError ? 16 : 14,
                                fontWeight: widget.isLevelError 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _dismiss,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
