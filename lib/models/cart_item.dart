class CartItem {
  final String id;
  final String foodId;
  final String name;
  final String restaurantName;
  final double price;
  final String imageUrl;
  final String size;
  int quantity;

  CartItem({
    required this.id,
    required this.foodId,
    required this.name,
    required this.restaurantName,
    required this.price,
    required this.imageUrl,
    required this.size,
    required this.quantity,
  });

  // Tính tổng giá cho item này
  double get totalPrice => price * quantity;

  // Copy with method để tạo instance mới với giá trị updated
  CartItem copyWith({
    String? id,
    String? foodId,
    String? name,
    String? restaurantName,
    double? price,
    String? imageUrl,
    String? size,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      restaurantName: restaurantName ?? this.restaurantName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      size: size ?? this.size,
      quantity: quantity ?? this.quantity,
    );
  }

  // Convert to Map (để lưu vào Firebase sau này)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodId': foodId,
      'name': name,
      'restaurantName': restaurantName,
      'price': price,
      'imageUrl': imageUrl,
      'size': size,
      'quantity': quantity,
    };
  }

  // Create from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] ?? '',
      foodId: map['foodId'] ?? '',
      name: map['name'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      size: map['size'] ?? 'M',
      quantity: map['quantity'] ?? 1,
    );
  }
}
