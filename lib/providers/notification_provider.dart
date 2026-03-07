import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Lấy Stream danh sách thông báo của user hiện tại
  Stream<List<NotificationModel>> getNotificationsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs.map((doc) {
            try {
              return NotificationModel.fromMap(doc.id, doc.data());
            } catch (e) {
              print('Lỗi parse notification ${doc.id}: $e');
              return null;
            }
          }).whereType<NotificationModel>().toList();

          // Sắp xếp theo thời gian tạo (mới nhất lên đầu) ở client side
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          // Cập nhật số lượng thông báo chưa đọc (không gọi notifyListeners trong stream!)
          _unreadCount = notifications.where((n) => !n.isRead).length;

          return notifications;
        });
  }

  // Tạo thông báo mới khi admin cập nhật trạng thái đơn hàng
  Future<void> createOrderStatusNotification({
    required String userId,
    required String orderId,
    required String orderStatus,
  }) async {
    try {
      String title = '';
      String message = '';

      switch (orderStatus.toLowerCase()) {
        case 'pending':
          title = '🕐 Đơn hàng đang chờ xác nhận';
          message = 'Đơn hàng #$orderId đang chờ xác nhận từ nhà hàng';
          break;
        case 'confirmed':
          title = '✅ Đơn hàng đã được xác nhận';
          message = 'Đơn hàng #$orderId đã được xác nhận và đang chuẩn bị';
          break;
        case 'preparing':
          title = '👨‍🍳 Đang chuẩn bị món ăn';
          message = 'Nhà hàng đang chuẩn bị đơn hàng #$orderId của bạn';
          break;
        case 'shipping':
          title = '🚚 Đang giao hàng';
          message = 'Đơn hàng #$orderId đang trên đường giao đến bạn';
          break;
        case 'delivered':
          title = '🎉 Giao hàng thành công';
          message = 'Đơn hàng #$orderId đã được giao thành công. Cảm ơn bạn!';
          break;
        case 'cancelled':
          title = '❌ Đơn hàng đã bị hủy';
          message =
              'Đơn hàng #$orderId đã bị hủy. Vui lòng liên hệ để biết thêm chi tiết';
          break;
        default:
          title = '📦 Cập nhật đơn hàng';
          message = 'Đơn hàng #$orderId có cập nhật mới: $orderStatus';
      }

      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: title,
        message: message,
        orderId: orderId,
        orderStatus: orderStatus,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('notifications').add(notification.toMap());
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi tạo thông báo: $e');
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông báo: $e');
    }
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông báo: $e');
    }
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi xóa thông báo: $e');
    }
  }

  // Xóa tất cả thông báo đã đọc
  Future<void> deleteAllRead() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      notifyListeners();
    } catch (e) {
      throw Exception('Lỗi khi xóa thông báo: $e');
    }
  }
}
