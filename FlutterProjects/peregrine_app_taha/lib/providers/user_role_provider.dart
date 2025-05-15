import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';
import 'package:peregrine_app_taha/models/contract_type_models.dart';

/// Enum representing different user roles in the system
enum UserRole {
  client,
  support,
  admin,
  guard,
  branchManager;
  
  /// Get the display name for the role
  String get displayName {
    switch (this) {
      case UserRole.client:
        return 'عميل';
      case UserRole.support:
        return 'دعم فني';
      case UserRole.admin:
        return 'مدير نظام';
      case UserRole.guard:
        return 'حارس أمن';
      case UserRole.branchManager:
        return 'مدير فرع';
    }
  }
}

/// Provider for managing user role and related data
class UserRoleProvider extends ChangeNotifier {
  UserRole _userRole = UserRole.client;
  bool _isLoading = false;
  
  // Branch and contract related data
  List<Branch> _branches = [];
  Branch? _selectedBranch;
  ContractType _selectedContractType = ContractType.security;
  
  // Getters
  UserRole get userRole => _userRole;
  bool get isLoading => _isLoading;
  List<Branch> get branches => _branches;
  Branch? get selectedBranch => _selectedBranch;
  ContractType get selectedContractType => _selectedContractType;
  
  /// Initialize the provider with mock data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Load mock branches
      _branches = _getMockBranches();
      
      // Set default selected branch if not already set
      if (_selectedBranch == null && _branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  /// Set the user role
  void setUserRole(UserRole role) {
    _userRole = role;
    notifyListeners();
  }
  
  /// Select a branch
  void selectBranch(Branch branch) {
    _selectedBranch = branch;
    notifyListeners();
  }
  
  /// Select a contract type
  void selectContractType(ContractType type) {
    _selectedContractType = type;
    notifyListeners();
  }
  
  /// Mock branches data
  List<Branch> _getMockBranches() {
    return [
      Branch(
        id: 'branch-001',
        name: 'فرع الرياض',
        address: 'الرياض، حي العليا، شارع التخصصي',
        phoneNumber: '0112345678',
        managerName: 'أحمد محمد',
        isActive: true,
      ),
      Branch(
        id: 'branch-002',
        name: 'فرع جدة',
        address: 'جدة، حي الروضة، شارع فلسطين',
        phoneNumber: '0123456789',
        managerName: 'خالد عبدالله',
        isActive: true,
      ),
      Branch(
        id: 'branch-003',
        name: 'فرع الدمام',
        address: 'الدمام، حي الشاطئ، طريق الملك فهد',
        phoneNumber: '0134567890',
        managerName: 'سعد العتيبي',
        isActive: true,
      ),
      Branch(
        id: 'branch-004',
        name: 'فرع مكة',
        address: 'مكة المكرمة، العزيزية',
        phoneNumber: '0145678901',
        managerName: 'فهد القحطاني',
        isActive: true,
      ),
      Branch(
        id: 'branch-005',
        name: 'فرع المدينة',
        address: 'المدينة المنورة، حي الروضة',
        phoneNumber: '0156789012',
        managerName: 'عبدالرحمن السلمي',
        isActive: true,
      ),
    ];
  }
}