import 'package:flutter/material.dart';

/// Centralized light and dark themes for Momukji.
class AppTheme {
  static const Color _seedColor = Color(0xFFFF6B35);

  static ThemeData light() {
    return _buildTheme(
      ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light),
    );
  }

  static ThemeData dark() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ).copyWith(
          // Warm charcoal surfaces keep the dark theme softer and easier to scan.
          surface: const Color(0xFF2B2421),
          surfaceContainerLowest: const Color(0xFF211B18),
          surfaceContainerLow: const Color(0xFF342B27),
          surfaceContainer: const Color(0xFF3B312D),
          surfaceContainerHigh: const Color(0xFF463A35),
          surfaceContainerHighest: const Color(0xFF534640),
          onSurface: const Color(0xFFFFF8F5),
          onSurfaceVariant: const Color(0xFFE6D1C9),
          outline: const Color(0xFFC9B2A9),
          outlineVariant: const Color(0xFF79645C),
        );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          );
        }),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: colorScheme.onSurface),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colorScheme.outline),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
