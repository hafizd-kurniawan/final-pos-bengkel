package main

import (
	"log"
	"vehicle-sales-backend/internal/auth"
	"vehicle-sales-backend/internal/config"
	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"
)

func main() {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatal("Failed to load configuration:", err)
	}

	// Connect to database
	if err := database.Connect(cfg); err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Run migrations
	if err := database.Migrate(); err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Create admin user
	hashedPassword, err := auth.HashPassword("admin123")
	if err != nil {
		log.Fatal("Failed to hash password:", err)
	}

	admin := models.User{
		Email:    "admin@vehiclesales.com",
		Password: hashedPassword,
		Name:     "System Administrator",
		Phone:    "+1234567890",
		Role:     models.RoleAdmin,
		IsActive: true,
	}

	// Check if admin already exists
	var existingAdmin models.User
	if err := database.DB.Where("email = ?", admin.Email).First(&existingAdmin).Error; err == nil {
		log.Println("Admin user already exists")
		return
	}

	if err := database.DB.Create(&admin).Error; err != nil {
		log.Fatal("Failed to create admin user:", err)
	}

	log.Printf("Admin user created successfully:")
	log.Printf("Email: %s", admin.Email)
	log.Printf("Password: admin123")
	log.Printf("Role: %s", admin.Role)

	// Create sample users for different roles
	users := []models.User{
		{
			Email:    "sales@vehiclesales.com",
			Password: hashedPassword,
			Name:     "John Sales",
			Phone:    "+1234567891",
			Role:     models.RoleSales,
			IsActive: true,
		},
		{
			Email:    "cashier@vehiclesales.com",
			Password: hashedPassword,
			Name:     "Jane Cashier",
			Phone:    "+1234567892",
			Role:     models.RoleCashier,
			IsActive: true,
		},
		{
			Email:    "customer@vehiclesales.com",
			Password: hashedPassword,
			Name:     "Bob Customer",
			Phone:    "+1234567893",
			Role:     models.RoleCustomer,
			IsActive: true,
		},
	}

	for _, user := range users {
		var existing models.User
		if err := database.DB.Where("email = ?", user.Email).First(&existing).Error; err == nil {
			log.Printf("User %s already exists", user.Email)
			continue
		}

		if err := database.DB.Create(&user).Error; err != nil {
			log.Printf("Failed to create user %s: %v", user.Email, err)
		} else {
			log.Printf("User %s created successfully", user.Email)
		}
	}

	// Create sample vehicles
	vehicles := []models.Vehicle{
		{
			Make:        "Toyota",
			Model:       "Camry",
			Year:        2023,
			Color:       "Silver",
			VIN:         "1HGBH41JXMN109186",
			Price:       28500.00,
			Mileage:     15000,
			Status:      models.VehicleStatusAvailable,
			Description: "Well-maintained Toyota Camry with excellent fuel economy",
		},
		{
			Make:        "Honda",
			Model:       "CR-V",
			Year:        2022,
			Color:       "Black",
			VIN:         "2HGBH41JXMN109187",
			Price:       32000.00,
			Mileage:     22000,
			Status:      models.VehicleStatusAvailable,
			Description: "Reliable Honda CR-V SUV perfect for families",
		},
		{
			Make:        "BMW",
			Model:       "X5",
			Year:        2023,
			Color:       "White",
			VIN:         "3HGBH41JXMN109188",
			Price:       65000.00,
			Mileage:     8000,
			Status:      models.VehicleStatusAvailable,
			Description: "Luxury BMW X5 with premium features and performance",
		},
	}

	for _, vehicle := range vehicles {
		var existing models.Vehicle
		if err := database.DB.Where("vin = ?", vehicle.VIN).First(&existing).Error; err == nil {
			log.Printf("Vehicle %s already exists", vehicle.VIN)
			continue
		}

		if err := database.DB.Create(&vehicle).Error; err != nil {
			log.Printf("Failed to create vehicle %s: %v", vehicle.VIN, err)
		} else {
			log.Printf("Vehicle %s %s created successfully", vehicle.Make, vehicle.Model)
		}
	}

	log.Println("Database seeding completed!")
}