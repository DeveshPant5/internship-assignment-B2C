# How to Run the App

Since you don't have Docker installed, the easiest way is to use the automated script I created.

### Option 1: Automated Script (Recommended)

Simply double-click `start_without_docker.bat` or run:

```cmd
.\start_without_docker.bat
```

This will automatically:
1. Open 4 new terminal windows for the backend services.
2. Install dependencies (`pip install`).
3. specific each service (`uvicorn`).
4. Launch the Flutter frontend in the main window.

---

### Option 2: Run Manually (Terminal by Terminal)

If the script doesn't work, open **5 separate terminal windows** and run these commands:

#### Terminal 1: User Service
```bash
cd backend/user_service
pip install -r requirements.txt
uvicorn main:app --port 8001 --reload
```

#### Terminal 2: Product Service
```bash
cd backend/product_service
pip install -r requirements.txt
python seed.py
uvicorn main:app --port 8002 --reload
```

#### Terminal 3: Cart Order Service
```bash
cd backend/cart_order_service
pip install -r requirements.txt
uvicorn main:app --port 8003 --reload
```

#### Terminal 4: Delivery Service
```bash
cd backend/delivery_service
pip install -r requirements.txt
uvicorn main:app --port 8004 --reload
```

#### Terminal 5: Flutter Frontend
```bash
cd flutter_app
flutter run
```
