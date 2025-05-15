import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peregrine_app_taha/models/auth_models.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
// TODO: Import HTTP package for API calls
// import 'package:http/http.dart' as http;

/// Service for handling authentication-related operations
class AuthService {
  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_profile';
  static const String _offlineSessionKey = 'offline_session';
  static const String _lastUsernameKey = 'last_username';
  
  // API endpoints - to be configured based on actual backend
  // These will be used when implementing the actual API calls
  // static const String _baseUrl = 'https://api.example.com'; // Replace with actual API URL
  // static const String _loginEndpoint = '/auth/login';
  // static const String _refreshTokenEndpoint = '/auth/refresh';
  
  /// Login with username and password
  static Future<AuthResponse> login(LoginRequest request) async {
    try {
      AppLogger.i('Attempting login for user: ${request.username} as ${request.role}');
      
      // TODO: Replace with actual API call when backend is ready
      // Example of how the API call would be structured:
      /*
      final response = await http.post(
        Uri.parse('$_baseUrl$_loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);
        
        // Save auth data
        await _saveAuthData(authResponse);
        
        return authResponse;
      } else {
        // Handle error responses
        final errorData = jsonDecode(response.body);
        return AuthResponse.error(errorData['message'] ?? 'Login failed');
      }
      */
      
      // Temporary mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // Create mock response
      final mockUser = UserProfile(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        username: request.username,
        displayName: request.username,
        email: '${request.username}@example.com',
        role: request.role,
        permissions: _getMockPermissions(request.role),
        lastLogin: DateTime.now(),
      );
      
      final mockToken = AuthToken(
        token: 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock-refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      
      final authResponse = AuthResponse(
        user: mockUser,
        token: mockToken,
        success: true,
        message: 'Login successful',
      );
      
      // Save auth data
      await _saveAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
      AppLogger.e('Login error: $e');
      return AuthResponse.error('حدث خطأ أثناء تسجيل الدخول: $e');
    }
  }
  
  /// Authenticate in offline mode
  static Future<AuthResponse> authenticateOffline(OfflineLoginRequest request) async {
    try {
      AppLogger.i('Attempting offline login for user: ${request.username} as ${request.role}');
      
      // Check if we have stored user data for offline use
      final prefs = await SharedPreferences.getInstance();
      final storedUserJson = prefs.getString(_userKey);
      
      if (storedUserJson != null) {
        // Use stored user data if available
        final userData = jsonDecode(storedUserJson);
        final storedUser = UserProfile.fromJson(userData);
        
        // Verify username matches
        if (storedUser.username.toLowerCase() == request.username.toLowerCase()) {
          // Create offline session
          final offlineSession = {
            ...request.toJson(),
            'userId': storedUser.id,
          };
          
          // Save offline session
          await prefs.setString(_offlineSessionKey, jsonEncode(offlineSession));
          
          // Create mock token for offline session
          final mockToken = AuthToken(
            token: 'offline-token-${DateTime.now().millisecondsSinceEpoch}',
            refreshToken: '',
            expiresAt: DateTime.now().add(const Duration(hours: 12)),
          );
          
          return AuthResponse(
            user: storedUser,
            token: mockToken,
            success: true,
            message: 'تم تسجيل الدخول بدون إنترنت',
          );
        }
      }
      
      // If no stored user or username doesn't match, create a basic offline profile
      final offlineUser = UserProfile(
        id: 'offline-user-${DateTime.now().millisecondsSinceEpoch}',
        username: request.username,
        displayName: request.username,
        email: '',
        role: request.role,
        permissions: _getMockPermissions(request.role, isOffline: true),
        lastLogin: DateTime.now(),
      );
      
      final mockToken = AuthToken(
        token: 'offline-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: '',
        expiresAt: DateTime.now().add(const Duration(hours: 12)),
      );
      
      final authResponse = AuthResponse(
        user: offlineUser,
        token: mockToken,
        success: true,
        message: 'تم تسجيل الدخول بدون إنترنت',
      );
      
      // Save offline session
      final offlineSession = {
        ...request.toJson(),
        'userId': offlineUser.id,
      };
      
      // Get shared preferences instance and save session
      await (await SharedPreferences.getInstance())
          .setString(_offlineSessionKey, jsonEncode(offlineSession));
      
      return authResponse;
    } catch (e) {
      AppLogger.e('Offline login error: $e');
      return AuthResponse.error('حدث خطأ أثناء تسجيل الدخول بدون إنترنت: $e');
    }
  }
  
  /// Logout the current user
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear auth data
      await prefs.remove(_tokenKey);
      await prefs.remove(_offlineSessionKey);
      
      // Note: We don't remove user profile data to support offline login
      
      return true;
    } catch (e) {
      AppLogger.e('Logout error: $e');
      return false;
    }
  }
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      return token != null && !token.isExpired;
    } catch (e) {
      return false;
    }
  }
  
  /// Get the current authentication token
  static Future<AuthToken?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString(_tokenKey);
      
      if (tokenJson == null) return null;
      
      final tokenData = jsonDecode(tokenJson);
      final token = AuthToken.fromJson(tokenData);
      
      // Check if token is expired
      if (token.isExpired) {
        // TODO: Implement token refresh when backend is ready
        return null;
      }
      
      return token;
    } catch (e) {
      AppLogger.e('Get auth token error: $e');
      return null;
    }
  }
  
  /// Get the current user profile
  static Future<UserProfile?> getUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson == null) return null;
      
      final userData = jsonDecode(userJson);
      return UserProfile.fromJson(userData);
    } catch (e) {
      AppLogger.e('Get user profile error: $e');
      return null;
    }
  }
  
  /// Save authentication data
  static Future<void> _saveAuthData(AuthResponse authResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save token
      await prefs.setString(_tokenKey, jsonEncode(authResponse.token.toJson()));
      
      // Save user profile
      await prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));
      
      // Save last username for biometric login
      await prefs.setString(_lastUsernameKey, authResponse.user.username);
    } catch (e) {
      AppLogger.e('Save auth data error: $e');
    }
  }
  
  /// Get the last logged in username
  static Future<String?> getLastLoggedInUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastUsernameKey);
    } catch (e) {
      AppLogger.e('Get last username error: $e');
      return null;
    }
  }
  
  /// Get mock permissions based on role (for development only)
  static Map<String, dynamic> _getMockPermissions(String role, {bool isOffline = false}) {
    if (role == 'client') {
      return {
        'viewReports': true,
        'createRequests': true,
        'viewProfile': true,
        'editProfile': true,
        'offlineAccess': isOffline ? true : false,
      };
    } else if (role == 'support') {
      return {
        'viewReports': true,
        'createReports': true,
        'manageClients': true,
        'viewRequests': true,
        'processRequests': true,
        'viewProfile': true,
        'editProfile': true,
        'offlineAccess': isOffline ? true : false,
      };
    }
    
    return {
      'viewProfile': true,
      'offlineAccess': isOffline ? true : false,
    };
  }
}