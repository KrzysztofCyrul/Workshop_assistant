class RepairItem {
  final String id;
  final String appointmentId;
  final String description;
  final bool isCompleted;
  final String? completedBy;
  final String status;
  final Duration? estimatedDuration;
  final Duration? actualDuration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double cost;
  final int order;

  RepairItem({
    required this.id,
    required this.appointmentId,
    required this.description,
    required this.isCompleted,
    this.completedBy,
    required this.status,
    this.estimatedDuration,
    this.actualDuration,
    required this.createdAt,
    required this.updatedAt,
    required this.cost,
    required this.order,
  });

  factory RepairItem.fromJson(Map<String, dynamic> json) {
    return RepairItem(
      id: json['id'],
      appointmentId: json['appointment'],
      description: json['description'] ?? '',
      isCompleted: json['is_completed'] ?? false,
      completedBy: json['completed_by'],
      status: json['status'] ?? 'pending',
      estimatedDuration: json['estimated_duration'] != null
          ? _parseDuration(json['estimated_duration'])
          : null,
      actualDuration: json['actual_duration'] != null
          ? _parseDuration(json['actual_duration'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      cost: json['cost'] != null ? double.parse(json['cost'].toString()) : 0.0,
      order: json['order'] ?? 0,
    );
  }

  // Funkcja pomocnicza do parsowania ciągu znaków na Duration
  static Duration _parseDuration(String durationStr) {
    try {
      if (durationStr.contains(':')) {
        // Format "HH:MM:SS" lub "HH:MM"
        final parts = durationStr.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          return Duration(hours: hours, minutes: minutes, seconds: seconds);
        } else if (parts.length == 2) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          return Duration(hours: hours, minutes: minutes);
        } else {
          throw FormatException('Nieprawidłowy format czasu');
        }
      } else {
        // Format dziesiętny "34.800000" (godziny)
        double decimalHours = double.parse(durationStr);
        int hours = decimalHours.floor();
        int minutes = ((decimalHours - hours) * 60).round();
        return Duration(hours: hours, minutes: minutes);
      }
    } catch (e) {
      // Obsłuż błąd parsowania, np. zwróć Duration.zero lub inny domyślny
      print('Błąd parsowania Duration: $e');
      return Duration.zero;
    }
  }

  // Funkcja do formatowania Duration na string w formacie dziesiętnym "HH.HHHHHH"
  static String? _formatDuration(Duration? duration) {
    if (duration == null) return null;
    double decimalHours =
        duration.inMinutes / 60 + (duration.inSeconds.remainder(60) / 3600);
    return decimalHours.toStringAsFixed(6);
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'status': status,
      'order': order,
      'cost': cost.toString(),
      'estimated_duration':
          estimatedDuration != null ? _formatDuration(estimatedDuration) : null,
      'actual_duration':
          actualDuration != null ? _formatDuration(actualDuration) : null,
    };
  }
}