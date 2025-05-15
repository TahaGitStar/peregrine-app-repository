import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep track of the current locale
  static Locale? _currentLocale;
  
  // Singleton instance
  static AppLocalizations? _instance;
  
  // Getter for the current instance
  static AppLocalizations get instance {
    if (_instance == null) {
      throw Exception('AppLocalizations not initialized. Call AppLocalizations.load() first.');
    }
    return _instance!;
  }

  // Static method to load the current locale from shared preferences
  static Future<Locale> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';
    
    _currentLocale = Locale(languageCode);
    _instance = AppLocalizations(_currentLocale!);
    
    return _currentLocale!;
  }

  // Static method to save the current locale to shared preferences
  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    
    _currentLocale = locale;
    _instance = AppLocalizations(locale);
  }

  // Static method to get the current locale
  static Locale? get currentLocale => _currentLocale;

  // Localized strings
  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Common
      'app_name': 'تطبيق بيريجرين',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ',
      'success': 'تمت العملية بنجاح',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'delete': 'حذف',
      'edit': 'تعديل',
      'confirm': 'تأكيد',
      'back': 'رجوع',
      'next': 'التالي',
      'submit': 'إرسال',
      'yes': 'نعم',
      'no': 'لا',
      
      // Login & Auth
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'register': 'إنشاء حساب',
      'username': 'اسم المستخدم',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'login_success': 'تم تسجيل الدخول بنجاح',
      'login_failed': 'فشل تسجيل الدخول',
      'logout_confirm': 'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
      'biometric_login': 'تسجيل الدخول بالبصمة',
      'biometric_login_prompt': 'قم بالمصادقة للدخول إلى التطبيق',
      'biometric_login_success': 'تم تسجيل الدخول بالبصمة بنجاح',
      'biometric_login_failed': 'فشل تسجيل الدخول بالبصمة',
      
      // Home
      'home': 'الرئيسية',
      'welcome': 'مرحباً',
      'recent_activities': 'النشاطات الأخيرة',
      'view_all': 'عرض الكل',
      
      // Settings
      'settings': 'الإعدادات',
      'account': 'الحساب',
      'profile': 'الملف الشخصي',
      'edit_profile': 'تعديل الملف الشخصي',
      'change_password': 'تغيير كلمة المرور',
      'preferences': 'التفضيلات',
      'notifications': 'الإشعارات',
      'enable_notifications': 'تفعيل الإشعارات',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'theme': 'المظهر',
      'language': 'اللغة',
      'arabic': 'العربية',
      'english': 'English',
      'about': 'حول',
      'about_app': 'عن التطبيق',
      'help_support': 'المساعدة والدعم',
      'version': 'الإصدار',
      'biometric_enable': 'تفعيل تسجيل الدخول بالبصمة',
      'biometric_disable': 'تعطيل تسجيل الدخول بالبصمة',
      'biometric_settings': 'إعدادات البصمة',
      'biometric_subtitle': 'استخدام البصمة لتسجيل الدخول بسرعة',
      'biometric_test': 'اختبار البصمة',
      'biometric_test_prompt': 'هل ترغب في اختبار تسجيل الدخول بالبصمة الآن؟',
      'biometric_test_later': 'لاحقاً',
      'biometric_test_now': 'اختبار الآن',
      'biometric_test_success': 'تم التحقق بنجاح! يمكنك الآن استخدام البصمة لتسجيل الدخول',
      'biometric_test_failed': 'فشل التحقق. يرجى المحاولة مرة أخرى لاحقاً',
      
      // Client specific
      'submit_complaint': 'تقديم شكوى',
      'submit_request': 'تقديم طلب',
      'my_guards': 'أفرادي',
      'security_incidents': 'الحوادث الأمنية',
      'tracking': 'التتبع',
      
      // Support specific
      'support_dashboard': 'لوحة تحكم الدعم',
      'client_management': 'إدارة العملاء',
      'create_client': 'إنشاء حساب عميل',
      'support_requests': 'طلبات الدعم',
      'support_settings': 'إعدادات الدعم',
      'clear_cache': 'مسح ذاكرة التخزين المؤقت',
      'reset_settings': 'إعادة ضبط الإعدادات',
      'font_size': 'حجم الخط',
    },
    'en': {
      // Common
      'app_name': 'Peregrine App',
      'loading': 'Loading...',
      'error': 'An error occurred',
      'success': 'Operation completed successfully',
      'cancel': 'Cancel',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'confirm': 'Confirm',
      'back': 'Back',
      'next': 'Next',
      'submit': 'Submit',
      'yes': 'Yes',
      'no': 'No',
      
      // Login & Auth
      'login': 'Login',
      'logout': 'Logout',
      'register': 'Register',
      'username': 'Username',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'login_success': 'Login successful',
      'login_failed': 'Login failed',
      'logout_confirm': 'Are you sure you want to logout?',
      'biometric_login': 'Biometric Login',
      'biometric_login_prompt': 'Authenticate to access the app',
      'biometric_login_success': 'Biometric login successful',
      'biometric_login_failed': 'Biometric login failed',
      
      // Home
      'home': 'Home',
      'welcome': 'Welcome',
      'recent_activities': 'Recent Activities',
      'view_all': 'View All',
      
      // Settings
      'settings': 'Settings',
      'account': 'Account',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'change_password': 'Change Password',
      'preferences': 'Preferences',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'theme': 'Theme',
      'language': 'Language',
      'arabic': 'Arabic',
      'english': 'English',
      'about': 'About',
      'about_app': 'About App',
      'help_support': 'Help & Support',
      'version': 'Version',
      'biometric_enable': 'Enable Biometric Login',
      'biometric_disable': 'Disable Biometric Login',
      'biometric_settings': 'Biometric Settings',
      'biometric_subtitle': 'Use biometrics for quick login',
      'biometric_test': 'Test Biometrics',
      'biometric_test_prompt': 'Would you like to test biometric login now?',
      'biometric_test_later': 'Later',
      'biometric_test_now': 'Test Now',
      'biometric_test_success': 'Verification successful! You can now use biometrics to login',
      'biometric_test_failed': 'Verification failed. Please try again later',
      
      // Client specific
      'submit_complaint': 'Submit Complaint',
      'submit_request': 'Submit Request',
      'my_guards': 'My Guards',
      'security_incidents': 'Security Incidents',
      'tracking': 'Tracking',
      
      // Support specific
      'support_dashboard': 'Support Dashboard',
      'client_management': 'Client Management',
      'create_client': 'Create Client Account',
      'support_requests': 'Support Requests',
      'support_settings': 'Support Settings',
      'clear_cache': 'Clear Cache',
      'reset_settings': 'Reset Settings',
      'font_size': 'Font Size',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Convenience method to get translations
  static String get(String key) {
    return instance.translate(key);
  }
}

// Extension on BuildContext to easily access translations
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.get(key);
  }
}