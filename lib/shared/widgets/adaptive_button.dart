import 'package:flutter/material.dart';

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    Key? key,
    required this.widthGain,
    required this.heightGain,
    required this.imagePath,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
    this.showImage = true,
  }) : super(key: key);

  final double widthGain;
  final double heightGain;
  final String imagePath;
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * widthGain,
        height: screenHeight * heightGain,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showImage)
                Image.asset(
                  imagePath,
                  width: screenWidth * widthGain * 0.5,
                  height: screenHeight * heightGain * 0.5,
                ),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: screenWidth * widthGain * 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
