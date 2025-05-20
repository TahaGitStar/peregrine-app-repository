import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A badge widget to show notification count
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double size;
  final Widget? child;
  
  const NotificationBadge({
    super.key,
    required this.count,
    this.color,
    this.size = 20,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show badge if count is 0
    if (count <= 0) {
      return child ?? const SizedBox.shrink();
    }
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child ?? const SizedBox.shrink(),
        Positioned(
          top: -5,
          right: -5,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color ?? Colors.red,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            constraints: BoxConstraints(
              minWidth: size,
              minHeight: size,
            ),
            child: Center(
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: size * 0.6,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}