import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/guard_models.dart';
import 'package:peregrine_app_taha/services/guard_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';
// Import url_launcher_string for string-based URL handling
import 'package:url_launcher/url_launcher_string.dart';

class GuardDetailsScreen extends StatefulWidget {
  final String guardId;
  
  const GuardDetailsScreen({
    super.key,
    required this.guardId,
  });

  @override
  State<GuardDetailsScreen> createState() => _GuardDetailsScreenState();
}

class _GuardDetailsScreenState extends State<GuardDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  Guard? _guard;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Load guard details
    _loadGuardDetails();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Load guard details from the service
  Future<void> _loadGuardDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final guard = await GuardService.getGuardDetails(widget.guardId);
      
      if (guard != null) {
        setState(() {
          _guard = guard;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = 'لم يتم العثور على بيانات الحارس';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل البيانات';
        _isLoading = false;
      });
    }
  }
  
  /// Call the guard's phone number
  Future<void> _callGuard() async {
    if (_guard == null || _guard!.phoneNumber.isEmpty) return;
    
    try {
      final phoneUrl = 'tel:${_guard!.phoneNumber}';
      
      // Try to launch directly without checking canLaunch first
      // This avoids the channel error in some environments
      await launchUrlString(
        phoneUrl,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      AppLogger.e('Error launching phone call: $e');
      if (!mounted) return;
      
      // Show a dialog with the phone number so the user can copy it
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'تعذر الاتصال',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعذر فتح تطبيق الاتصال تلقائياً. يمكنك الاتصال يدوياً بالرقم:',
                style: GoogleFonts.cairo(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SelectableText(
                _guard!.phoneNumber,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '(اضغط مطولاً للنسخ)',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل بيانات الحارس...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadGuardDetails,
      );
    }
    
    if (_guard == null) {
      return const AppErrorWidget(
        message: 'لم يتم العثور على بيانات الحارس',
      );
    }
    
    // Check if guard is on leave
    final onLeave = _guard!.leaveDays.any((leave) => leave.isActive);
    final activeLeave = onLeave ? _guard!.leaveDays.firstWhere((leave) => leave.isActive) : null;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar with guard info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    
                    // Guard info
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Guard avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: onLeave ? Colors.orange : Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: _guard!.profileImageUrl != null
                                  ? ClipOval(
                                      child: Image.network(
                                        _guard!.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(
                                            LucideIcons.user,
                                            color: AppTheme.primary,
                                            size: 40,
                                          );
                                        },
                                      ),
                                    )
                                  : const Icon(
                                      LucideIcons.user,
                                      color: AppTheme.primary,
                                      size: 40,
                                    ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Guard name
                            Text(
                              _guard!.name,
                              style: GoogleFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Guard badge number and specialization
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'رقم الشارة: ${_guard!.badgeNumber}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (_guard!.specialization != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _guard!.specialization!,
                                      style: GoogleFonts.cairo(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              // Call button
              if (_guard!.phoneNumber.isNotEmpty)
                IconButton(
                  icon: const Icon(LucideIcons.phone, color: Colors.white),
                  tooltip: 'اتصال',
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _callGuard();
                  },
                ),
              const SizedBox(width: 8),
            ],
          ),
          
          // Guard details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card (if on leave)
                  if (onLeave && activeLeave != null) ...[
                    _buildLeaveStatusCard(activeLeave),
                    const SizedBox(height: 24),
                  ],
                  
                  // Work schedule section
                  _buildSectionHeader(
                    title: 'جدول العمل',
                    icon: LucideIcons.calendar,
                  ),
                  const SizedBox(height: 16),
                  _buildWorkScheduleList(),
                  const SizedBox(height: 24),
                  
                  // Leave days section
                  _buildSectionHeader(
                    title: 'الإجازات',
                    icon: LucideIcons.calendarOff,
                  ),
                  const SizedBox(height: 16),
                  _buildLeaveDaysList(),
                  const SizedBox(height: 24),
                  
                  // Contact information section
                  _buildSectionHeader(
                    title: 'معلومات الاتصال',
                    icon: LucideIcons.phoneCall,
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfo(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLeaveStatusCard(LeaveDay leaveDay) {
    return Card(
      elevation: 4,
      shadowColor: Colors.orange.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Colors.orange.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.alertCircle,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'الحارس في إجازة حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  color: AppTheme.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'فترة الإجازة: ${DateFormatter.formatDateRange(
                    leaveDay.startDate,
                    leaveDay.endDate,
                  )}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  color: AppTheme.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'سبب الإجازة: ${leaveDay.reason}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
            
            if (leaveDay.replacementGuard != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  const Icon(
                    LucideIcons.userCheck,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الحارس البديل:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  // Replacement guard avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                    ),
                    child: leaveDay.replacementGuard!.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              leaveDay.replacementGuard!.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  LucideIcons.user,
                                  color: Colors.green,
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            color: Colors.green,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Replacement guard info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leaveDay.replacementGuard!.name,
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        Text(
                          'رقم الشارة: ${leaveDay.replacementGuard!.badgeNumber}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppTheme.accent.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // View details button
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuardDetailsScreen(
                            guardId: leaveDay.replacementGuard!.id,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      LucideIcons.info,
                      size: 16,
                    ),
                    label: Text(
                      'التفاصيل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildWorkScheduleList() {
    if (_guard!.schedule.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.calendar,
        message: 'لا يوجد جدول عمل محدد',
      );
    }
    
    // Sort schedule by day of week
    final sortedSchedule = List<WorkSchedule>.from(_guard!.schedule)
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
    
    return Column(
      children: sortedSchedule.map((schedule) => _buildScheduleItem(schedule)).toList(),
    );
  }
  
  Widget _buildScheduleItem(WorkSchedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: AppTheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Day container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  schedule.dayName,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Schedule details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        color: AppTheme.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${schedule.startTime} - ${schedule.endTime}',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        color: AppTheme.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        schedule.location,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppTheme.accent.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLeaveDaysList() {
    if (_guard!.leaveDays.isEmpty) {
      return _buildEmptyState(
        icon: LucideIcons.calendarOff,
        message: 'لا توجد إجازات مسجلة',
      );
    }
    
    // Sort leave days by start date (newest first)
    final sortedLeaveDays = List<LeaveDay>.from(_guard!.leaveDays)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    
    return Column(
      children: sortedLeaveDays.map((leave) => _buildLeaveItem(leave)).toList(),
    );
  }
  
  Widget _buildLeaveItem(LeaveDay leave) {
    // Determine leave status color
    Color statusColor;
    String statusText;
    
    if (leave.isActive) {
      statusColor = Colors.orange;
      statusText = 'جارية';
    } else if (leave.status == 'approved') {
      statusColor = Colors.green;
      statusText = 'معتمدة';
    } else if (leave.status == 'rejected') {
      statusColor = Colors.red;
      statusText = 'مرفوضة';
    } else {
      statusColor = Colors.blue;
      statusText = 'قيد المراجعة';
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: statusColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormatter.formatDateRange(leave.startDate, leave.endDate),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.info,
                  color: AppTheme.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'سبب الإجازة: ${leave.reason}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.accent.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  LucideIcons.clock,
                  color: AppTheme.accent,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'المدة: ${leave.durationInDays} ${leave.durationInDays > 10 ? 'يوم' : 'أيام'}',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppTheme.accent.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            
            if (leave.replacementGuard != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(
                    LucideIcons.userCheck,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الحارس البديل: ${leave.replacementGuard!.name}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accent,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GuardDetailsScreen(
                            guardId: leave.replacementGuard!.id,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'التفاصيل',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactInfo() {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_guard!.phoneNumber.isNotEmpty)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.phone,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                title: Text(
                  'رقم الهاتف',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                subtitle: Text(
                  _guard!.phoneNumber,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppTheme.accent.withOpacity(0.7),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    LucideIcons.phoneCall,
                    color: Colors.green,
                    size: 24,
                  ),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _callGuard();
                  },
                ),
              ),
            
            if (_guard!.phoneNumber.isEmpty)
              _buildEmptyState(
                icon: LucideIcons.phoneOff,
                message: 'لا توجد معلومات اتصال متاحة',
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.accent.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppTheme.accent.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}