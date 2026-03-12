# 🔧 HƯỚNG DẪN FIX IMPORTS SAU KHI TÁI CẤU TRÚC

## ⚠️ QUAN TRỌNG

Sau khi di chuyển file, BẠN CẦN UPDATE TẤT CẢ IMPORTS trong project!

---

## 📋 BẢNG ĐỔI IMPORT PATH

### 🔐 AUTH SCREENS

```dart
// CŨ
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';

// MỚI
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
```

### 👨‍💼 ADMIN SCREENS

```dart
// CŨ
import 'screens/admin_dashboard_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/manage_foods_screen.dart';
import 'screens/manage_orders_screen.dart';
import 'screens/manage_users_screen.dart';
import 'screens/manage_categories_screen.dart';
import 'screens/revenue_screen.dart';

// MỚI
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_login_screen.dart';
import 'screens/admin/manage_foods_screen.dart';
import 'screens/admin/manage_orders_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/manage_categories_screen.dart';
import 'screens/admin/revenue_screen.dart';
```

### 👤 USER SCREENS

```dart
// CŨ
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/chatbot_screen.dart';

// MỚI
import 'screens/user/home_screen.dart';
import 'screens/user/cart_screen.dart';
import 'screens/user/checkout_screen.dart';
import 'screens/user/favorites_screen.dart';
import 'screens/user/notification_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/chatbot_screen.dart';
```

### 🍕 PRODUCT SCREENS

```dart
// CŨ
import 'screens/category_detail_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/restaurant_detail_screen.dart';
import 'screens/search_screen.dart';

// MỚI
import 'screens/product/category_detail_screen.dart';
import 'screens/product/product_detail_screen.dart';
import 'screens/product/restaurant_detail_screen.dart';
import 'screens/product/search_screen.dart';
```

### 📦 ORDER SCREENS

```dart
// CŨ
import 'screens/order_screen.dart';
import 'screens/order_history_screen.dart';
import 'screens/order_detail_screen.dart';

// MỚI
import 'screens/order/order_screen.dart';
import 'screens/order/order_history_screen.dart';
import 'screens/order/order_detail_screen.dart';
```

### 📍 ADDRESS SCREENS

```dart
// CŨ
import 'screens/address_list_screen.dart';
import 'screens/add_edit_address_screen.dart';

// MỚI
import 'screens/address/address_list_screen.dart';
import 'screens/address/add_edit_address_screen.dart';
```

### ℹ️ OTHER SCREENS

```dart
// CŨ
import 'screens/about_screen.dart';

// MỚI
import 'screens/other/about_screen.dart';
```

---

## 🔍 CÁCH FIX NHANH BẰNG FIND & REPLACE

### 1. Mở VS Code

### 2. Nhấn `Ctrl + Shift + H` (Find and Replace in Files)

### 3. Replace từng màn hình:

**AUTH:**
```
Find: import '../screens/login_screen.dart'
Replace: import '../screens/auth/login_screen.dart'
```

**ADMIN:**
```
Find: import '../screens/admin_dashboard_screen.dart'
Replace: import '../screens/admin/admin_dashboard_screen.dart'
```

...và tương tự cho các màn hình khác.

---

## ⚡ CÁCH FIX TỰ ĐỘNG

### Chạy lệnh này trong terminal:

```powershell
# Fix tất cả imports trong lib folder
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    
    # Fix AUTH
    $content = $content -replace "import '(.*/)?screens/login_screen\.dart'", "import '$1screens/auth/login_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/signup_screen\.dart'", "import '$1screens/auth/signup_screen.dart'"
    
    # Fix ADMIN
    $content = $content -replace "import '(.*/)?screens/admin_dashboard_screen\.dart'", "import '$1screens/admin/admin_dashboard_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/admin_login_screen\.dart'", "import '$1screens/admin/admin_login_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/manage_foods_screen\.dart'", "import '$1screens/admin/manage_foods_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/manage_orders_screen\.dart'", "import '$1screens/admin/manage_orders_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/manage_users_screen\.dart'", "import '$1screens/admin/manage_users_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/manage_categories_screen\.dart'", "import '$1screens/admin/manage_categories_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/revenue_screen\.dart'", "import '$1screens/admin/revenue_screen.dart'"
    
    # Fix USER
    $content = $content -replace "import '(.*/)?screens/home_screen\.dart'", "import '$1screens/user/home_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/cart_screen\.dart'", "import '$1screens/user/cart_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/checkout_screen\.dart'", "import '$1screens/user/checkout_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/favorites_screen\.dart'", "import '$1screens/user/favorites_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/notification_screen\.dart'", "import '$1screens/user/notification_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/profile_screen\.dart'", "import '$1screens/user/profile_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/chatbot_screen\.dart'", "import '$1screens/user/chatbot_screen.dart'"
    
    # Fix PRODUCT
    $content = $content -replace "import '(.*/)?screens/category_detail_screen\.dart'", "import '$1screens/product/category_detail_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/product_detail_screen\.dart'", "import '$1screens/product/product_detail_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/restaurant_detail_screen\.dart'", "import '$1screens/product/restaurant_detail_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/search_screen\.dart'", "import '$1screens/product/search_screen.dart'"
    
    # Fix ORDER
    $content = $content -replace "import '(.*/)?screens/order_screen\.dart'", "import '$1screens/order/order_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/order_history_screen\.dart'", "import '$1screens/order/order_history_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/order_detail_screen\.dart'", "import '$1screens/order/order_detail_screen.dart'"
    
    # Fix ADDRESS
    $content = $content -replace "import '(.*/)?screens/address_list_screen\.dart'", "import '$1screens/address/address_list_screen.dart'"
    $content = $content -replace "import '(.*/)?screens/add_edit_address_screen\.dart'", "import '$1screens/address/add_edit_address_screen.dart'"
    
    # Fix OTHER
    $content = $content -replace "import '(.*/)?screens/about_screen\.dart'", "import '$1screens/other/about_screen.dart'"
    
    Set-Content $_.FullName -Value $content -NoNewline
}

Write-Host "✅ Đã fix tất cả imports!" -ForegroundColor Green
```

---

## ✅ KIỂM TRA SAU KHI FIX

### 1. Chạy Flutter Analyze:
```bash
flutter analyze
```

### 2. Nếu còn lỗi import, tìm bằng:
```bash
flutter analyze 2>&1 | Select-String "import"
```

### 3. Build app để test:
```bash
flutter clean
flutter pub get
flutter run
```

---

## 💡 TIPS

- **Backup trước khi chạy script!**
- Nếu dùng Git: `git add .` trước rồi test, nếu lỗi thì `git reset --hard`
- Một số file có thể dùng import relative `./` hoặc `../` → Check kỹ
- Screens mới thêm vào thì tự động đã đúng thư mục rồi

---

**🎯 Sau khi fix xong, app sẽ chạy bình thường với cấu trúc mới!**
