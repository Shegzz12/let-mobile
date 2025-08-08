import 'package:flutter/material.dart';
import '../../../utils/app_textstyles.dart';

class AddressCard extends StatelessWidget {
  final Map<String, dynamic> shippingDetails;

  const AddressCard({super.key, required this.shippingDetails});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final street = shippingDetails['street'] ?? '';
    final city = shippingDetails['city'] ?? '';
    final state = shippingDetails['state'] ?? '';
    final country = shippingDetails['country'] ?? '';
    final zipCode = shippingDetails['zip_code'] ?? '';

    final address = '$street\n$city, $state\n$country - $zipCode';

    return Container(
      padding: EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Home',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyLarge,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      address,
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodySmall,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
