import 'package:peregrine_app_taha/models/notification_models.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';
import 'package:peregrine_app_taha/models/support_request.dart';

/// Service for handling notifications
class NotificationService {
  /// Get all notifications for the support team
  static Future<List<AppNotification>> getSupportNotifications() async {
    // In a real app, this would fetch from an API
    // For now, we'll use mock data
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    return getMockNotifications();
  }
  
  /// Get unread notifications count
  static Future<int> getUnreadNotificationsCount() async {
    final notifications = await getSupportNotifications();
    return notifications.where((notification) => !notification.isRead).length;
  }
  
  /// Mark a notification as read
  static Future<bool> markNotificationAsRead(String notificationId) async {
    // In a real app, this would update the notification status in the backend
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return true;
  }
  
  /// Mark all notifications as read
  static Future<bool> markAllNotificationsAsRead() async {
    // In a real app, this would update all notifications status in the backend
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    return true;
  }
  
  /// Create a notification for a new support request
  static Future<AppNotification> createRequestNotification(
    SupportRequest request,
    Branch branch,
    String contractType,
    String operationType,
  ) async {
    final notification = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'طلب جديد: ${request.title}',
      message: 'تم استلام طلب جديد من العميل ${request.clientName}',
      timestamp: DateTime.now(),
      type: NotificationType.newRequest,
      clientName: request.clientName,
      clientId: request.clientId,
      branchName: branch.name,
      branchId: branch.id,
      contractType: contractType,
      requestId: request.id,
      operationType: operationType,
    );
    
    // In a real app, this would save the notification to the backend
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return notification;
  }
  
  /// Create a notification for a new complaint
  static Future<AppNotification> createComplaintNotification(
    SupportRequest complaint,
    Branch branch,
    String contractType,
  ) async {
    final notification = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'شكوى جديدة: ${complaint.title}',
      message: 'تم استلام شكوى جديدة من العميل ${complaint.clientName}',
      timestamp: DateTime.now(),
      type: NotificationType.newComplaint,
      clientName: complaint.clientName,
      clientId: complaint.clientId,
      branchName: branch.name,
      branchId: branch.id,
      contractType: contractType,
      requestId: complaint.id,
      operationType: 'تقديم شكوى',
    );
    
    // In a real app, this would save the notification to the backend
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return notification;
  }
  
  /// Create a notification for a request update
  static Future<AppNotification> createRequestUpdateNotification(
    SupportRequest request,
    Branch branch,
    String contractType,
    String updateMessage,
  ) async {
    final notification = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      title: 'تحديث طلب: ${request.title}',
      message: updateMessage,
      timestamp: DateTime.now(),
      type: NotificationType.requestUpdate,
      clientName: request.clientName,
      clientId: request.clientId,
      branchName: branch.name,
      branchId: branch.id,
      contractType: contractType,
      requestId: request.id,
      operationType: 'تحديث طلب',
    );
    
    // In a real app, this would save the notification to the backend
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    return notification;
  }
}