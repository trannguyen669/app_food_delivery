import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // API key từ .env file
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  bool _isInitialized = false;
  String _systemPrompt = '';

  // Khởi tạo chat session với context về sản phẩm
  Future<void> initializeChat() async {
    try {
      print('🔍 Đang tìm kiếm collection "foods" trong Firestore...');
      
      // Lấy danh sách sản phẩm từ Firestore
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('foods')
          .limit(50)
          .get();

      print('📊 Số lượng sản phẩm tìm thấy: ${productsSnapshot.docs.length}');

      if (productsSnapshot.docs.isEmpty) {
        print('⚠️ Firestore trống! Tạo dữ liệu mẫu...');
        _systemPrompt = 'Bạn là trợ lý ảo. Thực đơn: TEST - Món ăn mẫu (Test) - 10000đ. Hãy tư vấn món ăn cho khách hàng.';
        _isInitialized = true;
        print('✅ Chatbot đã sẵn sàng (test mode)!');
        return;
      }

      final products = productsSnapshot.docs.map((doc) {
        final data = doc.data();
        print('📦 Sản phẩm: ${data['name']}');
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Chưa rõ tên',
          'category': data['category'] ?? 'Khác',
          'price': data['price'] ?? 0,
          'description': data['description'] ?? '',
        };
      }).toList();

      print('✅ Đã tải ${products.length} sản phẩm từ Firestore');

      // Tạo system prompt
      final productList = products.map((p) => 
        '${p['name']} (${p['category']}) - ${p['price']}đ'
      ).join(', ');

      _systemPrompt = '''
Bạn là trợ lý ảo tư vấn món ăn. Thực đơn: $productList. 
Hãy tư vấn ngắn gọn, thân thiện bằng tiếng Việt. Chỉ giới thiệu món có trong thực đơn.
''';
      
      _isInitialized = true;
      print('✅ Chatbot đã sẵn sàng!');
    } catch (e) {
      print('Error initializing chat: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn và nhận phản hồi
  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      return 'Chatbot đang khởi tạo, vui lòng đợi một chút...';
    }
    
    // 👇 API v1beta với model gemini-2.5-flash
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey'
    );

    // Kết hợp system prompt với message người dùng
    final fullMessage = '$_systemPrompt\n\nKhách hàng hỏi: $message';

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": fullMessage}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("LOG STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Kiểm tra an toàn để tránh crash nếu cấu trúc JSON khác
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        return "Gemini không trả lời (Empty response).";
      } else {
        print("❌ LỖI TỪ GOOGLE: ${response.body}");
        return "Lỗi API: ${response.statusCode} - Xem log để biết chi tiết.";
      }
    } catch (e) {
      print("❌ LỖI MẠNG: $e");
      return "Không thể kết nối internet.";
    }
  }

  // Parse sản phẩm từ response
  List<Map<String, dynamic>>? parseProductsFromResponse(String response) {
    return null;
  }
}
