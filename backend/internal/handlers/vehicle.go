package handlers

import (
	"strconv"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/middleware"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type VehicleHandler struct{}

func NewVehicleHandler() *VehicleHandler {
	return &VehicleHandler{}
}

type CreateVehicleRequest struct {
	Make         string                `json:"make" validate:"required"`
	Model        string                `json:"model" validate:"required"`
	Year         int                   `json:"year" validate:"required,min=1900,max=2030"`
	Color        string                `json:"color"`
	VIN          string                `json:"vin"`
	LicensePlate string                `json:"license_plate"`
	Price        float64               `json:"price" validate:"required,min=0"`
	Mileage      int                   `json:"mileage" validate:"min=0"`
	Status       models.VehicleStatus  `json:"status"`
	Description  string                `json:"description"`
}

func (h *VehicleHandler) GetVehicles(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	status := c.Query("status")
	search := c.Query("search")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.Vehicle{}).Preload("Images")

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if search != "" {
		query = query.Where("make ILIKE ? OR model ILIKE ? OR description ILIKE ?", 
			"%"+search+"%", "%"+search+"%", "%"+search+"%")
	}

	var vehicles []models.Vehicle
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Find(&vehicles).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to fetch vehicles",
		})
	}

	return c.JSON(fiber.Map{
		"data": vehicles,
		"meta": fiber.Map{
			"total":       total,
			"page":        page,
			"limit":       limit,
			"total_pages": (total + int64(limit) - 1) / int64(limit),
		},
	})
}

func (h *VehicleHandler) GetVehicle(c *fiber.Ctx) error {
	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid vehicle ID",
		})
	}

	var vehicle models.Vehicle
	if err := database.DB.Preload("Images").First(&vehicle, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Vehicle not found",
		})
	}

	return c.JSON(vehicle)
}

func (h *VehicleHandler) CreateVehicle(c *fiber.Ctx) error {
	authCtx := middleware.GetAuthContext(c)
	
	// Only admin and sales can create vehicles
	if authCtx.Role != models.RoleAdmin && authCtx.Role != models.RoleSales {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "Insufficient permissions",
		})
	}

	var req CreateVehicleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Set default status if not provided
	if req.Status == "" {
		req.Status = models.VehicleStatusAvailable
	}

	vehicle := models.Vehicle{
		Make:         req.Make,
		Model:        req.Model,
		Year:         req.Year,
		Color:        req.Color,
		VIN:          req.VIN,
		LicensePlate: req.LicensePlate,
		Price:        req.Price,
		Mileage:      req.Mileage,
		Status:       req.Status,
		Description:  req.Description,
	}

	if err := database.DB.Create(&vehicle).Error; err != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{
			"error": "Failed to create vehicle",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(vehicle)
}

func (h *VehicleHandler) UpdateVehicle(c *fiber.Ctx) error {
	authCtx := middleware.GetAuthContext(c)
	
	// Only admin and sales can update vehicles
	if authCtx.Role != models.RoleAdmin && authCtx.Role != models.RoleSales {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "Insufficient permissions",
		})
	}

	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid vehicle ID",
		})
	}

	var req CreateVehicleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	var vehicle models.Vehicle
	if err := database.DB.First(&vehicle, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "Vehicle not found",
		})
	}

	// Update fields
	vehicle.Make = req.Make
	vehicle.Model = req.Model
	vehicle.Year = req.Year
	vehicle.Color = req.Color
	vehicle.VIN = req.VIN
	vehicle.LicensePlate = req.LicensePlate
	vehicle.Price = req.Price
	vehicle.Mileage = req.Mileage
	vehicle.Status = req.Status
	vehicle.Description = req.Description

	if err := database.DB.Save(&vehicle).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to update vehicle",
		})
	}

	return c.JSON(vehicle)
}

func (h *VehicleHandler) DeleteVehicle(c *fiber.Ctx) error {
	authCtx := middleware.GetAuthContext(c)
	
	// Only admin can delete vehicles
	if authCtx.Role != models.RoleAdmin {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "Insufficient permissions",
		})
	}

	id, err := strconv.Atoi(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid vehicle ID",
		})
	}

	if err := database.DB.Delete(&models.Vehicle{}, id).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to delete vehicle",
		})
	}

	return c.JSON(fiber.Map{
		"message": "Vehicle deleted successfully",
	})
}