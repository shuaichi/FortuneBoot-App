import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';

class AppTheme {
  // 主色调
  static const Color primaryColor = Colors.teal;

  // 强调色
  static const Color accentColor = Colors.orange;

  // 错误颜色
  static const Color errorColor = Colors.deepOrange;

  // 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // 卡片背景色
  static const Color cardColor = Colors.white;

  // 文本主色
  static const Color textPrimaryColor = Color(0xFF212121);

  // 文本次要色
  static const Color textSecondaryColor = Color(0xFF757575);

  // 分隔线颜色
  static const Color dividerColor = Color(0xFFBDBDBD);

  // 按钮颜色
  static const Color buttonColor = primaryColor;

  // 按钮文本颜色
  static const Color buttonTextColor = Colors.white;

  // 输入框边框颜色
  static const Color inputBorderColor = Color(0xFFE0E0E0);

  // 输入框焦点颜色
  static const Color inputFocusColor = primaryColor;

  // 圆角大小
  static const double borderRadius = 8.0;

  // 按钮圆角
  static const double buttonBorderRadius = 8.0;

  // 卡片圆角
  static const double cardBorderRadius = 12.0;

  // 输入框圆角
  static const double inputBorderRadius = 8.0;

  // 间距
  static const double spacing = 16.0;
  static const double spacingSmall = 8.0;
  static const double spacingLarge = 24.0;

  // 阴影
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  // 字体
  static const String fontFamily = 'Quicksand';

  // 创建应用主题
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        background: backgroundColor,
        surface: cardColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          color: textPrimaryColor,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          color: textPrimaryColor,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: textPrimaryColor,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          color: textPrimaryColor,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          color: textPrimaryColor,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: textPrimaryColor,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: textPrimaryColor,
        ),
        titleSmall: TextStyle(fontFamily: fontFamily, color: textPrimaryColor),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16.0,
          color: textPrimaryColor,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.0,
          color: textPrimaryColor,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.0,
          color: textSecondaryColor,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
          color: buttonTextColor,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          color: textSecondaryColor,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: buttonTextColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonBorderRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputFocusColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: textSecondaryColor,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: textSecondaryColor,
        ),
        errorStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: errorColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputBorderRadius),
            borderSide: const BorderSide(color: inputBorderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputBorderRadius),
            borderSide: const BorderSide(color: inputBorderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(inputBorderRadius),
            borderSide: const BorderSide(color: inputFocusColor, width: 2),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),
    );
  }

  // 登录页面特定主题
  static LoginTheme loginTheme(BuildContext context) {
    return LoginTheme(
      primaryColor: primaryColor,
      accentColor: accentColor,
      errorColor: errorColor,
      pageColorLight: primaryColor.withOpacity(0.8),
      pageColorDark: primaryColor,
      logoWidth: 0.80,
      // titleStyle: const TextStyle(
      //   color: Colors.white,
      //   fontFamily: fontFamily,
      //   fontWeight: FontWeight.w600,
      //   letterSpacing: 2,
      // ),
      bodyStyle: const TextStyle(
        fontFamily: fontFamily,
        color: textPrimaryColor,
      ),
      // textFieldStyle: const TextStyle(
      //   fontFamily: fontFamily,
      //   color: textPrimaryColor,
      // ),
      buttonStyle: const TextStyle(
        fontFamily: fontFamily,
        fontWeight: FontWeight.w600,
        color: buttonTextColor,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 4,
        margin: const EdgeInsets.only(top: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
      ),
      inputTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: inputFocusColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputBorderRadius),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: textSecondaryColor,
        ),
        hintStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          // color: textSecondaryColor,
        ),
        errorStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: errorColor,
        ),
      ),
      buttonTheme: LoginButtonTheme(
        backgroundColor: buttonColor,
        highlightColor: buttonColor.withOpacity(0.8),
        splashColor: accentColor,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonBorderRadius),
        ),
      ),
    );
  }
}
