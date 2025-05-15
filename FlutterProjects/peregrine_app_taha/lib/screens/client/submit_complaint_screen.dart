import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:peregrine_app_taha/providers/user_role_provider.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart'; // Ensure this file defines the 'Branch' class
import 'package:peregrine_app_taha/providers/branch_contract_provider.dart'; // Ensure this is the correct import path

class SubmitComplaintScreen extends StatefulWidget {
  static const String routeName = '/submit-complaint';
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedComplaintType = 'خدمة الحراسة';
  final List<String> _complaintTypes = [
    'خدمة الحراسة',
    'تأخر الاستجابة',
    'سلوك الموظفين',
    'جودة الخدمة',
    'مشكلة أخرى',
  ];
  
  // Impact level state variable
  String _selectedImpactLevel = 'متوسط - تأثير ملحوظ على العمل';
  final List<Map<String, dynamic>> _impactLevels = [
    {'label': 'منخفض - تأثير بسيط على العمل', 'color': Colors.green},
    {'label': 'متوسط - تأثير ملحوظ على العمل', 'color': Colors.orange},
    {'label': 'مرتفع - تعطيل كبير للعمل', 'color': Colors.red},
  ];
  
  // Branch and contract selection
  Branch? _selectedBranch;
  Contract? _selectedContract;
  
  final List<String> _attachedFiles = [];
  bool _isSubmitting = false;
  bool _showSuccessState = false;
  
  // For the stepper
  int _currentStep = 0;

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
    
