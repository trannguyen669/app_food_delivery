import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'manage_foods_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_users_screen.dart';
import 'manage_categories_screen.dart';
import 'revenue_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens() {
    return [
      AdminHomeScreen(onNavigateToTab: (index) {
        setState(() => _selectedIndex = index);
      }),
      const ManageFoodsScreen(),
      const ManageOrdersScreen(),
      const ManageUsersScreen(),
      const ManageCategoriesScreen(),
      const RevenueScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange.shade600, Colors.deepOrange.shade500],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade600, Colors.deepOrange.shade500],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(Icons.dashboard_rounded, 'Tổng quan', 0),
                  _buildMenuItem(Icons.restaurant_menu_rounded, 'Quản lý món ăn', 1),
                  _buildMenuItem(Icons.receipt_long_rounded, 'Quản lý đơn hàng', 2),
                  _buildMenuItem(Icons.people_rounded, 'Quản lý người dùng', 3),
                  _buildMenuItem(Icons.category_rounded, 'Quản lý danh mục', 4),
                  _buildMenuItem(Icons.bar_chart_rounded, 'Quản lý doanh thu', 5),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
              ),
              title: Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      body: _getScreens()[_selectedIndex],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.orange.shade100 
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.orange.shade700 : Colors.grey.shade600,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.orange.shade700 : Colors.grey.shade800,
            fontSize: 14,
          ),
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// Admin Home Screen với thống kê Realtime
class AdminHomeScreen extends StatelessWidget {
  final Function(int)? onNavigateToTab;
  
  const AdminHomeScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modern Header with Gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan hệ thống',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Theo dõi hoạt động và doanh thu',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Statistics Cards
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, foodsSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('orders').snapshots(),
                  builder: (context, ordersSnapshot) {
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, usersSnapshot) {
                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                          builder: (context, categoriesSnapshot) {
                            final foodsCount = foodsSnapshot.data?.docs.length ?? 0;
                            final ordersCount = ordersSnapshot.data?.docs.length ?? 0;
                            final usersCount = usersSnapshot.data?.docs.length ?? 0;
                            final categoriesCount = categoriesSnapshot.data?.docs.length ?? 0;
                            
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.3,
                                children: [
                                  _buildStatCard(
                                    context,
                                    'Món ăn',
                                    Icons.restaurant_menu_rounded,
                                    Colors.orange,
                                    foodsCount.toString(),
                                    onTap: () => _navigateToTab(1),
                                  ),
                                  _buildStatCard(
                                    context,
                                    'Đơn hàng',
                                    Icons.receipt_long_rounded,
                                    Colors.blue,
                                    ordersCount.toString(),
                                    onTap: () => _navigateToTab(2),
                                  ),
                                  _buildStatCard(
                                    context,
                                    'Người dùng',
                                    Icons.people_rounded,
                                    Colors.green,
                                    usersCount.toString(),
                                    onTap: () => _navigateToTab(3),
                                  ),
                                  _buildStatCard(
                                    context,
                                    'Danh mục',
                                    Icons.category_rounded,
                                    Colors.purple,
                                    categoriesCount.toString(),
                                    onTap: () => _navigateToTab(4),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Doanh thu
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'completed')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalRevenue = 0;
                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalRevenue += (data['totalAmount'] as num?)?.toInt() ?? 0;
                  }
                }
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade600],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tổng doanh thu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${NumberFormat('#,###', 'vi_VN').format(totalRevenue)}đ',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Recent Orders
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Đơn hàng gần đây',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inbox_rounded,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có đơn hàng nào',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final statusColors = {
                  'pending': Colors.orange,
                  'confirmed': Colors.blue,
                  'preparing': Colors.purple,
                  'delivering': Colors.indigo,
                  'completed': Colors.green,
                  'cancelled': Colors.red,
                };
                
                final statusLabels = {
                  'pending': 'Chờ xác nhận',
                  'confirmed': 'Đã xác nhận',
                  'preparing': 'Đang chuẩn bị',
                  'delivering': 'Đang giao',
                  'completed': 'Hoàn thành',
                  'cancelled': 'Đã hủy',
                };
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'pending';
                    final total = data['totalAmount'] ?? 0;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (statusColors[status] ?? Colors.grey).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.receipt_long_rounded,
                            color: statusColors[status] ?? Colors.grey,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          'Đơn #${doc.id.substring(0, 8)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${NumberFormat('#,###', 'vi_VN').format(total)}đ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: (statusColors[status] ?? Colors.grey).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColors[status] ?? Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            statusLabels[status] ?? status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColors[status] ?? Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String count, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    onNavigateToTab?.call(index);
  }
}
