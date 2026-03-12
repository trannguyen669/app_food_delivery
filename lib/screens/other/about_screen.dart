import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Về chúng tôi'),
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header với logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6B35),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Food Delivery App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Phiên bản 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Thông tin về app
            _buildInfoCard(
              icon: Icons.info_outline,
              title: 'Giới thiệu',
              content:
                  'Food Delivery là nền tảng giao đồ ăn hàng đầu, kết nối bạn với hàng ngàn nhà hàng và quán ăn ngon trên toàn quốc. Chúng tôi cam kết mang đến trải nghiệm đặt món tiện lợi, giao hàng nhanh chóng và dịch vụ tận tâm nhất.',
            ),

            _buildInfoCard(
              icon: Icons.rocket_launch_outlined,
              title: 'Tầm nhìn & Sứ mệnh',
              content:
                  'Trở thành ứng dụng giao đồ ăn được yêu thích nhất tại Việt Nam. Sứ mệnh của chúng tôi là kết nối mọi người với những món ăn ngon, phục vụ nhanh chóng và giá cả hợp lý, mọi lúc mọi nơi.',
            ),

            _buildInfoCard(
              icon: Icons.verified_outlined,
              title: 'Cam kết của chúng tôi',
              content: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _FeatureItem(text: 'Giao hàng nhanh chóng trong 30 phút'),
                  _FeatureItem(text: 'Đảm bảo chất lượng và vệ sinh an toàn thực phẩm'),
                  _FeatureItem(text: 'Đội ngũ shipper chuyên nghiệp, thân thiện'),
                  _FeatureItem(text: 'Hỗ trợ khách hàng 24/7'),
                  _FeatureItem(text: 'Giá cả minh bạch, không phí ẩn'),
                  _FeatureItem(text: 'Chương trình khuyến mãi hấp dẫn'),
                ],
              ),
            ),

            _buildInfoCard(
              icon: Icons.restaurant_outlined,
              title: 'Đối tác nhà hàng',
              content:
                  'Hợp tác với hơn 5,000+ nhà hàng và quán ăn uy tín trên toàn quốc. Từ món Việt truyền thống đến ẩm thực quốc tế, từ cửa hàng nhỏ đến chuỗi nhà hàng lớn, chúng tôi mang đến sự đa dạng và phong phú cho mọi khẩu vị.',
            ),

            _buildInfoCard(
              icon: Icons.contact_mail_outlined,
              title: 'Liên hệ',
              content: null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ContactItem(
                    icon: Icons.email_outlined,
                    text: 'Email: fooddelivery@example.com',
                  ),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    text: 'Hotline: 1900 1234',
                  ),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Icons.location_on_outlined,
                    text: 'Địa chỉ: 26 Lê Thiện Trị, Phường Ngũ Hành Sơn, Thành phố Đà Nẵng',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Copyright
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                '© 2025 Food Delivery App\nAll rights reserved',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoCard({
    required IconData icon,
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF6B35),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.6,
              ),
            ),
          ],
          if (child != null) ...[
            const SizedBox(height: 16),
            child,
          ],
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFFFF6B35),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFF6B35),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}
