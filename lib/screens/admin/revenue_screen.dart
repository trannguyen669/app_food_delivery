import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({Key? key}) : super(key: key);

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> with SingleTickerProviderStateMixin {
  DateTimeRange? _selectedRange;
  double _totalRevenue = 0;
  int _totalOrders = 0;
  Map<String, double> _dailyRevenue = {};
  List<Map<String, dynamic>> _topSellingItems = [];
  bool _loading = false;
  late TabController _tabController;

  Future<void> _fetchRevenue() async {
    setState(() => _loading = true);
    
    try {
      Query query = FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'completed');
      
      if (_selectedRange != null) {
        final startDate = DateTime(
          _selectedRange!.start.year,
          _selectedRange!.start.month,
          _selectedRange!.start.day,
          0, 0, 0,
        );
        
        final endDate = DateTime(
          _selectedRange!.end.year,
          _selectedRange!.end.month,
          _selectedRange!.end.day,
          23, 59, 59,
        );
        
        query = query
            .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
            .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      
      final snapshot = await query.get();
      double total = 0;
      int orderCount = 0;
      Map<String, double> daily = {};
      Map<String, Map<String, dynamic>> foodStats = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final amount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final createdAt = data['createdAt'];
        final items = data['items'] as List<dynamic>? ?? [];
        
        total += amount;
        orderCount++;
        
        // Tính doanh thu theo ngày
        if (createdAt != null) {
          DateTime date;
          if (createdAt is Timestamp) {
            date = createdAt.toDate();
          } else if (createdAt is DateTime) {
            date = createdAt;
          } else {
            continue;
          }
          
          final key = DateFormat('dd/MM/yyyy').format(date);
          daily[key] = (daily[key] ?? 0) + amount;
        }
        
        // Thống kê món ăn
        for (var item in items) {
          if (item is Map<String, dynamic>) {
            final foodId = item['foodId'] ?? '';
            final foodName = item['name'] ?? 'Không rõ';
            final quantity = (item['quantity'] as num?)?.toInt() ?? 0;
            final price = (item['price'] as num?)?.toDouble() ?? 0.0;
            final imageUrl = item['imageUrl'] ?? '';
            
            if (foodId.isNotEmpty) {
              if (!foodStats.containsKey(foodId)) {
                foodStats[foodId] = {
                  'name': foodName,
                  'quantity': 0,
                  'revenue': 0.0,
                  'imageUrl': imageUrl,
                };
              }
              foodStats[foodId]!['quantity'] = 
                  (foodStats[foodId]!['quantity'] as int) + quantity;
              foodStats[foodId]!['revenue'] = 
                  (foodStats[foodId]!['revenue'] as double) + (price * quantity);
            }
          }
        }
      }
      
      // Sắp xếp theo ngày giảm dần
      final sortedDaily = Map.fromEntries(
        daily.entries.toList()
          ..sort((a, b) {
            final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
            final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
            return dateB.compareTo(dateA);
          }),
      );
      
      // Sắp xếp món ăn theo số lượng bán
      final topSelling = foodStats.entries
          .map((e) => {
                'foodId': e.key,
                'name': e.value['name'],
                'quantity': e.value['quantity'],
                'revenue': e.value['revenue'],
                'imageUrl': e.value['imageUrl'],
              })
          .toList()
        ..sort((a, b) => (b['quantity'] as int).compareTo(a['quantity'] as int));
      
      setState(() {
        _totalRevenue = total;
        _totalOrders = orderCount;
        _dailyRevenue = sortedDaily;
        _topSellingItems = topSelling.take(20).toList();
        _loading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu doanh thu: $e');
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchRevenue();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Header với gradient
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quản lý doanh thu',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Nút chọn khoảng thời gian
                        InkWell(
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020, 1, 1),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                              initialDateRange: _selectedRange,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Colors.orange.shade600,
                                      onPrimary: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() => _selectedRange = picked);
                              await _fetchRevenue();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.date_range,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedRange == null
                                      ? 'Chọn khoảng thời gian'
                                      : '${DateFormat('dd/MM/yyyy').format(_selectedRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedRange!.end)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_selectedRange != null) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedRange = null);
                                      _fetchRevenue();
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stats Cards
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Tổng doanh thu',
                            _formatCurrency(_totalRevenue),
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Tổng đơn hàng',
                            _totalOrders.toString(),
                            Icons.receipt_long,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.orange.shade700,
                      unselectedLabelColor: Colors.grey.shade600,
                      indicatorColor: Colors.orange.shade700,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      tabs: const [
                        Tab(text: 'Theo ngày'),
                        Tab(text: 'Món bán chạy'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Tab Bar View
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDailyRevenueTab(),
                      _buildTopSellingTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueTab() {
    if (_dailyRevenue.isEmpty) {
      return _buildEmptyState(
        'Chưa có dữ liệu',
        'Không có đơn hàng nào trong khoảng thời gian này',
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _dailyRevenue.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = _dailyRevenue.entries.elementAt(index);
          final date = entry.key;
          final amount = entry.value;
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade400,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Doanh thu trong ngày',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSellingTab() {
    if (_topSellingItems.isEmpty) {
      return _buildEmptyState(
        'Chưa có dữ liệu',
        'Không có món ăn nào được bán trong khoảng thời gian này',
      );
    }

    return Container(
      color: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _topSellingItems.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _topSellingItems[index];
          final rank = index + 1;
          
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rank <= 3 
                    ? Colors.orange.shade200 
                    : Colors.grey.shade200,
                width: rank <= 3 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: rank <= 3 
                      ? Colors.orange.shade100 
                      : Colors.grey.shade100,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: rank <= 3
                        ? LinearGradient(
                            colors: rank == 1
                                ? [Colors.amber.shade400, Colors.amber.shade600]
                                : rank == 2
                                    ? [Colors.grey.shade400, Colors.grey.shade600]
                                    : [Colors.orange.shade300, Colors.orange.shade500],
                          )
                        : null,
                    color: rank > 3 ? Colors.grey.shade200 : null,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: rank <= 3 ? Colors.white : Colors.grey.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Food Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty
                      ? Image.network(
                          item['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                const SizedBox(width: 12),
                
                // Food Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item['quantity']} đã bán',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Revenue
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(item['revenue']),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Doanh thu',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.restaurant,
        color: Colors.grey.shade400,
        size: 30,
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
