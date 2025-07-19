package api

import (
	"vehicle-sales-backend/internal/config"
	"vehicle-sales-backend/internal/handlers"
	"vehicle-sales-backend/internal/middleware"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App, config *config.Config) {
	// Initialize handlers
	authHandler := handlers.NewAuthHandler(config)
	vehicleHandler := handlers.NewVehicleHandler()

	// API group
	api := app.Group("/api/v1")

	// Health check (public)
	api.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
			"message": "Vehicle Sales API is running",
		})
	})

	// Public routes
	api.Post("/auth/login", authHandler.Login)
	api.Post("/auth/register", authHandler.Register)

	// Public vehicle routes (for customers to browse)
	api.Get("/vehicles", vehicleHandler.GetVehicles)
	api.Get("/vehicles/:id", vehicleHandler.GetVehicle)

	// Protected routes
	protected := api.Group("", middleware.AuthRequired(config))

	// Vehicle management (Admin and Sales)
	vehicles := protected.Group("/vehicles")
	vehicles.Post("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), vehicleHandler.CreateVehicle)
	vehicles.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), vehicleHandler.UpdateVehicle)
	vehicles.Delete("/:id", middleware.RoleRequired(models.RoleAdmin), vehicleHandler.DeleteVehicle)
}