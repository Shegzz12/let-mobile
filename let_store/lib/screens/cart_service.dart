// lib/services/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {
  static const String _baseUrl =
      'https://let-commerce.onrender.com/api/cart/add'; // Your cart add API endpoint

  static Future<bool> addToCart(
    String productId,
    int quantity,
    String bearerToken,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Product $productId added to cart successfully.');
        return true;
      } else {
        print(
          '❌ Failed to add product $productId to cart. Status: ${response.statusCode}, Body: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('⚠️ Error adding product $productId to cart: $e');
      return false;
    }
  }
}
