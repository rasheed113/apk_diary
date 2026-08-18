class DiaryEntry {
  final int? id;

  final String itemName;
  final String sizes;

  final int pieces;

  final double rate;

  final String rateType;

  final double total;

  final String machineType;

  final String jobType;

  final String notes;

  final String workDate;

  final String createdTime;

  const DiaryEntry({
    this.id,
    required this.itemName,
    required this.sizes,
    required this.pieces,
    required this.rate,
    required this.rateType,
    required this.total,
    required this.machineType,
    required this.jobType,
    required this.notes,
    required this.workDate,
    required this.createdTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item_name': itemName,
      'sizes': sizes,
      'pieces': pieces,
      'rate': rate,
      'rate_type': rateType,
      'total': total,
      'machine_type': machineType,
      'job_type': jobType,
      'notes': notes,
      'work_date': workDate,
      'created_time': createdTime,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'] as int?,
      itemName: map['item_name'] ?? '',
      sizes: map['sizes'] ?? '',
      pieces: map['pieces'] ?? 0,
      rate: (map['rate'] ?? 0).toDouble(),
      rateType: map['rate_type'] ?? '',
      total: (map['total'] ?? 0).toDouble(),
      machineType: map['machine_type'] ?? '',
      jobType: map['job_type'] ?? '',
      notes: map['notes'] ?? '',
      workDate: map['work_date'] ?? '',
      createdTime: map['created_time'] ?? '',
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? itemName,
    String? sizes,
    int? pieces,
    double? rate,
    String? rateType,
    double? total,
    String? machineType,
    String? jobType,
    String? notes,
    String? workDate,
    String? createdTime,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      sizes: sizes ?? this.sizes,
      pieces: pieces ?? this.pieces,
      rate: rate ?? this.rate,
      rateType: rateType ?? this.rateType,
      total: total ?? this.total,
      machineType: machineType ?? this.machineType,
      jobType: jobType ?? this.jobType,
      notes: notes ?? this.notes,
      workDate: workDate ?? this.workDate,
      createdTime: createdTime ?? this.createdTime,
    );
  }
}
