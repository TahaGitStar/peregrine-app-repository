import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/screens/client/submit_complaint_screen.dart';
import 'package:peregrine_app_taha/screens/client/submit_request_screen.dart';
import 'package:peregrine_app_taha/screens/client/tracking_screen.dart';
import 'package:peregrine_app_taha/screens/client/guards_screen.dart';
import 'package:peregrine_app_taha/screens/client/accidents_screen.dart';
import 'package:peregrine_app_taha/screens/client/settings_screen.dart';
import 'package:peregrine_app_taha/screens/login_screen.dart';
import 'package:peregrine_app_taha/screens/change_password_screen.dart';
import 'package:peregrine_app_taha/screens/profile_edit_screen.dart';
import 'package:peregrine_app_taha/services/profile_service.dart';

class ClientHomeScreen extends StatefulWidget {
  static const String routeName = '/client-home';
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Mock data
  final List<Map<String, dynamic>> _recent = [
    {
      'id': 'A123', 
      'title': 'مشكلة وصول الأمن', 
      'status': 'قيد المعالجة',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'شكوى',
    },
    {
      'id': 'B456', 
      'title': 'طلب خدمة حراسة إضافية', 
      'status': 'مغلقة',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'طلب',
    },
    {
      'id': 'C789', 
      'title': 'استفسار عن الخدمات', 
      'status': 'جديدة',
      'date': DateTime.now().subtract(const Duration(hours: 6)),
      'type': 'استفسار',
    },
  ];
  