    // Initialize branch and contract data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
      userRoleProvider.initialize();
    });
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  void _attachFile() {
    // Mock file attachment
    final fileName = 'ملف_${_attachedFiles.length + 1}.${_attachedFiles.length % 2 == 0 ? 'pdf' : 'jpg'}';
    setState(() {
      _attachedFiles.add(fileName);
    });
  }
  
  void _removeFile(int index) {
    setState(() {
      _attachedFiles.removeAt(index);
    });
  }
  
  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Check if branch and contract are selected
      if (_selectedBranch == null || _selectedContract == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى اختيار الفرع والعقد',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      setState(() {
        _isSubmitting = true;
      });
      
      // Prepare complaint data with branch and contract information
      final complaintData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'type': _selectedComplaintType,
        'impactLevel': _selectedImpactLevel,
        'branchId': _selectedBranch!.id,
        'branchName': _selectedBranch!.name,
        'contractId': _selectedContract!.id,
        'contractTitle': _selectedContract!.title,
        'attachments': _attachedFiles,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Log the complaint data for debugging
      print('Submitting complaint: $complaintData');
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isSubmitting = false;
        _showSuccessState = true;
      });
      
      // Return to previous screen after showing success
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep += 1;
      });
    }
  }
  
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'تقديم شكوى', 
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
        child: _showSuccessState 
            ? _buildSuccessState() 
            : _buildComplaintForm(),
      ),
    );
  }
  
  Widget _buildComplaintForm() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepTapped: (step) {
            setState(() {
              _currentStep = step;
            });
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'السابق',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep < 2 ? _nextStep : _submitComplaint,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 3,
                        shadowColor: AppTheme.primary.withOpacity(0.3),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _currentStep < 2 ? 'التالي' : 'إرسال الشكوى',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(
                'معلومات الشكوى',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Selection Dropdown
                  Text(
                    'الفرع',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
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
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<Branch>(
                          value: _selectedBranch,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            prefixIcon: const Icon(Icons.business, color: AppTheme.primary),
                            hintText: 'اختر الفرع',
                            hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          ),
                          style: GoogleFonts.cairo(
                            color: AppTheme.accent,
                            fontSize: 12,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                          items: provider.branches.map<DropdownMenuItem<Branch>>((branch) {
                            return DropdownMenuItem<Branch>(
                              value: branch,
                              child: Text(branch.name),
                            );
                          }).toList(),
                          onChanged: (Branch? newValue) {
                            setState(() {
                              _selectedBranch = newValue;
                              _selectedContract = null; // Reset contract when branch changes
                            });
                            if (newValue != null) {
                              provider.selectBranch(newValue);
                            }
                          },
                          validator: (val) => val == null ? 'يرجى اختيار الفرع' : null,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Contract Selection Dropdown
                  Text(
                    'العقد',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Consumer<BranchContractProvider>(
                    builder: (context, provider, child) {
                      if (_selectedBranch == null) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'يرجى اختيار الفرع أولاً',
                            style: GoogleFonts.cairo(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        );
                      }
                      
                      final contractsForBranch = provider.contracts
                          .where((contract) => contract.branchId == _selectedBranch!.id)
                          .toList();
                      
                      if (contractsForBranch.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'لا توجد عقود متاحة لهذا الفرع',
                            style: GoogleFonts.cairo(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<Contract>(
                          value: _selectedContract,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
                            prefixIcon: const Icon(Icons.description, color: AppTheme.primary),
                            hintText: 'اختر العقد',
                            hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                          ),
                          style: GoogleFonts.cairo(
                            color: AppTheme.accent,
                            fontSize: 10,
                          ),
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                          items: contractsForBranch.map((Contract contract) {
                            return DropdownMenuItem<Contract>(
                              value: contract,
                              child: Text(contract.title),
                            );
                          }).toList(),
                          onChanged: (Contract? newValue) {
                            setState(() {
                              _selectedContract = newValue;
                            });
                            if (newValue != null) {
                              provider.selectContract(newValue);
                            }
                          },
                          validator: (val) => val == null ? 'يرجى اختيار العقد' : null,
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Complaint Type Dropdown
                  Text(
                    'نوع الشكوى',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedComplaintType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        prefixIcon: const Icon(Icons.warning, color: AppTheme.primary),
                      ),
                      style: GoogleFonts.cairo(
                        color: AppTheme.accent,
                        fontSize: 16,
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                      items: _complaintTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedComplaintType = newValue!;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title Field
                  Text(
                    'عنوان الشكوى',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'أدخل عنوان موجز للشكوى',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.title, color: AppTheme.primary),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: GoogleFonts.cairo(color: Colors.red),
                    ),
                    style: GoogleFonts.cairo(),
                    validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال عنوان الشكوى' : null,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text(
                'تفاصيل الشكوى',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Field
                  Text(
                    'وصف المشكلة',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'اشرح المشكلة بالتفصيل...',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: const Icon(Icons.description, color: AppTheme.primary),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.red, width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Colors.red, width: 2),
                      ),
                      errorStyle: GoogleFonts.cairo(color: Colors.red),
                    ),
                    style: GoogleFonts.cairo(),
                    validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال تفاصيل الشكوى' : null,
                    textDirection: TextDirection.rtl,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Complaint Impact
                  Text(
                    'تأثير المشكلة',
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _impactLevels.map((impact) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildImpactOption(impact['label'], impact['color']),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text(
                'المرفقات والمراجعة',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attachments
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المرفقات',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _attachFile,
                        icon: const Icon(Icons.attach_file, size: 18),
                        label: Text(
                          'إضافة مرفق',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Attached Files List
                  _attachedFiles.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'لا توجد مرفقات',
                              style: GoogleFonts.cairo(
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _attachedFiles.length,
                          itemBuilder: (context, index) {
                            final file = _attachedFiles[index];
                            final isImage = file.endsWith('jpg') || file.endsWith('png');
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isImage 
                                          ? Colors.blue.withOpacity(0.1) 
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isImage ? Icons.image : Icons.description,
                                      color: isImage ? Colors.blue : Colors.red,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      file,
                                      style: GoogleFonts.cairo(
                                        color: AppTheme.accent,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () => _removeFile(index),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                  
                  const SizedBox(height: 24),
                  
                  // Review Summary
                  Text(
                    'ملخص الشكوى',
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryItem('نوع الشكوى:', _selectedComplaintType),
                        const Divider(),
                        _buildSummaryItem('العنوان:', _titleController.text.isEmpty ? '-' : _titleController.text),
                        const Divider(),
                        _buildSummaryItem(
                          'التفاصيل:', 
                          _descriptionController.text.isEmpty 
                              ? '-' 
                              : _descriptionController.text.length > 100 
                                  ? '${_descriptionController.text.substring(0, 100)}...' 
                                  : _descriptionController.text,
                        ),
                        const Divider(),
                        _buildSummaryItem('تأثير المشكلة:', _selectedImpactLevel),
                        const Divider(),
                        _buildSummaryItem('المرفقات:', '${_attachedFiles.length} ملفات'),
                      ],
                    ),
                  ),
                ],
              ),
              isActive: _currentStep >= 2,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImpactOption(String label, Color color) {
    final isSelected = _selectedImpactLevel == label;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: color, width: 1.5) 
            : Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: RadioListTile<String>(
        title: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? color : AppTheme.accent,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        value: label,
        groupValue: _selectedImpactLevel,
        onChanged: (value) {
          setState(() {
            _selectedImpactLevel = value!;
          });
        },
        activeColor: color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        dense: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  
  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'تم إرسال شكواك بنجاح!',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم مراجعة شكواك والرد عليها في أقرب وقت',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك متابعة حالة شكواك من خلال صفحة التتبع',
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
}
