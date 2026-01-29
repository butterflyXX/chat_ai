// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class ColorsTheme {
  // --- 背景色 (Backgrounds) ---
  // 采用非纯黑（深碳灰）和非纯白（暖烟灰），更有高级感
  static const Color backgroundDark = Color(0xFF141416);
  static const Color backgroundLight = Color(0xFFF9F9F8);

  // --- 填充色 (Fills / Surfaces) ---
  // 用于聊天气泡、输入框等
  static const Color fillsDarkPrimary = Color(0xFF232326);
  static const Color fillsDarkSecondary = Color(0xFF2D2D30);
  static const Color fillsDarkTertiary = Color(0xFF3E3E42);

  static const Color fillsLightPrimary = Color(0xFFFFFFFF); // 气泡通常用纯白
  static const Color fillsLightSecondary = Color(0xFFF0F2F5); // 辅助气泡
  static const Color fillsLightTertiary = Color(0xFFE4E7EB);

  // --- 文本色 (Text) ---
  static const Color textOndarkPrimary = Color(0xFFECECED);
  static const Color textOndarkSecondary = Color(0xFFA1A1AA);
  static const Color textOndarkTertiary = Color(0xFF71717A);

  static const Color textOnlightPrimary = Color(0xFF1A1A1A);
  static const Color textOnlightSecondary = Color(0xFF4B5563);
  static const Color textOnlightTertiary = Color(0xFF9CA3AF);

  // --- 分割线 (Separators / Borders) ---
  static const Color separatorsOndarkPrimary = Color(0xFF2D2D30);
  static const Color separatorsOndarkSecondary = Color(0xFF3E3E42);

  static const Color separatorsOnlightPrimary = Color(0xFFE5E7EB);
  static const Color separatorsOnlightSecondary = Color(0xFFD1D5DB);

  // --- 强调色 (Highlights) ---
  // 采用更加深邃、饱和度适中的颜色
  static const Color highlightBlue = Color(0xFF3B82F6); // 典型 AI 蓝色
  static const Color highlightRed = Color(0xFFEF4444); // 报错/警告
  static const Color highlightGreen = Color(0xFF10B981); // 成功/运行
  static const Color highlightOrange = Color(0xFFF59E0B); // 提示
  static const Color highlightProrights = Color(0xFF8B5CF6); // Pro 会员通常用紫色调
}

class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.backgroundColor,
    required this.fillsPrimary,
    required this.fillsSecondary,
    required this.fillsTertiary,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.separatorsPrimary,
    required this.separatorsSecondary,
    required this.highlightBlue,
    required this.highlightRed,
    required this.highlightGreen,
    required this.highlightOrange,
    required this.highlightProrights,
  });

  final Color backgroundColor;
  final Color fillsPrimary;
  final Color fillsSecondary;
  final Color fillsTertiary;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color separatorsPrimary;
  final Color separatorsSecondary;
  final Color highlightBlue;
  final Color highlightRed;
  final Color highlightGreen;
  final Color highlightOrange;
  final Color highlightProrights;

  // 浅色主题
  static const light = AppThemeExtension(
    backgroundColor: ColorsTheme.backgroundLight,
    fillsPrimary: ColorsTheme.fillsLightPrimary,
    fillsSecondary: ColorsTheme.fillsLightSecondary,
    fillsTertiary: ColorsTheme.fillsLightTertiary,
    textPrimary: ColorsTheme.textOnlightPrimary,
    textSecondary: ColorsTheme.textOnlightSecondary,
    textTertiary: ColorsTheme.textOnlightTertiary,
    separatorsPrimary: ColorsTheme.separatorsOnlightPrimary,
    separatorsSecondary: ColorsTheme.separatorsOnlightSecondary,
    highlightBlue: ColorsTheme.highlightBlue,
    highlightRed: ColorsTheme.highlightRed,
    highlightGreen: ColorsTheme.highlightGreen,
    highlightOrange: ColorsTheme.highlightOrange,
    highlightProrights: ColorsTheme.highlightProrights,
  );

  // 暗色主题
  static const dark = AppThemeExtension(
    backgroundColor: ColorsTheme.backgroundDark,
    fillsPrimary: ColorsTheme.fillsDarkPrimary,
    fillsSecondary: ColorsTheme.fillsDarkSecondary,
    fillsTertiary: ColorsTheme.fillsDarkTertiary,
    textPrimary: ColorsTheme.textOndarkPrimary,
    textSecondary: ColorsTheme.textOndarkSecondary,
    textTertiary: ColorsTheme.textOndarkTertiary,
    separatorsPrimary: ColorsTheme.separatorsOndarkPrimary,
    separatorsSecondary: ColorsTheme.separatorsOndarkSecondary,
    highlightBlue: ColorsTheme.highlightBlue,
    highlightRed: ColorsTheme.highlightRed,
    highlightGreen: ColorsTheme.highlightGreen,
    highlightOrange: ColorsTheme.highlightOrange,
    highlightProrights: ColorsTheme.highlightProrights,
  );

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    Color? backgroundColor,
    Color? fillsPrimary,
    Color? fillsSecondary,
    Color? fillsTertiary,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? separatorsPrimary,
    Color? separatorsSecondary,
    Color? highlightBlue,
    Color? highlightRed,
    Color? highlightGreen,
    Color? highlightOrange,
    Color? highlightProrights,
  }) {
    return AppThemeExtension(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fillsPrimary: fillsPrimary ?? this.fillsPrimary,
      fillsSecondary: fillsSecondary ?? this.fillsSecondary,
      fillsTertiary: fillsTertiary ?? this.fillsTertiary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      separatorsPrimary: separatorsPrimary ?? this.separatorsPrimary,
      separatorsSecondary: separatorsSecondary ?? this.separatorsSecondary,
      highlightBlue: highlightBlue ?? this.highlightBlue,
      highlightRed: highlightRed ?? this.highlightRed,
      highlightGreen: highlightGreen ?? this.highlightGreen,
      highlightOrange: highlightOrange ?? this.highlightOrange,
      highlightProrights: highlightProrights ?? this.highlightProrights,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(covariant ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      fillsPrimary: Color.lerp(fillsPrimary, other.fillsPrimary, t)!,
      fillsSecondary: Color.lerp(fillsSecondary, other.fillsSecondary, t)!,
      fillsTertiary: Color.lerp(fillsTertiary, other.fillsTertiary, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      separatorsPrimary: Color.lerp(separatorsPrimary, other.separatorsPrimary, t)!,
      separatorsSecondary: Color.lerp(separatorsSecondary, other.separatorsSecondary, t)!,
      highlightBlue: Color.lerp(highlightBlue, other.highlightBlue, t)!,
      highlightRed: Color.lerp(highlightRed, other.highlightRed, t)!,
      highlightGreen: Color.lerp(highlightGreen, other.highlightGreen, t)!,
      highlightOrange: Color.lerp(highlightOrange, other.highlightOrange, t)!,
      highlightProrights: Color.lerp(highlightProrights, other.highlightProrights, t)!,
    );
  }
}

extension ThemeExtensionGetter on BuildContext {
  AppThemeExtension get appTheme => Theme.of(this).extension<AppThemeExtension>()!;
}
