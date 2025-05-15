import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
import 'package:peregrine_app_taha/utils/app_localizations.dart';


/// Service for handling biometric authentication
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_login_enabled';

  /// Check if biometric authentication is available on the device
  static Future<bool> isBiometricAvailable() async {
    try {
      // Check if biometric hardware is available
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      
      if (canAuthenticate) {
        // Get available biometrics
        final availableBiometrics = await _localAuth.getAvailableBiometrics();
        
        // Log available biometrics
        AppLogger.i('Available biometrics: $availableBiometrics');
        
        // Return true if any biometric is available
        return availableBiometrics.isNotEmpty;
      }
      
      return false;
    } on PlatformException catch (e) {
      AppLogger.e('Biometric availability check error: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.e('Biometric availability check error: $e');
      return false;
    }
  }

  /// Check if biometric login is enabled by the user
  static Future<bool> isBiometricLoginEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      AppLogger.e('Biometric login enabled check error: $e');
      return false;
    }
  }

  /// Enable or disable biometric login
  static Future<bool> setBiometricLoginEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, enabled);
      return true;
    } catch (e) {
      AppLogger.e('Set biometric login enabled error: $e');
      return false;
    }
  }

  /// Error message from the last authentication attempt
  static String? _lastErrorMessage;
  
  /// Get the error message from the last authentication attempt
  static String? get lastErrorMessage => _lastErrorMessage;
  
  /// Authenticate using biometrics
  static Future<bool> authenticate() async {
    // Reset error message
    _lastErrorMessage = null;
    
    // First check if biometric is available
    final isBiometricAvailable = await BiometricService.isBiometricAvailable();
    if (!isBiometricAvailable) {
      _lastErrorMessage = 'Biometric authentication is not available on this device';
      AppLogger.e(_lastErrorMessage!);
      return false;
    }
    
    try {
      // Get the current locale
      final locale = AppLocalizations.currentLocale;
      final isArabic = locale?.languageCode == 'ar' || locale == null;
      
      // Get the localized reason
      final localizedReason = isArabic
          ? 'قم بالمصادقة للدخول إلى التطبيق'
          : 'Authenticate to access the app';
      
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      
      return authenticated;
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        _lastErrorMessage = 'Biometric authentication not available';
      } else if (e.code == auth_error.notEnrolled) {
        _lastErrorMessage = 'No fingerprints enrolled on this device. Please add fingerprints in your device settings.';
      } else if (e.code == auth_error.lockedOut) {
        _lastErrorMessage = 'Biometric authentication locked out due to too many attempts. Please try again later.';
      } else if (e.code == auth_error.permanentlyLockedOut) {
        _lastErrorMessage = 'Biometric authentication permanently locked out. Please unlock your device using your PIN/pattern/password.';
      } else {
        _lastErrorMessage = 'Biometric authentication error: ${e.message}';
      }
      AppLogger.e(_lastErrorMessage!);
      return false;
    } catch (e) {
      _lastErrorMessage = 'Biometric authentication error: $e';
      AppLogger.e(_lastErrorMessage!);
      return false;
    }
  }
}