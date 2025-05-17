import 'package:flutter/material.dart';

class ActionButtonWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final String? tooltip;
  final bool isOutlined;
  
  const ActionButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.blue,
    this.textColor,
    this.tooltip,
    this.isOutlined = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonWidget = isOutlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: backgroundColor),
              foregroundColor: backgroundColor,
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 16),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor ?? Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
    
    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: buttonWidget,
      );
    }
    
    return buttonWidget;
  }
}
