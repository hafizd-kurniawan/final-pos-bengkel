# Vehicle Sales Management System MVP

A comprehensive Vehicle Sales Management System built with Golang backend and Flutter frontend, featuring role-based access control and modern UI/UX design.

## 🚀 Features

### Backend (Golang + Fiber + PostgreSQL)
- ✅ **REST API** with JWT authentication
- ✅ **Role-based access control** (Admin, Sales, Cashier, Customer)
- ✅ **Database schema** with GORM migrations
- ✅ **CRUD operations** for all entities
- ✅ **Secure authentication** with bcrypt password hashing
- ✅ **CORS support** for cross-origin requests

### Frontend (Flutter App)
- ✅ **Modern Material Design 3** UI/UX
- ✅ **Role-based dashboard** and navigation
- ✅ **Clean architecture** with BLoC pattern
- ✅ **Responsive design** for mobile and web
- 🔄 **State management** with BLoC
- 🔄 **HTTP client** with Dio
- 🔄 **Local storage** with Hive
- 🔄 **Camera integration** for photos

### Key Features Implemented

#### 1. **Authentication System**
- ✅ User registration and login
- ✅ JWT token management
- ✅ Role-based authorization
- ✅ Password encryption

#### 2. **User Management**
- ✅ Multiple user roles (Admin, Sales, Cashier, Customer)
- ✅ User profile management
- ✅ Role-based permissions

#### 3. **Vehicle Management**
- ✅ Vehicle CRUD operations
- ✅ Vehicle status tracking (Available, Sold, Reserved, Service)
- ✅ Vehicle image management
- ✅ Vehicle search and filtering

#### 4. **Database Schema**
- ✅ Users and roles
- ✅ Vehicles and images
- ✅ Sales and transactions
- ✅ Test drive bookings
- ✅ Lead management

## 🛠️ Tech Stack

### Backend
- **Framework**: Fiber (Go)
- **Database**: PostgreSQL
- **ORM**: GORM
- **Authentication**: JWT
- **Password**: bcrypt
- **Environment**: godotenv

### Frontend
- **Framework**: Flutter
- **State Management**: BLoC
- **HTTP Client**: Dio
- **Local Storage**: Hive
- **Navigation**: GoRouter
- **UI**: Material Design 3

## 📋 Prerequisites

- Go 1.21+
- Flutter 3.0+
- PostgreSQL 15+
- Docker & Docker Compose (optional)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/hafizd-kurniawan/final-pos-bengkel.git
cd final-pos-bengkel
```

### 2. Backend Setup

#### Using Docker (Recommended)
```bash
# Start PostgreSQL with Docker Compose
docker-compose up postgres -d

# Navigate to backend directory
cd backend

# Copy environment file
cp .env.example .env

# Install dependencies
go mod tidy

# Run database migrations and seed data
go run cmd/seed/main.go

# Start the server
go run main.go
```

#### Manual Setup
```bash
# Install PostgreSQL and create database
createdb vehicle_sales

# Navigate to backend directory
cd backend

# Copy environment file and update database credentials
cp .env.example .env

# Install dependencies
go mod tidy

# Run database migrations and seed data
go run cmd/seed/main.go

# Start the server
go run main.go
```

The backend server will start on `http://localhost:8080`

### 3. Frontend Setup
```bash
# Navigate to Flutter app directory
cd flutter_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## 📚 API Documentation

### Authentication Endpoints
```
POST /api/v1/auth/login
POST /api/v1/auth/register
```

### Vehicle Endpoints
```
GET    /api/v1/vehicles           # Get all vehicles (public)
GET    /api/v1/vehicles/:id       # Get vehicle by ID (public)
POST   /api/v1/vehicles           # Create vehicle (Admin/Sales)
PUT    /api/v1/vehicles/:id       # Update vehicle (Admin/Sales)
DELETE /api/v1/vehicles/:id       # Delete vehicle (Admin only)
```

### Health Check
```
GET /api/v1/health
```

## 👥 Default Users

The system comes with pre-seeded users for testing:

| Role     | Email                    | Password | Permissions |
|----------|--------------------------|----------|-------------|
| Admin    | admin@vehiclesales.com   | admin123 | Full access |
| Sales    | sales@vehiclesales.com   | admin123 | Vehicle management, customer interaction |
| Cashier  | cashier@vehiclesales.com | admin123 | Transaction processing |
| Customer | customer@vehiclesales.com| admin123 | Vehicle browsing, test drives |

## 🏗️ Project Structure

### Backend Structure
```
backend/
├── cmd/
│   └── seed/           # Database seeding
├── internal/
│   ├── api/           # API routes
│   ├── auth/          # JWT authentication
│   ├── config/        # Configuration management
│   ├── database/      # Database connection
│   ├── handlers/      # HTTP handlers
│   ├── middleware/    # HTTP middleware
│   ├── models/        # Data models
│   └── services/      # Business logic
├── migrations/        # Database migrations
├── .env              # Environment variables
├── main.go           # Application entry point
└── Dockerfile        # Docker configuration
```

### Frontend Structure
```
flutter_app/
├── lib/
│   ├── core/
│   │   ├── constants/  # App constants
│   │   ├── theme/      # App theming
│   │   └── utils/      # Utility functions
│   ├── data/
│   │   ├── models/     # Data models
│   │   ├── repositories/ # Data repositories
│   │   └── datasources/ # Data sources
│   ├── domain/
│   │   ├── entities/   # Domain entities
│   │   ├── repositories/ # Repository interfaces
│   │   └── usecases/   # Use cases
│   ├── presentation/
│   │   ├── pages/      # UI pages
│   │   ├── widgets/    # Reusable widgets
│   │   └── bloc/       # BLoC state management
│   └── main.dart      # App entry point
└── pubspec.yaml       # Dependencies
```

## 🔧 Development

### Backend Development
```bash
cd backend

# Run with hot reload (using air - install first)
go install github.com/cosmtrek/air@latest
air

# Run tests
go test ./...

# Build for production
go build -o vehicle-sales-backend
```

### Frontend Development
```bash
cd flutter_app

# Run with hot reload
flutter run

# Build for production
flutter build web
flutter build apk
```

## 🐳 Docker Deployment

### Full Stack with Docker Compose
```bash
# Build and start all services
docker-compose up --build

# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 🔒 Security Features

- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt for secure password storage
- **Role-based Authorization**: Granular permission control
- **CORS Protection**: Configurable cross-origin request handling
- **Input Validation**: Request body validation and sanitization

## 📱 UI/UX Features

- **Material Design 3**: Modern and consistent design system
- **Responsive Layout**: Works on mobile, tablet, and desktop
- **Dark/Light Theme**: System-based theme switching
- **Smooth Animations**: Enhanced user experience with animations
- **Role-based Navigation**: Different UI based on user roles
- **Professional Color Scheme**: Carefully chosen colors for business use

## 🔄 Current Status

### ✅ Completed Features
- Backend API foundation
- Database schema and models
- JWT authentication system
- Role-based access control
- Vehicle CRUD operations
- Flutter app structure
- Material Design 3 theming
- Basic navigation and UI components

### 🔄 In Progress
- Complete Flutter app implementation
- BLoC state management
- HTTP client integration
- Local storage with Hive
- Camera integration
- Real-time updates

### 📋 Planned Features
- Sales dashboard and analytics
- Transaction processing
- Test drive booking system
- Lead management
- Reporting and analytics
- Mobile app deployment
- Web app deployment

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 📞 Support

For questions or support, please open an issue in the GitHub repository.
