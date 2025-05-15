import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Extension to add custom color modification method to Color class
extension ColorExtension on Color {
  Color withCustomValues({int? red, int? green, int? blue, int? alpha}) {
    return Color.fromARGB(
      alpha ?? this.alpha,
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}

class AppTheme {
  // 1) Define your color palette
  static const Color primary = Color(0xFFC68642); // glowing gold
  static const Color accent  = Color(0xFF4B2E1F); // dark brown
  static const Color bg      = Color(0xFFFDF8F3); // soft cream
  
  // Dark theme colors
  static const Color darkPrimary = Color(0xFFE0B978); // enhanced gold for dark theme
  static const Color darkAccent  = Color(0xFFF0DFC8); // light cream for dark theme
  static const Color darkBg      = Color(0xFF121212); // dark background (Material dark theme standard)
  static const Color darkCardBg  = Color(0xFF1E1E1E); // slightly lighter for cards
  static const Color darkSurface = Color(0xFF2C2C2C); // surface color for inputs, dialogs
  static const Color darkError   = Color(0xFFCF6679); // error color for dark theme
  
  // 2) Expose ThemeData getters
  static ThemeData get light {
    return ThemeData(
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      fontFamily: 'Cairo', // uses your declared Cairo font
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        background: bg,
        surface: Colors.white,
        brightness: Brightness.light,
      ),

      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: accent,
        ),
        // Add more styles (subtitle1, button, etc.) as needed
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 6,
          shadowColor: primary.withCustomValues(alpha: (0.5 * 255).toInt()),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // You can also configure appBarTheme, bottomNavigationBarTheme, etc.
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        centerTitle: true,
      ),
    );
  }
  
  static ThemeData get dark {
    return ThemeData(
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Cairo',
      useMaterial3: true, // Use Material 3 design
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkAccent,
        background: darkBg,
        surface: darkCardBg,
        error: darkError,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onBackground: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),

      // Enhanced text theme with better contrast
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkAccent,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkAccent,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkAccent,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: Colors.white.withOpacity(0.9),
          height: 1.5,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkPrimary,
        ),
      ),

      // Enhanced input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: darkPrimary.withOpacity(0.3), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: darkError, width: 2),
        ),
        labelStyle: GoogleFonts.cairo(
          color: Colors.white.withOpacity(0.8),
        ),
        hintStyle: GoogleFonts.cairo(
          color: Colors.white.withOpacity(0.5),
        ),
        // Add subtle shadow for depth
        floatingLabelStyle: GoogleFonts.cairo(
          color: darkPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Enhanced button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          shadowColor: darkPrimary.withCustomValues(alpha: (0.4 * 255).toInt()),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Enhanced outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: BorderSide(color: darkPrimary, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Enhanced text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          textStyle: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Enhanced card theme
      cardTheme: CardTheme(
        color: darkCardBg,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Enhanced app bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkCardBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(
          color: darkPrimary,
          size: 24,
        ),
      ),

      // Enhanced dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: darkCardBg,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        contentTextStyle: GoogleFonts.cairo(
          fontSize: 16,
          color: Colors.white.withOpacity(0.9),
        ),
      ),

      // Enhanced bottom sheet theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCardBg,
        modalBackgroundColor: darkCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),

      // Enhanced switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary.withOpacity(0.5);
          }
          return Colors.grey.shade700;
        }),
      ),

      // Enhanced checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.black),
        side: BorderSide(color: Colors.grey.shade400),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Enhanced radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPrimary;
          }
          return Colors.grey.shade400;
        }),
      ),

      // Enhanced slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: darkPrimary,
        inactiveTrackColor: darkPrimary.withOpacity(0.3),
        thumbColor: darkPrimary,
        overlayColor: darkPrimary.withOpacity(0.2),
        valueIndicatorColor: darkPrimary,
        valueIndicatorTextStyle: GoogleFonts.cairo(
          color: Colors.black,
        ),
      ),

      // Enhanced divider theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade800,
        thickness: 1,
        space: 24,
      ),

      // Enhanced tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: darkCardBg,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        textStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 14,
        ),
      ),

      // Enhanced snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardBg,
        contentTextStyle: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}