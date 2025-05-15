import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:peregrine_app_taha/utils/logger.dart';

class RegisterScreen extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterScreen({super.key});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  int _currentStep = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _register() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      _formKey.currentState!.save();
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 2));
        
        AppLogger.i('Registering user: ${_nameController.text} with email: ${_emailController.text}');
        
        if (mounted) {
          // Show success and navigate back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء الحساب بنجاح!',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
          
          // Navigate back after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ أثناء إنشاء الحساب: $e',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى الموافقة على الشروط والأحكام',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }
  
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'إنشاء حساب جديد',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: AppTheme.primary.withOpacity(0.4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepTapped: (step) {
                setState(() {
                  _currentStep = step;
                });
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: const BorderSide(color: AppTheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'السابق',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0)
                        const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentStep < 2 ? _nextStep : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 3,
                            shadowColor: AppTheme.primary.withOpacity(0.3),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentStep < 2 ? 'التالي' : 'إنشاء الحساب',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(
                    'المعلومات الشخصية',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      Text(
                        'الاسم الكامل',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'أدخل اسمك الكامل',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.person, color: AppTheme.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: GoogleFonts.cairo(color: Colors.red),
                        ),
                        style: GoogleFonts.cairo(),
                        validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال اسمك الكامل' : null,
                        textDirection: TextDirection.rtl,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Email Field
                      Text(
                        'البريد الإلكتروني',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'أدخل بريدك الإلكتروني',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.email, color: AppTheme.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: GoogleFonts.cairo(color: Colors.red),
                        ),
                        style: GoogleFonts.cairo(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى إدخال بريدك الإلكتروني';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                            return 'يرجى إدخال بريد إلكتروني صحيح';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        textDirection: TextDirection.ltr,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Phone Field
                      Text(
                        'رقم الهاتف',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: 'أدخل رقم هاتفك',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.phone, color: AppTheme.primary),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: GoogleFonts.cairo(color: Colors.red),
                        ),
                        style: GoogleFonts.cairo(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى إدخال رقم هاتفك';
                          }
                          if (!RegExp(r'^\d{10,}$').hasMatch(val)) {
                            return 'يرجى إدخال رقم هاتف صحيح';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'معلومات الحساب',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Password Field
                      Text(
                        'كلمة المرور',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'أدخل كلمة المرور',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.lock, color: AppTheme.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: GoogleFonts.cairo(color: Colors.red),
                        ),
                        style: GoogleFonts.cairo(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى إدخال كلمة المرور';
                          }
                          if (val.length < 6) {
                            return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password Field
                      Text(
                        'تأكيد كلمة المرور',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'أعد إدخال كلمة المرور',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.primary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 1),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          errorStyle: GoogleFonts.cairo(color: Colors.red),
                        ),
                        style: GoogleFonts.cairo(),
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'يرجى تأكيد كلمة المرور';
                          }
                          if (val != _passwordController.text) {
                            return 'كلمة المرور غير متطابقة';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Strength Indicator
                      if (_passwordController.text.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'قوة كلمة المرور:',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppTheme.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: _getPasswordStrength(),
                              backgroundColor: Colors.grey[300],
                              color: _getPasswordStrengthColor(),
                              borderRadius: BorderRadius.circular(10),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getPasswordStrengthText(),
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: _getPasswordStrengthColor(),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: Text(
                    'الشروط والأحكام',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الشروط والأحكام',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'بالتسجيل في تطبيق بيريجرين، أنت توافق على الشروط والأحكام التالية:',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildTermItem('سيتم استخدام بياناتك الشخصية وفقًا لسياسة الخصوصية الخاصة بنا.'),
                            _buildTermItem('يجب أن تكون جميع المعلومات المقدمة صحيحة ودقيقة.'),
                            _buildTermItem('يحق لنا إنهاء أو تعليق حسابك في حالة انتهاك الشروط.'),
                            _buildTermItem('أنت مسؤول عن الحفاظ على سرية كلمة المرور الخاصة بك.'),
                            _buildTermItem('نحتفظ بالحق في تغيير هذه الشروط في أي وقت.'),
                            const SizedBox(height: 16),
                            Text(
                              'للمزيد من المعلومات، يرجى الاطلاع على سياسة الخصوصية الكاملة.',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Terms Acceptance Checkbox
                      CheckboxListTile(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        title: Text(
                          'أوافق على الشروط والأحكام',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: AppTheme.accent,
                          ),
                        ),
                        activeColor: AppTheme.primary,
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ],
                  ),
                  isActive: _currentStep >= 2,
                  state: StepState.indexed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  double _getPasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) return 0.0;
    
    double strength = 0.0;
    
    // Length check
    if (password.length >= 8) strength += 0.2;
    
    // Contains uppercase
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    
    // Contains lowercase
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
    
    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    
    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    
    return strength;
  }
  
  Color _getPasswordStrengthColor() {
    final strength = _getPasswordStrength();
    
    if (strength < 0.3) return Colors.red;
    if (strength < 0.6) return Colors.orange;
    return Colors.green;
  }
  
  String _getPasswordStrengthText() {
    final strength = _getPasswordStrength();
    
    if (strength < 0.3) return 'ضعيفة';
    if (strength < 0.6) return 'متوسطة';
    return 'قوية';
  }
}