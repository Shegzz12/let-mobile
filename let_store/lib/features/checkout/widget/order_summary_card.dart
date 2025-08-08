import 'package:flutter/material.dart';

import '../../../utils/app_textstyles.dart';

class OrderSummaryCard extends StatelessWidget {
  final double total;
  const OrderSummaryCard({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    // final double subtotal = double.parse(total);
    final tax = calculateTax(total);
    final shipping = calculateShipping();
    final overallTotal = calculateTotal(total);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, 'Subtotal', '\$$total'),
          SizedBox(height: 8),
          _buildSummaryRow(context, 'Shipping', '\$$shipping'),
          SizedBox(height: 8),
          _buildSummaryRow(context, 'Tax (0.1%)', '\$$tax'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          _buildSummaryRow(context, 'Total', '\$$overallTotal', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final textStyle = isTotal ? AppTextStyle.h3 : AppTextStyle.bodyLarge;
    final textStylevalue = AppTextStyle.withWeight(
      AppTextStyle.h3,
      FontWeight.w600,
    );
    final color = isTotal
        ? Theme.of(context).primaryColor
        : Theme.of(context).textTheme.bodyLarge!.color!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyle.withColor(textStyle, color)),
        Text(value, style: AppTextStyle.withColor(textStylevalue, color)),
      ],
    );
  }
}

double calculateTax(double subtotal) => subtotal * 0.001;

double calculateShipping() => 20.00;

double calculateTotal(double subtotal) {
  final tax = calculateTax(subtotal);
  final shipping = calculateShipping();
  return subtotal + tax + shipping;
}
