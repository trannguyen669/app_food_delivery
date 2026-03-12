# Script tự động fix imports sau khi tái cấu trúc screens

Write-Host "Bat dau fix imports..." -ForegroundColor Cyan

$filesFixed = 0
$totalChanges = 0

Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $originalContent = Get-Content $filePath -Raw
    $content = $originalContent
    
    # Fix AUTH
    $content = $content -replace "screens/login_screen\.dart", "screens/auth/login_screen.dart"
    $content = $content -replace "screens/signup_screen\.dart", "screens/auth/signup_screen.dart"
    
    # Fix ADMIN
    $content = $content -replace "screens/admin_dashboard_screen\.dart", "screens/admin/admin_dashboard_screen.dart"
    $content = $content -replace "screens/admin_login_screen\.dart", "screens/admin/admin_login_screen.dart"
    $content = $content -replace "screens/manage_foods_screen\.dart", "screens/admin/manage_foods_screen.dart"
    $content = $content -replace "screens/manage_foods_screen_modern\.dart", "screens/admin/manage_foods_screen_modern.dart"
    $content = $content -replace "screens/manage_orders_screen\.dart", "screens/admin/manage_orders_screen.dart"
    $content = $content -replace "screens/manage_orders_screen_new\.dart", "screens/admin/manage_orders_screen_new.dart"
    $content = $content -replace "screens/manage_users_screen\.dart", "screens/admin/manage_users_screen.dart"
    $content = $content -replace "screens/manage_users_screen_new\.dart", "screens/admin/manage_users_screen_new.dart"
    $content = $content -replace "screens/manage_categories_screen\.dart", "screens/admin/manage_categories_screen.dart"
    $content = $content -replace "screens/manage_categories_screen_new\.dart", "screens/admin/manage_categories_screen_new.dart"
    
    $content = $content -replace "import '(.*/)?screens/revenue_screen\.dart'", "import '`${1}screens/admin/revenue_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Fix USER
    $content = $content -replace "import '(.*/)?screens/home_screen\.dart'", "import '`${1}screens/user/home_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/cart_screen\.dart'", "import '`${1}screens/user/cart_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/checkout_screen\.dart'", "import '`${1}screens/user/checkout_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/favorites_screen\.dart'", "import '`${1}screens/user/favorites_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/notification_screen\.dart'", "import '`${1}screens/user/notification_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/profile_screen\.dart'", "import '`${1}screens/user/profile_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/chatbot_screen\.dart'", "import '`${1}screens/user/chatbot_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Fix PRODUCT
    $content = $content -replace "import '(.*/)?screens/category_detail_screen\.dart'", "import '`${1}screens/product/category_detail_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/product_detail_screen\.dart'", "import '`${1}screens/product/product_detail_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/restaurant_detail_screen\.dart'", "import '`${1}screens/product/restaurant_detail_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/search_screen\.dart'", "import '`${1}screens/product/search_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Fix ORDER
    $content = $content -replace "import '(.*/)?screens/order_screen\.dart'", "import '`${1}screens/order/order_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/order_history_screen\.dart'", "import '`${1}screens/order/order_history_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/order_detail_screen\.dart'", "import '`${1}screens/order/order_detail_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Fix ADDRESS
    $content = $content -replace "import '(.*/)?screens/address_list_screen\.dart'", "import '`${1}screens/address/address_list_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    $content = $content -replace "import '(.*/)?screens/add_edit_address_screen\.dart'", "import '`${1}screens/address/add_edit_address_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Fix OTHER
    $content = $content -replace "import '(.*/)?screens/about_screen\.dart'", "import '`${1}screens/other/about_screen.dart'"
    if ($content -ne $originalContent) { $replacements++; $originalContent = $content }
    
    # Lưu file nếu có thay đổi
    if ($content -ne (Get-Content $filePath -Raw)) {
        Set-Content $filePath -Value $content -NoNewline
        $filesFixed++
        $totalReplacements += $replacements
        Write-Host "  ✓ $($_.Name) - $replacements imports fixed" -ForegroundColor Green
    }
}

Write-Host "`n✅ Hoan thanh!" -ForegroundColor Cyan
Write-Host "  📁 Files da fix: $filesFixed" -ForegroundColor Yellow
Write-Host "  🔄 Tong so imports da thay doi: $totalReplacements" -ForegroundColor Yellow
Write-Host "`n🔍 Chay flutter analyze de kiem tra..." -ForegroundColor Cyan
