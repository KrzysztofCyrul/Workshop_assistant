import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PartsSuggestionField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final Function(String) onChanged;
  
  const PartsSuggestionField({
    Key? key,
    required this.controller,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<PartsSuggestionField> createState() => _PartsSuggestionFieldState();
}

class _PartsSuggestionFieldState extends State<PartsSuggestionField> {
  List<String> partsSuggestions = [];
  bool isSuggestionsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadPartsSuggestions();
  }

  Future<void> _loadPartsSuggestions() async {
    if (!isSuggestionsLoaded) {
      try {
        final String response = await rootBundle.loadString('assets/parts.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          partsSuggestions = List<String>.from(data);
          isSuggestionsLoaded = true;
        });
      } catch (e) {
        debugPrint('Error loading parts suggestions: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return partsSuggestions.where((String part) {
          return part.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        widget.controller.text = selection;
        widget.onChanged(selection);
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        widget.controller.addListener(() {
          if (widget.controller.text != textEditingController.text) {
            textEditingController.text = widget.controller.text;
          }
        });

        return TextField(
          controller: widget.controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          ),
          onChanged: widget.onChanged,
        );
      },
    );
  }
}
