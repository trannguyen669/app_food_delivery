import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  // Map để lưu cart items, key = unique ID (foodId + size)
  final Map<String, CartItem> _items = {};

  // Getter để truy cập items
  Map<String, CartItem> get items => {..._items};

  // Danh sách các items trong giỏ hàng
  List<CartItem> get cartItems => _items.values.toList();

  // Số lượng items trong giỏ hàng
  int get itemCount => _items.length;

  // Tổng số sản phẩm (bao gồm quantity của từng item)
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, item) {
      total += item.quantity;
    });
    return total;
  }

  // Tổng giá tiền trong giỏ hàng
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  // Thêm item vào giỏ hàng
  void addItem({
    required String foodId,
    required String name,
    required String restaurantName,
    required double price,
    required String imageUrl,
    required String size,
    int quantity = 1,
  }) {
    // Tạo unique key từ foodId + size
    final cartKey = '${foodId}_$size';

    if (_items.containsKey(cartKey)) {
      // Nếu đã có item này (cùng foodId và size), tăng quantity
      _items.update(
        cartKey,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
        ),
      );
    } else {
      // Nếu chưa có, thêm mới
      _items.putIfAbsent(
        cartKey,
        () => CartItem(
          id: cartKey,
          foodId: foodId,
          name: name,
          restaurantName: restaurantName,
          price: price,
          imageUrl: imageUrl,
          size: size,
          quantity: quantity,
        ),
      );
    }

    notifyListeners(); // Thông báo UI cập nhật
  }

  // Xóa item khỏi giỏ hàng
  void removeItem(String cartKey) {
    _items.remove(cartKey);
    notifyListeners();
  }

  // Giảm quantity của item (dùng khi nhấn nút trừ trong cart)
  void decreaseQuantity(String cartKey) {
    if (!_items.containsKey(cartKey)) return;

    // Chỉ giảm nếu quantity > 1, không xóa item
    if (_items[cartKey]!.quantity > 1) {
      _items.update(
        cartKey,
        (existingItem) => existingItem.copyWith(
          quantity: existingItem.quantity - 1,
        ),
      );
      notifyListeners();
    }
    // Nếu quantity = 1, không làm gì (phải dùng nút xóa)
  }

  // Tăng quantity của item (dùng khi nhấn nút cộng trong cart)
  void increaseQuantity(String cartKey) {
    if (!_items.containsKey(cartKey)) return;

    _items.update(
      cartKey,
      (existingItem) => existingItem.copyWith(
        quantity: existingItem.quantity + 1,
      ),
    );

    notifyListeners();
  }

  // Cập nhật quantity trực tiếp
  void updateQuantity(String cartKey, int newQuantity) {
    if (!_items.containsKey(cartKey)) return;

    if (newQuantity <= 0) {
      _items.remove(cartKey);
    } else {
      _items.update(
        cartKey,
        (existingItem) => existingItem.copyWith(quantity: newQuantity),
      );
    }

    notifyListeners();
  }

  // Xóa toàn bộ giỏ hàng
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Kiểm tra xem item đã có trong giỏ hàng chưa
  bool isInCart(String foodId, String size) {
    final cartKey = '${foodId}_$size';
    return _items.containsKey(cartKey);
  }

  // Lấy quantity của item trong giỏ hàng
  int getItemQuantity(String foodId, String size) {
    final cartKey = '${foodId}_$size';
    if (_items.containsKey(cartKey)) {
      return _items[cartKey]!.quantity;
    }
    return 0;
  }
}
