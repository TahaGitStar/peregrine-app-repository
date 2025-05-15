import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:peregrine_app_taha/providers/user_role_provider.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';
import 'package:peregrine_app_taha/providers/branch_contract_provider.dart'; // Ensure this is the correct path

class SubmitRequestScreen extends StatefulWidget {
  static const String routeName = '/submit-request';
  const SubmitRequestScreen({super.key});

  @override
  State<SubmitRequestScreen> createState() => _SubmitRequestScreenState();
}

class _SubmitRequestScreenState extends State<SubmitRequestScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _detailsController = TextEditingController();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  String _selectedRequestType = 'خدمة حراسة';
  final List<String> _requestTypes = [
    'خدمة حراسة',
    'حماية شخصية',
    'تقرير أمني',
    'استشارة أمنية',
    'خدمة أخرى',
  ];
  
  String? _selectedPriority;
  final List<String> _priorities = ['عادي', 'مهم', 'عاجل'];
  
  // Branch and contract selection
  Branch? _selectedBranch;
  Contract? _selectedContract;
  
  DateTime? _selectedDate;
  bool _isSubmitting = false;
  bool _showSuccessState = false;

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
    _subjectController.dispose();
    _detailsController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
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
  
  void _submitRequest() async {
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
      
      // Prepare request data with branch and contract information
      final requestData = {
        'subject': _subjectController.text,
        'details': _detailsController.text,
        'type': _selectedRequestType,
        'priority': _selectedPriority,
        'scheduledDate': _selectedDate?.toIso8601String(),
        'branchId': _selectedBranch!.id,
        'branchName': _selectedBranch!.name,
        'contractId': _selectedContract!.id,
        'contractTitle': _selectedContract!.title,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Log the request data for debugging
      print('Submitting request: $requestData');
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'تقديم طلب', 
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
            : _buildRequestForm(),
      ),
    );
  }
  
  Widget _buildRequestForm() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.description,
                      color: AppTheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نموذج تقديم طلب جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          Text(
                            'يرجى تعبئة جميع الحقول المطلوبة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
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
                      items: provider.branches.map<DropdownMenuItem<Branch>>((Branch branch) {
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        prefixIcon: const Icon(Icons.description, color: AppTheme.primary),
                        hintText: 'اختر العقد',
                        hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                      ),
                      style: GoogleFonts.cairo(
                        color: AppTheme.accent,
                        fontSize: 12,
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
              
              // Request Type Dropdown
              Text(
                'نوع الطلب',
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
                  value: _selectedRequestType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    prefixIcon: const Icon(Icons.list_alt, color: AppTheme.primary),
                  ),
                  style: GoogleFonts.cairo(
                    color: AppTheme.accent,
                    fontSize: 16,
                  ),
                  icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                  items: _requestTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRequestType = newValue!;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Subject Field
              Text(
                'موضوع الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'أدخل عنوان موجز للطلب',
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
                validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال موضوع الطلب' : null,
                textDirection: TextDirection.rtl,
              ),
              
              const SizedBox(height: 20),
              
              // Details Field
              Text(
                'تفاصيل الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'اشرح طلبك بالتفصيل...',
                  hintStyle: GoogleFonts.cairo(color: Colors.grey[400]),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
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
                validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال تفاصيل الطلب' : null,
                textDirection: TextDirection.rtl,
              ),
              
              const SizedBox(height: 20),
              
              // Priority Selection
              Text(
                'الأولوية',
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
                ),
                child: Row(
                  children: _priorities.map((priority) {
                    final isSelected = _selectedPriority == priority;
                    Color chipColor;
                    
                    if (priority == 'عاجل') {
                      chipColor = Colors.red;
                    } else if (priority == 'مهم') {
                      chipColor = Colors.orange;
                    } else {
                      chipColor = Colors.green;
                    }
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? chipColor.withOpacity(0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? chipColor : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                priority == 'عاجل' 
                                    ? Icons.warning 
                                    : priority == 'مهم' 
                                        ? Icons.info 
                                        : Icons.check_circle,
                                color: isSelected ? chipColor : Colors.grey[400],
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priority,
                                style: GoogleFonts.cairo(
                                  color: isSelected ? chipColor : Colors.grey[600],
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_selectedPriority == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Text(
                    'يرجى اختيار الأولوية',
                    style: GoogleFonts.cairo(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const SizedBox(height: 20),
              
              // Date Selection
              Text(
                'تاريخ التنفيذ المطلوب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedDate == null ? Colors.grey[300]! : AppTheme.primary,
                      width: _selectedDate == null ? 1 : 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _selectedDate == null ? Colors.grey[400] : AppTheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null 
                            ? 'اختر التاريخ' 
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: GoogleFonts.cairo(
                          color: _selectedDate == null ? Colors.grey[600] : AppTheme.accent,
                          fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: _selectedDate == null ? Colors.grey[400] : AppTheme.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedDate == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Text(
                    'يرجى اختيار التاريخ',
                    style: GoogleFonts.cairo(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting || _selectedPriority == null || _selectedDate == null 
                      ? null 
                      : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: AppTheme.primary.withOpacity(0.3),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send),
                            const SizedBox(width: 8),
                            Text(
                              'إرسال الطلب',
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
            'تم إرسال طلبك بنجاح!',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'سيتم مراجعة طلبك والرد عليه في أقرب وقت',
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'يمكنك متابعة حالة طلبك من خلال صفحة التتبع',
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