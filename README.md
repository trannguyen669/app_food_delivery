# Food Delivery App

Ứng dụng đặt đồ ăn đa nền tảng được xây dựng bằng Flutter. App hỗ trợ đăng ký, đăng nhập, xem danh mục món ăn, tìm kiếm, giỏ hàng, đặt hàng, yêu thích, thông báo đơn hàng, quản lý địa chỉ, chatbot tư vấn món ăn bằng Gemini và khu vực quản trị cho admin.

## Mục lục

- [Tính năng chính](#tính-năng-chính)
- [Công nghệ sử dụng](#công-nghệ-sử-dụng)
- [Yêu cầu môi trường](#yêu-cầu-môi-trường)
- [Cài đặt và chạy dự án](#cài-đặt-và-chạy-dự-án)
- [Cấu hình Firebase](#cấu-hình-firebase)
- [Cấu hình Gemini API](#cấu-hình-gemini-api)
- [Tài khoản và phân quyền](#tài-khoản-và-phân-quyền)
- [Cấu trúc thư mục](#cấu-trúc-thư-mục)
- [Mô hình dữ liệu Firestore](#mô-hình-dữ-liệu-firestore)
- [Luồng hoạt động](#luồng-hoạt-động)
- [Lệnh phát triển thường dùng](#lệnh-phát-triển-thường-dùng)
- [Ghi chú bảo mật](#ghi-chú-bảo-mật)

## Tính năng chính

### Người dùng

- Đăng ký và đăng nhập bằng Firebase Authentication.
- Điều hướng tự động theo trạng thái đăng nhập.
- Trang chủ hiển thị danh mục, món ăn gợi ý, ưu đãi và nhà hàng gần đây.
- Tìm kiếm món ăn theo tên món, tên nhà hàng hoặc danh mục.
- Xem chi tiết món ăn, chọn size và thêm vào giỏ hàng.
- Quản lý giỏ hàng: tăng, giảm, xóa món, tính tổng tiền.
- Thanh toán và tạo đơn hàng trên Firestore.
- Hỗ trợ phương thức thanh toán: tiền mặt, MoMo, ZaloPay.
- Theo dõi lịch sử đơn hàng và chi tiết đơn hàng.
- Lưu món ăn yêu thích.
- Quản lý địa chỉ giao hàng.
- Nhận thông báo khi trạng thái đơn hàng thay đổi.
- Chatbot AI tư vấn món ăn dựa trên dữ liệu món ăn trong Firestore.

### Quản trị viên

- Dashboard tổng quan số món ăn, đơn hàng, người dùng và danh mục.
- Quản lý món ăn: thêm, sửa, xóa, lọc theo danh mục, tìm kiếm và sắp xếp.
- Quản lý danh mục: thêm, sửa, xóa và tự cập nhật món ăn khi đổi tên danh mục.
- Quản lý đơn hàng và cập nhật trạng thái đơn hàng.
- Quản lý người dùng, đổi vai trò user/admin và xóa người dùng.
- Xem thống kê doanh thu và món bán chạy.

## Công nghệ sử dụng

- Flutter SDK với Dart `^3.9.2`
- Firebase Core
- Firebase Authentication
- Cloud Firestore
- Provider cho quản lý state
- Google Fonts
- Cached Network Image
- Intl
- Flutter Dotenv
- HTTP
- Google Gemini API qua endpoint REST `gemini-2.5-flash`

## Yêu cầu môi trường

- Flutter SDK tương thích Dart `^3.9.2`
- Android Studio hoặc VS Code có Flutter/Dart plugin
- Firebase project đã bật Authentication và Cloud Firestore
- FlutterFire CLI nếu cần tạo lại `lib/firebase_options.dart`
- Gemini API key nếu dùng chatbot

Kiểm tra môi trường:

```bash
flutter doctor
```

## Cài đặt và chạy dự án

1. Clone hoặc mở thư mục dự án:

```bash
cd food_delivery_app
```

2. Cài dependencies:

```bash
flutter pub get
```

3. Tạo file `.env` ở thư mục gốc:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

4. Đảm bảo file `lib/firebase_options.dart` đã tồn tại và chứa cấu hình Firebase thật. Nếu chưa có, xem phần [Cấu hình Firebase](#cấu-hình-firebase).

5. Chạy app:

```bash
flutter run
```

Chạy trên một thiết bị cụ thể:

```bash
flutter devices
flutter run -d <device_id>
```

## Cấu hình Firebase

Dự án khởi tạo Firebase tại `lib/main.dart` bằng:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

File cấu hình cần có:

```text
lib/firebase_options.dart
```

Trong repo có file mẫu:

```text
lib/firebase_options.dart.example
```

Nếu cần tạo lại cấu hình Firebase, chạy:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Sau đó chọn Firebase project và các nền tảng cần hỗ trợ. Dự án hiện có cấu trúc nền tảng cho Android, iOS, Web, Windows, macOS và Linux. Lưu ý file mẫu hiện chưa cấu hình Linux.

Trên Firebase Console cần bật:

- Authentication bằng Email/Password.
- Cloud Firestore.

## Cấu hình Gemini API

Chatbot đọc API key từ `.env` bằng `flutter_dotenv`:

```env
GEMINI_API_KEY=your_gemini_api_key_here
```

File `.env` được khai báo trong `pubspec.yaml`:

```yaml
flutter:
  assets:
    - .env
```

Service chính nằm ở:

```text
lib/services/gemini_service.dart
```

Chatbot lấy tối đa 50 món từ collection `foods`, tạo system prompt bằng danh sách món và gửi câu hỏi tới Gemini. Nếu collection `foods` trống, service dùng dữ liệu test tạm thời.

## Tài khoản và phân quyền

App dùng Firebase Auth để đăng nhập. Sau khi đăng nhập, `AuthGate` kiểm tra document tương ứng trong collection `users`:

```text
users/{uid}.role
```

Quy tắc điều hướng:

- `role == "admin"`: vào màn hình `AdminDashboardScreen`.
- Không có role hoặc role khác: vào `HomeScreen` của người dùng.

Khi đăng ký tài khoản mới, app tạo document trong `users` với các trường cơ bản:

```json
{
  "uid": "firebase_user_uid",
  "name": "Tên người dùng",
  "email": "email@example.com"
}
```

Để cấp quyền admin, cập nhật Firestore:

```json
{
  "role": "admin"
}
```

## Cấu trúc thư mục

```text
lib/
  main.dart
  firebase_options.dart
  models/
    address.dart
    cart_item.dart
    chat_message.dart
    favorite_item.dart
    notification.dart
    order.dart
  providers/
    address_provider.dart
    cart_provider.dart
    chat_provider.dart
    favorite_provider.dart
    notification_provider.dart
  screens/
    address/
    admin/
    auth/
    order/
    other/
    product/
    user/
  services/
    auth_gate.dart
    auth_service.dart
    gemini_service.dart
  widgets/
    category_list.dart
    food_card.dart
    main_navigation.dart
    recommendation_list.dart
    special_offer_card.dart
```

Các thư mục nền tảng:

```text
android/
ios/
web/
windows/
macos/
linux/
```

## Mô hình dữ liệu Firestore

### `users`

Dùng cho thông tin tài khoản và phân quyền.

```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "role": "user | admin"
}
```

Subcollection địa chỉ:

```text
users/{userId}/addresses/{addressId}
```

```json
{
  "fullName": "string",
  "phoneNumber": "string",
  "streetAddress": "string",
  "ward": "string",
  "district": "string",
  "city": "string",
  "label": "Nhà | Công ty | Khác",
  "isDefault": true,
  "createdAt": "ISO-8601 string"
}
```

### `categories`

```json
{
  "name": "string",
  "description": "string",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `foods`

```json
{
  "name": "string",
  "price": 50000,
  "category": "string",
  "description": "string",
  "imageUrl": "string",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

Một số màn hình cũng đọc các trường bổ sung nếu có:

```json
{
  "restaurantName": "string",
  "rating": 4.5
}
```

### `restaurants`

Hiển thị ở mục nhà hàng gần đây trên trang chủ.

```json
{
  "name": "string",
  "distance": 2.5,
  "rating": 4.5,
  "imageUrl": "string",
  "promo": "13 Promo",
  "foodImageUrl": "string"
}
```

### `orders`

```json
{
  "userId": "string",
  "items": [
    {
      "id": "string",
      "foodId": "string",
      "name": "string",
      "restaurantName": "string",
      "price": 50000,
      "imageUrl": "string",
      "size": "M",
      "quantity": 1
    }
  ],
  "totalAmount": 50000,
  "status": "pending",
  "paymentMethod": "cash",
  "deliveryAddress": "string",
  "phoneNumber": "string",
  "note": "string",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

Các trạng thái đơn hàng được dùng trong model:

- `pending`: chờ xác nhận
- `processing`: đang xử lý
- `delivering`: đang giao
- `completed`: hoàn thành
- `cancelled`: đã hủy

Một số màn hình thông báo/admin cũng có thể dùng các trạng thái:

- `confirmed`
- `preparing`
- `shipping`
- `delivered`

### `favorites`

```json
{
  "userId": "string",
  "foodId": "string",
  "name": "string",
  "restaurantName": "string",
  "price": 50000,
  "imageUrl": "string",
  "addedAt": 1710000000000
}
```

### `notifications`

```json
{
  "userId": "string",
  "title": "string",
  "message": "string",
  "orderId": "string",
  "orderStatus": "string",
  "isRead": false,
  "createdAt": "Timestamp"
}
```

### `special_offers`

Được đọc bởi widget ưu đãi đặc biệt. Nên chuẩn hóa dữ liệu theo các trường đang hiển thị trong UI:

```json
{
  "restaurantName": "string",
  "rating": 4.5,
  "imageUrl": "string",
  "title": "string",
  "description": "string"
}
```

## Luồng hoạt động

1. App load `.env`, khởi tạo Firebase và đăng ký các Provider trong `main.dart`.
2. `AuthGate` lắng nghe `authStateChanges`.
3. Nếu chưa đăng nhập, app mở `LoginScreen`.
4. Nếu đã đăng nhập, app đọc `users/{uid}` để xác định role.
5. Người dùng thường vào `HomeScreen`; admin vào `AdminDashboardScreen`.
6. Người dùng chọn món, thêm vào `CartProvider`, checkout và lưu đơn vào `orders`.
7. Admin quản lý món, danh mục, người dùng, đơn hàng và có thể tạo thông báo trạng thái đơn hàng.
8. Chatbot lấy dữ liệu từ `foods` để tư vấn món ăn qua Gemini.

## Lệnh phát triển thường dùng

Cài package:

```bash
flutter pub get
```

Phân tích code:

```bash
flutter analyze
```

Chạy test:

```bash
flutter test
```

Chạy app:

```bash
flutter run
```

Build Android APK:

```bash
flutter build apk
```

Build Web:

```bash
flutter build web
```

Build Windows:

```bash
flutter build windows
```

## Ghi chú bảo mật

- Không commit `.env` nếu chứa API key thật.
- Không công khai `lib/firebase_options.dart` nếu project Firebase không được cấu hình rule phù hợp.
- Nên cấu hình Firestore Security Rules để người dùng chỉ đọc/ghi dữ liệu của chính họ.
- Quyền admin hiện dựa trên trường `role` trong Firestore, vì vậy cần rule phía server để ngăn user tự sửa role.
- API key Gemini trong app client có thể bị trích xuất; với sản phẩm thật nên gọi Gemini qua backend/proxy.

## Gợi ý Firestore Rules tối thiểu

Ví dụ tham khảo, cần điều chỉnh theo yêu cầu thực tế:

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function signedIn() {
      return request.auth != null;
    }

    function isAdmin() {
      return signedIn()
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "admin";
    }

    match /users/{userId} {
      allow read: if signedIn() && (request.auth.uid == userId || isAdmin());
      allow create: if signedIn() && request.auth.uid == userId;
      allow update: if (
        signedIn()
        && request.auth.uid == userId
        && !request.resource.data.diff(resource.data).affectedKeys().hasAny(["role"])
      ) || isAdmin();
      allow delete: if isAdmin();

      match /addresses/{addressId} {
        allow read, write: if signedIn() && request.auth.uid == userId;
      }
    }

    match /categories/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /foods/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /restaurants/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }

    match /orders/{id} {
      allow create: if signedIn() && request.resource.data.userId == request.auth.uid;
      allow read: if signedIn() && (resource.data.userId == request.auth.uid || isAdmin());
      allow update, delete: if isAdmin();
    }

    match /favorites/{id} {
      allow read, delete: if signedIn() && resource.data.userId == request.auth.uid;
      allow create: if signedIn() && request.resource.data.userId == request.auth.uid;
    }

    match /notifications/{id} {
      allow read, update, delete: if signedIn() && resource.data.userId == request.auth.uid;
      allow create: if isAdmin();
    }

    match /special_offers/{id} {
      allow read: if true;
      allow write: if isAdmin();
    }
  }
}
```


