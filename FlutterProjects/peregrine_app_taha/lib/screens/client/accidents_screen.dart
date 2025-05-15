import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/accident_models.dart';
import 'package:peregrine_app_taha/screens/client/accident_details_screen.dart';
import 'package:peregrine_app_taha/screens/client/report_accident_screen.dart';
import 'package:peregrine_app_taha/services/accident_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';

class AccidentsScreen extends StatefulWidget {
  static const String routeName = '/accidents';
  
  const AccidentsScreen({super.key});

  @override
  State<AccidentsScreen> createState() => _AccidentsScreenState();
}

class _AccidentsScreenState extends State<AccidentsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<AccidentReport> _accidents = [];
  
  @override
  void initState() {
    super.initState();
    _loadAccidents();
  }
  
  Future<void> _loadAccidents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final response = await AccidentService.getAccidentReports();
      
      if (response.isSuccess && response.reports != null) {
        setState(() {
          _accidents = response.reports!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.errorMessage ?? 'حدث خطأ أثناء تحميل البيانات';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ غير متوقع';
        _isLoading = false;
      });
    }
  }
  
  void _navigateToReportAccident() {
    Navigator.pushNamed(
      context,
      ReportAccidentScreen.routeName,
    ).then((_) => _loadAccidents()); // Refresh list when returning
  }
  
  void _navigateToAccidentDetails(String accidentId) {
    Navigator.pushNamed(
      context,
      AccidentDetailsScreen.routeName,
      arguments: accidentId,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'الحوادث الأمنية',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white),
            onPressed: _loadAccidents,
            tooltip: 'تحديث',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToReportAccident,
        backgroundColor: AppTheme.primary,
        icon: const Icon(LucideIcons.fileWarning, color: Colors.white),
        label: Text(
          'إبلاغ عن حادثة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل الحوادث...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadAccidents,
      );
    }
    
    if (_accidents.isEmpty) {
      return _buildEmptyState();
    }
    
    return RefreshIndicator(
      onRefresh: _loadAccidents,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _accidents.length,
        itemBuilder: (context, index) {
          final accident = _accidents[index];
          return _buildAccidentCard(accident);
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileCheck,
            size: 80,
            color: AppTheme.accent.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد حوادث مسجلة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'يمكنك الإبلاغ عن حادثة جديدة باستخدام الزر أدناه',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: AppTheme.accent.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _navigateToReportAccident,
            icon: const Icon(LucideIcons.fileWarning),
            label: Text(
              'إبلاغ عن حادثة جديدة',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccidentCard(AccidentReport accident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToAccidentDetails(accident.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Accident type icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: _getAccidentTypeIcon(accident.type),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accident.title,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          accident.type,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppTheme.accent.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accident.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accident.statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      accident.status,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accident.statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Description preview
              Text(
                accident.descriptionPreview,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppTheme.accent.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              // Date and location
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 16,
                    color: AppTheme.accent.withOpacity(0.6),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatDateTime(accident.dateTime),
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.accent.withOpacity(0.6),
                    ),
                  ),
                  
                  if (accident.location != null) ...[
                    const SizedBox(width: 16),
                    Icon(
                      LucideIcons.mapPin,
                      size: 16,
                      color: AppTheme.accent.withOpacity(0.6),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        accident.location!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppTheme.accent.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  
                  // Has media indicator
                  if (accident.mediaUrls.isNotEmpty)
                    Icon(
                      LucideIcons.image,
                      size: 16,
                      color: AppTheme.primary.withOpacity(0.7),
                    ),
                  
                  // Has comments indicator
                  if (accident.comments.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.messageSquare,
                      size: 16,
                      color: AppTheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      accident.comments.length.toString(),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: AppTheme.primary.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
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
      size: 24,
    );
  }
}