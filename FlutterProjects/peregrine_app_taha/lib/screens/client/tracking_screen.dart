import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TrackingScreen extends StatefulWidget {
  static const String routeName = '/tracking';
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Mock data with more details
  final List<Map<String, dynamic>> _items = [
    {
      'id': 'A123', 
      'title': 'مشكلة وصول الأمن',
      'type': 'شكوى', 
      'status': 'قيد المعالجة',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'description': 'لم يصل فريق الأمن في الوقت المحدد مما تسبب في تأخير العمل',
      'updates': [
        {'date': DateTime.now().subtract(const Duration(days: 2)), 'text': 'تم استلام الشكوى'},
        {'date': DateTime.now().subtract(const Duration(days: 1)), 'text': 'جاري التحقيق في المشكلة'},
      ]
    },
    {
      'id': 'B456', 
      'title': 'طلب خدمة حراسة إضافية',
      'type': 'طلب', 
      'status': 'مغلقة',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'description': 'طلب توفير حراسة إضافية للمبنى خلال فترة العطلة',
      'updates': [
        {'date': DateTime.now().subtract(const Duration(days: 5)), 'text': 'تم استلام الطلب'},
        {'date': DateTime.now().subtract(const Duration(days: 4)), 'text': 'تمت الموافقة على الطلب'},
        {'date': DateTime.now().subtract(const Duration(days: 3)), 'text': 'تم تنفيذ الطلب بنجاح'},
      ]
    },
    {
      'id': 'C789', 
      'title': 'تأخر في الرد على الاستفسارات',
      'type': 'شكوى', 
      'status': 'جديدة',
      'date': DateTime.now().subtract(const Duration(hours: 6)),
      'description': 'هناك تأخر كبير في الرد على استفساراتي عبر منصة الدعم',
      'updates': [
        {'date': DateTime.now().subtract(const Duration(hours: 6)), 'text': 'تم استلام الشكوى'},
      ]
    },
    {
      'id': 'D012', 
      'title': 'طلب تقرير أمني شهري',
      'type': 'طلب', 
      'status': 'قيد المعالجة',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'description': 'طلب الحصول على تقرير أمني مفصل عن الشهر الماضي',
      'updates': [
        {'date': DateTime.now().subtract(const Duration(days: 1)), 'text': 'تم استلام الطلب'},
        {'date': DateTime.now().subtract(const Duration(hours: 12)), 'text': 'جاري إعداد التقرير'},
      ]
    },
    {
      'id': 'E345', 
      'title': 'استفسار عن خدمات الحماية الشخصية',
      'type': 'استفسار', 
      'status': 'مغلقة',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'description': 'أرغب في معرفة المزيد عن خدمات الحماية الشخصية المتاحة',
      'updates': [
        {'date': DateTime.now().subtract(const Duration(days: 3)), 'text': 'تم استلام الاستفسار'},
        {'date': DateTime.now().subtract(const Duration(days: 2)), 'text': 'تم الرد على الاستفسار'},
      ]
    },
  ];
  
  List<Map<String, dynamic>> _filtered = [];
  String _selectedFilter = 'الكل';
  final List<String> _filterOptions = ['الكل', 'شكوى', 'طلب', 'استفسار'];
  bool _isSearchFocused = false;

  @override
  void initState() {
    super.initState();
    _filtered = List.from(_items);
    _searchController.addListener(_filterList);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  void _filterList() {
    String query = _searchController.text.trim();
    setState(() {
      _filtered = _items
          .where((item) {
            // Filter by search query
            bool matchesQuery = item['id']!.contains(query) || 
                               item['title']!.contains(query) || 
                               item['type']!.contains(query);
            
            // Filter by type if not "All"
            bool matchesType = _selectedFilter == 'الكل' || item['type'] == _selectedFilter;
            
            return matchesQuery && matchesType;
          })
          .toList();
    });
  }
  
  void _applyTypeFilter(String type) {
    setState(() {
      _selectedFilter = type;
      _filterList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
          'تتبع الطلبات والشكاوى', 
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: AppTheme.primary.withOpacity(0.4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search and Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Search Field
                  Focus(
                    onFocusChange: (hasFocus) {
                      setState(() {
                        _isSearchFocused = hasFocus;
                      });
                    },
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث برقم الطلب أو العنوان...',
                        hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                        prefixIcon: Icon(
                          LucideIcons.search,
                          color: _isSearchFocused ? AppTheme.primary : Colors.grey[400],
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(LucideIcons.x),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        fillColor: Colors.grey[100],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      style: GoogleFonts.cairo(),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filterOptions.length,
                      itemBuilder: (context, index) {
                        final option = _filterOptions[index];
                        final isSelected = _selectedFilter == option;
                        
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text(
                              option,
                              style: GoogleFonts.cairo(
                                color: isSelected ? Colors.white : AppTheme.accent,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              _applyTypeFilter(option);
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppTheme.primary,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppTheme.primary : Colors.grey[300]!,
                              ),
                            ),
                            elevation: isSelected ? 2 : 0,
                            shadowColor: AppTheme.primary.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'النتائج: ${_filtered.length}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Results List
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filtered.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final item = _filtered[index];
                        return _buildTrackingCard(item, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrackingCard(Map<String, dynamic> item, int index) {
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
    
    return Hero(
      tag: 'activity-${item['id']}',
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 4,
        shadowColor: AppTheme.primary.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 16),
        child: InkWell(
          onTap: () => _showDetailsBottomSheet(context, item),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        typeIcon,
                        color: AppTheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item['id']} - ${item['type']}',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['status'],
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getTimeAgo(item['date']),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          LucideIcons.chevronLeft,
                          size: 20,
                          color: AppTheme.primary,
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
    );
  }
  
  void _showDetailsBottomSheet(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForType(item['type']),
                      color: AppTheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        Text(
                          '${item['id']} - ${item['type']}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(item['status']).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(item['status']),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            item['status'],
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(item['status']),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatDate(item['date']),
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      'التفاصيل',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item['description'],
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Timeline
                    Text(
                      'التحديثات',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Timeline Items
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: (item['updates'] as List).length,
                      itemBuilder: (context, index) {
                        final update = (item['updates'] as List)[index];
                        final isLast = index == (item['updates'] as List).length - 1;
                        
                        return _buildTimelineItem(
                          update['text'], 
                          update['date'], 
                          isLast,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            // Action Button
            if (item['status'] != 'مغلقة')
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إرسال متابعة للطلب بنجاح',
                          style: GoogleFonts.cairo(),
                          textAlign: TextAlign.center,
                        ),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LucideIcons.messageCircle),
                  label: Text(
                    'متابعة الطلب',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTimelineItem(String text, DateTime date, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                _formatDate(date),
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.search,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول تغيير معايير البحث',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  IconData _getIconForType(String type) {
    if (type == 'شكوى') {
      return LucideIcons.fileWarning;
    } else if (type == 'طلب') {
      return LucideIcons.fileText;
    } else {
      return LucideIcons.helpCircle;
    }
  }
  
  Color _getStatusColor(String status) {
    if (status == 'جديدة') {
      return Colors.blue;
    } else if (status == 'قيد المعالجة') {
      return Colors.orange;
    } else {
      return Colors.green;
    }
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
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} - ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
