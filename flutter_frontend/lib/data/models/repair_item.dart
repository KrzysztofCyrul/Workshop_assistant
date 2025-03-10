class RepairItem {
  final String? appointmentId;
  final String? description;
  bool isCompleted;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final double cost;
  final String? completedBy;
  String status;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int order;

  RepairItem({
    this.appointmentId,
    this.description,
    this.isCompleted = false,
    this.estimatedDuration,
    this.actualDuration,
    this.cost = 0.0,
    this.completedBy,
    this.status = 'pending',
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
  });

 // Funkcja `copyWith` umożliwia modyfikację wybranych pól
  RepairItem copyWith({
    String? id,
    String? appointmentId,
    String? description,
    bool? isCompleted,
    String? completedBy,
    String? status,
    Duration? estimatedDuration,
    Duration? actualDuration,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? cost,
    int? order,
  }) {
    return RepairItem(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      status: status ?? this.status,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cost: cost ?? this.cost,
      order: order ?? this.order,
    );
  }

  factory RepairItem.fromJson(Map<String, dynamic> json) {
    return RepairItem(
      appointmentId: json['appointment'] as String?,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      estimatedDuration: _parseDuration(json['estimated_duration']),
      actualDuration: _parseDuration(json['actual_duration']),
      cost: double.tryParse(json['cost']?.toString() ?? '0.0') ?? 0.0,
      completedBy: json['completed_by'] as String?,
      status: json['status'] as String? ?? 'pending',
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      order: json['order'] ?? 0,
    );
  }

  // Funkcja pomocnicza do parsowania ciągu znaków na Duration
  static Duration? _parseDuration(dynamic value) {
    if (value == null) return null;
    try {
      // Przyjmuje format "HH:MM:SS"
      final parts = value.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (_) {
      return null;
    }
  }

  // Funkcja do formatowania Duration na string w formacie dziesiętnym "HH.HHHHHH"

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'status': status,
      'order': order,
      'cost': cost,
      'estimated_duration': estimatedDuration?.inMinutes,
      'actual_duration': actualDuration?.inMinutes,
    };
  }

  String get formattedCost => '${cost.toStringAsFixed(2)} PLN';
}