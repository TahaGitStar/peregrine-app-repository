import 'package:flutter/foundation.dart';
import 'package:peregrine_app_taha/models/notification_models.dart';
import 'package:peregrine_app_taha/services/notification_service.dart';

/// Provider for managing notifications state
class NotificationProvider extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  
  /// Get all notifications
  List<AppNotification> get notifications => _notifications;
  
  /// Get unread notifications
  List<AppNotification> get unreadNotifications => 
      _notifications.where((notification) => !notification.isRead).toList();
  
  /// Get unread notifications count
  int get unreadCount => unreadNotifications.length;
  
  /// Check if notifications are loading
  bool get isLoading => _isLoading;
  
  /// Get error message if any
  String? get error => _error;
  
  /// Initialize the provider
  Future<void> initialize() async {
    await fetchNotifications();
  }
  
  /// Fetch notifications from the service
  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final notifications = await NotificationService.getSupportNotifications();
      _notifications = notifications;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في تحميل الإشعارات: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await NotificationService.markNotificationAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'فشل في تحديث حالة الإشعار: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final success = await NotificationService.markAllNotificationsAsRead();
      if (success) {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
        notifyListeners();
      }
    } catch (e) {
      _error = 'فشل في تحديث حالة الإشعارات: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Add a new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }
}