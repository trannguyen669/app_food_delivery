import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({Key? key}) : super(key: key);

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _roleFilter = 'all'; // all, admin, user

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm người dùng...',
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

          // Role filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('all', 'Tất cả', Icons.people),
                _buildFilterChip('admin', 'Quản trị viên', Icons.admin_panel_settings),
                _buildFilterChip('user', 'Người dùng', Icons.person),
              ],
            ),
          ),

          const Divider(height: 1),

          // Statistics
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('users').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final allUsers = snapshot.data!.docs;
              final adminCount =
                  allUsers.where((u) => (u.data() as Map)['role'] == 'admin').length;
              final userCount = allUsers.length - adminCount;

              return Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Tổng số', allUsers.length.toString(),
                        Icons.people, Colors.blue),
                    _buildStatCard('Quản trị viên', adminCount.toString(),
                        Icons.admin_panel_settings, Colors.orange),
                    _buildStatCard(
                        'Người dùng', userCount.toString(), Icons.person, Colors.green),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Users list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var users = snapshot.data!.docs;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  users = users.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    final phone = (data['phone'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) ||
                        email.contains(_searchQuery) ||
                        phone.contains(_searchQuery);
                  }).toList();
                }

                // Filter by role
                if (_roleFilter != 'all') {
                  users = users.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['role'] == _roleFilter;
                  }).toList();
                }

                if (users.isEmpty) {
                  return const Center(child: Text('Không có người dùng nào'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isAdmin = data['role'] == 'admin';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: isAdmin
                              ? Colors.orange.shade100
                              : Colors.blue.shade100,
                          radius: 30,
                          child: Icon(
                            isAdmin ? Icons.admin_panel_settings : Icons.person,
                            color: isAdmin ? Colors.orange.shade700 : Colors.blue.shade700,
                            size: 30,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['name'] ?? 'Chưa có tên',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? Colors.orange.shade700
                                    : Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isAdmin ? 'Admin' : 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.email, size: 14, color: Colors.grey.shade600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    data['email'] ?? 'Chưa có email',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (data['phone'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    data['phone'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (data['createdAt'] != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 14, color: Colors.grey.shade600),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Tham gia: ${DateFormat('dd/MM/yyyy').format((data['createdAt'] as Timestamp).toDate())}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'promote') {
                              _changeUserRole(doc.id, 'admin');
                            } else if (value == 'demote') {
                              _changeUserRole(doc.id, 'user');
                            } else if (value == 'delete') {
                              _deleteUser(doc.id, data['name']);
                            } else if (value == 'view_orders') {
                              _viewUserOrders(doc.id, data['name']);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isAdmin)
                              const PopupMenuItem(
                                value: 'promote',
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_upward, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Đặt làm Admin'),
                                  ],
                                ),
                              ),
                            if (isAdmin)
                              const PopupMenuItem(
                                value: 'demote',
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Bỏ quyền Admin'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'view_orders',
                              child: Row(
                                children: [
                                  Icon(Icons.receipt_long, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Xem đơn hàng'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Xóa người dùng'),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildFilterChip(String role, String label, IconData icon) {
    final isSelected = _roleFilter == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
        ),
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _roleFilter = role);
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
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

  Future<void> _changeUserRole(String userId, String newRole) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          newRole == 'admin'
              ? 'Bạn có chắc muốn đặt người dùng này làm Admin?'
              : 'Bạn có chắc muốn bỏ quyền Admin của người dùng này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newRole == 'admin' ? Colors.orange : Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'role': newRole,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                newRole == 'admin'
                    ? 'Đã đặt làm Admin thành công'
                    : 'Đã bỏ quyền Admin thành công',
              ),
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
  }

  Future<void> _deleteUser(String userId, String? name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa người dùng "${name ?? 'này'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa người dùng thành công'),
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
  }

  Future<void> _viewUserOrders(String userId, String? userName) async {
    final ordersSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Đơn hàng của ${userName ?? 'người dùng'}'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ordersSnapshot.docs.isEmpty
              ? const Center(child: Text('Chưa có đơn hàng nào'))
              : ListView.builder(
                  itemCount: ordersSnapshot.docs.length,
                  itemBuilder: (context, index) {
                    final order = ordersSnapshot.docs[index];
                    final data = order.data();
                    
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.receipt,
                          color: _getStatusColor(data['status'] ?? ''),
                        ),
                        title: Text('Đơn #${order.id.substring(0, 8)}'),
                        subtitle: Text(
                          data['createdAt'] != null
                              ? DateFormat('dd/MM/yyyy HH:mm')
                                  .format((data['createdAt'] as Timestamp).toDate())
                              : 'N/A',
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _getStatusText(data['status'] ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(data['status'] ?? ''),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              NumberFormat.currency(locale: 'vi', symbol: 'đ')
                                  .format(data['totalAmount'] ?? 0),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
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
}
