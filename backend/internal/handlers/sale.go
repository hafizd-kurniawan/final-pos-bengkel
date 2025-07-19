package handlers

import (
	"strconv"
	"time"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type SaleHandler struct{}

func NewSaleHandler() *SaleHandler {
	return &SaleHandler{}
}

type CreateSaleRequest struct {
	VehicleID     uint    `json:"vehicle_id" validate:"required"`
	CustomerID    uint    `json:"customer_id" validate:"required"`
	SalesPersonID uint    `json:"sales_person_id" validate:"required"`
	SalePrice     float64 `json:"sale_price" validate:"required,min=0"`
	Notes         string  `json:"notes"`
}

type UpdateSaleRequest struct {
	SalePrice float64              `json:"sale_price,omitempty"`
	Status    models.SaleStatus    `json:"status,omitempty"`
	Notes     string               `json:"notes,omitempty"`
}

// GetSales retrieves sales with filtering and pagination
func (h *SaleHandler) GetSales(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	status := c.Query("status")
	salesPersonID := c.Query("sales_person_id")
	customerID := c.Query("customer_id")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.Sale{}).
		Preload("Vehicle").
		Preload("Customer").
		Preload("SalesPerson")

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if salesPersonID != "" {
		query = query.Where("sales_person_id = ?", salesPersonID)
	}

	if customerID != "" {
		query = query.Where("customer_id = ?", customerID)
	}

	var sales []models.Sale
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&sales).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to retrieve sales",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"sales": sales,
			"pagination": fiber.Map{
				"page":  page,
				"limit": limit,
				"total": total,
				"pages": (total + int64(limit) - 1) / int64(limit),
			},
		},
	})
}

// GetSale retrieves a single sale by ID
func (h *SaleHandler) GetSale(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var sale models.Sale
	if err := database.DB.Preload("Vehicle").
		Preload("Customer").
		Preload("SalesPerson").
		First(&sale, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Sale not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   sale,
	})
}

// CreateSale creates a new sale
func (h *SaleHandler) CreateSale(c *fiber.Ctx) error {
	var req CreateSaleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Verify vehicle exists and is available
	var vehicle models.Vehicle
	if err := database.DB.First(&vehicle, req.VehicleID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Vehicle not found",
		})
	}

	if vehicle.Status != models.VehicleStatusAvailable {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Vehicle is not available for sale",
		})
	}

	// Verify customer exists
	var customer models.User
	if err := database.DB.Where("id = ? AND role = ?", req.CustomerID, models.RoleCustomer).First(&customer).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Customer not found",
		})
	}

	// Verify sales person exists
	var salesPerson models.User
	if err := database.DB.Where("id = ? AND role = ?", req.SalesPersonID, models.RoleSales).First(&salesPerson).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Sales person not found",
		})
	}

	sale := models.Sale{
		VehicleID:     req.VehicleID,
		CustomerID:    req.CustomerID,
		SalesPersonID: req.SalesPersonID,
		SalePrice:     req.SalePrice,
		Status:        models.SaleStatusPending,
		Notes:         req.Notes,
	}

	if err := database.DB.Create(&sale).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to create sale",
			"error":   err.Error(),
		})
	}

	// Update vehicle status to reserved
	database.DB.Model(&vehicle).Update("status", models.VehicleStatusReserved)

	// Load relationships for response
	database.DB.Preload("Vehicle").
		Preload("Customer").
		Preload("SalesPerson").
		First(&sale, sale.ID)

	return c.Status(201).JSON(fiber.Map{
		"status": "success",
		"data":   sale,
	})
}

// UpdateSale updates an existing sale
func (h *SaleHandler) UpdateSale(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var sale models.Sale
	if err := database.DB.First(&sale, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Sale not found",
		})
	}

	var req UpdateSaleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if req.SalePrice > 0 {
		sale.SalePrice = req.SalePrice
	}
	if req.Status != "" {
		sale.Status = req.Status
		
		// If completed, set completed timestamp and update vehicle status
		if req.Status == models.SaleStatusCompleted {
			now := time.Now()
			sale.CompletedAt = &now
			
			// Update vehicle status to sold
			database.DB.Model(&models.Vehicle{}).Where("id = ?", sale.VehicleID).Update("status", models.VehicleStatusSold)
		} else if req.Status == models.SaleStatusCanceled {
			// If canceled, make vehicle available again
			database.DB.Model(&models.Vehicle{}).Where("id = ?", sale.VehicleID).Update("status", models.VehicleStatusAvailable)
		}
	}
	if req.Notes != "" {
		sale.Notes = req.Notes
	}

	if err := database.DB.Save(&sale).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update sale",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("Vehicle").
		Preload("Customer").
		Preload("SalesPerson").
		First(&sale, sale.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   sale,
	})
}

// DeleteSale deletes a sale
func (h *SaleHandler) DeleteSale(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var sale models.Sale
	if err := database.DB.First(&sale, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Sale not found",
		})
	}

	// Only allow deletion of pending sales
	if sale.Status != models.SaleStatusPending {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Can only delete pending sales",
		})
	}

	// Make vehicle available again
	database.DB.Model(&models.Vehicle{}).Where("id = ?", sale.VehicleID).Update("status", models.VehicleStatusAvailable)

	if err := database.DB.Delete(&sale).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to delete sale",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Sale deleted successfully",
	})
}

// GetSalesAnalytics returns sales analytics data
func (h *SaleHandler) GetSalesAnalytics(c *fiber.Ctx) error {
	var analytics struct {
		TotalSales     int64   `json:"total_sales"`
		CompletedSales int64   `json:"completed_sales"`
		PendingSales   int64   `json:"pending_sales"`
		TotalRevenue   float64 `json:"total_revenue"`
		AvgSalePrice   float64 `json:"avg_sale_price"`
	}

	database.DB.Model(&models.Sale{}).Count(&analytics.TotalSales)
	database.DB.Model(&models.Sale{}).Where("status = ?", models.SaleStatusCompleted).Count(&analytics.CompletedSales)
	database.DB.Model(&models.Sale{}).Where("status = ?", models.SaleStatusPending).Count(&analytics.PendingSales)
	
	database.DB.Model(&models.Sale{}).
		Where("status = ?", models.SaleStatusCompleted).
		Select("COALESCE(SUM(sale_price), 0)").
		Scan(&analytics.TotalRevenue)
	
	database.DB.Model(&models.Sale{}).
		Where("status = ?", models.SaleStatusCompleted).
		Select("COALESCE(AVG(sale_price), 0)").
		Scan(&analytics.AvgSalePrice)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}