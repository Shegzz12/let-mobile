import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  final double total;

  CartItem({
    required this.product,
    required this.quantity,
    required this.total,
  });

  factory CartItem.fromJson(Map<String, dynamic> json, String bearerToken) {
    return CartItem(
      product: Product.fromJson(json['product'], bearerToken),
      quantity: json['quantity'],
      total: json['total'].toDouble(),
    );
  }

  CartItem copyWith({Product? product, int? quantity, double? total}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      total: total ?? this.total,
    );
  }
}
