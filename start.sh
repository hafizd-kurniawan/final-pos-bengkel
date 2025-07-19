#!/bin/bash

echo "🚀 Starting Vehicle Sales Management System"
echo "=========================================="

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "📦 Starting PostgreSQL with Docker..."
    
    # Start PostgreSQL container
    docker run --name vehicle_sales_db \
        -e POSTGRES_USER=postgres \
        -e POSTGRES_PASSWORD=password \
        -e POSTGRES_DB=vehicle_sales \
        -p 5432:5432 \
        -d postgres:15 || true
    
    echo "⏳ Waiting for PostgreSQL to start..."
    sleep 5
    
else
    echo "⚠️  Docker not found. Please ensure PostgreSQL is running on localhost:5432"
    echo "   Database: vehicle_sales"
    echo "   User: postgres"
    echo "   Password: password"
fi

echo "🔧 Building backend..."
cd backend
go build .

echo "🌱 Seeding database..."
go run cmd/seed/main.go

echo "🚀 Starting backend server..."
echo "API will be available at: http://localhost:8080"
echo "Health check: http://localhost:8080/api/v1/health"
echo ""
echo "Demo accounts:"
echo "  Admin: admin@vehiclesales.com / admin123"
echo "  Sales: sales@vehiclesales.com / admin123"
echo "  Cashier: cashier@vehiclesales.com / admin123"
echo "  Customer: customer@vehiclesales.com / admin123"
echo ""
echo "Press Ctrl+C to stop the server"
echo "=================================="

./vehicle-sales-backend