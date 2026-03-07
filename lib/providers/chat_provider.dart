import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  // Khởi tạo chat
  Future<void> initializeChat() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _geminiService.initializeChat();
      
      // Thêm tin nhắn chào mừng
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Xin chào! Tôi là trợ lý ảo của cửa hàng. Tôi có thể giúp bạn tìm món ăn phù hợp, tư vấn thực đơn hoặc giải đáp thắc mắc. Bạn cần gì hôm nay?',
        isUser: false,
        timestamp: DateTime.now(),
      ));

      _isInitialized = true;
    } catch (e) {
      print('Error initializing chat: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gửi tin nhắn
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Nếu chưa khởi tạo, khởi tạo ngay
    if (!_isInitialized) {
      await _initializeChatIfNeeded();
    }

    // Thêm tin nhắn của user
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    notifyListeners();

    // Hiển thị loading
    _isLoading = true;
    notifyListeners();

    try {
      // Gửi đến Gemini và nhận phản hồi
      final response = await _geminiService.sendMessage(text);

      // Thêm phản hồi của bot
      final botMessage = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        products: _geminiService.parseProductsFromResponse(response),
      );
      _messages.add(botMessage);
    } catch (e) {
      // Thêm tin nhắn lỗi
      _messages.add(ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: 'Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Khởi tạo chat khi cần (lazy loading)
  Future<void> _initializeChatIfNeeded() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _geminiService.initializeChat();
      _isInitialized = true;
      
      // Thêm tin nhắn chào
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Xin chào! Tôi có thể giúp bạn tìm món ăn. Bạn muốn gì?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      print('Error initializing chat: $e');
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Không thể kết nối chatbot. Vui lòng kiểm tra internet.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa lịch sử chat
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}
