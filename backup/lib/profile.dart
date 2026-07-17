class Profile {
  final int? id;

  final String operatorName;

  final String companyName;

  final String defaultMachineType;

  final String defaultJobType;

  final String currency;

  const Profile({
    this.id,
    required this.operatorName,
    required this.companyName,
    required this.defaultMachineType,
    required this.defaultJobType,
    required this.currency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'operator_name': operatorName,
      'company_name': companyName,
      'default_machine_type': defaultMachineType,
      'default_job_type': defaultJobType,
      'currency': currency,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as int?,
      operatorName: map['operator_name'] ?? '',
      companyName: map['company_name'] ?? '',
      defaultMachineType: map['default_machine_type'] ?? '',
      defaultJobType: map['default_job_type'] ?? '',
      currency: map['currency'] ?? 'PKR',
    );
  }

  Profile copyWith({
    int? id,
    String? operatorName,
    String? companyName,
    String? defaultMachineType,
    String? defaultJobType,
    String? currency,
  }) {
    return Profile(
      id: id ?? this.id,
      operatorName: operatorName ?? this.operatorName,
      companyName: companyName ?? this.companyName,
      defaultMachineType: defaultMachineType ?? this.defaultMachineType,
      defaultJobType: defaultJobType ?? this.defaultJobType,
      currency: currency ?? this.currency,
    );
  }
}
