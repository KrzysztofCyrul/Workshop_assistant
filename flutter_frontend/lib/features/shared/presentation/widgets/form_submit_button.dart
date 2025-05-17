import 'package:flutter/material.dart';

class FormSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSubmitting;
  final Color? backgroundColor;
  final double? width;
  
  const FormSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isSubmitting = false,
    this.backgroundColor,
    this.width,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: backgroundColor != null 
            ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
            : null,
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
