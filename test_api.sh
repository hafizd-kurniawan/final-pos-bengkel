#!/bin/bash

# Backend API Test Script
echo "🚀 Testing Vehicle Sales Management System Backend API"
echo "=============================================="

BASE_URL="http://localhost:8080/api/v1"

# Test health endpoint
echo -e "\n📊 Testing Health Endpoint..."
curl -X GET "$BASE_URL/health" \
  -H "Content-Type: application/json" \
  -w "\nStatus: %{http_code}\n" \
  -s

# Test user registration
echo -e "\n👤 Testing User Registration..."
REGISTER_RESPONSE=$(curl -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "test123",
    "name": "Test User",
    "phone": "+1234567890",
    "role": "customer"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$REGISTER_RESPONSE"

# Test user login
echo -e "\n🔐 Testing User Login..."
LOGIN_RESPONSE=$(curl -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@vehiclesales.com",
    "password": "admin123"
  }' \
  -w "\nStatus: %{http_code}\n" \
  -s)

echo "$LOGIN_RESPONSE"

# Extract token for authenticated requests
TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token' 2>/dev/null)

if [ "$TOKEN" != "null" ] && [ "$TOKEN" != "" ]; then
  echo -e "\n🔑 Token extracted: ${TOKEN:0:50}..."
  
  # Test vehicles endpoint (public)
  echo -e "\n🚗 Testing Vehicles Endpoint (Public)..."
  curl -X GET "$BASE_URL/vehicles" \
    -H "Content-Type: application/json" \
    -w "\nStatus: %{http_code}\n" \
    -s | jq .
  
  # Test creating a vehicle (authenticated)
  echo -e "\n➕ Testing Create Vehicle (Admin)..."
  curl -X POST "$BASE_URL/vehicles" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d '{
      "make": "Tesla",
      "model": "Model 3",
      "year": 2024,
      "color": "Red",
      "vin": "TEST123456789",
      "price": 45000.00,
      "mileage": 100,
      "description": "Brand new Tesla Model 3 with autopilot"
    }' \
    -w "\nStatus: %{http_code}\n" \
    -s | jq .
    
else
  echo "❌ Failed to extract token, skipping authenticated tests"
fi

echo -e "\n✅ API Testing completed!"