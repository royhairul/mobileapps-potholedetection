import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final double radius;
  final double width;
  final double height;
  final double size;
  GestureTapCallback? onTap;
  bool withIcon;
  IconData? icon;
  String text = "";
  AppButton({
    super.key,
    required this.color,
    required this.width,
    required this.height,
    this.radius = 15,
    required this.backgroundColor,
    this.text = "Hi",
    this.size = 18,
    this.onTap,
    this.withIcon = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (withIcon)
                Row(
                  children: [
                    Icon(icon, color: color, size: size),
                    const SizedBox(width: 5),
                  ],
                ),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: size,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
