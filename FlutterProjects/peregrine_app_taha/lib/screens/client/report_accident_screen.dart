import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/accident_models.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';
import 'package:peregrine_app_taha/providers/branch_contract_provider.dart';
import 'package:peregrine_app_taha/providers/user_role_provider.dart';
import 'package:peregrine_app_taha/services/accident_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/logger.dart';
import 'package:provider/provider.dart';

class ReportAccidentScreen extends StatefulWidget {
  static const String routeName = '/report-accident';
  
  const ReportAccidentScreen({super.key});

  @override
  State<ReportAccidentScreen> createState() => _ReportAccidentScreenState();
}

class _ReportAccidentScreenState extends State<ReportAccidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedType = AccidentTypes.types.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedLocation;
  
  // Branch selection
  Branch? _selectedBranch;
  
  final List<String> _locations = [
    'المبنى الرئيسي - الطابق الأرضي',
    'المبنى الرئيسي - الطابق الأول',
    'المبنى الرئيسي - الطابق الثاني',
    'المستودع الرئيسي',
    'موقف السيارات الأمامي',
    'موقف السيارات الخلفي',
    'ساحة المبنى',
    'مدخل المبنى',
    'أخرى',
  ];
  
  final List<File> _selectedMedia = [];
  bool _isSubmitting = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      // Initialize providers
      final branchContractProvider = Provider.of<BranchContractProvider>(context, listen: false);
      final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
      
      Future.wait([
        userRoleProvider.initialize(),
        branchContractProvider.initialize(),
      ]).then((_) {
        if (!mounted) return;
        
        if (userRoleProvider.selectedBranch != null) {
          setState(() {
            // Find the matching branch from branchContractProvider to ensure we use the same instance
            String selectedBranchId = userRoleProvider.selectedBranch!.id;
            _selectedBranch = branchContractProvider.branches.firstWhere(
              (branch) => branch.id == selectedBranchId,
              orElse: () => branchContractProvider.branches.isNotEmpty ? 
                            branchContractProvider.branches.first : 
                            userRoleProvider.selectedBranch!
            );
          });
        } else if (branchContractProvider.branches.isNotEmpty) {
          setState(() {
            _selectedBranch = branchContractProvider.branches.first;
          });
        }
      });
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.accent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.accent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedMedia.add(File(image.path));
        });
      }
    } catch (e) {
      AppLogger.e('Error picking image: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء اختيار الصورة',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }
  
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if branch is selected
    if (_selectedBranch == null) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى اختيار الفرع',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      // Convert media files to URLs (in a real app, we would upload them to a server)
      final mediaUrls = _selectedMedia.map((file) => file.path).toList();
      
      final success = await AccidentService.submitAccidentReport(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        dateTime: dateTime,
        location: _selectedLocation,
        branchId: _selectedBranch!.id,
        branchName: _selectedBranch!.name,
        mediaUrls: mediaUrls,
      );
      
      if (!mounted) return;
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال البلاغ بنجاح',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال البلاغ',
              style: GoogleFonts.cairo(),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
        
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    } catch (e) {
      AppLogger.e('Error submitting report: $e');
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ غير متوقع',
            style: GoogleFonts.cairo(),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red,
        ),
      );
      
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'إبلاغ عن حادثة أمنية',
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
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Form header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      LucideIcons.fileWarning,
                      color: AppTheme.primary,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'الرجاء تعبئة النموذج التالي للإبلاغ عن حادثة أمنية',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم مراجعة البلاغ والرد عليه في أقرب وقت ممكن',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.accent.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Title field
              _buildFormLabel('عنوان الحادثة', true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'أدخل عنواناً مختصراً للحادثة',
                  hintStyle: GoogleFonts.cairo(
                    color: AppTheme.accent.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.textCursor,
                    color: AppTheme.primary,
                  ),
                ),
                style: GoogleFonts.cairo(
                  color: AppTheme.accent,
                  fontSize: 16,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال عنوان الحادثة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Type dropdown
              _buildFormLabel('نوع الحادثة', true),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        LucideIcons.tag,
                        color: AppTheme.primary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: GoogleFonts.cairo(
                      color: AppTheme.accent,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: AccidentTypes.types.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Date and time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('تاريخ الحادثة', true),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.accent.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.calendar,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  DateFormat('yyyy/MM/dd').format(_selectedDate),
                                  style: GoogleFonts.cairo(
                                    color: AppTheme.accent,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFormLabel('وقت الحادثة', true),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectTime(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.accent.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime.format(context),
                                  style: GoogleFonts.cairo(
                                    color: AppTheme.accent,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Location dropdown
              _buildFormLabel('موقع الحادثة', false),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        LucideIcons.mapPin,
                        color: AppTheme.primary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: 'اختر موقع الحادثة (اختياري)',
                      hintStyle: GoogleFonts.cairo(
                        color: AppTheme.accent.withOpacity(0.5),
                      ),
                    ),
                    style: GoogleFonts.cairo(
                      color: AppTheme.accent,
                      fontSize: 16,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    items: _locations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location,
                        child: Text(location),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Branch selection dropdown
              _buildFormLabel('الفرع', true),
              const SizedBox(height: 8),
              Consumer<BranchContractProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    );
                  }
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accent.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<Branch>(
                        value: _selectedBranch,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            LucideIcons.building,
                            color: AppTheme.primary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          hintText: 'اختر الفرع',
                          hintStyle: GoogleFonts.cairo(
                            color: AppTheme.accent.withOpacity(0.5),
                          ),
                        ),
                        style: GoogleFonts.cairo(
                          color: AppTheme.accent,
                          fontSize: 16,
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        items: provider.branches.map<DropdownMenuItem<Branch>>((branch) {
                          return DropdownMenuItem<Branch>(
                            value: branch,
                            child: Text(branch.name),
                          );
                        }).toList(),
                        onChanged: (Branch? newValue) {
                          setState(() {
                            _selectedBranch = newValue;
                          });
                          if (newValue != null) {
                            provider.selectBranch(newValue);
                          }
                        },
                        validator: (val) => val == null ? 'يرجى اختيار الفرع' : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // Description field
              _buildFormLabel('وصف الحادثة', true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'اكتب وصفاً تفصيلياً للحادثة',
                  hintStyle: GoogleFonts.cairo(
                    color: AppTheme.accent.withOpacity(0.5),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.accent.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primary,
                      width: 1,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.5,
                    ),
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(
                      LucideIcons.fileText,
                      color: AppTheme.primary,
                    ),
                  ),
                  alignLabelWithHint: true,
                ),
                style: GoogleFonts.cairo(
                  color: AppTheme.accent,
                  fontSize: 16,
                ),
                maxLines: 6,
                minLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال وصف الحادثة';
                  }
                  if (value.trim().length < 10) {
                    return 'الرجاء إدخال وصف أكثر تفصيلاً';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              // Media upload
              _buildFormLabel('إرفاق صور (اختياري)', false),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accent.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Media grid
                    if (_selectedMedia.isNotEmpty) ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                        itemCount: _selectedMedia.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _selectedMedia[index],
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeMedia(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      LucideIcons.x,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Add image button
                    InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              LucideIcons.image,
                              color: AppTheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'إضافة صورة',
                              style: GoogleFonts.cairo(
                                color: AppTheme.primary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (_selectedMedia.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'عدد الصور: ${_selectedMedia.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppTheme.accent.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'جاري الإرسال...',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'إرسال البلاغ',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFormLabel(String label, bool isRequired) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 4),
        if (isRequired)
          const Text(
            '*',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}