import 'package:flutter/material.dart';

enum RequestStatus {
  new_request,
  pending,
  resolved,
}

extension RequestStatusExtension on RequestStatus {
  String get arabicLabel {
    switch (this) {
      case RequestStatus.new_request:
        return 'جديد';
      case RequestStatus.pending:
        return 'قيد المعالجة';
      case RequestStatus.resolved:
        return 'تم الحل';
    }
  }

  Color get color {
    switch (this) {
      case RequestStatus.new_request:
        return Colors.blue;
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.resolved:
        return Colors.green;
    }
  }
}

class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isFromClient;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isFromClient,
  });
}

class SupportRequest {
  final String id;
  final String title;
  final String clientName;
  final String clientId;
  final DateTime createdAt;
  final RequestStatus status;
  final List<Message> messages;

  SupportRequest({
    required this.id,
    required this.title,
    required this.clientName,
    required this.clientId,
    required this.createdAt,
    required this.status,
    required this.messages,
  });
}

// Mock data for support requests
List<SupportRequest> getMockSupportRequests() {
  return [
    SupportRequest(
      id: 'REQ-001',
      title: 'مشكلة في تسجيل الدخول',
      clientName: 'أحمد محمد',
      clientId: 'CLT-123',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: RequestStatus.new_request,
      messages: [
        Message(
          id: 'MSG-001',
          content: 'لا أستطيع تسجيل الدخول إلى حسابي، يظهر خطأ غير معروف',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isFromClient: true,
        ),
      ],
    ),
    SupportRequest(
      id: 'REQ-002',
      title: 'استفسار عن الخدمات المتاحة',
      clientName: 'سارة علي',
      clientId: 'CLT-456',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: RequestStatus.pending,
      messages: [
        Message(
          id: 'MSG-002',
          content: 'أريد معرفة المزيد عن الخدمات المتاحة في التطبيق',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isFromClient: true,
        ),
        Message(
          id: 'MSG-003',
          content: 'بالتأكيد، يمكنني مساعدتك. ما هي الخدمة التي تهتم بها تحديداً؟',
          timestamp: DateTime.now().subtract(const Duration(hours: 23)),
          isFromClient: false,
        ),
        Message(
          id: 'MSG-004',
          content: 'أنا مهتم بخدمات الأمان والحماية',
          timestamp: DateTime.now().subtract(const Duration(hours: 22)),
          isFromClient: true,
        ),
      ],
    ),
    SupportRequest(
      id: 'REQ-003',
      title: 'طلب استرداد مبلغ',
      clientName: 'خالد عبدالله',
      clientId: 'CLT-789',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: RequestStatus.resolved,
      messages: [
        Message(
          id: 'MSG-005',
          content: 'أريد استرداد المبلغ المدفوع للخدمة غير المستخدمة',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isFromClient: true,
        ),
        Message(
          id: 'MSG-006',
          content: 'تم استلام طلبك، سنقوم بمراجعته والرد عليك قريباً',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isFromClient: false,
        ),
        Message(
          id: 'MSG-007',
          content: 'تمت الموافقة على طلب الاسترداد وسيتم تحويل المبلغ خلال 3 أيام عمل',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isFromClient: false,
        ),
        Message(
          id: 'MSG-008',
          content: 'شكراً جزيلاً لكم',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isFromClient: true,
        ),
      ],
    ),
    SupportRequest(
      id: 'REQ-004',
      title: 'مشكلة في تحديث البيانات',
      clientName: 'نورا حسن',
      clientId: 'CLT-101',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: RequestStatus.new_request,
      messages: [
        Message(
          id: 'MSG-009',
          content: 'لا أستطيع تحديث بياناتي الشخصية في الملف الشخصي',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isFromClient: true,
        ),
      ],
    ),
    SupportRequest(
      id: 'REQ-005',
      title: 'استفسار عن الاشتراك السنوي',
      clientName: 'محمد أحمد',
      clientId: 'CLT-202',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
      status: RequestStatus.pending,
      messages: [
        Message(
          id: 'MSG-010',
          content: 'هل يمكنني تغيير خطة الاشتراك من شهري إلى سنوي؟',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 7)),
          isFromClient: true,
        ),
        Message(
          id: 'MSG-011',
          content: 'نعم يمكنك ذلك، هل تريد معرفة الخطوات اللازمة؟',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
          isFromClient: false,
        ),
      ],
    ),
  ];
}