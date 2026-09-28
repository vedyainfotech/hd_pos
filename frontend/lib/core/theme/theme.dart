import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─────────────────────────────────────────────
  // Primary
  // ─────────────────────────────────────────────

  /// Main brown / terracotta color
  static const Color primary = Color(0xFF9A3F0B);

  /// Darker version for pressed states / headings
  static const Color primaryDark = Color(0xFF7A2F08);

  /// Lighter primary
  static const Color primaryLight = Color(0xFFC7652B);

  /// Very light primary background
  static const Color primarySoft = Color(0xFFF7E8DE);

  // ─────────────────────────────────────────────
  // Backgrounds
  // ─────────────────────────────────────────────

  /// Main application background
  static const Color background = Color(0xFFFAF8F5);

  /// Card / surface background
  static const Color surface = Color(0xFFFFFFFF);

  /// Slightly warm surface
  static const Color surfaceSoft = Color(0xFFFDFBF8);

  /// Input background
  static const Color inputBackground = Color(0xFFFCFBF9);

  // ─────────────────────────────────────────────
  // Text
  // ─────────────────────────────────────────────

  static const Color textPrimary = Color(0xFF2D241F);

  static const Color textSecondary = Color(0xFF6F625A);

  static const Color textTertiary = Color(0xFF95877E);

  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────
  // Borders / Dividers
  // ─────────────────────────────────────────────

  static const Color border = Color(0xFFE3D9D1);

  static const Color borderLight = Color(0xFFEDE6E0);

  static const Color divider = Color(0xFFEAE2DC);

  // ─────────────────────────────────────────────
  // Status
  // ─────────────────────────────────────────────

  static const Color active = Color(0xFF9A3F0B);

  static const Color inactive = Color(0xFFB7B7B7);

  static const Color success = Color(0xFF5F7A52);

  static const Color warning = Color(0xFFC27A28);

  static const Color error = Color(0xFFB63D32);

  // ─────────────────────────────────────────────
  // Other
  // ─────────────────────────────────────────────

  static const Color icon = Color(0xFF715E52);

  static const Color shadow = Color(0x14000000);

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF000000);
}

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    // ───────────────────────────────────────────
    // Color Scheme
    // ───────────────────────────────────────────

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.textOnPrimary,

      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,

      secondary: AppColors.primaryLight,
      onSecondary: AppColors.white,

      secondaryContainer: AppColors.primarySoft,
      onSecondaryContainer: AppColors.primaryDark,

      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,

      surfaceContainerLowest: AppColors.white,
      surfaceContainerLow: AppColors.surfaceSoft,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: Color(0xFFF5F0EC),
      surfaceContainerHighest: Color(0xFFEDE5DF),

      outline: AppColors.border,
      outlineVariant: AppColors.borderLight,

      error: AppColors.error,
      onError: AppColors.white,
    ),

    // ───────────────────────────────────────────
    // Scaffold
    // ───────────────────────────────────────────

    scaffoldBackgroundColor: AppColors.background,

    // ───────────────────────────────────────────
    // App Bar
    // ───────────────────────────────────────────

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),

    // ───────────────────────────────────────────
    // Card
    // ───────────────────────────────────────────

    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
    ),

    // ───────────────────────────────────────────
    // Input Fields
    // ───────────────────────────────────────────

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),

      hintStyle: const TextStyle(
        color: AppColors.textTertiary,
        fontSize: 14,
      ),

      labelStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),

      prefixIconColor: AppColors.icon,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.error,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
    ),

    // ───────────────────────────────────────────
    // Elevated Button
    // ───────────────────────────────────────────

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,

        elevation: 0,

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ───────────────────────────────────────────
    // Outlined Button
    // ───────────────────────────────────────────

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,

        side: const BorderSide(
          color: AppColors.primary,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ───────────────────────────────────────────
    // Text Button
    // ───────────────────────────────────────────

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ───────────────────────────────────────────
    // Switch
    // ───────────────────────────────────────────

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.white;
          }

          return AppColors.white;
        },
      ),

      trackColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }

          return AppColors.inactive;
        },
      ),

      trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }

          return AppColors.border;
        },
      ),

      trackOutlineWidth: const WidgetStatePropertyAll(1),
    ),

    // ───────────────────────────────────────────
    // Checkbox
    // ───────────────────────────────────────────

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color?>(
        (states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }

          return Colors.transparent;
        },
      ),

      checkColor: const WidgetStatePropertyAll(
        AppColors.white,
      ),

      side: const BorderSide(
        color: AppColors.border,
      ),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // ───────────────────────────────────────────
    // Divider
    // ───────────────────────────────────────────

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    // ───────────────────────────────────────────
    // Icon
    // ───────────────────────────────────────────

    iconTheme: const IconThemeData(
      color: AppColors.icon,
      size: 22,
    ),

    // ───────────────────────────────────────────
    // Dialog
    // ───────────────────────────────────────────

    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      titleTextStyle: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),

      contentTextStyle: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),

    // ───────────────────────────────────────────
    // Bottom Sheet
    // ───────────────────────────────────────────

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),

    // ───────────────────────────────────────────
    // Snack Bar
    // ───────────────────────────────────────────

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(
        color: AppColors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // ───────────────────────────────────────────
    // Typography
    // ───────────────────────────────────────────

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),

      headlineMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),

      headlineSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),

      titleLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),

      bodyLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),

      bodyMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),

      bodySmall: TextStyle(
        color: AppColors.textTertiary,
        fontSize: 12,
      ),

      labelLarge: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),

      labelMedium: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}