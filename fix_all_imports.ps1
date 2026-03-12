# Script fix all imports after screens reorganization
$ErrorActionPreference = 'Stop'

# Mapping: screen filename -> folder name
$screenMapping = @{
    'login_screen' = 'auth'
    'signup_screen' = 'auth'
    'admin_dashboard_screen' = 'admin'
    'admin_login_screen' = 'admin'
    'manage_categories_screen' = 'admin'
    'manage_categories_screen_new' = 'admin'
    'manage_foods_screen' = 'admin'
    'manage_foods_screen_modern' = 'admin'
    'manage_orders_screen' = 'admin'
    'manage_orders_screen_new' = 'admin'
    'manage_restaurants_screen' = 'admin'
    'manage_users_screen' = 'admin'
    'manage_users_screen_new' = 'admin'
    'revenue_screen' = 'admin'
    'home_screen' = 'user'
    'cart_screen' = 'user'
    'checkout_screen' = 'user'
    'favorites_screen' = 'user'
    'notification_screen' = 'user'
    'profile_screen' = 'user'
    'chatbot_screen' = 'user'
    'category_detail_screen' = 'product'
    'product_detail_screen' = 'product'
    'restaurant_detail_screen' = 'product'
    'search_screen' = 'product'
    'order_screen' = 'order'
    'order_history_screen' = 'order'
    'order_detail_screen' = 'order'
    'address_list_screen' = 'address'
    'add_edit_address_screen' = 'address'
    'about_screen' = 'other'
}

function Fix-ImportsInFile {
    param (
        [string]$filePath
    )
    
    if (-not (Test-Path $filePath)) {
        return $false
    }
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Fix imports for screens
    foreach ($screenName in $screenMapping.Keys) {
        $folder = $screenMapping[$screenName]
        
        # Pattern: import 'screens/filename.dart' -> import 'screens/folder/filename.dart'
        $pattern1 = "import\s+'screens/${screenName}\.dart'"
        $replace1 = "import 'screens/${folder}/${screenName}.dart'"
        $content = $content -replace $pattern1, $replace1
        
        # Pattern: import '../screens/filename.dart' -> import '../screens/folder/filename.dart'  
        $pattern2 = "import\s+'\.\./screens/${screenName}\.dart'"
        $replace2 = "import '../screens/${folder}/${screenName}.dart'"
        $content = $content -replace $pattern2, $replace2
        
        # Pattern: import 'filename.dart' (within screens folder)
        if ($filePath -like "*\lib\screens\*") {
            $currentFileFolder = ""
            foreach ($name in $screenMapping.Keys) {
                if ($filePath -like "*\${name}.dart") {
                    $currentFileFolder = $screenMapping[$name]
                    break
                }
            }
            
            if ($currentFileFolder -and $currentFileFolder -ne $folder) {
                $pattern3 = "import\s+'${screenName}\.dart'"
                $replace3 = "import '../${folder}/${screenName}.dart'"
                $content = $content -replace $pattern3, $replace3
            }
        }
    }
    
    # Fix imports for services, providers, models, widgets from screens subfolders
    if ($filePath -like "*\lib\screens\*\*") {
        # File is in screens/subfolder/ - need to go up 2 levels
        $content = $content -replace "import\s+'\.\./(services|providers|models|widgets)/", "import '../../`$1/"
    }
    
    # Save if changed
    if ($content -ne $originalContent) {
        $content | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline
        Write-Host "[OK] Fixed: $filePath" -ForegroundColor Green
        return $true
    }
    
    return $false
}

Write-Host "Fixing imports in all Dart files..." -ForegroundColor Cyan

$fixedCount = 0

# Fix in all Dart files
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | ForEach-Object {
    if (Fix-ImportsInFile -filePath $_.FullName) {
        $fixedCount++
    }
}

Write-Host ""
Write-Host "Done! Fixed $fixedCount files!" -ForegroundColor Green
Write-Host "Run flutter analyze to check for remaining issues" -ForegroundColor Yellow
