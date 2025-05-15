import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/accident_models.dart';
import 'package:peregrine_app_taha/services/accident_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';

class AccidentDetailsScreen extends StatefulWidget {
  static const String routeName = '/accident-details';
  
  final String accidentId;
  
  const AccidentDetailsScreen({
    super.key,
    required this.accidentId,
  });

  @override
  State<AccidentDetailsScreen> createState() => _AccidentDetailsScreenState();
}

class _AccidentDetailsScreenState extends State<AccidentDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  AccidentReport? _accident;
  
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
    
    // Load accident details
    _loadAccidentDetails();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadAccidentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final accident = await AccidentService.getAccidentDetails(widget.accidentId);
      
      if (accident != null) {
        setState(() {
          _accident = accident;
          _isLoading = false;
        });
        _animationController.forward();
      } else {
        setState(() {
          _errorMessage = 'لم يتم العثور على بيانات الحادثة';
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل بيانات الحادثة...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadAccidentDetails,
      );
    }
    
    if (_accident == null) {
      return const AppErrorWidget(
        message: 'لم يتم العثور على بيانات الحادثة',
      );
    }
    
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
          // App bar with accident info
          SliverAppBar(
            expandedHeight: 180,
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
                    
                    // Accident info
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Accident type icon
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _getAccidentTypeIcon(_accident!.type),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Accident title
                            Text(
                              _accident!.title,
                              style: GoogleFonts.cairo(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            // Status badge
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _accident!.statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _accident!.statusColor.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _accident!.status,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Accident details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and location
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.calendar,
                                color: Color.fromARGB(255, 253, 177, 46),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'تاريخ الحادثة:',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 231, 162, 34),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormatter.formatDate(_accident!.dateTime),
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: const Color.fromARGB(255, 247, 171, 7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.clock,
                                color: Color.fromARGB(255, 232, 157, 8),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'وقت الحادثة:',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color.fromARGB(255, 255, 171, 35),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm').format(_accident!.dateTime),
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: const Color.fromARGB(255, 217, 152, 0),
                                ),
                              ),
                            ],
                          ),
                          
                          if (_accident!.location != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  color: Color.fromARGB(255, 249, 178, 36),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'الموقع:',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color.fromARGB(255, 255, 174, 12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _accident!.location!,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: const Color.fromARGB(255, 233, 161, 47),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Description section
                  _buildSectionHeader(
                    title: 'وصف الحادثة',
                    icon: LucideIcons.fileText,
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _accident!.description,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: const Color(0xFFC68642),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Media section (if any)
                  if (_accident!.mediaUrls.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'الصور والملفات',
                      icon: LucideIcons.image,
                    ),
                    const SizedBox(height: 12),
                    _buildMediaGrid(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Comments section
                  _buildSectionHeader(
                    title: 'التعليقات والتحديثات',
                    icon: LucideIcons.messageSquare,
                  ),
                  const SizedBox(height: 12),
                  _buildCommentsSection(),
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
            color: const Color(0xFFC68642),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
      ],
    );
  }
  
  Widget _buildMediaGrid() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // For now, we'll just show placeholders since we're using mock data
            // In a real app, we would load the actual images from the URLs
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _accident!.mediaUrls.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: AppTheme.primary.withOpacity(0.1),
                    child: Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 40,
                        color: AppTheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              'عدد الملفات: ${_accident!.mediaUrls.length}',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.accent.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommentsSection() {
    if (_accident!.comments.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  LucideIcons.messageSquare,
                  size: 40,
                  color: AppTheme.accent.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد تعليقات أو تحديثات حتى الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: AppTheme.accent.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    // Sort comments by date (newest first)
    final sortedComments = List<AccidentComment>.from(_accident!.comments)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedComments.length,
      itemBuilder: (context, index) {
        final comment = sortedComments[index];
        return _buildCommentItem(comment);
      },
    );
  }
  
  Widget _buildCommentItem(AccidentComment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: comment.isAdminComment
          ? AppTheme.primary.withOpacity(0.05)
          : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Author avatar or icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: comment.isAdminComment
                        ? AppTheme.primary.withOpacity(0.1)
                        : AppTheme.accent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      comment.isAdminComment
                          ? LucideIcons.shieldCheck
                          : LucideIcons.user,
                      color: comment.isAdminComment
                          ? AppTheme.primary
                          : AppTheme.accent,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Author name and badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.author,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          if (comment.isAdminComment) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'مسؤول',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        DateFormatter.formatDateTime(comment.dateTime),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppTheme.accent.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            
            // Comment content
            Text(
              comment.content,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: const Color.fromARGB(255, 207, 143, 33),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _getAccidentTypeIcon(String type) {
    IconData iconData;
    
    switch (type) {
      case 'سرقة':
        iconData = LucideIcons.briefcase;
        break;
      case 'تخريب':
        iconData = LucideIcons.hammer;
        break;
      case 'دخول غير مصرح':
        iconData = LucideIcons.userX;
        break;
      case 'حريق':
        iconData = LucideIcons.flame;
        break;
      case 'طارئ طبي':
        iconData = LucideIcons.stethoscope;
        break;
      default:
        iconData = LucideIcons.alertTriangle;
    }
    
    return Icon(
      iconData,
      color: AppTheme.primary,
      size: 32,
    );
  }
}