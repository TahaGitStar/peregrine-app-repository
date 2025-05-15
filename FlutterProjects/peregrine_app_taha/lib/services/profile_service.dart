import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _profileImageKey = 'profile_image';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userInitialsKey = 'user_initials';

  // Save profile image to shared preferences
  static Future<bool> saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_profileImageKey, imagePath);
    } catch (e) {
      debugPrint('Error saving profile image: $e');
      return false;
    }
  }

  // Get profile image path from shared preferences
  static Future<String?> getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profileImageKey);
    } catch (e) {
      debugPrint('Error getting profile image: $e');
      return null;
    }
  }

  // Save user name to shared preferences
  static Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Also update initials when name changes
      final initials = _generateInitials(name);
      await prefs.setString(_userInitialsKey, initials);
      
      return await prefs.setString(_userNameKey, name);
    } catch (e) {
      debugPrint('Error saving user name: $e');
      return false;
    }
  }

  // Get user name from shared preferences
  static Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey) ?? 'المستخدم';
    } catch (e) {
      debugPrint('Error getting user name: $e');
      return 'المستخدم';
    }
  }

  // Save user email to shared preferences
  static Future<bool> saveUserEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userEmailKey, email);
    } catch (e) {
      debugPrint('Error saving user email: $e');
      return false;
    }
  }

  // Get user email from shared preferences
  static Future<String> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey) ?? 'user@example.com';
    } catch (e) {
      debugPrint('Error getting user email: $e');
      return 'user@example.com';
    }
  }

  // Get user initials from shared preferences
  static Future<String> getUserInitials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? initials = prefs.getString(_userInitialsKey);
      
      // If initials don't exist, generate from name
      if (initials == null || initials.isEmpty) {
        final name = await getUserName();
        initials = _generateInitials(name);
        await prefs.setString(_userInitialsKey, initials);
      }
      
      return initials;
    } catch (e) {
      debugPrint('Error getting user initials: $e');
      return 'U';
    }
  }

  // Generate initials from name
  static String _generateInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    } else {
      return '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase();
    }
  }

  // Pick image from gallery or camera
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        await saveProfileImage(imageFile.path);
        return imageFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }
}