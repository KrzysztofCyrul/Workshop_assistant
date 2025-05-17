import 'package:flutter/material.dart';

/// A custom floating action button with a consistent style for adding items.
/// 
/// This widget creates either a standard round button with just an icon,
/// or an extended button with both icon and label, based on the [isExtended] property.
class AddActionButton extends StatelessWidget {
  /// The callback when button is pressed
  final VoidCallback onPressed;

  /// Text tooltip that appears when the user long-presses on the button
  final String tooltip;

  /// Icon to display in the button
  final IconData iconData;

  /// Optional label text to display next to the icon when [isExtended] is true
  final String? labelText;

  /// Whether to show an extended FAB with text label (true) or a standard circular FAB (false)
  final bool isExtended;

  /// Background color for the button (defaults to primary color)
  final Color? backgroundColor;

  /// Foreground/icon color for the button (defaults to white)
  final Color? foregroundColor;

  const AddActionButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.iconData = Icons.add,
    this.labelText,
    this.isExtended = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? Colors.blue.shade700;
    final fgColor = foregroundColor ?? Colors.white;

    // If extended mode is enabled and label is provided, show extended FAB
    if (isExtended && labelText != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(iconData, color: fgColor),
        label: Text(
          labelText!,
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: bgColor,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );
    }

    // Otherwise show standard circular FAB
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: 3,
      child: Icon(iconData),
    );
  }
}
