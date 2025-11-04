import 'package:flutter/material.dart';

class AdaptiveButton extends StatefulWidget {
  const AdaptiveButton({
    super.key,
    required this.widthGain,
    required this.heightGain,
    required this.imagePath,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    this.showImage = true,
    this.iconPath,
    this.highlightColor,
    this.shadowColor,
    this.fixedFontSize,
    this.fixedIconSize,
  });

  final double widthGain;
  final double heightGain;
  final String imagePath;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final bool showImage;
  final String? iconPath;
  final Color? highlightColor;
  final Color? shadowColor;
  final double? fixedFontSize;
  final double? fixedIconSize;

  @override
  State<AdaptiveButton> createState() => _AdaptiveButtonState();
}

class _AdaptiveButtonState extends State<AdaptiveButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 計算像素風格的顏色
    final highlightColor = widget.highlightColor ??
        Color.lerp(widget.borderColor, Colors.white, 0.4)!;
    final shadowColor = widget.shadowColor ??
        Color.lerp(widget.borderColor, Colors.black, 0.4)!;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(
          _isPressed ? 2 : 0,
          _isPressed ? 2 : 0,
          0,
        ),
        width: screenWidth * widget.widthGain,
        height: screenHeight * widget.heightGain,
        child: Stack(
          children: [
            // 陰影層（像素風格硬陰影）
            if (!_isPressed)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: screenWidth * widget.widthGain - 4,
                  height: screenHeight * widget.heightGain - 4,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: shadowColor, width: 4),
                      bottom: BorderSide(color: shadowColor, width: 4),
                    ),
                  ),
                ),
              ),
            // 主按鈕容器
            Container(
              width: screenWidth * widget.widthGain,
              height: screenHeight * widget.heightGain,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                border: Border.all(
                  color: widget.borderColor,
                  width: 3,
                ),
              ),
              child: Stack(
                children: [
                  // 高光邊框（上和左）
                  Positioned(
                    top: 3,
                    left: 3,
                    right: 3,
                    child: Container(
                      height: 2,
                      color: highlightColor,
                    ),
                  ),
                  Positioned(
                    top: 3,
                    left: 3,
                    bottom: 3,
                    child: Container(
                      width: 2,
                      color: highlightColor,
                    ),
                  ),
                  // 內陰影邊框（下和右）
                  Positioned(
                    bottom: 3,
                    left: 3,
                    right: 3,
                    child: Container(
                      height: 2,
                      color: shadowColor,
                    ),
                  ),
                  Positioned(
                    top: 3,
                    right: 3,
                    bottom: 3,
                    child: Container(
                      width: 2,
                      color: shadowColor,
                    ),
                  ),
                  // 內容區域
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.showImage && widget.iconPath != null)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: screenHeight * widget.heightGain * 0.08,
                            ),
                            child: Image.asset(
                              widget.iconPath!,
                              width: widget.fixedIconSize ??
                                  (screenWidth * widget.widthGain * 0.35),
                              height: widget.fixedIconSize ??
                                  (screenHeight * widget.heightGain * 0.35),
                              fit: BoxFit.contain,
                            ),
                          ),
                        Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.textColor,
                            fontSize: widget.fixedFontSize ??
                                (screenWidth * widget.widthGain * 0.09),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                offset: const Offset(2, 2),
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
