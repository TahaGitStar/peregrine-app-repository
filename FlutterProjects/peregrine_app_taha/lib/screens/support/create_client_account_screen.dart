import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';

class CreateClientAccountScreen extends StatefulWidget {
  static const String routeName = '/create-client-account';
  
  const CreateClientAccountScreen({super.key});

  @override
  State<CreateClientAccountScreen> createState() => _CreateClientAccountScreenState();
}

class _CreateClientAccountScreenState extends State<CreateClientAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  // List of authorized support users who can create client accounts
  // In a real app, this would come from a secure backend or auth service
  final List<String> _authorizedUsers = ['support1', 'support2'];
  
  // Current user - in a real app, this would be fetched from a secure auth service
  // For demo purposes, we're hardcoding it
  final String _currentUser = 'support1'; // Change to 'support3' to test unauthorized access
  
  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    
    // Check authorization when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthorization();
      }
    });
  }
  
  // Check if current user is authorized to access this screen
  void _checkAuthorization() {
    if (!_authorizedUsers.contains(_currentUser)) {
      // Show access denied dialog and navigate back
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            'غير مصرح بالوصول',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'ليس لديك صلاحية للوصول إلى هذه الصفحة',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: Text(
                'عودة',
                style: GoogleFonts.cairo(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
  
  // Create client account
  Future<void> _createAccount() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Prepare request data
      final Map<String, dynamic> requestData = {
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'password': _passwordController.text,
      };
      
      // Make API call
      final response = await http.post(
        Uri.parse('https://api.example.com/api/auth/register'), // Replace with actual API endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );
      
      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء حساب العميل بنجاح',
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
          
          // Navigate back to dashboard
          Navigator.of(context).pop();
        }
      } else {
        // Error
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'حدث خطأ أثناء إنشاء الحساب. الرجاء المحاولة مرة أخرى',
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
    } catch (e) {
      // Handle exceptions
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ في الاتصال. الرجاء التحقق من اتصالك بالإنترنت',
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
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'إنشاء حساب عميل',
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
      body: _isLoading
          ? _buildLoadingIndicator()
          : _buildForm(),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'جاري إنشاء الحساب...',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.userPlus,
                    size: 50,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'إنشاء حساب عميل جديد',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يرجى ملء جميع الحقول المطلوبة أدناه',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.accent.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Full Name field
            TextFormField(
              controller: _fullNameController,
              decoration: InputDecoration(
                labelText: 'الاسم الكامل',
                labelStyle: GoogleFonts.cairo(),
                hintText: 'أدخل الاسم الكامل للعميل',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                prefixIcon: const Icon(LucideIcons.user, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Username field
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'اسم المستخدم',
                labelStyle: GoogleFonts.cairo(),
                hintText: 'أدخل اسم المستخدم',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                prefixIcon: const Icon(LucideIcons.atSign, color: AppTheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال اسم المستخدم';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'كلمة المرور',
                labelStyle: GoogleFonts.cairo(),
                hintText: 'أدخل كلمة المرور',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                prefixIcon: const Icon(LucideIcons.lock, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppTheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 20),
            
            // Confirm Password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                labelStyle: GoogleFonts.cairo(),
                hintText: 'أعد إدخال كلمة المرور',
                hintStyle: GoogleFonts.cairo(color: Colors.grey),
                prefixIcon: const Icon(LucideIcons.key, color: AppTheme.primary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                    color: AppTheme.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.cairo(),
              textDirection: TextDirection.rtl,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمات المرور غير متطابقة';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 30),
            
            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.x),
                    label: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Create account button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _createAccount,
                    icon: const Icon(LucideIcons.userPlus),
                    label: Text(
                      'إنشاء الحساب',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}