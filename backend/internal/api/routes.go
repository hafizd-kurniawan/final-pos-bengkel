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
	saleHandler := handlers.NewSaleHandler()
	testDriveHandler := handlers.NewTestDriveHandler()
	leadHandler := handlers.NewLeadHandler()
	userHandler := handlers.NewUserHandler()
	dashboardHandler := handlers.NewDashboardHandler()
	transactionHandler := handlers.NewTransactionHandler()

	// API group
	api := app.Group("/api/v1")

	// Health check (public)
	api.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{
			"status": "ok",
			"message": "Vehicle Sales API is running",
			"version": "1.0.0",
		})
	})

	// Public routes
	api.Post("/auth/login", authHandler.Login)
	api.Post("/auth/register", authHandler.Register)

	// Public vehicle routes (for customers to browse)
	api.Get("/vehicles", vehicleHandler.GetVehicles)
	api.Get("/vehicles/:id", vehicleHandler.GetVehicle)

	// Public lead creation (for website contact forms)
	api.Post("/leads", leadHandler.CreateLead)

	// Protected routes
	protected := api.Group("", middleware.AuthRequired(config))

	// User profile routes
	protected.Get("/profile", userHandler.GetProfile)
	protected.Put("/profile", userHandler.UpdateProfile)
	protected.Put("/profile/password", userHandler.ChangePassword)

	// Dashboard routes (All authenticated users)
	protected.Get("/dashboard", dashboardHandler.GetDashboard)
	protected.Get("/analytics", dashboardHandler.GetAnalytics)

	// Vehicle management routes
	vehicles := protected.Group("/vehicles")
	vehicles.Post("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), vehicleHandler.CreateVehicle)
	vehicles.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), vehicleHandler.UpdateVehicle)
	vehicles.Delete("/:id", middleware.RoleRequired(models.RoleAdmin), vehicleHandler.DeleteVehicle)

	// Sales management routes
	sales := protected.Group("/sales")
	sales.Get("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales, models.RoleCashier), saleHandler.GetSales)
	sales.Get("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales, models.RoleCashier), saleHandler.GetSale)
	sales.Post("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), saleHandler.CreateSale)
	sales.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), saleHandler.UpdateSale)
	sales.Delete("/:id", middleware.RoleRequired(models.RoleAdmin), saleHandler.DeleteSale)
	sales.Get("/analytics", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), saleHandler.GetSalesAnalytics)

	// Transaction management routes (Cashier and Admin)
	transactions := protected.Group("/transactions")
	transactions.Get("/", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.GetTransactions)
	transactions.Get("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.GetTransaction)
	transactions.Post("/", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.CreateTransaction)
	transactions.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.UpdateTransaction)
	transactions.Post("/:id/process", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.ProcessPayment)
	transactions.Post("/:id/refund", middleware.RoleRequired(models.RoleAdmin), transactionHandler.RefundTransaction)
	transactions.Get("/analytics", middleware.RoleRequired(models.RoleAdmin, models.RoleCashier), transactionHandler.GetTransactionAnalytics)

	// Test drive management routes
	testDrives := protected.Group("/test-drives")
	testDrives.Get("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), testDriveHandler.GetTestDrives)
	testDrives.Get("/:id", testDriveHandler.GetTestDrive)
	testDrives.Post("/", testDriveHandler.CreateTestDrive) // All authenticated users can book test drives
	testDrives.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), testDriveHandler.UpdateTestDrive)
	testDrives.Delete("/:id", testDriveHandler.DeleteTestDrive) // Users can cancel their own bookings
	testDrives.Get("/analytics", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), testDriveHandler.GetTestDriveAnalytics)

	// Lead management routes
	leads := protected.Group("/leads")
	leads.Get("/", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), leadHandler.GetLeads)
	leads.Get("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), leadHandler.GetLead)
	leads.Put("/:id", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), leadHandler.UpdateLead)
	leads.Delete("/:id", middleware.RoleRequired(models.RoleAdmin), leadHandler.DeleteLead)
	leads.Post("/:id/assign", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), leadHandler.AssignLead)
	leads.Get("/analytics", middleware.RoleRequired(models.RoleAdmin, models.RoleSales), leadHandler.GetLeadAnalytics)

	// User management routes (Admin only)
	users := protected.Group("/users", middleware.RoleRequired(models.RoleAdmin))
	users.Get("/", userHandler.GetUsers)
	users.Get("/:id", userHandler.GetUser)
	users.Post("/", userHandler.CreateUser)
	users.Put("/:id", userHandler.UpdateUser)
	users.Delete("/:id", userHandler.DeleteUser)
	users.Put("/:id/password", userHandler.ChangePassword)
	users.Get("/analytics", userHandler.GetUserAnalytics)
}