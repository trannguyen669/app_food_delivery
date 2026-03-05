import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/product/category_detail_screen.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({Key? key}) : super(key: key);

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> with TickerProviderStateMixin {
  int? _selectedIndex;
  final Map<int, AnimationController> _controllers = {};
  final Map<int, Animation<double>> _scaleAnimations = {};

  // Danh sách màu gradient sang trọng cho các category
  static const List<List<Color>> _categoryGradients = [
    [Color(0xFFFF6B35), Color(0xFFFFAB76)], // Orange
    [Color(0xFF667EEA), Color(0xFF764BA2)], // Purple Blue
    [Color(0xFF11998E), Color(0xFF38EF7D)], // Green
    [Color(0xFFFC466B), Color(0xFF3F5EFB)], // Pink Blue
    [Color(0xFFF093FB), Color(0xFFF5576C)], // Pink
    [Color(0xFF4FACFE), Color(0xFF00F2FE)], // Cyan
    [Color(0xFFFA709A), Color(0xFFFEE140)], // Pink Yellow
    [Color(0xFF43E97B), Color(0xFF38F9D7)], // Mint
  ];

  // Icons cho từng loại category
  static const List<IconData> _categoryIcons = [
    Icons.local_pizza_rounded,
    Icons.lunch_dining_rounded,
    Icons.icecream_rounded,
    Icons.coffee_rounded,
    Icons.ramen_dining_rounded,
    Icons.cake_rounded,
    Icons.local_bar_rounded,
    Icons.rice_bowl_rounded,
  ];

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  AnimationController _getController(int index) {
    if (!_controllers.containsKey(index)) {
      _controllers[index] = AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      );
      _scaleAnimations[index] = Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(
          parent: _controllers[index]!,
          curve: Curves.easeInOut,
        ),
      );
    }
    return _controllers[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          // Nếu có lỗi
          if (snapshot.hasError) {
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Lỗi tải danh mục',
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }
          
          // Đang loading - Skeleton
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: _categoryGradients[index % _categoryGradients.length][0],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 12,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          
          // Không có dữ liệu
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category_outlined, color: Colors.grey[400], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Chưa có danh mục',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Hiển thị danh sách với animation
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              
              String categoryName = data['name'] ?? 'Không rõ';
              String categoryIconUrl = data['iconUrl'] ?? '';
              final gradient = _categoryGradients[index % _categoryGradients.length];
              final icon = _categoryIcons[index % _categoryIcons.length];
              final controller = _getController(index);
              final scaleAnimation = _scaleAnimations[index]!;
              final isSelected = _selectedIndex == index;

              return AnimatedBuilder(
                animation: scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: scaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) => controller.forward(),
                  onTapUp: (_) {
                    controller.reverse();
                    setState(() => _selectedIndex = index);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                          CategoryDetailScreen(
                            categoryId: doc.id,
                            categoryName: categoryName,
                            categoryIconUrl: categoryIconUrl,
                          ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  },
                  onTapCancel: () => controller.reverse(),
                  child: Container(
                    width: 88,
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Category Icon Container
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 76,
                          width: 76,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                ? [gradient[0], gradient[1]]
                                : [
                                    gradient[0].withOpacity(0.12),
                                    gradient[1].withOpacity(0.08),
                                  ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected 
                                ? Colors.white.withOpacity(0.5)
                                : gradient[0].withOpacity(0.2),
                              width: isSelected ? 2 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: gradient[0].withOpacity(isSelected ? 0.4 : 0.15),
                                blurRadius: isSelected ? 16 : 12,
                                offset: const Offset(0, 6),
                                spreadRadius: isSelected ? 2 : 0,
                              ),
                              if (isSelected)
                                BoxShadow(
                                  color: gradient[1].withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background pattern
                              if (isSelected)
                                Positioned(
                                  right: -10,
                                  bottom: -10,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.15),
                                    ),
                                  ),
                                ),
                              // Main content
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Center(
                                  child: categoryIconUrl.isEmpty
                                    ? Icon(
                                        icon,
                                        color: isSelected ? Colors.white : gradient[0],
                                        size: 34,
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: CachedNetworkImage(
                                          imageUrl: categoryIconUrl,
                                          fit: BoxFit.contain,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: isSelected ? Colors.white : gradient[0],
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Icon(
                                            icon,
                                            color: isSelected ? Colors.white : gradient[0],
                                            size: 34,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Category Name
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            color: isSelected ? gradient[0] : const Color(0xFF2D3436),
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                            fontSize: isSelected ? 13 : 12,
                            letterSpacing: 0.2,
                          ),
                          child: Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // Active indicator dot
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 4,
                          width: isSelected ? 20 : 0,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [gradient[0], gradient[1]],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
