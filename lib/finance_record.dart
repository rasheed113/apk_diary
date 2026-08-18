class FinanceRecord {
  final int? id;

  final String type;

  final double amount;

  final String reason;

  final String recordDate;

  final String createdTime;

  const FinanceRecord({
    this.id,
    required this.type,
    required this.amount,
    required this.reason,
    required this.recordDate,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'reason': reason,
      'record_date': recordDate,
      'created_time': createdTime,
    };
  }

  factory FinanceRecord.fromMap(Map<String, dynamic> map) {
    return FinanceRecord(
      id: map['id'] as int?,
      type: map['type'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      reason: map['reason'] ?? '',
      recordDate: map['record_date'] ?? '',
      createdTime: map['created_time'] ?? '',
    );
  }

  FinanceRecord copyWith({
    int? id,
    String? type,
    double? amount,
    String? reason,
    String? recordDate,
    String? createdTime,
  }) {
    return FinanceRecord(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      recordDate: recordDate ?? this.recordDate,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}
