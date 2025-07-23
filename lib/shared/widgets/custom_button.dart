import 'package:flutter/material.dart';
import 'package:pothole_detector/shared/constants.dart';

class AppButton extends StatelessWidget {
  final Color textColor;
  final double radius;
  final double size;
  final String text;
  VoidCallback onPressed;
  bool withIcon;
  IconData? icon;
  
  AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.radius = 10,
    this.textColor = Colors.white,
    this.size = 18,
    this.withIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: Color(COLOR_PRIMARY),
        overlayColor: Colors.black,
        disabledBackgroundColor: Colors.black12,
        splashFactory: InkSplash.splashFactory,
        enableFeedback: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))
        )
      ),
      child: Text(text, 
        style: TextStyle(
          fontSize: size,
          color: textColor
        ),
      ),
    );
  }
}
