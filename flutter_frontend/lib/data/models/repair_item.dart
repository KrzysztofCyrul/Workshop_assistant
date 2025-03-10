class RepairItem {
  final String? appointmentId;
  final String? description;
  bool isCompleted;
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
    DateTime? createdAt,
    DateTime? updatedAt,
    int? order,
  }) {
    return RepairItem(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedBy: completedBy ?? this.completedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  factory RepairItem.fromJson(Map<String, dynamic> json) {
    return RepairItem(
      appointmentId: json['appointment'] as String?,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
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
    };
  }
}