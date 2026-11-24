import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Colour palette
// ---------------------------------------------------------------------------

/// Colour tokens used across the app.
///
/// Widgets should reference these constants rather than raw hex values.
abstract final class AppColors {
  // Background (dark navy ramp, top to bottom of the gradient).
  static const Color backgroundTop = Color(0xFF101C44);
  static const Color backgroundMid = Color(0xFF0B1330);
  static const Color backgroundBottom = Color(0xFF070B1A);

  // Brand and status colours.
  static const Color primary = Color(0xFF3D8BFF);
  static const Color primaryGlow = Color(0xFF5AA9FF);
  static const Color success = Color(0xFF2ED47A);
  static const Color warning = Color(0xFFFFA726);
  static const Color danger = Color(0xFFFF5252);

  // Text.
  static const Color textPrimary = Color(0xFFF2F5FF);
  static const Color textSecondary = Color(0xFF9AA6C7);
  static const Color textMuted = Color(0xFF6B7794);

  // Glassmorphism (pre-computed ARGB values, so these can stay const).
  /// White at roughly 8% opacity: the frosted card fill.
  static const Color glassFill = Color(0x14FFFFFF);

  /// White at roughly 14% opacity: the card border.
  static const Color glassBorder = Color(0x24FFFFFF);

  /// White at roughly 22% opacity: the top-edge highlight of a card.
  static const Color glassHighlight = Color(0x38FFFFFF);

  /// Black at roughly 35% opacity: soft card shadow.
  static const Color shadow = Color(0x59000000);
}

// ---------------------------------------------------------------------------
// Gradients
// ---------------------------------------------------------------------------

/// Gradient tokens used across the app.
abstract final class AppGradients {
  /// Full-screen background behind every screen.
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.backgroundTop,
      AppColors.backgroundMid,
      AppColors.backgroundBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Primary blue accent, used for the navigation card and active states.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryGlow, AppColors.primary],
  );

  /// Subtle diagonal sheen laid over glass cards.
  static const LinearGradient glassSheen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
  );
}

// ---------------------------------------------------------------------------
// Spacing and radius
// ---------------------------------------------------------------------------

/// Spacing scale on a 4 dp grid.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

/// Corner radius scale.
abstract final class AppRadius {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 28;
  static const double pill = 100;
}

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

/// Builds the Material 3 dark theme for the app.
abstract final class AppTheme {
  /// The app's only theme: a premium dark automotive look.
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF16356B),
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.primaryGlow,
      onSecondary: Color(0xFF04132E),
      tertiary: AppColors.success,
      onTertiary: Color(0xFF03210F),
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.backgroundMid,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerHighest: Color(0xFF1A2650),
      outline: AppColors.textMuted,
      outlineVariant: AppColors.glassBorder,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      // Screens draw the gradient themselves, so the scaffold stays dark navy
      // as a safe fallback.
      scaffoldBackgroundColor: AppColors.backgroundBottom,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      cardTheme: CardThemeData(
        color: AppColors.glassFill,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),

      // Bottom navigation bar: transparent so the gradient shows through.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.primaryGlow : AppColors.textMuted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.textPrimary : AppColors.textMuted,
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.glassFill,
        side: const BorderSide(color: AppColors.glassBorder),
        labelStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.glassFill;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.glassBorder;
        }),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A2650),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  /// Rajdhani for display, headline, and title styles (techy, automotive);
  /// Inter for body and label styles (highly legible at small sizes).
  static TextTheme _buildTextTheme() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
    ).textTheme;

    final body = GoogleFonts.interTextTheme(base).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    TextStyle heading(TextStyle? style, {double letterSpacing = 0.5}) {
      return GoogleFonts.rajdhani(
        textStyle: style,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing,
        color: AppColors.textPrimary,
      );
    }

    return body.copyWith(
      displayLarge: heading(body.displayLarge),
      displayMedium: heading(body.displayMedium),
      displaySmall: heading(body.displaySmall),
      headlineLarge: heading(body.headlineLarge),
      headlineMedium: heading(body.headlineMedium),
      headlineSmall: heading(body.headlineSmall),
      titleLarge: heading(body.titleLarge),
      titleMedium: heading(body.titleMedium, letterSpacing: 0.4),
      titleSmall: heading(body.titleSmall, letterSpacing: 0.4),
    );
  }
}