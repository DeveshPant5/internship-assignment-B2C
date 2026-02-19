Write-Host "Starting ThriftApp Full Stack..." -ForegroundColor Cyan

# 1. Start Backend Services in a new window
Write-Host "Launching Backend (Docker Compose)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit'; docker-compose up --build"

# Wait a moment for backend to potentially start initializing
Start-Sleep -Seconds 5

# 2. Start Flutter Frontend in a new window
Write-Host "Launching Flutter Frontend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit\flutter_app'; flutter run"

Write-Host "All commands issued! Check the new windows." -ForegroundColor Green
