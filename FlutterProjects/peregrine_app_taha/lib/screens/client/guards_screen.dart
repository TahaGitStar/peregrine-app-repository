import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:peregrine_app_taha/models/guard_models.dart';
import 'package:peregrine_app_taha/models/contract_type_models.dart';
import 'package:peregrine_app_taha/models/branch_contract_models.dart';
import 'package:peregrine_app_taha/providers/branch_contract_provider.dart';
import 'package:peregrine_app_taha/providers/user_role_provider.dart';
import 'package:peregrine_app_taha/screens/client/guard_details_screen.dart';
import 'package:peregrine_app_taha/services/guard_service.dart';
import 'package:peregrine_app_taha/utils/app_theme.dart';
import 'package:peregrine_app_taha/utils/date_formatter.dart';
import 'package:peregrine_app_taha/widgets/error_widget.dart';
import 'package:peregrine_app_taha/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class GuardsScreen extends StatefulWidget {
  static const String routeName = '/client-guards';
  
  const GuardsScreen({super.key});

  @override
  State<GuardsScreen> createState() => _GuardsScreenState();
}

class _GuardsScreenState extends State<GuardsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = true;
  String? _errorMessage;
  List<Guard> _guards = [];
  
  // Filters
  ContractType _selectedContractType = ContractType.security;
  Branch? _selectedBranch;
  bool _filterOnDutyToday = false;
  bool _filterOnDutyTomorrow = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Initialize providers
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      // Initialize branch contract provider
      final branchContractProvider = Provider.of<BranchContractProvider>(context, listen: false);
      await branchContractProvider.initialize();
      
      // Initialize user role provider
      final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
      await userRoleProvider.initialize();
      
      if (!mounted) return;
      
      // Set the contract type from user role provider
      _selectedContractType = userRoleProvider.selectedContractType;
      
      // Get the contract type string
      final contractType = _selectedContractType == ContractType.security ? 'حراسة' : 'سياقة';
      
      // Find branches that have contracts of this type
      final branchesWithContractType = branchContractProvider.branches
          .where((branch) {
            final contractsForBranch = branchContractProvider.getContractsForBranch(branch.id);
            return contractsForBranch.any((contract) => contract.type == contractType);
          })
          .toList();
      
      // Check if the user has a selected branch
      if (userRoleProvider.selectedBranch != null) {
        // Find the matching branch from branchContractProvider to ensure we use the same instance
        String selectedBranchId = userRoleProvider.selectedBranch!.id;
        
        // Check if the selected branch has contracts of the selected type
        final selectedBranchHasContractType = branchContractProvider.getContractsForBranch(selectedBranchId)
            .any((contract) => contract.type == contractType);
        
        if (selectedBranchHasContractType) {
          // Use the selected branch
          setState(() {
            _selectedBranch = branchContractProvider.branches.firstWhere(
              (branch) => branch.id == selectedBranchId,
              orElse: () => branchesWithContractType.isNotEmpty ? 
                            branchesWithContractType.first : 
                            userRoleProvider.selectedBranch!
            );
          });
        } else if (branchesWithContractType.isNotEmpty) {
          // Use the first branch that has contracts of this type
          setState(() {
            _selectedBranch = branchesWithContractType.first;
          });
          userRoleProvider.selectBranch(_selectedBranch!);
        }
      } else if (branchesWithContractType.isNotEmpty) {
        // Auto-select branch if there's only one with this contract type
        if (branchesWithContractType.length == 1) {
          setState(() {
            _selectedBranch = branchesWithContractType.first;
          });
          userRoleProvider.selectBranch(_selectedBranch!);
        } else if (branchesWithContractType.isNotEmpty) {
          // Otherwise use the first branch that has contracts of this type
          setState(() {
            _selectedBranch = branchesWithContractType.first;
          });
          userRoleProvider.selectBranch(_selectedBranch!);
        }
      }
      
      // Sync the selected branch between providers
      if (_selectedBranch != null) {
        branchContractProvider.selectBranch(_selectedBranch!);
        
        // Find a contract for this branch and set it as selected
        final contractsForBranch = branchContractProvider.getContractsForBranch(_selectedBranch!.id);
        if (contractsForBranch.isNotEmpty) {
          // Find a contract matching the selected contract type if possible
          final matchingContracts = contractsForBranch.where(
            (contract) => contract.type == contractType
          ).toList();
          
          if (matchingContracts.isNotEmpty) {
            branchContractProvider.selectContract(matchingContracts.first);
          } else {
            // If no matching contracts, try to switch contract type
            final otherContractType = contractType == 'حراسة' ? 'سياقة' : 'حراسة';
            final otherTypeContracts = contractsForBranch.where(
              (contract) => contract.type == otherContractType
            ).toList();
            
            if (otherTypeContracts.isNotEmpty) {
              // Switch to the other contract type
              setState(() {
                _selectedContractType = contractType == 'حراسة' ? 
                    ContractType.personal : ContractType.security;
              });
              userRoleProvider.selectContractType(_selectedContractType);
              branchContractProvider.selectContract(otherTypeContracts.first);
            } else {
              // Use the first contract as a fallback
              branchContractProvider.selectContract(contractsForBranch.first);
            }
          }
        }
      }
      
      // Load guards data with initial filters
      _loadGuards();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  /// Load guards data from the service with filters
  Future<void> _loadGuards() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Map the contract type to the appropriate string value
      final contractTypeStr = _selectedContractType == ContractType.security ? 'حراسة' : 'سياقة';
      
      // Check if we have a selected branch
      if (_selectedBranch == null) {
        // Get branch contract provider
        final branchContractProvider = Provider.of<BranchContractProvider>(context, listen: false);
        
        // Find branches that have contracts of this type
        final branchesWithContractType = branchContractProvider.branches
            .where((branch) {
              final contractsForBranch = branchContractProvider.getContractsForBranch(branch.id);
              return contractsForBranch.any((contract) => contract.type == contractTypeStr);
            })
            .toList();
        
        // Auto-select branch if there's only one
        if (branchesWithContractType.length == 1) {
          setState(() {
            _selectedBranch = branchesWithContractType.first;
          });
          branchContractProvider.selectBranch(_selectedBranch!);
          
          // Find a contract of this type for the branch
          final contractsForBranch = branchContractProvider.getContractsForBranch(_selectedBranch!.id);
          final matchingContracts = contractsForBranch.where(
            (contract) => contract.type == contractTypeStr
          ).toList();
          
          if (matchingContracts.isNotEmpty) {
            branchContractProvider.selectContract(matchingContracts.first);
          }
        }
      }
      
      final response = await GuardService.getAssignedGuards(
        contractType: contractTypeStr,
        branchId: _selectedBranch?.id,
        onDutyToday: _filterOnDutyToday ? true : null,
        onDutyTomorrow: _filterOnDutyTomorrow ? true : null,
      );
      
      if (!mounted) return;
      
      if (response.success) {
        setState(() {
          _guards = response.guards;
          _isLoading = false;
        });
        if (_animationController.status != AnimationStatus.forward && 
            _animationController.status != AnimationStatus.completed) {
          _animationController.forward();
        }
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
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
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        title: Text(
          'أفرادي',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        elevation: 8,
        shadowColor: AppTheme.primary.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          // Filter button
          IconButton(
            icon: const Icon(LucideIcons.filter, color: Colors.white, size: 22),
            splashRadius: 24,
            tooltip: 'تصفية',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showFilterBottomSheet();
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: Colors.white, size: 22),
            splashRadius: 24,
            tooltip: 'تحديث',
            onPressed: () {
              HapticFeedback.mediumImpact();
              _loadGuards();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Contract type selector
          _buildContractTypeSelector(),
          
          // Main content
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
  
  /// Build contract type and branch selector
  Widget _buildContractTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Contract Type Row
          Row(
            children: [
              Text(
                'نوع العقد:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedContractType == ContractType.security ? 'حراسة' : 'سياقة',
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                      items: [
                        DropdownMenuItem<String>(
                          value: 'حراسة',
                          child: Text(
                            'عقد حراسة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'سياقة',
                          child: Text(
                            'عقد سائقين',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppTheme.accent,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedContractType = newValue == 'حراسة' ? 
                                ContractType.security : ContractType.personal;
                          });
                          
                          // Update provider
                          final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
                          userRoleProvider.selectContractType(_selectedContractType);
                          
                          // Get branch contract provider
                          final branchContractProvider = Provider.of<BranchContractProvider>(context, listen: false);
                          
                          // Find branches that have contracts of this type
                          final contractType = newValue;
                          final branchesWithContractType = branchContractProvider.branches
                              .where((branch) {
                                final contractsForBranch = branchContractProvider.getContractsForBranch(branch.id);
                                return contractsForBranch.any((contract) => contract.type == contractType);
                              })
                              .toList();
                          
                          // Auto-select branch if there's only one
                          if (branchesWithContractType.length == 1) {
                            setState(() {
                              _selectedBranch = branchesWithContractType.first;
                            });
                            branchContractProvider.selectBranch(_selectedBranch!);
                            
                            // Find a contract of this type for the branch
                            final contractsForBranch = branchContractProvider.getContractsForBranch(_selectedBranch!.id);
                            final matchingContracts = contractsForBranch.where(
                              (contract) => contract.type == contractType
                            ).toList();
                            
                            if (matchingContracts.isNotEmpty) {
                              branchContractProvider.selectContract(matchingContracts.first);
                            }
                          } else if (_selectedBranch != null) {
                            // Check if current branch has contracts of this type
                            final contractsForBranch = branchContractProvider.getContractsForBranch(_selectedBranch!.id);
                            final hasContractsOfType = contractsForBranch.any(
                              (contract) => contract.type == contractType
                            );
                            
                            if (!hasContractsOfType && branchesWithContractType.isNotEmpty) {
                              // Select the first branch that has contracts of this type
                              setState(() {
                                _selectedBranch = branchesWithContractType.first;
                              });
                              branchContractProvider.selectBranch(_selectedBranch!);
                              
                              // Find a contract of this type for the branch
                              final newContractsForBranch = branchContractProvider.getContractsForBranch(_selectedBranch!.id);
                              final matchingContracts = newContractsForBranch.where(
                                (contract) => contract.type == contractType
                              ).toList();
                              
                              if (matchingContracts.isNotEmpty) {
                                branchContractProvider.selectContract(matchingContracts.first);
                              }
                            }
                          }
                          
                          // Reload guards with new filter
                          _loadGuards();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Branch Selection Row
          Consumer<BranchContractProvider>(
            builder: (context, branchContractProvider, child) {
              // Get the current contract type
              final contractType = _selectedContractType == ContractType.security ? 'حراسة' : 'سياقة';
              
              // Find branches that have contracts of this type
              final branchesWithContractType = branchContractProvider.branches
                  .where((branch) {
                    final contractsForBranch = branchContractProvider.getContractsForBranch(branch.id);
                    return contractsForBranch.any((contract) => contract.type == contractType);
                  })
                  .toList();
              
              return Row(
                children: [
                  Text(
                    'الفرع:',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Branch>(
                          value: _selectedBranch,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                          hint: Text(
                            'اختر الفرع',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          items: branchesWithContractType.map((Branch branch) {
                            return DropdownMenuItem<Branch>(
                              value: branch,
                              child: Text(
                                branch.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: AppTheme.accent,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Branch? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedBranch = newValue;
                              });
                              
                              // Update providers
                              final userRoleProvider = Provider.of<UserRoleProvider>(context, listen: false);
                              userRoleProvider.selectBranch(newValue);
                              branchContractProvider.selectBranch(newValue);
                              
                              // Find a contract of the selected type for this branch
                              final contractsForBranch = branchContractProvider.getContractsForBranch(newValue.id);
                              final matchingContracts = contractsForBranch.where(
                                (contract) => contract.type == contractType
                              ).toList();
                              
                              if (matchingContracts.isNotEmpty) {
                                branchContractProvider.selectContract(matchingContracts.first);
                              }
                              
                              // Reload guards with new filter
                              _loadGuards();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
  
  /// Show filter bottom sheet
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'تصفية الأفراد',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.accent),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Branch selector
                Consumer2<UserRoleProvider, BranchContractProvider>(
                  builder: (context, userRoleProvider, branchContractProvider, child) {
                    if (userRoleProvider.isLoading || branchContractProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الفرع:',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Branch>(
                              value: _selectedBranch,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                              hint: Text(
                                'اختر الفرع',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              items: branchContractProvider.branches.map((Branch branch) {
                                return DropdownMenuItem<Branch>(
                                  value: branch,
                                  child: Text(
                                    branch.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: userRoleProvider.userRole == UserRole.branchManager 
                                ? null // Branch managers can't change their branch
                                : (Branch? newValue) {
                                    setState(() {
                                      _selectedBranch = newValue;
                                    });
                                    if (newValue != null) {
                                      // Update both providers
                                      userRoleProvider.selectBranch(newValue);
                                      branchContractProvider.selectBranch(newValue);
                                      
                                      // Find a contract for this branch
                                      final contractsForBranch = branchContractProvider.getContractsForBranch(newValue.id);
                                      if (contractsForBranch.isNotEmpty) {
                                        // Find a contract matching the selected contract type if possible
                                        final contractType = _selectedContractType == ContractType.security ? 'حراسة' : 'سياقة';
                                        final matchingContracts = contractsForBranch.where(
                                          (contract) => contract.type == contractType
                                        ).toList();
                                        
                                        if (matchingContracts.isNotEmpty) {
                                          branchContractProvider.selectContract(matchingContracts.first);
                                        } else {
                                          branchContractProvider.selectContract(contractsForBranch.first);
                                        }
                                      }
                                      
                                      // Reload guards with new filter
                                      Navigator.pop(context);
                                      _loadGuards();
                                    }
                                  },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Contract selection
                Consumer<BranchContractProvider>(
                  builder: (context, provider, child) {
                    if (_selectedBranch == null) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'العقد:',
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
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'يرجى اختيار الفرع أولاً',
                              style: GoogleFonts.cairo(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    final contractsForBranch = provider.getContractsForBranch(_selectedBranch!.id);
                    
                    if (contractsForBranch.isEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'العقد:',
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
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              'لا توجد عقود متاحة لهذا الفرع',
                              style: GoogleFonts.cairo(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العقد:',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Contract>(
                              value: provider.selectedContract,
                              isExpanded: true,
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primary),
                              hint: Text(
                                'اختر العقد',
                                style: GoogleFonts.cairo(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              items: contractsForBranch.map((Contract contract) {
                                return DropdownMenuItem<Contract>(
                                  value: contract,
                                  child: Text(
                                    contract.title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14,
                                      color: AppTheme.accent,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (Contract? newValue) {
                                if (newValue != null) {
                                  provider.selectContract(newValue);
                                  
                                  // Update contract type based on contract
                                  if (newValue.type == 'حراسة') {
                                    setState(() {
                                      _selectedContractType = ContractType.security;
                                    });
                                  } else if (newValue.type == 'سياقة') {
                                    setState(() {
                                      _selectedContractType = ContractType.personal;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Duty filters
                Text(
                  'تصفية حسب الدوام:',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(height: 8),
                
                // On duty today
                CheckboxListTile(
                  value: _filterOnDutyToday,
                  onChanged: (value) {
                    setState(() {
                      _filterOnDutyToday = value ?? false;
                    });
                  },
                  title: Text(
                    'على رأس العمل اليوم',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.accent,
                    ),
                  ),
                  activeColor: AppTheme.primary,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                
                // On duty tomorrow
                CheckboxListTile(
                  value: _filterOnDutyTomorrow,
                  onChanged: (value) {
                    setState(() {
                      _filterOnDutyTomorrow = value ?? false;
                    });
                  },
                  title: Text(
                    'على رأس العمل غداً',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppTheme.accent,
                    ),
                  ),
                  activeColor: AppTheme.primary,
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                
                const SizedBox(height: 24),
                
                // Apply filters button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadGuards();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تطبيق التصفية',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Reset filters button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _filterOnDutyToday = false;
                        _filterOnDutyTomorrow = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.accent,
                      side: BorderSide(color: AppTheme.accent.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إعادة ضبط',
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
      ),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'جاري تحميل بيانات الحراس...');
    }
    
    if (_errorMessage != null) {
      return AppErrorWidget(
        message: _errorMessage!,
        onRetry: _loadGuards,
      );
    }
    
    // Check if a branch is selected
    if (_selectedBranch == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.building2,
              size: 64,
              color: AppTheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'يرجى اختيار الفرع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'قم باختيار الفرع من القائمة أعلاه لعرض الحراس المخصصين',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.accent.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (_guards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.userX,
              size: 64,
              color: AppTheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد حراس مخصصين لهذا الفرع',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.accent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'جرب اختيار فرع آخر أو نوع عقد آخر',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppTheme.accent.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGuards,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: Text(
                'تحديث',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
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
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: RefreshIndicator(
        onRefresh: _loadGuards,
        color: AppTheme.primary,
        backgroundColor: Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _guards.length,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          itemBuilder: (context, index) {
            final guard = _guards[index];
            // Staggered animation for list items
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final delay = (index * 0.1).clamp(0.0, 0.5);
                final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Interval(delay, delay + 0.4, curve: Curves.easeOutQuart),
                  ),
                );
                
                return FadeTransition(
                  opacity: itemAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - itemAnimation.value)),
                    child: child,
                  ),
                );
              },
              child: _buildGuardCard(guard),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildGuardCard(Guard guard) {
    // Check if guard is on leave
    final onLeave = guard.leaveDays.isNotEmpty && guard.leaveDays.any((leave) => leave.isActive);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: AppTheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: onLeave 
              ? Colors.orange.withOpacity(0.5) 
              : AppTheme.primary.withOpacity(0.1),
          width: onLeave ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GuardDetailsScreen(guardId: guard.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Guard avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: onLeave 
                            ? Colors.orange 
                            : AppTheme.primary,
                        width: 2,
                      ),
                    ),
                    child: guard.profileImageUrl != null
                        ? ClipOval(
                            child: Image.network(
                              guard.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  LucideIcons.user,
                                  color: AppTheme.primary,
                                  size: 30,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            LucideIcons.user,
                            color: AppTheme.primary,
                            size: 30,
                          ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Guard info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                guard.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (onLeave)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'في إجازة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'رقم الشارة: ${guard.badgeNumber}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppTheme.accent.withOpacity(0.7),
                          ),
                        ),
                        if (guard.specialization != null && guard.specialization!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            guard.specialization!,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              
              // Schedule preview
              Text(
                'جدول العمل:',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 8),
              
              // Show first 3 days of schedule
              ...guard.schedule.take(3).map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        schedule.dayName,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${schedule.startTime} - ${schedule.endTime}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.accent,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      schedule.location,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppTheme.accent.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )),
              
              if (guard.schedule.length > 3) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    '+ ${guard.schedule.length - 3} أيام أخرى',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              // Show replacement guard if on leave
              if (onLeave && guard.leaveDays.isNotEmpty && guard.leaveDays.first.replacementGuard != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
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
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    // Replacement guard avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      child: guard.leaveDays.first.replacementGuard!.profileImageUrl != null
                          ? ClipOval(
                              child: Image.network(
                                guard.leaveDays.first.replacementGuard!.profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    LucideIcons.user,
                                    color: Colors.green,
                                    size: 20,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              LucideIcons.user,
                              color: Colors.green,
                              size: 20,
                            ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Replacement guard info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guard.leaveDays.first.replacementGuard!.name,
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accent,
                            ),
                          ),
                          Text(
                            'رقم الشارة: ${guard.leaveDays.first.replacementGuard!.badgeNumber}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppTheme.accent.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // View details button
                    IconButton(
                      icon: const Icon(
                        LucideIcons.arrowUpRight,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GuardDetailsScreen(
                              guardId: guard.leaveDays.first.replacementGuard!.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'فترة الإجازة: ${DateFormatter.formatDateRange(
                        guard.leaveDays.first.startDate,
                        guard.leaveDays.first.endDate,
                      )}',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 12),
              
              // View details button
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GuardDetailsScreen(guardId: guard.id),
                      ),
                    );
                  },
                  icon: const Icon(
                    LucideIcons.info,
                    size: 18,
                  ),
                  label: Text(
                    'عرض التفاصيل',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}