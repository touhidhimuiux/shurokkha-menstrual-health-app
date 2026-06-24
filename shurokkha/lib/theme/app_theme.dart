import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF7B35B5);
  static const Color lightPurple = Color(0xFFB89CC8);
  static const Color softPink = Color(0xFFFFB3D9);
  static const Color mediumPink = Color(0xFFE87DB0);
  static const Color lavender = Color(0xFFD4A8F0);
  static const Color softLavender = Color(0xFFEDD9FF);
  static const Color bgGradientTop = Color(0xFFFFB3D9);
  static const Color bgGradientMid = Color(0xFFF5D0F5);
  static const Color bgGradientBottom = Color(0xFFD4A8F0);
  static const Color cardWhite = Color(0xFFFFFAFF);
  static const Color textDark = Color(0xFF3D1A5C);
  static const Color textGrey = Color(0xFF8B6BA0);
  static const Color pinkAccent = Color(0xFFE91E8C);

  static const LinearGradient mainGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFB3D9),
      Color(0xFFFFCCE8),
      Color(0xFFF5D0F5),
      Color(0xFFD4A8F0),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const LinearGradient purplePinkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8D5FF), Color(0xFFFFD6EC)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF9B40D0), Color(0xFF7B35B5)],
  );
}

class AppTextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );

  static TextStyle heading2(BuildContext context) => TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 15,
        color: AppColors.textGrey,
        height: 1.5,
      );
}