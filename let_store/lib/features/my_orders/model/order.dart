// import 'dart:convert'; // Keep this import if you use json.decode/encode elsewhere

// Merged OrderStatus enum with all statuses (from your original and previous response)
enum OrderStatus { pending, active, shipped, delivered, cancelled }

// Extension to convert enum to string and vice versa
extension OrderStatusExtension on OrderStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'active':
        return OrderStatus.active;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      default:
        // Default to cancelled if status is null or unknown
        return OrderStatus.cancelled;
    }
  }
}

// OrderItem: Your existing OrderItem, now with toJson for consistency
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
    };
  }
}

// NEW: User model, as it's part of the backend order structure
class User {
  final String email;
  final String id;

  User({required this.email, required this.id});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json['email'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'email': email, 'id': id};
  }
}

// MODIFIED Order class: Now represents a single grouped order from the backend
class Order {
  final String createdAt;
  final String
  id; // This is the unique order ID from the backend (your orderNumber)
  final List<OrderItem> items; // Now directly holds the list of items
  OrderStatus status; // Made mutable for local UI updates
  final int totalAmount;
  final User user; // Added user details
  final String orderImageUrl; // General image for the order, if any

  Order({
    required this.createdAt,
    required this.id,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.user,
    this.orderImageUrl = 'assets/images/segun.jpg', // Default placeholder
  });

  // Factory constructor to parse a single grouped order JSON into an Order object
  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? []; // Handle null items list
    List<OrderItem> items = itemsList
        .map((i) => OrderItem.fromJson(i))
        .toList();

    return Order(
      createdAt: json['created_at'] ?? '',
      id: json['id'] ?? '', // Corresponds to your 'orderNumber'
      items: items,
      status: OrderStatusExtension.fromString(json['status']),
      totalAmount:
          (json['total_amount'] as num?)?.toInt() ??
          0, // Handle null and convert to int
      user: User.fromJson(json['user'] ?? {}), // Handle null user
      orderImageUrl: 'assets/images/segun.jpg', // Your existing placeholder
    );
  }

  // Removed fromJsonList as Order now represents a single grouped order
  // Removed productId, itemCount, productName as they are now within items
  // Removed statusString getter as status.toShortString() is used directly
}
