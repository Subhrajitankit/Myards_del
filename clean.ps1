# Flutter Clean Helper Script
# Run this instead of 'flutter clean' if you get the "Failed to remove build" error

Write-Host "Stopping locking processes..." -ForegroundColor Yellow
Stop-Process -Name "java","adb","gradle","dart","flutter_tools","androidstudio64","studio64" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Force-removing build folders..." -ForegroundColor Yellow
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".dart_tool" -ErrorAction SilentlyContinue

Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

Write-Host "Done! You can now run: flutter run" -ForegroundColor Green
