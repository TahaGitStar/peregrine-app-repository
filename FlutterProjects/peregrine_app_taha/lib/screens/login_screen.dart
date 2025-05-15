import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peregrine_app_taha/screens/register_screen.dart';
import 'package:peregrine_app_taha/screens/client/client_home_screen.dart';
import 'package:peregrine_app_taha/screens/support/support_dashboard_screen.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/auth_models.dart';
import 'package:peregrine_app_taha/services/auth_service.dart';
import 'package:peregrine_app_taha/services/biometric_service.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final List<bool> _selectedRole = [true, false]; // [0] = client, [1] = support
  String? _errorMessage; // Added error message property
  
  // Animation controllers
  late final AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  // Focus nodes for form fields
  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  
  // Text editing controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Security animation elements
  final List<Map<String, dynamic>> _securityElements = [];
  
  // Biometric authentication
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  
  @override
  void initState() {
    super.initState();
    
    // Generate security elements for background
    _generateSecurityElements();
    
    // Check biometric availability and settings
    _checkBiometricAuthentication();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
      ),
    );
    
    // Slide animation
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutQuart),
      ),
    );
    
    // Start animation
    _animationController.forward();
    
    // Add focus listeners for enhanced UX
    _usernameFocus.addListener(_onFocusChange);
    _passwordFocus.addListener(_onFocusChange);
    
    // Set system UI overlay style for a more immersive experience
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
            systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    // Remove listeners first to prevent callbacks after widget is disposed
    _usernameFocus.removeListener(_onFocusChange);
    _passwordFocus.removeListener(_onFocusChange);
    
    // Then dispose controllers and nodes
    _animationController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    
    super.dispose();
  }
  
  // Check if biometric authentication is available and enabled
  Future<void> _checkBiometricAuthentication() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final isEnabled = await BiometricService.isBiometricLoginEnabled();
    
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
      });
      
      // If biometric is available and enabled, prompt for authentication
      if (isAvailable && isEnabled) {
        // Add a small delay to allow the UI to build
        Future.delayed(const Duration(milliseconds: 500), () {
          _authenticateWithBiometrics();
        });
      }
    }
  }
  
  // Authenticate using biometrics
  Future<void> _authenticateWithBiometrics() async {
    final authenticated = await BiometricService.authenticate();
    
    if (authenticated && mounted) {
      // Simulate successful login
      setState(() {
        _isLoading = true;
      });
      
      AppLogger.i('Biometric authentication successful');
      
      // Create a login request based on the selected role
      final role = _selectedRole[0] ? 'client' : 'support';
      
      try {
        // Get the last logged in username from shared preferences
        final lastUsername = await AuthService.getLastLoggedInUsername();
        
        if (lastUsername != null) {
          // Create login request with the last username
          final loginRequest = LoginRequest(
            username: lastUsername,
            password: '', // Password not needed for biometric auth
            role: role,
          );
          
          // Perform login
          final response = await AuthService.login(loginRequest);
          
          if (response.success && mounted) {
            // Navigate to appropriate screen based on selected role
            if (_selectedRole[0]) { // Client
              Navigator.of(context).pushReplacementNamed(ClientHomeScreen.routeName);
            } else { // Support
              Navigator.of(context).pushReplacementNamed(SupportDashboardScreen.routeName);
            }
          } else {
            // Show error message
            setState(() {
              _isLoading = false;
              _errorMessage = response.message;
            });
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response.message),
                  backgroundColor: Colors.red[700],
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } else {
          // No last username found, show error
          final errorMsg = context.tr('biometric_login_failed');
          setState(() {
            _isLoading = false;
            _errorMessage = errorMsg;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                backgroundColor: Colors.red[700],
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        // Handle error
        final errorMsg = e.toString();
        setState(() {
          _isLoading = false;
          _errorMessage = errorMsg;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  
  void _onFocusChange() {
    setState(() {
      // Trigger rebuild when focus changes for custom focus effects
    });
  }
  
  void _generateSecurityElements() {
    final random = math.Random();
    
    // Security-themed icons for background
    final securityIcons = [
      LucideIcons.shield,
      LucideIcons.shieldCheck,
      LucideIcons.lock,
      LucideIcons.key,
      LucideIcons.fingerprint,
    ];
    
    // Create security elements with professional positioning
    for (int i = 0; i < 8; i++) {
      final distance = 300.0 + random.nextDouble() * 100;
      final angle = (i * (math.pi * 2 / 8)) + (random.nextDouble() * 0.3);
      
      _securityElements.add({
        'icon': securityIcons[i % securityIcons.length],
        'x': math.cos(angle) * distance,
        'y': math.sin(angle) * distance,
        'size': random.nextDouble() * 6 + 10,
        'opacity': random.nextDouble() * 0.08 + 0.02,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background security elements
          Positioned.fill(
            child: CustomPaint(
              painter: SecurityBackgroundPainter(
                elements: _securityElements,
                primaryColor: AppTheme.primary,
              ),
            ),
          ),
          
          // Top decorative wave
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: size.height * 0.28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withCustomValues(alpha: (0.85 * 255).toInt()),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative security patterns
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: SecurityPatternPainter(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.white.withOpacity(0.2) 
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    // Subtle glow effects
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white.withOpacity(0.05)
                              : Colors.white.withCustomValues(alpha: (0.1 * 255).toInt()),
                        ),
                      ),
                    ),
                    
                    Positioned(
                      bottom: -60,
                      left: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (Theme.of(context).brightness == Brightness.dark)
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withCustomValues(alpha: (0.08 * 255).toInt()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Main content with scroll
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      // Top spacing
                      SizedBox(height: size.height * 0.12),
                      
                      // Logo with security badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Logo container with shadow
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withCustomValues(alpha: (0.2 * 255).toInt()),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo1.png',
                              height: 100,
                              width: 100,
                            ),
                          ),
                          
                          // Security badge
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Theme.of(context).colorScheme.surface 
                                      : Colors.white, 
                                  width: 2
                                ),
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
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // App name with professional styling
                      Text(
                        'بيريجرين',
                        style: GoogleFonts.cairo(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      
                      // Tagline
                      Text(
                        'الحماية والأمان بين يديك',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login form with enhanced styling
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withCustomValues(alpha: (0.08 * 255).toInt()),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.black.withCustomValues(alpha: (0.03 * 255).toInt()),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form title
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        LucideIcons.logIn,
                                        size: 18,
                                        color: AppTheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تسجيل الدخول',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Username field with enhanced styling
                              _buildAnimatedTextField(
                                controller: _usernameController,
                                focusNode: _usernameFocus,
                                label: 'اسم المستخدم',
                                hint: 'أدخل اسم المستخدم',
                                prefixIcon: LucideIcons.user,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'برجاء إدخال اسم المستخدم';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _username = val!.trim(),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password field with enhanced styling
                              _buildAnimatedTextField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                label: 'كلمة المرور',
                                hint: 'أدخل كلمة المرور',
                                prefixIcon: LucideIcons.lock,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                    size: 20,
                                    color: AppTheme.accent.withCustomValues(alpha: (0.6 * 255).toInt()),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'برجاء إدخال كلمة المرور';
                                  }
                                  return null;
                                },
                                onSaved: (val) => _password = val!,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Error message display
                              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.alertCircle,
                                        color: Colors.red[700],
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              
                              if (_errorMessage != null && _errorMessage!.isNotEmpty)
                                const SizedBox(height: 16),
                              
                              // Remember me checkbox
                              Row(
                                children: [
                                  SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: Checkbox(
                                      value: _rememberMe,
                                      activeColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'تذكرني',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Implement forgot password
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'نسيت كلمة المرور؟',
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Role selection with enhanced styling
                              Text(
                                'اختر نوع الحساب:',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.accent,
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Custom role selector
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withCustomValues(alpha: (0.05 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    // Client role
                                    Expanded(
                                      child: _buildRoleSelector(
                                        index: 0,
                                        icon: LucideIcons.user,
                                        label: 'عميل',
                                      ),
                                    ),
                                    
                                    // Support role
                                    Expanded(
                                      child: _buildRoleSelector(
                                        index: 1,
                                        icon: LucideIcons.helpCircle,
                                        label: 'فريق الدعم',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Login buttons
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                                strokeWidth: 3,
                              ),
                            )
                          : Column(
                              children: [
                                // Main login button with enhanced styling
                                _buildGradientButton(
                                  onPressed: _handleLogin,
                                  icon: LucideIcons.logIn,
                                  label: 'تسجيل الدخول',
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Offline login button with enhanced styling
                                _buildOutlinedButton(
                                  onPressed: _handleOfflineLogin,
                                  icon: LucideIcons.wifi,
                                  label: 'الدخول بدون إنترنت',
                                ),
                                
                                // Biometric login button (only shown if available and enabled)
                                if (_isBiometricAvailable && _isBiometricEnabled) ...[
                                  const SizedBox(height: 16),
                                  _buildOutlinedButton(
                                    onPressed: _authenticateWithBiometrics,
                                    icon: LucideIcons.fingerprint,
                                    label: 'تسجيل الدخول بالبصمة',
                                  ),
                                ],
                              ],
                            ),
                      
                      // Register link
                      if (!isKeyboardVisible) ...[
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, RegisterScreen.routeName);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'إنشاء حساب جديد',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      
                      // Bottom spacing
                      SizedBox(height: isKeyboardVisible ? 20 : 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Security certification badge at bottom
          if (!isKeyboardVisible)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
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
                        LucideIcons.shield,
                        size: 14,
                        color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تطبيق آمن ومحمي 100%',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Custom animated text field with enhanced styling
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    required String? Function(String?) validator,
    required void Function(String?) onSaved,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused 
              ? AppTheme.primary 
              : AppTheme.accent.withCustomValues(alpha: (0.1 * 255).toInt()),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with animation
          if (controller.text.isNotEmpty || isFocused)
            Padding(
              padding: const EdgeInsets.only(top: 12, right: 16, left: 16),
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: isFocused 
                      ? AppTheme.primary 
                      : const Color.fromARGB(255, 247, 177, 28).withCustomValues(alpha: (0.6 * 255).toInt()),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          // Text field
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color.fromARGB(255, 255, 200, 34),
            ),
            decoration: InputDecoration(
              hintText: controller.text.isEmpty ? hint : null,
              hintStyle: GoogleFonts.cairo(
                fontSize: 16,
                color: AppTheme.accent.withCustomValues(alpha: (0.4 * 255).toInt()),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(right: 12, left: 16),
                child: Icon(
                  prefixIcon,
                  size: 20,
                  color: isFocused 
                      ? AppTheme.primary 
                      : const Color.fromARGB(255, 232, 174, 0).withCustomValues(alpha: (0.5 * 255).toInt()),
                ),
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                top: controller.text.isNotEmpty || isFocused ? 8 : 16,
                bottom: 16,
                right: 12,
                left: 16,
              ),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            validator: validator,
            onSaved: onSaved,
            onChanged: (value) {
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
  
  // Custom role selector with enhanced styling
  Widget _buildRoleSelector({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedRole[index];
    
    return GestureDetector(
      onTap: () {
        setState(() {
          for (int i = 0; i < _selectedRole.length; i++) {
            _selectedRole[i] = i == index;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : const Color.fromARGB(255, 75, 62, 31),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Gradient button with enhanced styling
  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primary,
            Color(0xFFD69652), // Slightly lighter version of AppTheme.primary
          ],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withCustomValues(alpha: (0.3 * 255).toInt()),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withCustomValues(alpha: (0.1 * 255).toInt()),
          highlightColor: Colors.white.withCustomValues(alpha: (0.05 * 255).toInt()),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Outlined button with enhanced styling
  Widget _buildOutlinedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withCustomValues(alpha: (0.5 * 255).toInt()),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
          highlightColor: AppTheme.primary.withCustomValues(alpha: (0.05 * 255).toInt()),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        // Get selected role
        final role = _selectedRole[0] ? 'client' : 'support';
        
        // Create login request using our model
        final loginRequest = LoginRequest(
          username: _username,
          password: _password,
          role: role,
          rememberMe: _rememberMe,
        );
        
        AppLogger.i('Preparing login request for user: $_username as $role');
        
        // Call authentication service
        final response = await AuthService.login(loginRequest);
        
        // Check authentication result
        if (!response.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        
        // Navigate based on authenticated user role
        if (!mounted) return;
        
        if (response.user.role == 'client') {
          Navigator.pushReplacementNamed(context, ClientHomeScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, SupportDashboardScreen.routeName);
        }
      } catch (e) {
        // Handle different types of API errors
        if (!mounted) return;
        
        String errorMessage = 'خطأ في تسجيل الدخول';
        
        // Example of error handling based on API response
        // if (e is NetworkException) {
        //   errorMessage = 'خطأ في الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت';
        // } else if (e is AuthException) {
        //   errorMessage = e.message; // Use error message from API
        // }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
  
  void _handleOfflineLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      _formKey.currentState!.save();

      try {
        // Get selected role
        final role = _selectedRole[0] ? 'client' : 'support';
        
        AppLogger.i('Initiating offline login as: $role');
        
        // Create offline login request using our model
        final offlineRequest = OfflineLoginRequest(
          username: _username,
          role: role,
        );
        
        // Call authentication service for offline login
        final response = await AuthService.authenticateOffline(offlineRequest);
        
        // Check authentication result
        if (!response.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        
        // Navigate based on authenticated user role
        if (!mounted) return;
        
        if (response.user.role == 'client') {
          Navigator.pushReplacementNamed(context, ClientHomeScreen.routeName);
        } else {
          Navigator.pushReplacementNamed(context, SupportDashboardScreen.routeName);
        }
      } catch (e) {
        // Handle offline authentication errors
        if (!mounted) return;
        
        String errorMessage = 'خطأ في تسجيل الدخول بدون إنترنت';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }
}

// Custom wave clipper for top decoration
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;
    
    path.lineTo(0, height * 0.8);
    
    // First curve
    final firstControlPoint = Offset(width * 0.25, height);
    final firstEndPoint = Offset(width * 0.5, height * 0.85);
    path.quadraticBezierTo(
      firstControlPoint.dx, firstControlPoint.dy,
      firstEndPoint.dx, firstEndPoint.dy,
    );
    
    // Second curve
    final secondControlPoint = Offset(width * 0.75, height * 0.7);
    final secondEndPoint = Offset(width, height * 0.75);
    path.quadraticBezierTo(
      secondControlPoint.dx, secondControlPoint.dy,
      secondEndPoint.dx, secondEndPoint.dy,
    );
    
    path.lineTo(width, 0);
    path.close();
    
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// Security background painter
class SecurityBackgroundPainter extends CustomPainter {
  final List<Map<String, dynamic>> elements;
  final Color primaryColor;
  
  SecurityBackgroundPainter({
    required this.elements,
    required this.primaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (final element in elements) {
      final x = center.dx + element['x'];
      final y = center.dy + element['y'];
      final iconSize = element['size'];
      final opacity = element['opacity'];
      final iconData = element['icon'];
      
      // Draw security icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(iconData.codePoint),
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: iconData.fontFamily,
            color: primaryColor.withCustomValues(alpha: (opacity * 255).toInt()),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas, 
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }
  
  @override
  bool shouldRepaint(SecurityBackgroundPainter oldDelegate) => false;
}

// Security pattern painter for decorative elements
class SecurityPatternPainter extends CustomPainter {
  final Color color;
  
  SecurityPatternPainter({
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Draw hexagonal security pattern
    final hexSize = size.width / 8;
    final rows = (size.height / hexSize).ceil() + 1;
    final cols = (size.width / hexSize).ceil() + 1;
    
    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        final isOffset = r % 2 == 0;
        final xCenter = c * hexSize + (isOffset ? hexSize / 2 : 0);
        final yCenter = r * hexSize * 0.75;
        
        // Draw hexagon
        final path = Path();
        for (int i = 0; i < 6; i++) {
          final angle = (i * 60) * math.pi / 180;
          final x = xCenter + hexSize / 2 * math.cos(angle);
          final y = yCenter + hexSize / 2 * math.sin(angle);
          
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }
  
  @override
  bool shouldRepaint(SecurityPatternPainter oldDelegate) => 
      color != oldDelegate.color;
}