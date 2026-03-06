import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/food_card.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;
  final String categoryIconUrl;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar với ảnh category
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFFF6B35),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                categoryName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFFF6B35),
                      const Color(0xFFFF6B35).withOpacity(0.8),
                    ],
                  ),
                ),
                child: categoryIconUrl.isNotEmpty
                    ? Opacity(
                        opacity: 0.3,
                        child: Image.network(
                          categoryIconUrl,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.fastfood,
                        size: 100,
                        color: Colors.white.withOpacity(0.3),
                      ),
              ),
            ),
          ),

          // Danh sách món ăn
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('foods')
                .where('categoryID', isEqualTo: categoryId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(50.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có món ăn trong danh mục này',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final foods = snapshot.data!.docs;

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var foodDoc = foods[index];
                      Map<String, dynamic> foodData =
                          foodDoc.data() as Map<String, dynamic>;

                      // Xử lý price có thể là String hoặc number
                      double price = 0;
                      var priceData = foodData['price'];
                      if (priceData is String) {
                        price = double.tryParse(priceData) ?? 0;
                      } else if (priceData is num) {
                        price = priceData.toDouble();
                      }

                      return FoodCard(
                        foodId: foodDoc.id,
                        name: foodData['name'] ?? 'Không có tên',
                        restaurantName: foodData['restaurantName'] ?? '',
                        price: price,
                        imageUrl: foodData['imageUrl'] ?? '',
                      );
                    },
                    childCount: foods.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
