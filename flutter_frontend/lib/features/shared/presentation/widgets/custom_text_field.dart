import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? suffixText;
  final String? hintText;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final TextAlign textAlign;
  final VoidCallback? onEditingComplete;
  final Function(String)? onChanged;
  final Function(PointerDownEvent)? onTapOutside;
  
  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.suffixText,
    this.hintText,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.onEditingComplete,
    this.onChanged,
    this.onTapOutside,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      textAlign: textAlign,
      onEditingComplete: onEditingComplete,
      onChanged: onChanged,
      onTapOutside: onTapOutside,
    );
  }
}
