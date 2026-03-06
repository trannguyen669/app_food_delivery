import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageFoodsScreen extends StatefulWidget {
  const ManageFoodsScreen({Key? key}) : super(key: key);

  @override
  State<ManageFoodsScreen> createState() => _ManageFoodsScreenState();
}

class _ManageFoodsScreenState extends State<ManageFoodsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedCategoryId = 'all'; // ID của category được chọn
  String _sortBy = 'name'; // name, price

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
                      'Quản lý món ăn',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm món ăn...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: Icon(Icons.search, color: Colors.orange.shade600),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value.toLowerCase());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Category Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (context, snapshot) {
                  final categoryMap = <String, String>{'all': 'all'};
                  final categoryNames = ['all'];
                  
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name']?.toString() ?? '';
                      if (name.isNotEmpty) {
                        categoryNames.add(name);
                        categoryMap[name] = doc.id;
                      }
                    }
                  }
                  
                  return Row(
                    children: categoryNames.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            category == 'all' ? 'Tất cả' : category,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                              _selectedCategoryId = categoryMap[category] ?? 'all';
                            });
                          },
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: Colors.orange.shade600,
                          checkmarkColor: Colors.white,
                          elevation: isSelected ? 4 : 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          
          const Divider(height: 1),

          // Foods list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('foods').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var foods = snapshot.data!.docs;

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  foods = foods.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();
                }

                // Filter by category
                if (_selectedCategoryId != 'all') {
                  foods = foods.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    // So sánh với categoryID (document ID của category)
                    final foodCategoryId = data['categoryID'] ?? '';
                    // Hoặc nếu dùng category name (cho dữ liệu cũ)
                    final foodCategoryName = data['category'] ?? '';
                    
                    return foodCategoryId == _selectedCategoryId || 
                           foodCategoryName.toString().toLowerCase() == _selectedCategory.toLowerCase();
                  }).toList();
                }

                // Sort
                foods.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  
                  if (_sortBy == 'price') {
                    final priceA = dataA['price'] ?? 0;
                    final priceB = dataB['price'] ?? 0;
                    return priceA.compareTo(priceB);
                  } else {
                    final nameA = dataA['name'] ?? '';
                    final nameB = dataB['name'] ?? '';
                    return nameA.toString().compareTo(nameB.toString());
                  }
                });

                if (foods.isEmpty) {
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
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.orange.shade300,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Chưa có món ăn nào',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhấn nút "Thêm món" để bắt đầu',
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
                  itemCount: foods.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final doc = foods[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
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
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _editFood(doc.id, data),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: data['imageUrl'] != null
                                      ? Image.network(
                                          data['imageUrl'],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 90,
                                            height: 90,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.grey.shade200, Colors.grey.shade300],
                                              ),
                                            ),
                                            child: Icon(Icons.fastfood, size: 40, color: Colors.grey.shade400),
                                          ),
                                        )
                                      : Container(
                                          width: 90,
                                          height: 90,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Colors.grey.shade200, Colors.grey.shade300],
                                            ),
                                          ),
                                          child: Icon(Icons.fastfood, size: 40, color: Colors.grey.shade400),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'Chưa có tên',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${data['price'] ?? 0}đ',
                                        style: TextStyle(
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          (data['category'] ?? data['categoryID'] ?? 'Chưa phân loại').toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Actions
                                Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.edit, color: Colors.blue.shade700),
                                        onPressed: () => _editFood(doc.id, data),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.delete, color: Colors.red.shade700),
                                        onPressed: () => _deleteFood(doc.id, data['name']),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addFood(),
        backgroundColor: Colors.orange.shade600,
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm món',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _addFood() {
    _showFoodDialog();
  }

  void _editFood(String id, Map<String, dynamic> data) {
    _showFoodDialog(id: id, currentData: data);
  }

  Future<void> _deleteFood(String id, String? name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Text('Xác nhận xóa'),
          ],
        ),
        content: Text('Bạn có chắc muốn xóa món "${name ?? 'này'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('foods').doc(id).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đã xóa món ăn'),
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

  void _showFoodDialog({String? id, Map<String, dynamic>? currentData}) {
    final nameController = TextEditingController(text: currentData?['name']);
    final priceController = TextEditingController(
      text: currentData?['price']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: currentData?['description'],
    );
    final imageUrlController = TextEditingController(
      text: currentData?['imageUrl'],
    );
    // Hỗ trợ cả 'category' và 'categoryID' cho dữ liệu cũ
    String selectedCategory = currentData?['category'] ?? currentData?['categoryID'] ?? 'Món chính';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  id == null ? Icons.add_circle : Icons.edit,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(id == null ? 'Thêm món mới' : 'Sửa món ăn'),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogTextField(
                    controller: nameController,
                    label: 'Tên món *',
                    icon: Icons.restaurant_menu,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: priceController,
                    label: 'Giá (VNĐ) *',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('categories')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final categories = <String>[];
                      if (snapshot.hasData) {
                        categories.addAll(
                          snapshot.data!.docs.map((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            return data['name']?.toString() ?? '';
                          }).where((name) => name.isNotEmpty),
                        );
                      }
                      if (categories.isEmpty) {
                        categories.add('Món chính');
                      }
                      if (!categories.contains(selectedCategory)) {
                        selectedCategory = categories.first;
                      }

                      return _buildDialogDropdown(
                        value: selectedCategory,
                        label: 'Danh mục *',
                        icon: Icons.category,
                        items: categories,
                        onChanged: (value) {
                          setState(() => selectedCategory = value!);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: descController,
                    label: 'Mô tả',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildDialogTextField(
                    controller: imageUrlController,
                    label: 'URL hình ảnh',
                    icon: Icons.image,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty ||
                    priceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Vui lòng nhập tên và giá món'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final data = {
                  'name': nameController.text.trim(),
                  'price': int.tryParse(priceController.text.trim()) ?? 0,
                  'category': selectedCategory,
                  'description': descController.text.trim(),
                  'imageUrl': imageUrlController.text.trim().isNotEmpty
                      ? imageUrlController.text.trim()
                      : null,
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (id == null) {
                  data['createdAt'] = FieldValue.serverTimestamp();
                }

                try {
                  if (id == null) {
                    await FirebaseFirestore.instance
                        .collection('foods')
                        .add(data);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('foods')
                        .doc(id)
                        .update(data);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(id == null
                            ? 'Đã thêm món mới thành công'
                            : 'Đã cập nhật món thành công'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(id == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.orange.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
