// Models related to branches and contracts

/// Represents a branch office
class Branch {
  final String id;
  final String name;
  final String address;
  final String? phoneNumber;
  final String? managerName;
  final String? managerEmail;
  final String? managerPhone;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    this.phoneNumber,
    this.managerName,
    this.managerEmail,
    this.managerPhone,
    this.isActive = true,
  });

  /// Create a Branch from JSON data
  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'],
      managerName: json['managerName'],
      managerEmail: json['managerEmail'],
      managerPhone: json['managerPhone'],
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'managerName': managerName,
      'managerEmail': managerEmail,
      'managerPhone': managerPhone,
      'isActive': isActive,
    };
  }
}

/// Represents a contract between client and company
class Contract {
  final String id;
  final String title;
  final String branchId;
  final String clientId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'active', 'pending', 'expired', 'terminated'
  final String type; // 'security', 'personal', 'event', etc.
  final int guardsCount;
  final double value;
  final String? notes;

  Contract({
    required this.id,
    required this.title,
    required this.branchId,
    required this.clientId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.type,
    required this.guardsCount,
    required this.value,
    this.notes,
  });

  /// Create a Contract from JSON data
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      title: json['title'],
      branchId: json['branchId'],
      clientId: json['clientId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      status: json['status'] ?? 'active',
      type: json['type'] ?? 'security',
      guardsCount: json['guardsCount'] ?? 0,
      value: (json['value'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'branchId': branchId,
      'clientId': clientId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status,
      'type': type,
      'guardsCount': guardsCount,
      'value': value,
      'notes': notes,
    };
  }

  /// Check if the contract is currently active
  bool get isActive => status == 'active';

  /// Get the remaining days until contract expiration
  int get remainingDays {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }
}

/// Response model for branch list API
class BranchesResponse {
  final List<Branch> branches;
  final bool success;
  final String message;
  final int total;

  BranchesResponse({
    required this.branches,
    required this.success,
    this.message = '',
    required this.total,
  });

  /// Create a BranchesResponse from JSON data
  factory BranchesResponse.fromJson(Map<String, dynamic> json) {
    final branchesJson = json['branches'] as List<dynamic>? ?? [];
    final branches = branchesJson
        .map((branchJson) => Branch.fromJson(branchJson))
        .toList();

    return BranchesResponse(
      branches: branches,
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      total: json['total'] ?? branches.length,
    );
  }

  /// Create an error response
  factory BranchesResponse.error(String errorMessage) {
    return BranchesResponse(
      branches: [],
      success: false,
      message: errorMessage,
      total: 0,
    );
  }
}

/// Response model for contract list API
class ContractsResponse {
  final List<Contract> contracts;
  final bool success;
  final String message;
  final int total;

  ContractsResponse({
    required this.contracts,
    required this.success,
    this.message = '',
    required this.total,
  });

  /// Create a ContractsResponse from JSON data
  factory ContractsResponse.fromJson(Map<String, dynamic> json) {
    final contractsJson = json['contracts'] as List<dynamic>? ?? [];
    final contracts = contractsJson
        .map((contractJson) => Contract.fromJson(contractJson))
        .toList();

    return ContractsResponse(
      contracts: contracts,
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      total: json['total'] ?? contracts.length,
    );
  }

  /// Create an error response
  factory ContractsResponse.error(String errorMessage) {
    return ContractsResponse(
      contracts: [],
      success: false,
      message: errorMessage,
      total: 0,
    );
  }
}