class FavoriteItem {
  final String id;
  final String userId;
  final String foodId;
  final String name;
  final String restaurantName;
  final double price;
  final String imageUrl;
  final DateTime addedAt;

  FavoriteItem({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.name,
    required this.restaurantName,
    required this.price,
    required this.imageUrl,
    required this.addedAt,
  });

  // Convert to Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodId': foodId,
      'name': name,
      'restaurantName': restaurantName,
      'price': price,
      'imageUrl': imageUrl,
      'addedAt': addedAt.millisecondsSinceEpoch,
    };
  }

  // Convert từ Map trong Firestore
  factory FavoriteItem.fromMap(String id, Map<String, dynamic> map) {
    return FavoriteItem(
      id: id,
      userId: map['userId'] ?? '',
      foodId: map['foodId'] ?? '',
      name: map['name'] ?? '',
      restaurantName: map['restaurantName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      addedAt: DateTime.fromMillisecondsSinceEpoch(map['addedAt'] ?? 0),
    );
  }
}
