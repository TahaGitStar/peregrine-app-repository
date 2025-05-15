import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';

/// A reusable loading widget with a customizable message
class LoadingWidget extends StatelessWidget {
  final String message;
  
  const LoadingWidget({
    super.key,
    this.message = 'جاري التحميل...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              strokeWidth: 4,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 24),
          
          // Loading message
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.accent,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}