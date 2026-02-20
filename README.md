 Winkit Architecture & Documentation

 Overall Architecture
The Winkit system is built using a "Microservices Architecture" for the backend and a "Flutter" application for the frontend. The backend services are written in "Python (FastAPI)" and are containerized using Docker. 

The system uses MongoDB" as its primary database, mapping different data domains to separate collections (`users`, `products`, `cart_items`, `orders`, `delivery_statuses`). All services and the database are orchestrated locally using `docker-compose`. There is also a `k8s` directory indicating support for Kubernetes deployments.

There is no API Gateway; the Flutter frontend communicates directly with the individual microservices exposed on different ports.

## Service Responsibilities

 1. User Service (Port 8001)
*   **Responsibility:** Handles user authentication, registration, and profile management.
*   **Database Collections:** `users`

 2. Product Catalog Service (Port 8002)
*   **Responsibility:** Manages the product catalog, serving product listings, details, and categories.
*   **Database Collections:** `products`

 3. Cart & Order Service (Port 8003)
*   **Responsibility:** Manages user shopping carts and processes order creations. Groups cart items into formal orders.
*   **Database Collections:** `cart_items`, `orders`

 4. Delivery & Order Status Service (Port 8004)
*   **Responsibility:** Tracks and updates the delivery status of created orders.
*   **Database Collections:** `delivery_statuses`

API List

 User Service (`http://localhost:8001`)
*   `GET /` - Root status check
*   `GET /health` - Health check
*   `POST /register` - Register a new user (Requires OTP)
*   `POST /login` - Authenticate a user and receive a Bearer token
*   `GET /profile?user_id={id}` - Retrieve user profile by ID

 Product Catalog Service (`http://localhost:8002`)
*   `GET /` - Root status check
*   `GET /health` - Health check
*   `GET /products` - Get all products (supports optional `?category=` filter)
*   `GET /products/{product_id}` - Get details of a specific product
*   `GET /categories` - Get a list of all product categories and their item counts

 Cart & Order Service (`http://localhost:8003`)
*   `GET /` - Root status check
*   `GET /health` - Health check
*   `GET /cart?user_id={id}` - Retrieve a user's cart items
*   `POST /cart/add` - Add an item to the cart
*   `POST /cart/remove` - Remove an item from the cart
*   `GET /orders?user_id={id}` - Retrieve a user's order history
*   `POST /order/create` - Checkout cart and create a new order

Delivery & Order Status Service (`http://localhost:8004`)
*   `GET /` - Root status check
*   `GET /health` - Health check
*   `GET /order/{order_id}/status` - Get the current delivery status of an order
*   `POST /order/{order_id}/update-status` - Advance the delivery status of an order (or set manually)

How to Run the System

 Prerequisites
*   **Docker** and **Docker Compose** installed.
*   **Flutter SDK** installed (for running the frontend).

 1. Start the Backend Services (Docker)
Open a terminal in the root directory (where `docker-compose.yml` is located) and run:
```bash
docker-compose up --build -d
```
This will start MongoDB on port `27017` and the 4 backend services on ports `8001` through `8004`. The `-d` flag runs them in the background.

 2. Start the Frontend App (Flutter)
Open a new terminal, navigate to the `flutter_app` directory, and run the app:
```bash
cd flutter_app
flutter run
```

 Known Limitations

1.  **Security & Authentication:** 
    *   The `User Service` generates tokens, but other services (`Cart`, `Order`, `Delivery`) do not strictly validate these JWT Bearer tokens. They currently rely primarily on `user_id` passed in queries or request bodies.
    *   OTP verification during registration uses a hardcoded mechanism (`1234`).
2.  **Shared Database Instance:** While collections are separated, all microservices connect to a single shared MongoDB database instance. In strict microservices environments, each service should arguably own and manage a completely isolated database to prevent tight coupling.
3.  **Missing API Gateway:** The frontend connects directly to each microservice's port. There is no unified API Gateway (like Nginx, Kong, or Traefik) handling routing, rate limiting, or centralized authentication.
4.  **No Inter-Service Communication:** Services seem to mostly rely on data passed from the frontend rather than communicating securely with each other via internal event buses (e.g., RabbitMQ/Kafka) or gRPC.
5.  **State Management:** Delivery status updates automatically transition linearly to the next status. There may not be robust failbacks if a status is incorrectly updated.
