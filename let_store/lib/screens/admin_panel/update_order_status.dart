import 'dart:convert';
import 'package:http/http.dart' as http;
// import '../models/api_order.dart';
import 'api_order.dart'; // Import the new ApiOrder model

class OrderService {
  // Use the API domain for patching as specified in your prompt
  static const String _baseUrl = 'https://let-commerce.onrender.com/api/orders';

  /// Updates the status of a specific order.
  ///
  /// Throws an [Exception] if the API request fails.
  static Future<ApiOrder> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
    String bearerToken,
  ) async {
    final url = Uri.parse('$_baseUrl/$orderId/status');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $bearerToken', // Include the bearer token
    };
    final body = jsonEncode({'status': newStatus.toShortString()});

    try {
      final response = await http.patch(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        // Assuming the API returns the updated order object
        return ApiOrder.fromJson(jsonDecode(response.body));
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(
          'Failed to update order status: ${response.statusCode} - ${errorBody['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }
}
