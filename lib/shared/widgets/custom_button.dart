import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Color textColor;
  final double radius;
  final double size;
  final String text;
  VoidCallback onPressed;
  bool withIcon;
  IconData? icon;
  
  AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.radius = 10,
    this.textColor = Colors.white,
    this.size = 18,
    this.withIcon = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16),
        backgroundColor: Colors.indigo[800],
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
