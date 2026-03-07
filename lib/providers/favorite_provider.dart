import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/favorite_item.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<String> _favoriteFoodIds = [];

  List<String> get favoriteFoodIds => _favoriteFoodIds;

  FavoriteProvider() {
    _loadFavorites();
  }

  // Load favorites từ Firestore
  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: user.uid)
          .get();

      _favoriteFoodIds = snapshot.docs.map((doc) => doc.data()['foodId'] as String).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Kiểm tra món có trong favorites không
  bool isFavorite(String foodId) {
    return _favoriteFoodIds.contains(foodId);
  }

  // Toggle favorite
  Future<void> toggleFavorite({
    required String foodId,
    required String name,
    required String restaurantName,
    required double price,
    required String imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (isFavorite(foodId)) {
        // Remove từ favorites
        final snapshot = await _firestore
            .collection('favorites')
            .where('userId', isEqualTo: user.uid)
            .where('foodId', isEqualTo: foodId)
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }

        _favoriteFoodIds.remove(foodId);
      } else {
        // Thêm vào favorites
        final favorite = FavoriteItem(
          id: '',
          userId: user.uid,
          foodId: foodId,
          name: name,
          restaurantName: restaurantName,
          price: price,
          imageUrl: imageUrl,
          addedAt: DateTime.now(),
        );

        await _firestore.collection('favorites').add(favorite.toMap());
        _favoriteFoodIds.add(foodId);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  // Stream để lắng nghe thay đổi
  Stream<List<FavoriteItem>> getFavoritesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('favorites')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FavoriteItem.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  // Xóa favorite
  Future<void> removeFavorite(String favoriteId, String foodId) async {
    try {
      await _firestore.collection('favorites').doc(favoriteId).delete();
      _favoriteFoodIds.remove(foodId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing favorite: $e');
    }
  }
}
