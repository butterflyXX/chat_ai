import 'package:chat_ai/common/theme/colors.dart';
import 'package:flutter/material.dart';

/// 构建浅色主题
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  // 移除点击水波纹效果
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  // 添加自定义主题扩展
  extensions: const [AppThemeExtension.light],
  // 配置主要颜色
  colorScheme: const ColorScheme.light(
    primary: ColorsTheme.textOnlightPrimary,
    secondary: Color(0xFF4AD6A0),
    error: ColorsTheme.highlightRed,
    surface: ColorsTheme.backgroundLight,
    onSurface: ColorsTheme.textOnlightPrimary,
  ),
  // AppBar主题
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: ColorsTheme.backgroundLight,
    foregroundColor: ColorsTheme.textOnlightPrimary,
    surfaceTintColor: Colors.transparent,
  ),
  // Scaffold主题
  scaffoldBackgroundColor: ColorsTheme.backgroundLight,
);

/// 构建暗色主题
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  // 移除点击水波纹效果
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  // 添加自定义主题扩展
  extensions: const [AppThemeExtension.dark],
  // 配置主要颜色
  colorScheme: const ColorScheme.dark(
    primary: ColorsTheme.textOndarkPrimary,
    secondary: Color(0xFF4AD6A0),
    error: ColorsTheme.highlightRed,
    surface: ColorsTheme.backgroundDark,
    onSurface: ColorsTheme.textOndarkPrimary,
  ),
  // AppBar主题
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: ColorsTheme.backgroundDark,
    foregroundColor: ColorsTheme.textOndarkPrimary,
    surfaceTintColor: Colors.transparent,
  ),
  // Scaffold主题
  scaffoldBackgroundColor: ColorsTheme.backgroundDark,
);
