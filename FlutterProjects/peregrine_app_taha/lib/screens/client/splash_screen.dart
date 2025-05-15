import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import '../login_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  bool _showText = false;
  bool _showSecondaryElements = false;
  
  // For security elements animation
  late AnimationController _securityElementsController;
  late Animation<double> _securityElementsAnimation;
  
  // Security elements
  final List<Map<String, dynamic>> _securityElements = [];
  
  // Background animation
  late AnimationController _backgroundAnimController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    
    // Generate security elements
    _generateSecurityElements();
    
    // Background animation
    _backgroundAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _backgroundAnimController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Scale animation for logo - smoother and slightly faster
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,  // Changed to a smoother curve
    );
    
    // Rotation animation for logo - more subtle
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 0.05,  // Reduced rotation for subtlety
    ).animate(
      CurvedAnimation(
        parent: _rotateController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Fade animation for text
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Slide animation for text
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutQuart,
      ),
    );
    
    // Security elements animation
    _securityElementsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
    
    _securityElementsAnimation = CurvedAnimation(
      parent: _securityElementsController,
      curve: Curves.easeInOut,
    );
    
    _securityElementsController.repeat(reverse: true);
    
    // Start animations in sequence
    _backgroundAnimController.forward();
    _scaleController.forward();
    _rotateController.forward();
    
    // Show text after a delay
    Timer(const Duration(milliseconds: 800), () {
      setState(() {
        _showText = true;
      });
      _fadeController.forward();
      _slideController.forward();
    });
    
    // Show secondary elements after another delay
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _showSecondaryElements = true;
      });
    });

    // Navigate to login after animation completes - slightly longer to appreciate the design
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        // Add a fade transition when navigating
        Navigator.of(context).pushReplacementNamed(
          LoginScreen.routeName,
          result: PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _securityElementsController.dispose();
    _backgroundAnimController.dispose();
    super.dispose();
  }
  
  void _generateSecurityElements() {
    final random = math.Random();
    
    // Security-themed icons and their positions
    final securityIcons = [
      LucideIcons.shield,
      LucideIcons.shieldCheck,
      LucideIcons.shieldAlert,
      LucideIcons.lock,
      LucideIcons.key,
      LucideIcons.fingerprint,
      LucideIcons.scan,
      LucideIcons.eye,
      LucideIcons.badgeCheck,
      LucideIcons.checkCircle,
    ];
    
    // Create security elements with professional positioning
    for (int i = 0; i < 12; i++) {
      // More controlled positioning for a professional look
      final distance = 180.0 + random.nextDouble() * 120;
      final angle = (i * (math.pi * 2 / 12)) + (random.nextDouble() * 0.3);
      
      _securityElements.add({
        'icon': securityIcons[i % securityIcons.length],
        'x': math.cos(angle) * distance,
        'y': math.sin(angle) * distance,
        'size': random.nextDouble() * 8 + 14,  // Larger, more visible icons
        'rotation': random.nextDouble() * 0.4 - 0.2,
        'opacity': random.nextDouble() * 0.3 + 0.2,  // Subtle opacity
        'animationOffset': random.nextDouble() * 1.0,  // For staggered animation
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Professional background with subtle gradient
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      AppTheme.primary.withCustomValues(alpha: (0.03 * 255).toInt()),
                      Colors.white,
                    ],
                    stops: [0.0, 0.5 + 0.1 * math.sin(_backgroundAnimation.value * math.pi), 1.0],
                  ),
                ),
              );
            },
          ),
          
          // Subtle pattern overlay for professional look
          CustomPaint(
            size: Size(screenSize.width, screenSize.height),
            painter: GridPatternPainter(
              color: AppTheme.primary.withCustomValues(alpha: (0.03 * 255).toInt()),
              lineWidth: 0.5,
              gridSize: 30,
            ),
          ),
          
          // Security elements (shields, locks, etc.)
          AnimatedBuilder(
            animation: _securityElementsAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size(screenSize.width, screenSize.height),
                painter: SecurityElementsPainter(
                  elements: _securityElements,
                  progress: _securityElementsController.value,
                  primaryColor: AppTheme.primary,
                  accentColor: AppTheme.accent,
                ),
              );
            },
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with scale and rotate animation
                AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: math.sin(_rotateController.value * 10) * _rotateAnimation.value,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer glow
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.primary.withCustomValues(alpha: (0.2 * 255).toInt()),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.6, 1.0],
                                ),
                              ),
                            ),
                            
                            // Logo container with professional shadow
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withCustomValues(alpha: (0.2 * 255).toInt()),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 6),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withCustomValues(alpha: (0.05 * 255).toInt()),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                              ),
                              child: Image.asset(
                                'assets/images/logo1.png',
                                width: 160,
                                height: 160,
                              ),
                            ),
                            
                            // Shield overlay for security theme
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withCustomValues(alpha: (0.2 * 255).toInt()),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  LucideIcons.shieldCheck,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // App name with fade and slide animation
                if (_showText)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: child,
                        );
                      },
                      child: Column(
                        children: [
                          // Company name with professional styling
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primary.withCustomValues(alpha: (0.9 * 255).toInt()),
                                  AppTheme.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withCustomValues(alpha: (0.3 * 255).toInt()),
                                  blurRadius: 15,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              'بيريجرين',
                              style: GoogleFonts.cairo(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                height: 1.1,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tagline with security shield icon
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withCustomValues(alpha: (0.15 * 255).toInt()),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                color: AppTheme.accent.withCustomValues(alpha: (0.1 * 255).toInt()),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.shield,
                                  color: AppTheme.accent,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الحماية والأمان بين يديك',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 60),
                
                // Professional loading indicator with security theme
                if (_showSecondaryElements)
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        // Progress bar with shield icon
                        Container(
                          width: 220,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 5),
                              ),
                              BoxShadow(
                                color: Colors.black.withCustomValues(alpha: (0.03 * 255).toInt()),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: AppTheme.primary.withCustomValues(alpha: (0.05 * 255).toInt()),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.shield,
                                  color: AppTheme.primary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'جاري تأمين التطبيق...',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(begin: 0.0, end: 0.8),
                                      duration: const Duration(milliseconds: 2000),
                                      curve: Curves.easeInOut,
                                      builder: (context, value, child) {
                                        return LinearProgressIndicator(
                                          value: value,
                                          backgroundColor: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                          borderRadius: BorderRadius.circular(10),
                                          minHeight: 6,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Professional version info with company branding
          if (_showSecondaryElements)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Security certification badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withCustomValues(alpha: (0.08 * 255).toInt()),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.accent.withCustomValues(alpha: (0.1 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 14,
                          color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'خيارك للأمان والحماية',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Version info
                  Text(
                    'الإصدار 1.0.0',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  final Color color;
  final double lineWidth;
  final double gridSize;
  
  GridPatternPainter({
    required this.color,
    required this.lineWidth,
    required this.gridSize,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }
  
  @override
  bool shouldRepaint(GridPatternPainter oldDelegate) => 
      color != oldDelegate.color || 
      lineWidth != oldDelegate.lineWidth || 
      gridSize != oldDelegate.gridSize;
}

class SecurityElementsPainter extends CustomPainter {
  final List<Map<String, dynamic>> elements;
  final double progress;
  final Color primaryColor;
  final Color accentColor;
  
  SecurityElementsPainter({
    required this.elements,
    required this.progress,
    required this.primaryColor,
    required this.accentColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final iconPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;
    
    // Draw security-themed elements (shields, locks, etc.)
    for (final element in elements) {
      // Calculate position with subtle floating animation
      final animationOffset = element['animationOffset'];
      final floatEffect = math.sin((progress + animationOffset) * math.pi * 2) * 10;
      
      final x = center.dx + element['x'];
      final y = center.dy + element['y'] + floatEffect;
      
      // Calculate opacity with subtle pulsing
      final baseOpacity = element['opacity'];
      final pulseEffect = 0.3 * math.sin((progress + animationOffset) * math.pi * 2);
      final opacity = baseOpacity + (pulseEffect > 0 ? pulseEffect : 0);
      final alpha = (opacity * 255).toInt();
      
      // Alternate between primary and accent colors for variety
      final useAccent = elements.indexOf(element) % 3 == 0;
      final iconColor = useAccent 
          ? accentColor.withCustomValues(alpha: alpha)
          : primaryColor.withCustomValues(alpha: alpha);
      
      iconPaint.color = iconColor;
      
      // Draw security icon
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(element['rotation'] + progress * 0.1);
      
      // Draw shield or security icon
      final iconSize = element['size'];
      final iconData = element['icon'];
      
      // Create a TextPainter to draw the icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: iconData.fontFamily,
            color: iconColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      
      // Draw subtle glow around some icons
      if (elements.indexOf(element) % 4 == 0) {
        final glowPaint = Paint()
          ..color = iconColor.withCustomValues(alpha: (alpha ~/ 4))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        
        canvas.drawCircle(Offset.zero, iconSize * 0.8, glowPaint);
      }
      
      canvas.restore();
    }
    
    // Draw connecting lines between some elements for a network security effect
    final linePaint = Paint()
      ..color = primaryColor.withCustomValues(alpha: (0.1 * 255).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    for (int i = 0; i < elements.length; i++) {
      for (int j = i + 1; j < elements.length; j++) {
        // Only connect some elements, not all (for a cleaner look)
        if ((i + j) % 5 != 0) continue;
        
        final element1 = elements[i];
        final element2 = elements[j];
        
        final x1 = center.dx + element1['x'];
        final y1 = center.dy + element1['y'] + math.sin((progress + element1['animationOffset']) * math.pi * 2) * 10;
        
        final x2 = center.dx + element2['x'];
        final y2 = center.dy + element2['y'] + math.sin((progress + element2['animationOffset']) * math.pi * 2) * 10;
        
        // Calculate distance between elements
        final distance = math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2));
        
        // Only draw lines between elements that are not too far apart
        if (distance < size.width * 0.3) {
          // Opacity based on distance (closer = more visible)
          final lineOpacity = 0.2 - (distance / (size.width * 0.5));
          if (lineOpacity <= 0) continue;
          
          linePaint.color = primaryColor.withCustomValues(alpha: (lineOpacity * 255).toInt());
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(SecurityElementsPainter oldDelegate) => true;
}