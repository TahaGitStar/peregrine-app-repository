import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/models/support_request.dart';
import 'package:peregrine_app_taha/screens/support/support_request_details_screen.dart';
import 'package:peregrine_app_taha/screens/support/support_settings_screen.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/screens/change_password_screen.dart';
import 'package:peregrine_app_taha/screens/login_screen.dart';
import 'package:peregrine_app_taha/screens/support/create_client_account_screen.dart';
import 'package:peregrine_app_taha/screens/profile_edit_screen.dart';
import 'package:peregrine_app_taha/services/profile_service.dart';

class SupportDashboardScreen extends StatefulWidget {
  static const String routeName = '/support-dashboard';
  const SupportDashboardScreen({super.key});

  @override
  State<SupportDashboardScreen> createState() => _SupportDashboardScreenState();
}

class _SupportDashboardScreenState extends State<SupportDashboardScreen> with SingleTickerProviderStateMixin {
  late List<SupportRequest> _requests;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = true;
  
  // Global key for the scaffold to access the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
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
    
    // Simulate loading data with a safer approach
    Future.microtask(() {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() {
            _requests = getMockSupportRequests();
            _isLoading = false;
          });
          
          // Animate items in
          Future.microtask(() {
            if (mounted) {
              _animationController.forward();
            }
          });
        }
      });
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
      key: _scaffoldKey,
      backgroundColor: AppTheme.bg,
      // Right-side drawer (RTL layout)
      endDrawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'لوحة دعم العملاء',
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
                                  snapshot.data ?? 'SA',
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
              child: _isLoading 
                  ? _buildLoadingIndicator() 
                  : _buildRequestsList(),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
            ),
          );
          
          return Transform.scale(
            scale: fabAnimation.value,
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Refresh the list
            setState(() {
              _isLoading = true;
            });
            
            // Use a safer approach with Future.microtask
            Future.microtask(() {
              Future.delayed(const Duration(milliseconds: 800), () {
                if (mounted) {
                  setState(() {
                    _requests = getMockSupportRequests();
                    _isLoading = false;
                  });
                }
              });
            });
          },
          backgroundColor: AppTheme.primary,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          tooltip: 'تحديث',
          child: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 26),
        ),
      ),
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
              shape: BoxShape.circle,
            ),
            child: const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppTheme.primary,
                AppTheme.accent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              'جاري تحميل طلبات الدعم...',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRequestsList() {
    if (_requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.inbox,
                size: 70,
                color: AppTheme.primary.withCustomValues(alpha: (0.8 * 255).toInt()),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طلبات دعم حالياً',
              style: GoogleFonts.cairo(
                fontSize: 22,
                color: AppTheme.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'ستظهر هنا طلبات الدعم الجديدة عند وصولها',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _requests.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final request = _requests[index];
        
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + (index * 100)),
          curve: Curves.easeOutQuart,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: _buildRequestCard(request),
        );
      },
    );
  }
  
  Widget _buildRequestCard(SupportRequest request) {
    return Hero(
      tag: 'request-${request.id}',
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        elevation: 8,
        shadowColor: AppTheme.primary.withCustomValues(alpha: (0.25 * 255).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              _navigateToDetails(request);
            },
            borderRadius: BorderRadius.circular(24),
            splashColor: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
            highlightColor: AppTheme.primary.withCustomValues(alpha: (0.05 * 255).toInt()),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withCustomValues(alpha: (0.15 * 255).toInt()),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getIconForRequest(request),
                          color: AppTheme.primary,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.title,
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accent,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'رقم الطلب: ${request.id}',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: request.status.color.withCustomValues(alpha: (0.15 * 255).toInt()),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: request.status.color,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: request.status.color.withCustomValues(alpha: (0.1 * 255).toInt()),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          request.status.arabicLabel,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: request.status.color,
                          ),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.user,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            request.clientName,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: AppTheme.accent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.clock,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'منذ ${DateFormatter.getTimeAgo(request.createdAt)}',
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              color: AppTheme.accent.withCustomValues(alpha: (0.7 * 255).toInt()),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withCustomValues(alpha: (0.1 * 255).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.chevronLeft,
                          size: 20,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  IconData _getIconForRequest(SupportRequest request) {
    if (request.title.contains('تسجيل')) {
      return LucideIcons.logIn;
    } else if (request.title.contains('استفسار')) {
      return LucideIcons.helpCircle;
    } else if (request.title.contains('استرداد') || request.title.contains('مبلغ')) {
      return LucideIcons.banknote;
    } else if (request.title.contains('تحديث')) {
      return LucideIcons.refreshCw;
    } else {
      return LucideIcons.messageSquare;
    }
  }
  
  void _navigateToDetails(SupportRequest request) {
    // Use Future.microtask to ensure the UI has time to respond
    // before navigation, preventing potential freezes
    Future.microtask(() {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            SupportRequestDetailsScreen(request: request),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeOutQuart;
            
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            
            var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
              ),
            );
            
            // Ensure the interval values are within valid range (0.0 to 1.0)
            var scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
              ),
            );
            
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }
  
  // We've removed the settings menu since we now have a drawer
  
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withCustomValues(alpha: (0.1 * 255).toInt()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.logOut,
                color: Colors.red,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: Colors.grey[800],
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
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
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
    
    // Cancel any ongoing operations or subscriptions
    // _cancelSubscriptions();
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
              icon: LucideIcons.userPlus,
              title: 'إنشاء حساب عميل جديد',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context); // Close drawer
                
                // Use Future.microtask to ensure the drawer is fully closed before navigating
                Future.microtask(() {
                  Navigator.of(context).pushNamed(CreateClientAccountScreen.routeName);
                });
              },
              iconColor: AppTheme.primary,
            ),
            
            const SizedBox(height: 8),
            
            _buildDrawerMenuItem(
              icon: LucideIcons.lock,
              title: 'تغيير كلمة المرور',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context); // Close drawer
                
                // Use Future.microtask to ensure the drawer is fully closed before navigating
                Future.microtask(() {
                  Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
                });
              },
              iconColor: AppTheme.primary,
            ),
            
            const SizedBox(height: 8),
            
            // Settings option
            _buildDrawerMenuItem(
              icon: LucideIcons.settings,
              title: 'الإعدادات',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context); // Close drawer
                
                // Use Future.microtask to ensure the drawer is fully closed before navigating
                Future.microtask(() {
                  Navigator.of(context).pushNamed(SupportSettingsScreen.routeName);
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
            AppTheme.primary.withCustomValues(alpha: (0.8 * 255).toInt()),
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
            color: AppTheme.primary.withCustomValues(alpha: (0.3 * 255).toInt()),
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
                    color: Colors.black.withCustomValues(alpha: (0.1 * 255).toInt()),
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
                                  snapshot.data ?? 'SA',
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
                snapshot.data ?? 'سارة أحمد',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
          
          // User role
          Text(
            'فريق الدعم',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.white.withCustomValues(alpha: (0.9 * 255).toInt()),
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
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
            color: iconColor.withCustomValues(alpha: (0.1 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor ?? AppTheme.accent,
          ),
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
        hoverColor: iconColor.withCustomValues(alpha: (0.05 * 255).toInt()),
        selectedTileColor: iconColor.withCustomValues(alpha: (0.1 * 255).toInt()),
      ),
    );
  }
}