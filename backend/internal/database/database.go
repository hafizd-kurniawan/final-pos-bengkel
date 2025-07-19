package database

import (
	"fmt"
	"log"

	"vehicle-sales-backend/internal/config"
	"vehicle-sales-backend/internal/models"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func Connect(config *config.Config) error {
	var err error
	
	DB, err = gorm.Open(postgres.Open(config.Database.URL), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	log.Println("Database connected successfully")
	return nil
}

func Migrate() error {
	err := DB.AutoMigrate(
		&models.User{},
		&models.Vehicle{},
		&models.VehicleImage{},
		&models.TestDrive{},
		&models.Sale{},
		&models.Transaction{},
		&models.Lead{},
	)
	
	if err != nil {
		return fmt.Errorf("failed to migrate database: %w", err)
	}

	log.Println("Database migration completed")
	return nil
}

func GetDB() *gorm.DB {
	return DB
}