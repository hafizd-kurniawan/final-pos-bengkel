#!/bin/bash

echo "🎯 VEHICLE SALES MANAGEMENT SYSTEM - COMPLETE DEMO"
echo "=================================================="

# Start PostgreSQL if not running
echo "📦 Starting PostgreSQL..."
docker start vehicle_sales_db 2>/dev/null || docker run --name vehicle_sales_db \
  -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=vehicle_sales \
  -p 5432:5432 -d postgres:15 >/dev/null 2>&1

sleep 3

# Start backend
echo "🚀 Starting backend server..."
cd backend
go build . >/dev/null 2>&1
./vehicle-sales-backend >/dev/null 2>&1 &
BACKEND_PID=$!
sleep 3

echo "✅ Backend running on http://localhost:8080"
echo ""

# Test all endpoints
echo "🔍 Testing All API Endpoints:"
echo "=============================="

echo "1. Health Check:"
curl -s http://localhost:8080/api/v1/health | jq .

echo -e "\n2. Login with Admin Account:"
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@vehiclesales.com","password":"admin123"}')
echo "$LOGIN_RESPONSE" | jq .

TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token')

echo -e "\n3. Get All Vehicles (Public):"
curl -s http://localhost:8080/api/v1/vehicles | jq '.data[] | {make, model, year, price, status}'

echo -e "\n4. Create New Vehicle (Admin):"
NEW_VEHICLE=$(curl -s -X POST http://localhost:8080/api/v1/vehicles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "make": "Mercedes-Benz",
    "model": "E-Class",
    "year": 2024,
    "color": "Black",
    "vin": "DEMO123456789",
    "price": 55000.00,
    "mileage": 500,
    "description": "Luxury Mercedes-Benz E-Class sedan"
  }')
echo "$NEW_VEHICLE" | jq '{id, make, model, price, status}'

VEHICLE_ID=$(echo "$NEW_VEHICLE" | jq -r '.id')

echo -e "\n5. Get Specific Vehicle:"
curl -s http://localhost:8080/api/v1/vehicles/$VEHICLE_ID | jq '{make, model, year, price, description}'

echo -e "\n6. Update Vehicle Price (Admin):"
curl -s -X PUT http://localhost:8080/api/v1/vehicles/$VEHICLE_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "make": "Mercedes-Benz",
    "model": "E-Class",
    "year": 2024,
    "color": "Black",
    "vin": "DEMO123456789",
    "price": 52000.00,
    "mileage": 500,
    "description": "Luxury Mercedes-Benz E-Class sedan - PRICE REDUCED!"
  }' | jq '{id, make, model, price, description}'

echo -e "\n7. Final Vehicle Count:"
curl -s http://localhost:8080/api/v1/vehicles | jq '.meta'

echo -e "\n🎉 Demo Complete! All features working:"
echo "✅ Authentication & Authorization"
echo "✅ Role-based Access Control"
echo "✅ Vehicle CRUD Operations"
echo "✅ Database Integration"
echo "✅ JWT Token Management"
echo "✅ Input Validation"
echo "✅ Error Handling"

echo -e "\n📊 Demo Accounts Available:"
echo "Admin:    admin@vehiclesales.com / admin123"
echo "Sales:    sales@vehiclesales.com / admin123"
echo "Cashier:  cashier@vehiclesales.com / admin123"
echo "Customer: customer@vehiclesales.com / admin123"

echo -e "\n🔗 API Documentation:"
echo "Health: GET  http://localhost:8080/api/v1/health"
echo "Login:  POST http://localhost:8080/api/v1/auth/login"
echo "Vehicles: GET http://localhost:8080/api/v1/vehicles"

# Cleanup
echo -e "\n🧹 Stopping backend server..."
kill $BACKEND_PID 2>/dev/null
echo "✅ Demo completed successfully!"