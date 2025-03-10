import 'package:flutter/material.dart';

class StatusHelpers {
  static String getStatusLabel(String status) {
    switch (status) {
      case 'pending': return 'Do wykonania';
      case 'in_progress': return 'W trakcie';
      case 'completed': return 'Zakończone';
      case 'canceled': return 'Anulowane';
      default: return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'in_progress': return Colors.blue;
      case 'completed': return Colors.green;
      case 'canceled': return Colors.red;
      default: return Colors.grey;
    }
  }
}