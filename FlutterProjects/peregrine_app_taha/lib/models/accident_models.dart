// Models related to security accidents and incident reports

import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';

/// Represents a security incident or accident report
class AccidentReport {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime dateTime;
  final String status;
  final String? location;
  final List<String> mediaUrls;
  final List<AccidentComment> comments;

  AccidentReport({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.dateTime,
    required this.status,
    this.location,
    this.mediaUrls = const [],
    this.comments = const [],
  });

  /// Get the color associated with the status
  Color get statusColor {
    switch (status) {
      case 'معلق':
        return Colors.orange;
      case 'تم المعالجة':
        return Colors.green;
      case 'مرفوض':
        return Colors.red;
      case 'قيد المراجعة':
        return AppTheme.primary;
      default:
        return Colors.grey;
    }
  }

  /// Get a short preview of the description (first 100 characters)
  String get descriptionPreview {
    if (description.length <= 100) {
      return description;
    }
    return '${description.substring(0, 97)}...';
  }
}

/// Represents a comment or update on an accident report
class AccidentComment {
  final String id;
  final String content;
  final String author;
  final DateTime dateTime;
  final bool isAdminComment;

  AccidentComment({
    required this.id,
    required this.content,
    required this.author,
    required this.dateTime,
    this.isAdminComment = false,
  });
}

/// Response wrapper for accident reports
class AccidentReportsResponse {
  final List<AccidentReport>? reports;
  final String? errorMessage;
  final bool isSuccess;

  AccidentReportsResponse.success(this.reports)
      : errorMessage = null,
        isSuccess = true;

  AccidentReportsResponse.error(this.errorMessage)
      : reports = null,
        isSuccess = false;
}

/// Available accident types
class AccidentTypes {
  static const List<String> types = [
    'سرقة',
    'تخريب',
    'دخول غير مصرح',
    'حريق',
    'طارئ طبي',
    'أخرى',
  ];
}