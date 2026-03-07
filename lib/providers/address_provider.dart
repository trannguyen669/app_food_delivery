import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/address.dart';

class AddressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference cho addresses của user hiện tại
  CollectionReference get _addressesCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User chưa đăng nhập');
    }
    return _firestore.collection('users').doc(userId).collection('addresses');
  }

  // Lấy Stream danh sách địa chỉ (real-time)
  Stream<List<Address>> getAddressesStream() {
    return _addressesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      // Lấy danh sách địa chỉ
      final addresses = snapshot.docs.map((doc) {
        return Address.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      
      // Sort trong code: địa chỉ mặc định lên đầu, sau đó sort theo thời gian
      addresses.sort((a, b) {
        // Địa chỉ mặc định lên đầu
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        // Nếu cả hai cùng là default hoặc không default, sort theo thời gian
        return b.createdAt.compareTo(a.createdAt);
      });
      
      return addresses;
    });
  }

  // Thêm địa chỉ mới
  Future<void> addAddress(Address address) async {
    try {
      // Nếu địa chỉ mới là mặc định, bỏ mặc định của các địa chỉ khác
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      await _addressesCollection.add(address.toMap());
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi thêm địa chỉ: $e');
    }
  }

  // Cập nhật địa chỉ
  Future<void> updateAddress(Address address) async {
    try {
      // Nếu địa chỉ này được đặt làm mặc định, bỏ mặc định của các địa chỉ khác
      if (address.isDefault) {
        await _clearDefaultAddresses();
      }

      await _addressesCollection.doc(address.id).update(address.toMap());
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật địa chỉ: $e');
    }
  }

  // Xóa địa chỉ
  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressesCollection.doc(addressId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi xóa địa chỉ: $e');
    }
  }

  // Đặt địa chỉ làm mặc định
  Future<void> setDefaultAddress(String addressId) async {
    try {
      // Bỏ mặc định của tất cả địa chỉ
      await _clearDefaultAddresses();

      // Đặt địa chỉ này làm mặc định
      await _addressesCollection.doc(addressId).update({'isDefault': true});
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi đặt địa chỉ mặc định: $e');
    }
  }

  // Lấy địa chỉ mặc định
  Future<Address?> getDefaultAddress() async {
    try {
      final snapshot = await _addressesCollection
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return Address.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  // Bỏ mặc định của tất cả địa chỉ
  Future<void> _clearDefaultAddresses() async {
    final snapshot =
        await _addressesCollection.where('isDefault', isEqualTo: true).get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }

  // Lấy địa chỉ theo ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      final doc = await _addressesCollection.doc(addressId).get();
      if (!doc.exists) {
        return null;
      }
      return Address.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}
