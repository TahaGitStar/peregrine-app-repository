/// Enum representing different types of security contracts
enum ContractType {
  security,
  personal,
  event,
  consultation,
  other;

  /// Get the Arabic name for the contract type
  String get arabicName {
    switch (this) {
      case ContractType.security:
        return 'خدمة حراسة';
      case ContractType.personal:
        return 'حماية شخصية';
      case ContractType.event:
        return 'تأمين فعاليات';
      case ContractType.consultation:
        return 'استشارات أمنية';
      case ContractType.other:
        return 'خدمات أخرى';
    }
  }

  /// Get the icon name for the contract type
  String get iconName {
    switch (this) {
      case ContractType.security:
        return 'shield';
      case ContractType.personal:
        return 'user_shield';
      case ContractType.event:
        return 'calendar_check';
      case ContractType.consultation:
        return 'file_text';
      case ContractType.other:
        return 'more_horizontal';
    }
  }

  /// Get the contract type from a string name
  static ContractType fromString(String name) {
    return ContractType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => ContractType.security,
    );
  }
}