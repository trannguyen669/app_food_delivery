import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import '../screens/user/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../main.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy AuthService
    final authService = AuthService();

    return Scaffold(
      body: StreamBuilder<User?>(
        // Lắng nghe trạng thái đăng nhập từ AuthService
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          // 1. Đang kiểm tra...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. User ĐÃ đăng nhập
          if (snapshot.hasData) {
            final user = snapshot.data!;
            
            // Kiểm tra role của user
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  final role = userData?['role'] ?? 'user';

                  // Điều hướng dựa trên role
                  if (role == 'admin') {
                    return const AdminDashboardScreen();
                  }
                }

                // Mặc định là user thường
                return HomeScreen(key: homeScreenKey);
              },
            );
          }

          // 3. User CHƯA đăng nhập
          return const LoginScreen(); 
        },
      ),
    );
  }
}
