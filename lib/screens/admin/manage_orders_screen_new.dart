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
  String _selectedFilter = 'all';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'preparing':
        return Colors.purple;
      case 'delivering':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'delivering':
        return 'Đang giao';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm đơn hàng...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      style: IconButton.styleFrom(
                        backgroundColor: _dateRange != null
                            ? Colors.orange.shade700
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
                if (_dateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(
                            '${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => setState(() => _dateRange = null),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Status filter chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'Tất cả', Icons.list_alt),
                _buildFilterChip('pending', 'Chờ xác nhận', Icons.pending),
                _buildFilterChip('confirmed', 'Đã xác nhận', Icons.check_circle),
                _buildFilterChip('preparing', 'Đang chuẩn bị', Icons.restaurant),
                _buildFilterChip('delivering', 'Đang giao', Icons.delivery_dining),
                _buildFilterChip('completed', 'Hoàn thành', Icons.done_all),
                _buildFilterChip('cancelled', 'Đã hủy', Icons.cancel),
              ],
            ),
          ),

          const Divider(height: 1),

          // Statistics summary
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final allOrders = snapshot.data!.docs;
              final pendingCount = allOrders
                  .where((o) => (o.data() as Map)['status'] == 'pending')
                  .length;
              final totalRevenue = allOrders
                  .where((o) => (o.data() as Map)['status'] == 'completed')
                  .fold<num>(
                      0, (sum, o) => sum + ((o.data() as Map)['totalAmount'] ?? 0));

              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.orange.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Tổng đơn',
                      allOrders.length.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Chờ xử lý',
                      pendingCount.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Doanh thu',
                      NumberFormat.compact(locale: 'vi').format(totalRevenue) + 'đ',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Orders list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var orders = snapshot.data!.docs;

                // Filter by status
                if (_selectedFilter != 'all') {
                  orders = orders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['status'] == _selectedFilter;
                  }).toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  orders = orders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final userName = (data['userName'] ?? '').toString().toLowerCase();
                    final userEmail = (data['userEmail'] ?? '').toString().toLowerCase();
                    final orderId = doc.id.toLowerCase();
                    return userName.contains(_searchQuery) ||
                        userEmail.contains(_searchQuery) ||
                        orderId.contains(_searchQuery);
                  }).toList();
                }

                // Filter by date range
                if (_dateRange != null) {
                  orders = orders.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final timestamp = data['createdAt'] as Timestamp?;
                    if (timestamp == null) return false;
                    final date = timestamp.toDate();
                    return date.isAfter(_dateRange!.start.subtract(const Duration(days: 1))) &&
                        date.isBefore(_dateRange!.end.add(const Duration(days: 1)));
                  }).toList();
                }

                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Không có đơn hàng nào'),
                  );
                }

                return ListView.builder(
                  itemCount: orders.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = orders[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        childrenPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getStatusColor(data['status'] ?? '').withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt,
                            color: _getStatusColor(data['status'] ?? ''),
                          ),
                        ),
                        title: Text(
                          'Đơn #${doc.id.substring(0, 8)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    data['userName'] ?? 'Chưa có tên',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  data['createdAt'] != null
                                      ? DateFormat('dd/MM/yyyy HH:mm')
                                          .format((data['createdAt'] as Timestamp).toDate())
                                      : 'N/A',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(data['status'] ?? ''),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getStatusText(data['status'] ?? ''),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              NumberFormat.currency(locale: 'vi', symbol: 'đ')
                                  .format(data['totalAmount'] ?? 0),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        children: [
                          // Order details
                          _buildOrderDetails(doc.id, data),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String status, String label, IconData icon) {
    final isSelected = _selectedFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _selectedFilter = status);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.orange.shade100,
        checkmarkColor: Colors.orange.shade700,
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(String orderId, Map<String, dynamic> data) {
    final items = (data['items'] as List?) ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        
        // Customer info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 8),
                  const Text('Thông tin khách hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Tên: ${data['userName'] ?? 'N/A'}'),
              Text('Email: ${data['userEmail'] ?? 'N/A'}'),
              if (data['userPhone'] != null)
                Text('SĐT: ${data['userPhone']}'),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Delivery address
        if (data['deliveryAddress'] != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(data['deliveryAddress']),
              ],
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Order items
        const Text('Món đã đặt:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text('${item['name']} x${item['quantity']}'),
                ),
                Text(
                  NumberFormat.currency(locale: 'vi', symbol: 'đ')
                      .format(item['price'] * item['quantity']),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }),
        
        const Divider(),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tổng cộng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(
              NumberFormat.currency(locale: 'vi', symbol: 'đ')
                  .format(data['totalAmount'] ?? 0),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (data['status'] == 'pending')
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(orderId, 'confirmed'),
                icon: const Icon(Icons.check_circle),
                label: const Text('Xác nhận'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            if (data['status'] == 'confirmed')
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(orderId, 'preparing'),
                icon: const Icon(Icons.restaurant),
                label: const Text('Chuẩn bị'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            if (data['status'] == 'preparing')
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(orderId, 'delivering'),
                icon: const Icon(Icons.delivery_dining),
                label: const Text('Giao hàng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            if (data['status'] == 'delivering')
              ElevatedButton.icon(
                onPressed: () => _updateOrderStatus(orderId, 'completed'),
                icon: const Icon(Icons.done_all),
                label: const Text('Hoàn thành'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            if (data['status'] != 'completed' && data['status'] != 'cancelled')
              OutlinedButton.icon(
                onPressed: () => _updateOrderStatus(orderId, 'cancelled'),
                icon: const Icon(Icons.cancel),
                label: const Text('Hủy đơn'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
          ],
        ),
      ],
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
            content: Text('Đã cập nhật trạng thái: ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.orange.shade700,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }
}
