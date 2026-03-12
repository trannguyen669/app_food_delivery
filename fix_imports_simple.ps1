# Script fix imports - Version đơn giản

Write-Host "Bat dau fix imports..." -ForegroundColor Cyan

$count = 0

Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    $original = $content
    
    # Fix tất cả imports
    $content = $content -replace "screens/login_screen", "screens/auth/login_screen"
    $content = $content -replace "screens/signup_screen", "screens/auth/signup_screen"
    $content = $content -replace "screens/admin_dashboard_screen", "screens/admin/admin_dashboard_screen"
    $content = $content -replace "screens/admin_login_screen", "screens/admin/admin_login_screen"
    $content = $content -replace "screens/manage_foods_screen_modern", "screens/admin/manage_foods_screen_modern"
    $content = $content -replace "screens/manage_foods_screen", "screens/admin/manage_foods_screen"
    $content = $content -replace "screens/manage_orders_screen_new", "screens/admin/manage_orders_screen_new"
    $content = $content -replace "screens/manage_orders_screen", "screens/admin/manage_orders_screen"
    $content = $content -replace "screens/manage_users_screen_new", "screens/admin/manage_users_screen_new"
    $content = $content -replace "screens/manage_users_screen", "screens/admin/manage_users_screen"
    $content = $content -replace "screens/manage_categories_screen_new", "screens/admin/manage_categories_screen_new"
    $content = $content -replace "screens/manage_categories_screen", "screens/admin/manage_categories_screen"
    $content = $content -replace "screens/revenue_screen", "screens/admin/revenue_screen"
    $content = $content -replace "screens/home_screen", "screens/user/home_screen"
    $content = $content -replace "screens/cart_screen", "screens/user/cart_screen"
    $content = $content -replace "screens/checkout_screen", "screens/user/checkout_screen"
    $content = $content -replace "screens/favorites_screen", "screens/user/favorites_screen"
    $content = $content -replace "screens/notification_screen", "screens/user/notification_screen"
    $content = $content -replace "screens/profile_screen", "screens/user/profile_screen"
    $content = $content -replace "screens/chatbot_screen", "screens/user/chatbot_screen"
    $content = $content -replace "screens/category_detail_screen", "screens/product/category_detail_screen"
    $content = $content -replace "screens/product_detail_screen", "screens/product/product_detail_screen"
    $content = $content -replace "screens/restaurant_detail_screen", "screens/product/restaurant_detail_screen"
    $content = $content -replace "screens/search_screen", "screens/product/search_screen"
    $content = $content -replace "screens/order_history_screen", "screens/order/order_history_screen"
    $content = $content -replace "screens/order_detail_screen", "screens/order/order_detail_screen"
    $content = $content -replace "screens/order_screen", "screens/order/order_screen"
    $content = $content -replace "screens/address_list_screen", "screens/address/address_list_screen"
    $content = $content -replace "screens/add_edit_address_screen", "screens/address/add_edit_address_screen"
    $content = $content -replace "screens/about_screen", "screens/other/about_screen"
    
    if ($content -ne $original) {
        Set-Content $_.FullName -Value $content -NoNewline
        $count++
        Write-Host "  Fixed: $($_.Name)" -ForegroundColor Green
    }
}

Write-Host "`nDa fix $count files!" -ForegroundColor Cyan
Write-Host "Chay 'flutter analyze' de kiem tra!" -ForegroundColor Yellow
