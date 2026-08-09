import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_radius.dart';
import 'package:delivo/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE9E5FF),
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFDDF2FF),
      onSecondaryContainer: Color(0xFF123F58),
      tertiary: AppColors.success,
      onTertiary: Color(0xFF092B21),
      tertiaryContainer: Color(0xFFD9F8EE),
      onTertiaryContainer: Color(0xFF123D31),
      error: AppColors.destructive,
      onError: Colors.white,
      errorContainer: Color(0xFFFFE2E5),
      onErrorContainer: Color(0xFF7B1F2A),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderLight,
      outlineVariant: Color(0xFFF0F1F6),
      shadow: Color(0x1A171A2B),
      scrim: Color(0x80171A2B),
      inverseSurface: AppColors.textPrimaryLight,
      onInverseSurface: AppColors.backgroundLight,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: Colors.transparent,
    );

    return _baseTheme(
      scheme: scheme,
      scaffoldBackground: AppColors.backgroundLight,
      elevatedSurface: AppColors.surfaceLight,
      destructive: AppColors.destructive,
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Color(0xFF17132D),
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: Color(0xFFECE9FF),
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF071E2B),
      secondaryContainer: Color(0xFF163B50),
      onSecondaryContainer: Color(0xFFDCEFFD),
      tertiary: AppColors.success,
      onTertiary: Color(0xFF092B21),
      tertiaryContainer: Color(0xFF19493A),
      onTertiaryContainer: Color(0xFFD9F8EE),
      error: AppColors.destructiveDark,
      onError: Color(0xFF3B0E14),
      errorContainer: Color(0xFF57222A),
      onErrorContainer: Color(0xFFFFE2E5),
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.surfaceElevatedDark,
      shadow: Colors.black,
      scrim: Color(0xB3000000),
      inverseSurface: AppColors.textPrimaryDark,
      onInverseSurface: AppColors.backgroundDark,
      inversePrimary: AppColors.primary,
      surfaceTint: Colors.transparent,
    );

    return _baseTheme(
      scheme: scheme,
      scaffoldBackground: AppColors.backgroundDark,
      elevatedSurface: AppColors.surfaceElevatedDark,
      destructive: AppColors.destructiveDark,
    );
  }

  static ThemeData _baseTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color elevatedSurface,
    required Color destructive,
  }) {
    final baseTextTheme = AppTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      fontFamily: AppTypography.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: baseTextTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scaffoldBackground,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: scheme.outline),
          borderRadius: AppRadius.borderLarge,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline,
        thickness: 1,
        space: 1,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.borderMedium),
          ),
          textStyle: const WidgetStatePropertyAll(AppTypography.labelLarge),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          side: WidgetStatePropertyAll(BorderSide(color: scheme.outline)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: AppRadius.borderMedium),
          ),
          textStyle: const WidgetStatePropertyAll(AppTypography.labelLarge),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          iconColor: WidgetStatePropertyAll(scheme.onSurface),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: elevatedSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.borderMedium,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMedium,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderMedium,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMedium,
          borderSide: BorderSide(color: destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.borderMedium,
          borderSide: BorderSide(color: destructive, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderMedium,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.borderLarge,
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: scheme.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xLarge),
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
