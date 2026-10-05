import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application-wide theme aligned with the Soko Mkononi brand palette.
abstract final class AppTheme {
  /// Primary green used for buttons, tabs, and accents (matches design screenshots).
  static const Color primaryGreen = Color(0xFF22A45D);
  static const Color seedColor = primaryGreen;
  static const Color scaffoldBackground = Color.fromARGB(255, 245, 247, 248);
  static const Color headerBackground = Color.fromARGB(255, 30, 38, 44);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryGreen,
      surface: scaffoldBackground,
      onSurface: const Color.fromARGB(255, 30, 38, 44),
      onSurfaceVariant: const Color.fromARGB(255, 120, 130, 138),
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: headerBackground,
      onPrimary: Colors.white,
    );

    // Poppins matches the rounded, geometric weight used throughout the
    // reference screenshots we've been designing against. Built from the
    // existing Material typography scale (same sizes/weights your app
    // already relies on) so only the glyph shapes change, not the sizing.
    final baseTextTheme =
        Typography.material2021(platform: TargetPlatform.android).black.apply(
              bodyColor: colorScheme.onSurface,
              displayColor: colorScheme.onSurface,
            );
    final textTheme = GoogleFonts.openSansTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      extensions: const [AppColorExtension()],
      appBarTheme: AppBarTheme(
        backgroundColor: headerBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: textTheme,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  /// Kept for backward compatibility — maps to [light].
  static ThemeData get dark => light;
}

@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  const AppColorExtension();

  Color headerBackground(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  Color headerForeground(BuildContext context) => Colors.white;

  Color homeCardColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;

  @override
  AppColorExtension copyWith() => const AppColorExtension();

  @override
  AppColorExtension lerp(ThemeExtension<AppColorExtension>? other, double t) =>
      const AppColorExtension();
}

extension AppColorExtensionContext on BuildContext {
  AppColorExtension get appColors =>
      Theme.of(this).extension<AppColorExtension>() ??
      const AppColorExtension();
}