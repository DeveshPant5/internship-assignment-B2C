@echo off
echo Starting ThriftApp without Docker (Using local venv)...

:: 1. User Service (Port 8001)
start "User Service" cmd /k "call .venv\Scripts\activate.bat && cd backend\user_service && pip install -r requirements.txt && uvicorn main:app --port 8001 --reload"

:: 2. Product Service (Port 8002)
start "Product Service" cmd /k "call .venv\Scripts\activate.bat && cd backend\product_service && pip install -r requirements.txt && python seed.py && uvicorn main:app --port 8002 --reload"

:: 3. Cart Order Service (Port 8003)
start "Cart/Order Service" cmd /k "call .venv\Scripts\activate.bat && cd backend\cart_order_service && pip install -r requirements.txt && uvicorn main:app --port 8003 --reload"

:: 4. Delivery Service (Port 8004)
start "Delivery Service" cmd /k "call .venv\Scripts\activate.bat && cd backend\delivery_service && pip install -r requirements.txt && uvicorn main:app --port 8004 --reload"

:: 5. Flutter Frontend
echo Launching Flutter Frontend...
cd flutter_app
flutter run

pause
