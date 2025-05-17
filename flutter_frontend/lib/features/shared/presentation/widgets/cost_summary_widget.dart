import 'package:flutter/material.dart';

class CostSummaryWidget extends StatelessWidget {
  final double totalPartsCost;
  final double totalServiceCost;
  final double totalMargin;

  const CostSummaryWidget({
    super.key,
    required this.totalPartsCost,
    required this.totalServiceCost,
    required this.totalMargin,
  });

  @override
  Widget build(BuildContext context) {
    final totalCost = totalPartsCost + totalServiceCost;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Podsumowanie kosztów',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildCostRow('Suma cen części:', totalPartsCost, false),
            _buildCostRow('Marża:', totalMargin, false),
            _buildCostRow('Suma cen usług:', totalServiceCost, false),
            const Divider(thickness: 1.0),
            _buildCostRow('Łączna cena:', totalCost, true),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double value, bool isTotal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16.0 : 14.0,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: isTotal
                ? BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: Colors.green.shade200),
                  )
                : null,
            child: Text(
              '${value.toStringAsFixed(2)} PLN',
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16.0 : 14.0,
                color: isTotal ? Colors.green.shade800 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
