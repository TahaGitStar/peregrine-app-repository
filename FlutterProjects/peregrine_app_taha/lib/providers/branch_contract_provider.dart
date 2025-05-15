import 'package:flutter/material.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';

/// Provider for managing branches and contracts data
class BranchContractProvider extends ChangeNotifier {
  List<Branch> _branches = [];
  List<Contract> _contracts = [];
  Branch? _selectedBranch;
  Contract? _selectedContract;
  bool _isLoading = false;

  // Getters
  List<Branch> get branches => _branches;
  List<Contract> get contracts => _contracts;
  Branch? get selectedBranch => _selectedBranch;
  Contract? get selectedContract => _selectedContract;
  bool get isLoading => _isLoading;

  /// Initialize the provider with mock data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Load mock branches
      _branches = _getMockBranches();
      
      // Load mock contracts
      _contracts = _getMockContracts();
      
      _isLoading = false;
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
    notifyListeners();
  }

  /// Select a contract
  void selectContract(Contract contract) {
    _selectedContract = contract;
    notifyListeners();
  }

  /// Get contracts for a specific branch
  List<Contract> getContractsForBranch(String branchId) {
    return _contracts.where((contract) => contract.branchId == branchId).toList();
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

  /// Mock contracts data
  List<Contract> _getMockContracts() {
    return [
      Contract(
        id: 'contract-001',
        title: 'عقد حراسة مجمع سكني الرياض',
        branchId: 'branch-001',
        clientId: 'client-001',
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 335)),
        status: 'active',
        type: 'security',
        guardsCount: 5,
        value: 120000,
      ),
      Contract(
        id: 'contract-002',
        title: 'عقد حماية شخصية لرجل أعمال',
        branchId: 'branch-001',
        clientId: 'client-002',
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().add(const Duration(days: 305)),
        status: 'active',
        type: 'personal',
        guardsCount: 2,
        value: 80000,
      ),
      Contract(
        id: 'contract-003',
        title: 'عقد تأمين مركز تجاري جدة',
        branchId: 'branch-002',
        clientId: 'client-003',
        startDate: DateTime.now().subtract(const Duration(days: 90)),
        endDate: DateTime.now().add(const Duration(days: 275)),
        status: 'active',
        type: 'security',
        guardsCount: 8,
        value: 200000,
      ),
      Contract(
        id: 'contract-004',
        title: 'عقد حراسة فندق الدمام',
        branchId: 'branch-003',
        clientId: 'client-004',
        startDate: DateTime.now().subtract(const Duration(days: 45)),
        endDate: DateTime.now().add(const Duration(days: 320)),
        status: 'active',
        type: 'security',
        guardsCount: 6,
        value: 150000,
      ),
      Contract(
        id: 'contract-005',
        title: 'عقد تأمين فعالية في الرياض',
        branchId: 'branch-001',
        clientId: 'client-005',
        startDate: DateTime.now().add(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 18)),
        status: 'pending',
        type: 'event',
        guardsCount: 12,
        value: 36000,
      ),
      Contract(
        id: 'contract-006',
        title: 'عقد استشارات أمنية لشركة',
        branchId: 'branch-002',
        clientId: 'client-006',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime.now().add(const Duration(days: 355)),
        status: 'active',
        type: 'consultation',
        guardsCount: 0,
        value: 50000,
      ),
      Contract(
        id: 'contract-007',
        title: 'عقد حراسة مستشفى مكة',
        branchId: 'branch-004',
        clientId: 'client-007',
        startDate: DateTime.now().subtract(const Duration(days: 120)),
        endDate: DateTime.now().add(const Duration(days: 245)),
        status: 'active',
        type: 'security',
        guardsCount: 10,
        value: 240000,
      ),
      Contract(
        id: 'contract-008',
        title: 'عقد حماية شخصية المدينة',
        branchId: 'branch-005',
        clientId: 'client-008',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 350)),
        status: 'active',
        type: 'personal',
        guardsCount: 3,
        value: 100000,
      ),
    ];
  }
}