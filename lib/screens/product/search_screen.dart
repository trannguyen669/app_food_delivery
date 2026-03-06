import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/food_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;

  const SearchScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      final queryLower = query.toLowerCase().trim();
      
      // Bước 1: Tìm categoryID và tạo map categoryID -> categoryName
      String? targetCategoryId;
      String? targetCategoryName;
      final categorySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .get();
      
      for (var categoryDoc in categorySnapshot.docs) {
        final categoryData = categoryDoc.data();
        final categoryName = (categoryData['name'] ?? '').toString();
        if (categoryName.toLowerCase().contains(queryLower)) {
          targetCategoryId = categoryDoc.id;
          targetCategoryName = categoryName;
          break;
        }
      }
      
      // Bước 2: Query foods collection
      final snapshot = await FirebaseFirestore.instance
          .collection('foods')
          .get();

      // Bước 3: Filter results
      final results = snapshot.docs.where((doc) {
        final data = doc.data();
        final name = (data['name'] ?? '').toString().toLowerCase();
        final restaurant = (data['restaurantName'] ?? '').toString().toLowerCase();
        final foodCategoryId = data['categoryID'] ?? '';
        
        // Tìm kiếm: name, restaurant, hoặc categoryID khớp với category được tìm
        final matches = name.contains(queryLower) || 
               restaurant.contains(queryLower) ||
               (targetCategoryId != null && foodCategoryId == targetCategoryId);
        
        return matches;
      }).map((doc) {
        final data = doc.data();
        
        // Parse price safely (handle both String and num)
        double price = 0;
        final priceData = data['price'];
        if (priceData is num) {
          price = priceData.toDouble();
        } else if (priceData is String) {
          price = double.tryParse(priceData) ?? 0;
        }
        
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'restaurantName': data['restaurantName'] ?? '',
          'price': price,
          'imageUrl': data['imageUrl'] ?? '',
          'category': targetCategoryName ?? _searchQuery,
        };
      }).toList();

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tìm kiếm: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          cursorColor: const Color(0xFFFF6B35),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.none,
            decorationThickness: 0,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm pizza, burger, yogurt...',
            hintStyle: const TextStyle(
              color: Colors.black38,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.black54),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _searchResults = [];
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Debounce search - chỉ search sau khi user ngừng gõ 500ms
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _performSearch(value);
              }
            });
          },
          onSubmitted: (value) {
            _performSearch(value);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _performSearch(_searchController.text);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF6B35),
        ),
      );
    }

    if (_searchQuery.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    final suggestions = [
      {'icon': '🍕', 'text': 'Pizza', 'query': 'pizza'},
      {'icon': '🍔', 'text': 'Burger', 'query': 'burger'},
      {'icon': '🍦', 'text': 'Yogurt', 'query': 'yogurt'},
      {'icon': '🍰', 'text': 'Cream', 'query': 'cream'},
      {'icon': '🍓', 'text': 'Fruit', 'query': 'fruit'},
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gợi ý tìm kiếm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...suggestions.map((suggestion) {
              return InkWell(
                onTap: () {
                  _searchController.text = suggestion['query'] as String;
                  _performSearch(suggestion['query'] as String);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        suggestion['icon'] as String,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        suggestion['text'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    // Lấy category name để hiển thị (viết hoa chữ cái đầu)
    String categoryTitle = _searchQuery;
    if (_searchResults.isNotEmpty) {
      final category = _searchResults[0]['category'] as String;
      categoryTitle = category.substring(0, 1).toUpperCase() + category.substring(1);
    }
    
    // Lấy ảnh đầu tiên làm background
    final backgroundImage = _searchResults.isNotEmpty ? _searchResults[0]['imageUrl'] : '';

    return Column(
      children: [
        // Header với background image và category name
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            image: backgroundImage.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(backgroundImage),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  )
                : null,
            color: backgroundImage.isEmpty ? const Color(0xFFFF6B35) : null,
          ),
          child: Center(
            child: Text(
              categoryTitle,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    offset: Offset(2, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Grid results
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return FoodCard(
                foodId: food['id'],
                imageUrl: food['imageUrl'],
                name: food['name'],
                restaurantName: food['restaurantName'],
                price: food['price'],
              );
            },
          ),
        ),
      ],
    );
  }
}