  final List<Map<String, dynamic>> _actionCards = [
    {
      'label': 'تقديم شكوى',
      'icon': LucideIcons.fileWarning,
      'color': AppTheme.primary,
      'route': SubmitComplaintScreen.routeName,
    },
    {
      'label': 'تقديم طلب',
      'icon': LucideIcons.fileText,
      'color': AppTheme.primary,
      'route': SubmitRequestScreen.routeName,
    },
    {
      'label': 'أفرادي',
      'icon': LucideIcons.shield,
      'color': AppTheme.primary,
      'route': GuardsScreen.routeName,
    },
    {
      'label': 'الحوادث الأمنية',
      'icon': LucideIcons.alertTriangle,
      'color': AppTheme.primary,
      'route': AccidentsScreen.routeName,
    },
    {
      'label': 'التتبع',
      'icon': LucideIcons.search,
      'color': AppTheme.primary,
      'route': TrackingScreen.routeName,
    },
    {
      'label': 'الإعدادات',
      'icon': LucideIcons.settings,
      'color': AppTheme.primary,
      'route': SettingsScreen.routeName,
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuart),
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Global key for the scaffold to access the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.bg,
      // Right-side drawer (RTL layout)
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'الرئيسية', 
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: AppTheme.primary.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        // Custom drawer button
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, color: Colors.white, size: 24),
            splashRadius: 24,
            tooltip: 'الإشعارات',
            onPressed: () {
              HapticFeedback.lightImpact();
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'لا توجد إشعارات جديدة',
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
            },
          ),
          // User profile button to open drawer
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: FutureBuilder<String?>(
                future: ProfileService.getProfileImagePath(),
                builder: (context, snapshot) {
                  final imagePath = snapshot.data;
                  
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12,
                    child: ClipOval(
                      child: imagePath != null && imagePath.isNotEmpty
                          ? Image.file(
                              File(imagePath),
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                            )
                          : FutureBuilder<String>(
                              future: ProfileService.getUserInitials(),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'U',
                                  style: const TextStyle(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
            tooltip: 'الملف الشخصي',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
          const SizedBox(width: 8), // Add some padding at the end
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Card
                      _buildWelcomeCard(),
                      
                      const SizedBox(height: 20),
                      
                      // Action cards
                      Expanded(
                        flex: 6,
                        child: GridView.builder(
                          // MODIFIED: Further adjusted childAspectRatio to prevent overflow
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 0.85, // Further reduced to give more height to cards and prevent overflow
                          ),
                          itemCount: _actionCards.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final card = _actionCards[index];
                            // Staggered animation for cards
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                // Calculate delay with a maximum to ensure it doesn't exceed 1.0
                                final delay = (index * 0.2).clamp(0.0, 0.6);
                                final end = (delay + 0.3).clamp(0.0, 0.9);
                                final cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                    parent: _animationController,
                                    curve: Interval(delay, end, curve: Curves.easeOutQuart),
                                  ),
                                );
                                
                                return FadeTransition(
                                  opacity: cardAnimation,
                                  child: Transform.translate(
                                    offset: Offset(0, 30 * (1 - cardAnimation.value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: _ActionCard(
                                label: card['label'],
                                icon: card['icon'],
                                color: card['color'],
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  if (card['route'] != null) {
                                    // Use Future.microtask to ensure the UI has time to respond
                                    // before navigation, preventing potential freezes
                                    Future.microtask(() {
                                      Navigator.pushNamed(context, card['route']);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'هذه الميزة قيد التطوير',
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
                                },
                              ),
                            );
                          },
                        ),
                      ),
          
                      const SizedBox(height: 5),
                      
                      // Recent Activities Header
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          final headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                            ),
                          );
                          
                          return FadeTransition(
                            opacity: headerAnimation,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - headerAnimation.value)),
                              child: child,
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'النشاطات الأخيرة', 
                              style: GoogleFonts.cairo(
                                fontSize: 20, 
                                fontWeight: FontWeight.bold, 
                                color: const Color.fromARGB(255, 113, 66, 42),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                // Use Future.microtask to ensure the UI has time to respond
                                Future.microtask(() {
                                  Navigator.pushNamed(context, TrackingScreen.routeName);
                                });
                              },
                              icon: const Icon(LucideIcons.arrowLeft, size: 18),
                              label: Text(
                                'عرض الكل',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
          
                      // Recent list
                      // MODIFIED: Adjusted flex to ensure proper space allocation
                      Expanded(
                        flex: 3, // Increased flex to give more space to the list
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            final listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
                              ),
                            );
                            
                            return FadeTransition(
                              opacity: listAnimation,
                              child: Transform.translate(
                                offset: Offset(0, 30 * (1 - listAnimation.value)),
                                child: child,
                              ),
                            );
                          },
                          child: _recent.isEmpty 
                              ? _buildEmptyState() 
                              : ListView.builder(
                                  itemCount: _recent.length,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (ctx, i) {
                                    final item = _recent[i];
                                    return _buildActivityCard(item, i);
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
            AppTheme.primary.withOpacity(0.7),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(102), // 0.4 * 255 = 102
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26), // 0.1 * 255 = 25.5, rounded to 26
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: Icon(
                LucideIcons.user,
                color: AppTheme.primary,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(bounds),
                  child: Text(
                    'مرحباً بك',
                    style: GoogleFonts.cairo(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // MODIFIED: Added overflow handling for welcome message
                Text(
                  'كيف يمكننا مساعدتك اليوم؟',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityCard(Map<String, dynamic> item, int index) {
    // Determine status color
    Color statusColor;
    if (item['status'] == 'جديدة') {
      statusColor = Colors.blue;
    } else if (item['status'] == 'قيد المعالجة') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }
    
    // Determine icon based on type
    IconData typeIcon;
    if (item['type'] == 'شكوى') {
      typeIcon = LucideIcons.fileWarning;
    } else if (item['type'] == 'طلب') {
      typeIcon = LucideIcons.fileText;
    } else {
      typeIcon = LucideIcons.helpCircle;
    }
    
    // MODIFIED: Added ConstrainedBox to ensure activity cards have proper height
    return Hero(
      tag: 'activity-${item['id']}',
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 120), // Ensure minimum height
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 6,
          shadowColor: AppTheme.primary.withOpacity(0.25),
          margin: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              // Use Future.microtask to ensure the UI has time to respond
              Future.microtask(() {
                Navigator.pushNamed(context, TrackingScreen.routeName);
              });
            },
            borderRadius: BorderRadius.circular(24),
            splashColor: AppTheme.primary.withOpacity(0.1),
            highlightColor: AppTheme.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withAlpha(26), // 0.1 * 255 = 25.5, rounded to 26
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          typeIcon,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // MODIFIED: Improved text overflow handling for Arabic titles
                            Text(
                              '${item['title']}',
                              style: GoogleFonts.cairo(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                            const SizedBox(height: 4),
                            // MODIFIED: Added overflow handling for ID and type text
                            Text(
                              '${item['id']} - ${item['type']}',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // MODIFIED: Wrapped status text in FittedBox to prevent overflow with longer Arabic status text
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: statusColor,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withAlpha(26), // 0.1 * 255 = 25.5, rounded to 26
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item['status'],
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: AppTheme.primary.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          // MODIFIED: Added FittedBox for time ago text to prevent overflow
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _getTimeAgo(item['date']),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: AppTheme.accent.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),  // Closing tag for ConstrainedBox
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.clipboardList,
              size: 70,
              color: AppTheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد نشاطات حديثة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'ستظهر هنا الشكاوى والطلبات الأخيرة',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppTheme.accent.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
  
  // Build the drawer widget
  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            // Profile header section
            _buildDrawerHeader(),
            
            const SizedBox(height: 8),
            
            // Divider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Menu items
            _buildDrawerMenuItem(
              icon: LucideIcons.lock,
              title: 'تغيير كلمة المرور',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context); // Close drawer
                
                // Use Future.delayed to ensure the drawer is fully closed before navigating
                Future.microtask(() {
                  Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
                });
              },
              iconColor: AppTheme.primary,
            ),
            
            const SizedBox(height: 8),
            
            // Logout option
            _buildDrawerMenuItem(
              icon: LucideIcons.logOut,
              title: 'تسجيل الخروج',
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context); // Close drawer
                _showLogoutConfirmation();
              },
              iconColor: Colors.red,
              textColor: Colors.red,
            ),
            
            const Spacer(),
            
            // App version at bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'الإصدار 1.0.0',
                style: GoogleFonts.cairo(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build the drawer header with user profile
  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(77), // 0.3 * 255 = 76.5, rounded to 77
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with close button and edit profile button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Close button
              IconButton(
                icon: const Icon(LucideIcons.x, color: Colors.white, size: 24),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              
              // Edit profile button
              IconButton(
                icon: const Icon(LucideIcons.edit, color: Colors.white, size: 20),
                onPressed: () {
                  Navigator.pop(context); // Close drawer
                  
                  // Navigate to profile edit screen
                  Future.microtask(() {
                    Navigator.of(context).pushNamed(ProfileEditScreen.routeName).then((_) {
                      // Refresh drawer header when returning from edit screen
                      setState(() {});
                    });
                  });
                },
                tooltip: 'تعديل الملف الشخصي',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // User avatar
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // Close drawer
              
              // Navigate to profile edit screen
              Future.microtask(() {
                Navigator.of(context).pushNamed(ProfileEditScreen.routeName).then((_) {
                  // Refresh drawer header when returning from edit screen
                  setState(() {});
                });
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(26), // 0.1 * 255 = 25.5, rounded to 26
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FutureBuilder<String?>(
                future: ProfileService.getProfileImagePath(),
                builder: (context, snapshot) {
                  final imagePath = snapshot.data;
                  
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: imagePath != null && imagePath.isNotEmpty
                          ? Image.file(
                              File(imagePath),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : FutureBuilder<String>(
                              future: ProfileService.getUserInitials(),
                              builder: (context, snapshot) {
                                return Text(
                                  snapshot.data ?? 'U',
                                  style: GoogleFonts.cairo(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                );
                              },
                            ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User name
          FutureBuilder<String>(
            future: ProfileService.getUserName(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'المستخدم',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
          
          const SizedBox(height: 4),
          
          // User email
          FutureBuilder<String>(
            future: ProfileService.getUserEmail(),
            builder: (context, snapshot) {
              return Text(
                snapshot.data ?? 'user@example.com',
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Build a drawer menu item
  Widget _buildDrawerMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = AppTheme.primary,
    Color? textColor,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl, // Ensure RTL for menu items
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        // MODIFIED: Added overflow handling for drawer menu items
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor ?? AppTheme.accent,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        trailing: Icon(
          LucideIcons.chevronLeft,
          color: iconColor,
          size: 20,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        hoverColor: iconColor.withOpacity(0.05),
        selectedTileColor: iconColor.withOpacity(0.1),
      ),
    );
  }
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          elevation: 20,
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(51), // 0.2 * 255 = 51
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.logOut,
                  color: Colors.red,
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'تسجيل الخروج',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            'هل أنت متأكد أنك تريد تسجيل الخروج؟',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey[800],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // First dismiss the dialog
                      Navigator.pop(context);
                      
                      // Clear any user session data
                      _clearUserSession();
                      
                      // Navigate immediately without waiting for animation
                      // This prevents potential freezing issues
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        LoginScreen.routeName,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.red.withOpacity(0.4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'تسجيل الخروج',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        ),
      ),
    );
  }
  
  // Method to clear user session data
  void _clearUserSession() {
    // This would typically involve clearing:
    // 1. Any cached user data
    // 2. Authentication tokens
    // 3. Preferences related to the current user
    // 4. Any in-memory state
    
    // For demonstration purposes:
    HapticFeedback.mediumImpact();
    
    // Here you would add actual implementation to clear user data
    // For example:
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.remove('user_token');
    // prefs.remove('user_data');
    
    // Cancel any ongoing operations
    // _cancelSubscriptions();
  }
}

class _ActionCard extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

// MODIFIED: Completely restructured to prevent overflow with Arabic text
class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
    
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onHover(bool isHovered) {
    if (isHovered != _isHovered) {
      setState(() {
        _isHovered = isHovered;
      });
      
      if (isHovered) {
        _hoverController.forward();
      } else {
        _hoverController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTapDown: (_) => _onHover(true),
        onTapUp: (_) => _onHover(false),
        onTapCancel: () => _onHover(false),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _hoverController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withAlpha(((0.2 + (0.2 * _glowAnimation.value)) * 255).toInt()),
                      blurRadius: 10 + (10 * _glowAnimation.value),
                      spreadRadius: 1 + (2 * _glowAnimation.value),
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          // MODIFIED: Completely restructured the card layout to prevent overflow
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available height and adjust layout accordingly
              return Padding(
                padding: const EdgeInsets.all(12), // Reduced padding
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Use minimum space needed
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container - takes about 60% of available height
                    SizedBox(
                      height: constraints.maxHeight * 0.6,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _hoverController,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(16), // Reduced padding
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.color.withAlpha(((0.1 + (0.1 * _glowAnimation.value)) * 255).toInt()),
                                    widget.color.withAlpha(((0.2 + (0.1 * _glowAnimation.value)) * 255).toInt()),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.color.withAlpha((0.1 * _glowAnimation.value * 255).toInt()),
                                    blurRadius: 10 * _glowAnimation.value,
                                    spreadRadius: 1 * _glowAnimation.value,
                                  ),
                                ],
                              ),
                              child: Icon(
                                widget.icon, 
                                size: 32, // Slightly reduced size
                                color: widget.color,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // Text container - takes remaining space with proper constraints
                    // MODIFIED: Further improved text container to prevent overflow
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth,
                            maxHeight: constraints.maxHeight * 0.3, // Limit height to prevent overflow
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              width: constraints.maxWidth,
                              alignment: Alignment.center,
                              child: Text(
                                widget.label, 
                                style: GoogleFonts.cairo(
                                  fontSize: 15, // Further reduced font size
                                  fontWeight: FontWeight.w600, 
                                  color: AppTheme.accent,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
