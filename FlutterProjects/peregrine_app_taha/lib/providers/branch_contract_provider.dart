import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';

/// Provider for managing branches and contracts data
class BranchContractProvider extends ChangeNotifier {
  List<Branch> _branches = [];
  List<Contract> _contracts = [];
  Branch? _selectedBranch;
  Contract? _selectedContract;
  String? _selectedContractType;
  bool _isLoading = false;
  bool _initialized = false;

  // Getters
  List<Branch> get branches => _branches;
  List<Contract> get contracts => _contracts;
  Branch? get selectedBranch => _selectedBranch;
  Contract? get selectedContract => _selectedContract;
  String? get selectedContractType => _selectedContractType;
  bool get isLoading => _isLoading;
  bool get isInitialized => _initialized;

  /// Initialize the provider with mock data
  Future<void> initialize() async {
    if (_initialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Load mock branches
      _branches = _getMockBranches();
      
      // Load mock contracts
      _contracts = _getMockContracts();
      
      // Set default branch if not already set
      if (_selectedBranch == null && _branches.isNotEmpty) {
        _selectedBranch = _branches.first;
      }
      
      _isLoading = false;
      _initialized = true;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Select a branch
  void selectBranch(Branch branch) {
    _selectedBranch = branch;
    
    // Reset selected contract if it doesn't belong to this branch
    if (_selectedContract != null && _selectedContract!.branchId != branch.id) {
      _selectedContract = null;
    }
    
    notifyListeners();
  }

  /// Select a contract
  void selectContract(Contract contract) {
    _selectedContract = contract;
    
    // Update selected branch to match contract's branch if needed
    if (_selectedBranch == null || _selectedBranch!.id != contract.branchId) {
      _selectedBranch = _branches.firstWhere(
        (branch) => branch.id == contract.branchId,
        orElse: () => _branches.first,
      );
    }
    
    // Update selected contract type
    _selectedContractType = contract.type;
    
    notifyListeners();
  }
  
  /// Select a contract type
  void selectContractType(String type) {
    _selectedContractType = type;
    notifyListeners();
  }

  /// Get contracts for a specific branch
  List<Contract> getContractsForBranch(String branchId) {
    return _contracts.where((contract) => contract.branchId == branchId).toList();
  }
  
  /// Get contracts filtered by branch and type
  List<Contract> getFilteredContracts({String? branchId, String? type}) {
    return _contracts.where((contract) {
      bool matchesBranch = branchId == null || contract.branchId == branchId;
      bool matchesType = type == null || contract.type == type;
      return matchesBranch && matchesType;
    }).toList();
  }

  /// Mock branches data
  List<Branch> _getMockBranches() {
    return [
      Branch(
        id: 'branch-001',
        name: 'فرع صنعاء',
        address: 'صنعاء، شارع الزبيري',
        phoneNumber: '01234567',
        managerName: 'محمد علي',
        isActive: true,
      ),
      Branch(
        id: 'branch-002',
        name: 'فرع عدن',
        address: 'عدن، المعلا',
        phoneNumber: '02345678',
        managerName: 'أحمد سالم',
        isActive: true,
      ),
      Branch(
        id: 'branch-003',
        name: 'فرع تعز',
        address: 'تعز، شارع جمال',
        phoneNumber: '03456789',
        managerName: 'سعيد عمر',
        isActive: true,
      ),
      Branch(
        id: 'branch-004',
        name: 'فرع الحديدة',
        address: 'الحديدة، شارع صنعاء',
        phoneNumber: '04567890',
        managerName: 'خالد محمد',
        isActive: true,
      ),
      Branch(
        id: 'branch-005',
        name: 'فرع المكلا',
        address: 'المكلا، شارع الميناء',
        phoneNumber: '05678901',
        managerName: 'عبدالله سعيد',
        isActive: true,
      ),
    ];
  }

  /// Mock contracts data
  List<Contract> _getMockContracts() {
    return [
      Contract(
        id: 'contract-001',
        title: 'عقد حراسة مجمع سكني صنعاء',
        branchId: 'branch-001',
        clientId: 'client-001',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 335)),
        status: 'active',
        type: 'حراسة',
        guardsCount: 5,
        value: 120000,
      ),
      Contract(
        id: 'contract-002',
        title: 'عقد سياقة لرجل أعمال',
        branchId: 'branch-001',
        clientId: 'client-002',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 305)),
        status: 'active',
        type: 'سياقة',
        guardsCount: 2,
        value: 80000,
      ),
      Contract(
        id: 'contract-003',
        title: 'عقد تأمين مركز تجاري عدن',
        branchId: 'branch-002',
        clientId: 'client-003',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().add(const Duration(days: 275)),
        status: 'active',
        type: 'حراسة',
        guardsCount: 8,
        value: 200000,
      ),
      Contract(
        id: 'contract-004',
        title: 'عقد حراسة فندق تعز',
        branchId: 'branch-003',
        clientId: 'client-004',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 320)),
        status: 'active',
        type: 'حراسة',
        guardsCount: 6,
        value: 150000,
      ),
      Contract(
        id: 'contract-005',
        title: 'عقد سياقة في صنعاء',
        branchId: 'branch-001',
        clientId: 'client-005',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 18)),
        status: 'active',
        type: 'سياقة',
        guardsCount: 1,
        value: 36000,
      ),
      Contract(
        id: 'contract-006',
        title: 'عقد حراسة لشركة',
        branchId: 'branch-002',
        clientId: 'client-006',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 355)),
        status: 'active',
        type: 'حراسة',
        guardsCount: 4,
        value: 50000,
      ),
      Contract(
        id: 'contract-007',
        title: 'عقد حراسة مستشفى الحديدة',
        branchId: 'branch-004',
        clientId: 'client-007',
        startDate: DateTime.now().subtract(const Duration(days: 120)),
        endDate: DateTime.now().add(const Duration(days: 245)),
        status: 'active',
        type: 'حراسة',
        guardsCount: 10,
        value: 240000,
      ),
      Contract(
        id: 'contract-008',
        title: 'عقد سياقة المكلا',
        branchId: 'branch-005',
        clientId: 'client-008',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 350)),
        status: 'active',
        type: 'سياقة',
        guardsCount: 3,
        value: 100000,
      ),
    ];
  }
}