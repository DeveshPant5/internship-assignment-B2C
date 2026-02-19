Write-Host "Starting ThriftApp Microservices Individually..." -ForegroundColor Cyan

# 1. MongoDB (Docker)
Write-Host "Starting MongoDB (Docker)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "docker run -p 27017:27017 --name winkit-mongo-local mongo:7"

# Wait for MongoDB to start
Start-Sleep -Seconds 5

# 2. User Service (Port 8001)
Write-Host "Launching User Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit'; .venv\Scripts\activate; cd backend\user_service; pip install -r requirements.txt; uvicorn main:app --port 8001 --reload"

# 3. Product Service (Port 8002)
Write-Host "Launching Product Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit'; .venv\Scripts\activate; cd backend\product_service; pip install -r requirements.txt; uvicorn main:app --port 8002 --reload"

# 4. Cart Order Service (Port 8003)
Write-Host "Launching Cart/Order Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit'; .venv\Scripts\activate; cd backend\cart_order_service; pip install -r requirements.txt; uvicorn main:app --port 8003 --reload"

# 5. Delivery Service (Port 8004)
Write-Host "Launching Delivery Service..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd 'C:\Users\deves\OneDrive\Desktop\Winkit'; .venv\Scripts\activate; cd backend\delivery_service; pip install -r requirements.txt; uvicorn main:app --port 8004 --reload"

Write-Host "All services launched in separate windows!" -ForegroundColor Cyan
