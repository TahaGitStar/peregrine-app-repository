// Models related to security guards and their schedules.

/// Represents a security guard assigned to a client
class Guard {
  final String id;
  final String name;
  final String badgeNumber;
  final String phoneNumber;
  final String? profileImageUrl;
  final String? specialization;
  final bool isActive;
  final List<WorkSchedule> schedule;
  final List<LeaveDay> leaveDays;
  final Guard? replacementGuard;

  Guard({
    required this.id,
    required this.name,
    required this.badgeNumber,
    required this.phoneNumber,
    this.profileImageUrl,
    this.specialization,
    required this.isActive,
    required this.schedule,
    required this.leaveDays,
    this.replacementGuard,
  });

  /// Create a Guard from JSON data
  factory Guard.fromJson(Map<String, dynamic> json) {
    // Parse schedule
    final scheduleJson = json['schedule'] as List<dynamic>? ?? [];
    final schedule = scheduleJson
        .map((scheduleItem) => WorkSchedule.fromJson(scheduleItem))
        .toList();

    // Parse leave days
    final leaveDaysJson = json['leaveDays'] as List<dynamic>? ?? [];
    final leaveDays = leaveDaysJson
        .map((leaveDay) => LeaveDay.fromJson(leaveDay))
        .toList();

    // Parse replacement guard if available
    Guard? replacementGuard;
    if (json['replacementGuard'] != null) {
      replacementGuard = Guard.fromJson(json['replacementGuard']);
    }

    return Guard(
      id: json['id'],
      name: json['name'],
      badgeNumber: json['badgeNumber'],
      phoneNumber: json['phoneNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      specialization: json['specialization'],
      isActive: json['isActive'] ?? true,
      schedule: schedule,
      leaveDays: leaveDays,
      replacementGuard: replacementGuard,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'badgeNumber': badgeNumber,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'specialization': specialization,
      'isActive': isActive,
      'schedule': schedule.map((s) => s.toJson()).toList(),
      'leaveDays': leaveDays.map((l) => l.toJson()).toList(),
      'replacementGuard': replacementGuard?.toJson(),
    };
  }
}

/// Represents a work schedule for a security guard
class WorkSchedule {
  final int dayOfWeek; // 1 = Monday, 7 = Sunday
  final String startTime;
  final String endTime;
  final String location;

  WorkSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.location,
  });

  /// Create a WorkSchedule from JSON data
  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      location: json['location'] ?? '',
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'location': location,
    };
  }

  /// Get the day name in Arabic
  String get dayName {
    switch (dayOfWeek) {
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      default:
        return '';
    }
  }
}

/// Represents a leave day for a security guard
class LeaveDay {
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status; // 'approved', 'pending', 'rejected'
  final Guard? replacementGuard;

  LeaveDay({
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.replacementGuard,
  });

  /// Create a LeaveDay from JSON data
  factory LeaveDay.fromJson(Map<String, dynamic> json) {
    // Parse replacement guard if available
    Guard? replacementGuard;
    if (json['replacementGuard'] != null) {
      replacementGuard = Guard.fromJson(json['replacementGuard']);
    }

    return LeaveDay(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      replacementGuard: replacementGuard,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
      'status': status,
      'replacementGuard': replacementGuard?.toJson(),
    };
  }

  /// Check if the leave is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Get the duration of the leave in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }
}

/// Response model for guard list API
class GuardsResponse {
  final List<Guard> guards;
  final bool success;
  final String message;
  final int total;

  GuardsResponse({
    required this.guards,
    required this.success,
    this.message = '',
    required this.total,
  });

  /// Create a GuardsResponse from JSON data
  factory GuardsResponse.fromJson(Map<String, dynamic> json) {
    final guardsJson = json['guards'] as List<dynamic>? ?? [];
    final guards = guardsJson
        .map((guardJson) => Guard.fromJson(guardJson))
        .toList();

    return GuardsResponse(
      guards: guards,
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      total: json['total'] ?? guards.length,
    );
  }

  /// Create an error response
  factory GuardsResponse.error(String errorMessage) {
    return GuardsResponse(
      guards: [],
      success: false,
      message: errorMessage,
      total: 0,
    );
  }
}