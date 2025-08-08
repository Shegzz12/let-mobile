import 'package:flutter/material.dart';
import '../../model/order.dart';
// Import your modified Order model (for OrderItem and OrderStatus)
// Note: We are not using AppTextStyle or GetUtils.capitalize! here,
// as this widget focuses on the product item, not the overall order status chip.

class OrderProductItemCard extends StatelessWidget {
  final OrderItem item; // Now takes a single OrderItem
  final String productImageUrl; // Image URL for this specific product
  final Function(String productId)? onViewDetails;

  const OrderProductItemCard({
    super.key,
    required this.item,
    required this.productImageUrl,
    this.onViewDetails, // Made optional as it might not always be needed
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onViewDetails == null
          ? null
          : () => onViewDetails!(item.productId),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the top
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(8.0),
            //   child: Image.asset(
            //     productImageUrl, // Use the provided product image URL
            //     width: 60,
            //     height: 60,
            //     fit: BoxFit.cover,
            //     errorBuilder: (context, error, stackTrace) => Container(
            //       width: 60,
            //       height: 60,
            //       color: Colors.grey[200],
            //       child: const Icon(
            //         Icons.image_not_supported,
            //         size: 30,
            //         color: Colors.grey,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    'Quantity: ${item.quantity}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // You can add price per item here if available in OrderItem
                  // Text('Price: ₦${item.price}', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
