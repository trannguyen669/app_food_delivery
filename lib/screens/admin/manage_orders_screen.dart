import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({Key? key}) : super(key: key);

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> {
  String _selectedStatus = 'all';

  final Map<String, String> _statusLabels = {
    'all': 'Tất cả',
    'pending': 'Chờ xác nhận',
    'confirmed': 'Đã xác nhận',
    'preparing': 'Đang chuẩn bị',
    'delivering': 'Đang giao',
    'completed': 'Hoàn thành',
    'cancelled': 'Đã hủy',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.blue,
    'preparing': Colors.purple,
    'delivering': Colors.indigo,
    'completed': Colors.green,
    'cancelled': Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Modern Header with Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade600,
                  Colors.deepOrange.shade500,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.shade200,
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quản lý đơn hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Status Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _statusLabels.entries.map((entry) {
                          final isSelected = _selectedStatus == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                entry.value,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey.shade700,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() => _selectedStatus = entry.key);
                              },
                              backgroundColor: Colors.white.withOpacity(0.2),
                              selectedColor: entry.key == 'all' ? Colors.white.withOpacity(0.3) : _statusColors[entry.key],
                              checkmarkColor: Colors.white,
                              elevation: isSelected ? 4 : 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Orders list
          Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedStatus == 'all'
                ? FirebaseFirestore.instance
                    .collection('orders')
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('orders')
                    .where('status', isEqualTo: _selectedStatus)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var orders = snapshot.data!.docs;

              // Sắp xếp theo createdAt ở client side khi filter theo status
              if (_selectedStatus != 'all') {
                orders.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final timeA = (dataA['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                  final timeB = (dataB['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
                  return timeB.compareTo(timeA); // Descending order
                });
              }

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.orange.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Chưa có đơn hàng nào',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedStatus == 'all' 
                            ? 'Chưa có đơn hàng trong hệ thống'
                            : 'Không có đơn hàng với trạng thái này',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final doc = orders[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  return _buildOrderCard(doc.id, data);
                },
              );
            },
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(String orderId, Map<String, dynamic> data) {
    final status = data['status'] ?? 'pending';
    final total = data['totalAmount'] ?? 0;
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final items = data['items'] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: (_statusColors[status] ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.receipt_long,
              color: _statusColors[status] ?? Colors.grey,
              size: 24,
            ),
          ),
          title: Text(
            'Đơn #${orderId.substring(0, 8)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '${NumberFormat('#,###').format(total)}đ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (_statusColors[status] ?? Colors.grey).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _statusColors[status] ?? Colors.grey,
                width: 1.5,
              ),
            ),
            child: Text(
              _statusLabels[status] ?? status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _statusColors[status] ?? Colors.grey,
              ),
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer info
                  if (data['deliveryAddress'] != null || data['phoneNumber'] != null) ...[
                    Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Thông tin khách hàng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (data['phoneNumber'] != null)
                      _buildInfoRow(Icons.phone, 'SĐT:', data['phoneNumber']),
                    if (data['deliveryAddress'] != null)
                      _buildInfoRow(Icons.location_on, 'Địa chỉ:', data['deliveryAddress']),
                    if (data['note'] != null && data['note'].toString().isNotEmpty)
                      _buildInfoRow(Icons.note, 'Ghi chú:', data['note']),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                  ],

                  // Order items
                  Row(
                    children: [
                      Icon(Icons.shopping_bag, size: 18, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Chi tiết đơn hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  '${item['quantity']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${NumberFormat('#,###').format(item['price'])}đ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${NumberFormat('#,###').format(item['price'] * item['quantity'])}đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      )),
                  
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade300),
                  const SizedBox(height: 16),

                  // Status actions
                  Row(
                    children: [
                      Icon(Icons.update, size: 18, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Cập nhật trạng thái',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusLabels.entries
                        .where((e) => e.key != 'all')
                        .map((entry) => ElevatedButton(
                              onPressed: status == entry.key
                                  ? null
                                  : () => _updateOrderStatus(orderId, entry.key),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: status == entry.key
                                    ? Colors.grey.shade300
                                    : (_statusColors[entry.key] ?? Colors.grey).withOpacity(0.1),
                                foregroundColor: _statusColors[entry.key],
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: _statusColors[entry.key] ?? Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              child: Text(
                                entry.value,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // Lấy thông tin đơn hàng trước để có userId
      final orderDoc = await FirebaseFirestore.instance.collection('orders').doc(orderId).get();
      final userId = orderDoc.data()?['userId'] as String?;

      // Cập nhật trạng thái đơn hàng
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Tạo thông báo cho người dùng
      if (userId != null && mounted) {
        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        await notificationProvider.createOrderStatusNotification(
          userId: userId,
          orderId: orderId,
          orderStatus: newStatus,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật: ${_statusLabels[newStatus]}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
