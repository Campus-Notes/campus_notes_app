import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color borderColor;

  const VerifiedBadge({
    super.key,
    this.fontSize = 10,
    this.iconSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    this.backgroundColor = const Color.fromARGB(51, 76, 175, 80),
    this.textColor = Colors.green,
    this.iconColor = Colors.green,
    this.borderColor = const Color.fromARGB(128, 76, 175, 80),
  });

  // Factory constructor for white/light theme variant
  factory VerifiedBadge.white({
    double fontSize = 10,
    double iconSize = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) {
    return VerifiedBadge(
      fontSize: fontSize,
      iconSize: iconSize,
      padding: padding,
      backgroundColor: Colors.transparent,
      textColor: Colors.white,
      iconColor: Colors.white,
      borderColor: Colors.white24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            size: iconSize,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

