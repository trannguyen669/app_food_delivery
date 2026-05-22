# 📂 CẤU TRÚC THƯ MỤC SCREENS

Cấu trúc thư mục đã được tổ chức lại theo logic chức năng để dễ quản lý và maintain.

## 📋 PHÂN LOẠI THEO CHỨC NĂNG

### 🔐 auth/ - **Màn hình Xác thực**
Các màn hình liên quan đến đăng nhập, đăng ký
- `login_screen.dart` - Đăng nhập
- `signup_screen.dart` - Đăng ký tài khoản mới

### 👨‍💼 admin/ - **Màn hình Quản trị**
Các màn hình dành cho admin quản lý hệ thống
- `admin_dashboard_screen.dart` - Dashboard tổng quan admin
- `admin_login_screen.dart` - Đăng nhập admin (riêng biệt)
- `manage_categories_screen.dart` - Quản lý danh mục
- `manage_categories_screen_new.dart` - Phiên bản mới quản lý danh mục
- `manage_foods_screen.dart` - Quản lý món ăn (CRUD)
- `manage_foods_screen_modern.dart` - Phiên bản hiện đại quản lý món ăn
- `manage_orders_screen.dart` - Quản lý đơn hàng
- `manage_orders_screen_new.dart` - Phiên bản mới quản lý đơn hàng
- `manage_users_screen.dart` - Quản lý người dùng
- `manage_users_screen_new.dart` - Phiên bản mới quản lý người dùng
- `revenue_screen.dart` - Thống kê doanh thu

### 👤 user/ - **Màn hình Người dùng**
Các màn hình chính trong luồng sử dụng của khách hàng
- `home_screen.dart` - Trang chủ
- `cart_screen.dart` - Giỏ hàng
- `checkout_screen.dart` - Thanh toán
- `favorites_screen.dart` - Món ăn yêu thích
- `notification_screen.dart` - Thông báo
- `profile_screen.dart` - Trang cá nhân
- `chatbot_screen.dart` - Chatbot AI tư vấn

### 🍕 product/ - **Màn hình Sản phẩm**
Các màn hình liên quan đến xem và tìm kiếm sản phẩm
- `category_detail_screen.dart` - Chi tiết danh mục
- `product_detail_screen.dart` - Chi tiết món ăn
- `restaurant_detail_screen.dart` - Chi tiết nhà hàng
- `search_screen.dart` - Tìm kiếm món ăn

### 📦 order/ - **Màn hình Đơn hàng**
Các màn hình quản lý đơn hàng của người dùng
- `order_screen.dart` - Màn hình đơn hàng chung
- `order_history_screen.dart` - Lịch sử đơn hàng
- `order_detail_screen.dart` - Chi tiết đơn hàng

### 📍 address/ - **Màn hình Địa chỉ**
Các màn hình quản lý địa chỉ giao hàng
- `address_list_screen.dart` - Danh sách địa chỉ
- `add_edit_address_screen.dart` - Thêm/sửa địa chỉ

### ℹ️ other/ - **Màn hình Khác**
Các màn hình phụ khác
- `about_screen.dart` - Về ứng dụng

---

## 🎯 LỢI ÍCH CỦA CẤU TRÚC MỚI

### ✅ **Dễ tìm kiếm**
- Muốn sửa màn admin → Vào thư mục `admin/`
- Muốn sửa màn user → Vào thư mục `user/`
- Không còn lộn xộn với 30+ files trong 1 thư mục

### ✅ **Dễ maintain**
- Tách biệt rõ ràng giữa admin và user
- Dễ phân công cho nhiều dev cùng làm
- Dễ review code khi biết màn hình thuộc module nào

### ✅ **Scalable**
- Thêm màn hình mới dễ dàng vào đúng thư mục
- Xóa cả module admin không ảnh hưởng user
- Có thể tạo thêm module mới (ví dụ: `seller/`, `delivery/`)

### ✅ **Professional**
- Cấu trúc chuẩn cho dự án lớn
- Dễ thuyết trình và giải thích cho giám khảo
- Thể hiện tư duy kiến trúc tốt

---

## 📝 HƯỚNG DẪN SỬ DỤNG

### Khi thêm màn hình mới:

**1. Xác định màn hình thuộc module nào:**
- Admin? → `admin/`
- User? → `user/`
- Sản phẩm? → `product/`
- ...

**2. Đặt tên file theo convention:**
- `tên_chức_năng_screen.dart`
- Ví dụ: `payment_method_screen.dart`

**3. Update import path:**
```dart
// CŨ
import '../screens/home_screen.dart';

// MỚI
import '../screens/user/home_screen.dart';
```

---

## 🔄 MIGRATION

Nếu cần rollback về cấu trúc cũ, chỉ cần di chuyển tất cả file từ các thư mục con ra ngoài `screens/`.

---

**📅 Cập nhật:** Ngày 26/12/2025  
**👨‍💻 Tái cấu trúc bởi:** GitHub Copilot
