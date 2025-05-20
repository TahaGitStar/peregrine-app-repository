import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/notification_models.dart';
import 'package:peregrine_app_taha/providers/notification_provider.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = '/support/notifications';
  
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Initialize notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'الإشعارات',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: AppTheme.primary.withCustomValues(alpha: (0.5 * 255).toInt()),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          // Mark all as read
          IconButton(
            icon: const Icon(LucideIcons.checkCheck, color: Colors.white, size: 22),
            splashRadius: 24,
            tooltip: 'تعليم الكل كمقروء',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _markAllAsRead();
            },
          ),
          // Refresh
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 22),
            splashRadius: 24,
            tooltip: 'تحديث',
            onPressed: () {
              HapticFeedback.mediumImpact();
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              notificationProvider.fetchNotifications();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const LoadingWidget(message: 'جاري تحميل الإشعارات...');
          }
          
          if (notificationProvider.error != null) {
            return AppErrorWidget(
              message: notificationProvider.error!,
              onRetry: () => notificationProvider.fetchNotifications(),
            );
          }
          
          final notifications = notificationProvider.notifications;
          
          if (notifications.isEmpty) {
            return _buildEmptyState();
          }
          
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: child,
              );
            },
            child: RefreshIndicator(
              onRefresh: () => notificationProvider.fetchNotifications(),
              color: AppTheme.primary,
              backgroundColor: Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  
                  // Staggered animation for list items
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      final delay = (index * 0.1).clamp(0.0, 0.5);
                      final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(delay, delay + 0.4, curve: Curves.easeOutQuart),
                        ),
                      );
                      
                      return FadeTransition(
                        opacity: itemAnimation,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - itemAnimation.value)),
                          child: child,
                        ),
                      );
                    },
                    child: _buildNotificationItem(notification),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bellOff,
            size: 64,
            color: AppTheme.primary.withCustomValues(alpha: (0.5 * 255).toInt()),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا الإشعارات الجديدة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              notificationProvider.fetchNotifications();
            },
            icon: const Icon(LucideIcons.refreshCw, size: 18),
            label: Text(
              'تحديث',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build notification item
  Widget _buildNotificationItem(AppNotification notification) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    final formattedDate = dateFormat.format(notification.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withCustomValues(alpha: (0.1 * 255).toInt()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: notification.isRead 
            ? BorderSide.none 
            : BorderSide(color: notification.type.color, width: 1.5),
      ),
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with type and time
              Row(
                children: [
                  // Notification type badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: notification.type.color.withCustomValues(alpha: (0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: notification.type.color.withCustomValues(alpha: (0.5 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          notification.type.icon,
                          size: 16,
                          color: notification.type.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notification.type.arabicLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: notification.type.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Timestamp
                  Text(
                    formattedDate,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  // Read indicator
                  if (!notification.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: notification.type.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Title
              Text(
                notification.title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Message
              Text(
                notification.message,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.accent.withCustomValues(alpha: (0.8 * 255).toInt()),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Context information
              if (notification.contextInfo.isNotEmpty) ...[
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  notification.contextInfo,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  /// Mark a notification as read
  void _markAsRead(AppNotification notification) {
    if (!notification.isRead) {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.markAsRead(notification.id);
    }
    
    // Show details or navigate to related screen
    // This would depend on the notification type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تعليم الإشعار كمقروء',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppTheme.accent,
      ),
    );
  }
  
  /// Mark all notifications as read
  void _markAllAsRead() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.markAllAsRead();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم تعليم جميع الإشعارات كمقروءة',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.center,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppTheme.accent,
      ),
    );
  }
}