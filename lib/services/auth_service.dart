import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Lấy "thể hiện" (instance) của Firebase Auth & Firestore
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy user hiện tại
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // --- HÀM ĐĂNG NHẬP ---
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      // Cố gắng đăng nhập
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // (Không cần lưu vào CSDL ở đây vì user đã tồn tại)

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Hiển thị lỗi nếu có
      throw Exception(e.message);
    }
  }

  // --- HÀM ĐĂNG KÝ ---
  Future<UserCredential?> signUpWithEmailPassword(String name, String email, String password) async {
    try {
      // 1. Tạo user mới trên Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. TẠO MỘT DOCUMENT CHO USER TRÊN FIRESTORE
  
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'name': name,
          'email': email,
          // Thêm các trường khác bạn muốn (từ thiết kế UI)
          // 'phone': '', 
          // 'profileImageUrl': '',
          // 'address': '',
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Hiển thị lỗi nếu có
      throw Exception(e.message);
    }
  }

  // --- HÀM ĐĂNG XUẤT ---
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // --- STREAM (LUỒNG) TRẠNG THÁI AUTH ---
  // (Đây là hàm "lắng nghe" quan trọng nhất)
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}
