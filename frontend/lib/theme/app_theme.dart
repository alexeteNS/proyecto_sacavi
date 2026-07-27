import 'package:flutter/material.dart';

class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF0A2B6E);       // Deep navy blue
  static const Color primaryLight = Color(0xFF1A3D8F);  // Slightly lighter navy
  static const Color accent = Color(0xFF1565C0);        // Bright blue accent
  static const Color accentLight = Color(0xFF1976D2);   // Lighter blue

  // Status colors
  static const Color success = Color(0xFF2E7D32);       // Green approved
  static const Color successLight = Color(0xFF4CAF50);  // Lighter green
  static const Color successBg = Color(0xFFE8F5E9);     // Green background
  static const Color error = Color(0xFFC62828);         // Red error
  static const Color errorLight = Color(0xFFEF5350);    // Lighter red
  static const Color errorBg = Color(0xFFFFEBEE);       // Red background
  static const Color warning = Color(0xFFF9A825);       // Yellow warning
  static const Color warningBg = Color(0xFFFFF8E1);     // Yellow background
  static const Color inactive = Color(0xFF9E9E9E);      // Gray inactive

  // Status badge colors
  static const Color activeChip = Color(0xFF1B5E20);
  static const Color inactiveChip = Color(0xFF616161);
  static const Color entradaColor = Color(0xFF1565C0);
  static const Color salidaColor = Color(0xFF6A1B9A);

  // Backgrounds
  static const Color background = Color(0xFFF0F4FF);    // Light blue-gray background
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color navBar = Color(0xFF0A2B6E);

  // Text
  static const Color textPrimary = Color(0xFF0D1B3E);
  static const Color textSecondary = Color(0xFF546E7A);
  static const Color textLight = Color(0xFF90A4AE);
  static const Color textWhite = Colors.white;

  // Borders
  static const Color border = Color(0xFFDDE3EE);
  static const Color divider = Color(0xFFEEF2FF);

  // Online indicator
  static const Color online = Color(0xFF00C853);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBar,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF5C7EC7),
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 10),
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
    letterSpacing: 0.5,
  );
}
