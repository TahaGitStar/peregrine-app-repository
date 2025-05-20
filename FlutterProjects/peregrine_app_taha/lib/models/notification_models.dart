// Models related to notifications

import 'package:flutter/material.dart';

/// Notification type enum
enum NotificationType {
  newRequest,
  newComplaint,
  requestUpdate,
  complaintUpdate,
  system,
}

/// Extension for NotificationType
extension NotificationTypeExtension on NotificationType {
  String get arabicLabel {
    switch (this) {
      case NotificationType.newRequest:
        return 'طلب جديد';
      case NotificationType.newComplaint:
        return 'شكوى جديدة';
      case NotificationType.requestUpdate:
        return 'تحديث طلب';
      case NotificationType.complaintUpdate:
        return 'تحديث شكوى';
      case NotificationType.system:
        return 'إشعار نظام';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.newRequest:
        return Icons.assignment_add;
      case NotificationType.newComplaint:
        return Icons.warning_amber;
      case NotificationType.requestUpdate:
        return Icons.update;
      case NotificationType.complaintUpdate:
        return Icons.feedback;
      case NotificationType.system:
        return Icons.notifications;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.newRequest:
        return Colors.blue;
      case NotificationType.newComplaint:
        return Colors.orange;
      case NotificationType.requestUpdate:
        return Colors.green;
      case NotificationType.complaintUpdate:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey;
    }
  }
}

/// Notification model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final bool isRead;
  
  // Required context information
  final String? clientName;
  final String? clientId;
  final String? branchName;
  final String? branchId;
  final String? contractType;
  final String? requestId;
  final String? operationType;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.clientName,
    this.clientId,
    this.branchName,
    this.branchId,
    this.contractType,
    this.requestId,
    this.operationType,
  });

  /// Create a copy of this notification with some fields updated
  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationType? type,
    bool? isRead,
    String? clientName,
    String? clientId,
    String? branchName,
    String? branchId,
    String? contractType,
    String? requestId,
    String? operationType,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      clientName: clientName ?? this.clientName,
      clientId: clientId ?? this.clientId,
      branchName: branchName ?? this.branchName,
      branchId: branchId ?? this.branchId,
      contractType: contractType ?? this.contractType,
      requestId: requestId ?? this.requestId,
      operationType: operationType ?? this.operationType,
    );
  }

  /// Get a formatted context string for display
  String get contextInfo {
    final List<String> contextParts = [];
    
    if (clientName != null) {
      contextParts.add('العميل: $clientName');
    }
    
    if (branchName != null) {
      contextParts.add('الفرع: $branchName');
    }
    
    if (contractType != null) {
      final String contractTypeDisplay = contractType == 'حراسة' ? 'عقد حراسة' : 'عقد سائقين';
      contextParts.add('نوع العقد: $contractTypeDisplay');
    }
    
    if (operationType != null) {
      contextParts.add('نوع العملية: $operationType');
    }
    
    if (requestId != null) {
      contextParts.add('رقم الطلب: $requestId');
    }
    
    return contextParts.join(' | ');
  }
}

/// Mock data for notifications
List<AppNotification> getMockNotifications() {
  return [
    AppNotification(
      id: 'NOTIF-001',
      title: 'طلب خدمة جديد',
      message: 'تم استلام طلب خدمة جديد من العميل أحمد محمد',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      type: NotificationType.newRequest,
      clientName: 'أحمد محمد',
      clientId: 'CLT-123',
      branchName: 'فرع صنعاء',
      branchId: 'branch-001',
      contractType: 'حراسة',
      requestId: 'REQ-001',
      operationType: 'طلب خدمة',
    ),
    AppNotification(
      id: 'NOTIF-002',
      title: 'شكوى جديدة',
      message: 'تم استلام شكوى جديدة من العميل سارة علي',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      type: NotificationType.newComplaint,
      clientName: 'سارة علي',
      clientId: 'CLT-456',
      branchName: 'فرع عدن',
      branchId: 'branch-002',
      contractType: 'سياقة',
      requestId: 'COMP-001',
      operationType: 'تقديم شكوى',
    ),
    AppNotification(
      id: 'NOTIF-003',
      title: 'تحديث طلب',
      message: 'تم تحديث حالة الطلب إلى قيد المعالجة',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      type: NotificationType.requestUpdate,
      clientName: 'خالد عبدالله',
      clientId: 'CLT-789',
      branchName: 'فرع تعز',
      branchId: 'branch-003',
      contractType: 'حراسة',
      requestId: 'REQ-003',
      operationType: 'تحديث طلب',
    ),
    AppNotification(
      id: 'NOTIF-004',
      title: 'تحديث شكوى',
      message: 'تم الرد على الشكوى المقدمة من العميل نورا حسن',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      type: NotificationType.complaintUpdate,
      clientName: 'نورا حسن',
      clientId: 'CLT-101',
      branchName: 'فرع الحديدة',
      branchId: 'branch-004',
      contractType: 'حراسة',
      requestId: 'COMP-002',
      operationType: 'تحديث شكوى',
    ),
    AppNotification(
      id: 'NOTIF-005',
      title: 'إشعار نظام',
      message: 'تم تحديث النظام إلى الإصدار الجديد',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      type: NotificationType.system,
    ),
  ];
}