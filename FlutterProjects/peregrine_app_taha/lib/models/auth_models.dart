// Models related to authentication and user data

/// Represents a login request to the API
class LoginRequest {
  final String username;
  final String password;
  final String role;
  final bool rememberMe;

  LoginRequest({
    required this.username,
    required this.password,
    required this.role,
    this.rememberMe = false,
  });

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'rememberMe': rememberMe,
    };
  }
}

/// Represents an offline login request
class OfflineLoginRequest {
  final String username;
  final String role;
  final DateTime timestamp;

  OfflineLoginRequest({
    required this.username,
    required this.role,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'offlineMode': true,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Represents a user profile with authentication data
class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String role;
  final String? profileImageUrl;
  final Map<String, dynamic> permissions;
  final DateTime lastLogin;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.role,
    this.profileImageUrl,
    required this.permissions,
    required this.lastLogin,
  });

  // Create from JSON response
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      displayName: json['displayName'] ?? json['username'],
      email: json['email'] ?? '',
      role: json['role'],
      profileImageUrl: json['profileImageUrl'],
      permissions: json['permissions'] ?? {},
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : DateTime.now(),
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
      'permissions': permissions,
      'lastLogin': lastLogin.toIso8601String(),
    };
  }
}

/// Represents an authentication token response
class AuthToken {
  final String token;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  AuthToken({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  // Create from JSON response
  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      token: json['token'],
      refreshToken: json['refreshToken'] ?? '',
      expiresAt: json['expiresAt'] != null 
          ? DateTime.parse(json['expiresAt']) 
          : DateTime.now().add(const Duration(hours: 24)),
      tokenType: json['tokenType'] ?? 'Bearer',
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
    };
  }

  // Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  // Get formatted token for API requests
  String get authorizationHeader => '$tokenType $token';
}

/// Represents a complete authentication response
class AuthResponse {
  final UserProfile user;
  final AuthToken token;
  final bool success;
  final String message;

  AuthResponse({
    required this.user,
    required this.token,
    required this.success,
    this.message = '',
  });

  // Create from JSON response
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserProfile.fromJson(json['user']),
      token: AuthToken.fromJson(json['token']),
      success: json['success'] ?? true,
      message: json['message'] ?? '',
    );
  }

  // Create an error response
  factory AuthResponse.error(String errorMessage) {
    return AuthResponse(
      user: UserProfile(
        id: '',
        username: '',
        displayName: '',
        email: '',
        role: '',
        permissions: {},
        lastLogin: DateTime.now(),
      ),
      token: AuthToken(
        token: '',
        refreshToken: '',
        expiresAt: DateTime.now(),
      ),
      success: false,
      message: errorMessage,
    );
  }
}