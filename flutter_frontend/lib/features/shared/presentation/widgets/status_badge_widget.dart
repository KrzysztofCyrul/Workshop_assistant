import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  final String status;
  final IconData icon;
  final Color color;
  final String label;
  final double fontSize;
  final bool showIcon;
  
  const StatusBadgeWidget({
    super.key,
    required this.status,
    required this.icon,
    required this.color,
    required this.label,
    this.fontSize = 12,
    this.showIcon = true,
  });
  
  factory StatusBadgeWidget.fromStatus(String status) {
    IconData statusIcon;
    Color statusColor;
    String statusLabel;
    
    switch (status.toLowerCase()) {
      case 'completed':
        statusIcon = Icons.check_circle;
        statusColor = Colors.green;
        statusLabel = 'Zakończone';
      case 'pending':
        statusIcon = Icons.pending;
        statusColor = Colors.orange;
        statusLabel = 'Do wykonania';
      case 'in_progress':
        statusIcon = Icons.timelapse;
        statusColor = Colors.blue;
        statusLabel = 'W toku';
      case 'canceled':
        statusIcon = Icons.cancel;
        statusColor = Colors.red;
        statusLabel = 'Anulowane';
      default:
        statusIcon = Icons.info;
        statusColor = Colors.grey;
        statusLabel = status;
    }
    
    return StatusBadgeWidget(
      status: status,
      icon: statusIcon,
      color: statusColor,
      label: statusLabel,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
