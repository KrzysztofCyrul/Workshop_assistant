import 'package:flutter/material.dart';

class PartFormWidget extends StatefulWidget {
  final TextEditingController partNameController;
  final TextEditingController quantityController;
  final TextEditingController partCostController;
  final TextEditingController serviceCostController;
  final TextEditingController buyCostPartController;
  final List<String> partsSuggestions;
  final VoidCallback onAddPart;
  final String addButtonLabel;

  const PartFormWidget({
    super.key,
    required this.partNameController,
    required this.quantityController,
    required this.partCostController,
    required this.serviceCostController,
    required this.buyCostPartController,
    required this.partsSuggestions,
    required this.onAddPart,
    this.addButtonLabel = 'Dodaj część',
  });

  @override
  State<PartFormWidget> createState() => _PartFormWidgetState();
}

class _PartFormWidgetState extends State<PartFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return widget.partsSuggestions.where((String part) {
                        return part.toLowerCase().contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      widget.partNameController.text = selection;
                    },
                    fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                      // Synchronize controllers
                      widget.partNameController.addListener(() {
                        if (widget.partNameController.text != textEditingController.text) {
                          textEditingController.text = widget.partNameController.text;
                        }
                      });

                      return TextField(
                        controller: widget.partNameController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Nazwa części',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        onChanged: (value) {
                          widget.partNameController.text = value;
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: widget.quantityController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      labelText: 'Ilość',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: widget.buyCostPartController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'Cena Hurtowa',
                      prefixIcon: const Icon(Icons.money_off),
                      suffixText: 'PLN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: widget.partCostController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'Cena detaliczna',
                      prefixIcon: const Icon(Icons.shopping_cart),
                      suffixText: 'PLN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: widget.serviceCostController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.right,
                    decoration: InputDecoration(
                      labelText: 'Koszt usługi',
                      prefixIcon: const Icon(Icons.build),
                      suffixText: 'PLN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(widget.addButtonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: widget.onAddPart,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
