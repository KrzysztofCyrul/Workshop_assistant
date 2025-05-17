import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  final String labelText;
  final String hintText;
  final ValueChanged<String> onChanged;
  final String searchQuery;
  final VoidCallback? onClear;
  
  const SearchFieldWidget({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.onChanged,
    required this.searchQuery,
    this.onClear,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear ?? () => onChanged(''),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
