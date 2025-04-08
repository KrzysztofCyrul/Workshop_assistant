import 'package:flutter/material.dart';

class VehicleSearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const VehicleSearchField({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Wyszukaj pojazd',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: onChanged,
    );
  }
}