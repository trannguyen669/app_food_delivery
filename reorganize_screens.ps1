# Script để tái cấu trúc thư mục screens

$screensPath = "d:\LapTrinhMobile\food_delivery_app\lib\screens"

# Di chuyển các màn hình AUTH
Write-Host "Di chuyen cac man hinh AUTH..." -ForegroundColor Green
Move-Item "$screensPath\login_screen.dart" "$screensPath\auth\login_screen.dart" -Force
Move-Item "$screensPath\signup_screen.dart" "$screensPath\auth\signup_screen.dart" -Force

# Di chuyển các màn hình ADMIN
Write-Host "Di chuyen cac man hinh ADMIN..." -ForegroundColor Green
Move-Item "$screensPath\admin_dashboard_screen.dart" "$screensPath\admin\admin_dashboard_screen.dart" -Force
Move-Item "$screensPath\admin_login_screen.dart" "$screensPath\admin\admin_login_screen.dart" -Force
Move-Item "$screensPath\manage_categories_screen.dart" "$screensPath\admin\manage_categories_screen.dart" -Force
Move-Item "$screensPath\manage_categories_screen_new.dart" "$screensPath\admin\manage_categories_screen_new.dart" -Force
Move-Item "$screensPath\manage_foods_screen.dart" "$screensPath\admin\manage_foods_screen.dart" -Force
Move-Item "$screensPath\manage_foods_screen_modern.dart" "$screensPath\admin\manage_foods_screen_modern.dart" -Force
Move-Item "$screensPath\manage_orders_screen.dart" "$screensPath\admin\manage_orders_screen.dart" -Force
Move-Item "$screensPath\manage_orders_screen_new.dart" "$screensPath\admin\manage_orders_screen_new.dart" -Force
Move-Item "$screensPath\manage_users_screen.dart" "$screensPath\admin\manage_users_screen.dart" -Force
Move-Item "$screensPath\manage_users_screen_new.dart" "$screensPath\admin\manage_users_screen_new.dart" -Force
Move-Item "$screensPath\revenue_screen.dart" "$screensPath\admin\revenue_screen.dart" -Force

# Di chuyển các màn hình USER
Write-Host "Di chuyen cac man hinh USER..." -ForegroundColor Green
Move-Item "$screensPath\home_screen.dart" "$screensPath\user\home_screen.dart" -Force
Move-Item "$screensPath\cart_screen.dart" "$screensPath\user\cart_screen.dart" -Force
Move-Item "$screensPath\checkout_screen.dart" "$screensPath\user\checkout_screen.dart" -Force
Move-Item "$screensPath\favorites_screen.dart" "$screensPath\user\favorites_screen.dart" -Force
Move-Item "$screensPath\notification_screen.dart" "$screensPath\user\notification_screen.dart" -Force
Move-Item "$screensPath\profile_screen.dart" "$screensPath\user\profile_screen.dart" -Force
Move-Item "$screensPath\chatbot_screen.dart" "$screensPath\user\chatbot_screen.dart" -Force

# Di chuyển các màn hình PRODUCT
Write-Host "Di chuyen cac man hinh PRODUCT..." -ForegroundColor Green
Move-Item "$screensPath\category_detail_screen.dart" "$screensPath\product\category_detail_screen.dart" -Force
Move-Item "$screensPath\product_detail_screen.dart" "$screensPath\product\product_detail_screen.dart" -Force
Move-Item "$screensPath\restaurant_detail_screen.dart" "$screensPath\product\restaurant_detail_screen.dart" -Force
Move-Item "$screensPath\search_screen.dart" "$screensPath\product\search_screen.dart" -Force

# Di chuyển các màn hình ORDER
Write-Host "Di chuyen cac man hinh ORDER..." -ForegroundColor Green
Move-Item "$screensPath\order_screen.dart" "$screensPath\order\order_screen.dart" -Force
Move-Item "$screensPath\order_history_screen.dart" "$screensPath\order\order_history_screen.dart" -Force
Move-Item "$screensPath\order_detail_screen.dart" "$screensPath\order\order_detail_screen.dart" -Force

# Di chuyển các màn hình ADDRESS
Write-Host "Di chuyen cac man hinh ADDRESS..." -ForegroundColor Green
Move-Item "$screensPath\address_list_screen.dart" "$screensPath\address\address_list_screen.dart" -Force
Move-Item "$screensPath\add_edit_address_screen.dart" "$screensPath\address\add_edit_address_screen.dart" -Force

# Di chuyển các màn hình OTHER
Write-Host "Di chuyen cac man hinh OTHER..." -ForegroundColor Green
Move-Item "$screensPath\about_screen.dart" "$screensPath\other\about_screen.dart" -Force

Write-Host "`nHoan thanh! Cau truc moi:" -ForegroundColor Cyan
Write-Host "screens/" -ForegroundColor Yellow
Write-Host "  |-- auth/           (Xac thuc)" -ForegroundColor Yellow
Write-Host "  |-- admin/          (Quan tri)" -ForegroundColor Yellow
Write-Host "  |-- user/           (Nguoi dung)" -ForegroundColor Yellow
Write-Host "  |-- product/        (San pham)" -ForegroundColor Yellow
Write-Host "  |-- order/          (Don hang)" -ForegroundColor Yellow
Write-Host "  |-- address/        (Dia chi)" -ForegroundColor Yellow
Write-Host "  \-- other/          (Khac)" -ForegroundColor Yellow
