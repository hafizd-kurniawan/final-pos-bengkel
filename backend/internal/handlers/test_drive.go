package handlers

import (
	"strconv"
	"time"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type TestDriveHandler struct{}

func NewTestDriveHandler() *TestDriveHandler {
	return &TestDriveHandler{}
}

type CreateTestDriveRequest struct {
	VehicleID     uint      `json:"vehicle_id" validate:"required"`
	CustomerID    uint      `json:"customer_id" validate:"required"`
	ScheduledTime time.Time `json:"scheduled_time" validate:"required"`
	Notes         string    `json:"notes"`
}

type UpdateTestDriveRequest struct {
	ScheduledTime    time.Time                  `json:"scheduled_time,omitempty"`
	Status           models.TestDriveStatus     `json:"status,omitempty"`
	Notes            string                     `json:"notes,omitempty"`
	CustomerFeedback string                     `json:"customer_feedback,omitempty"`
}

// GetTestDrives retrieves test drives with filtering and pagination
func (h *TestDriveHandler) GetTestDrives(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	status := c.Query("status")
	vehicleID := c.Query("vehicle_id")
	customerID := c.Query("customer_id")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.TestDrive{}).
		Preload("Vehicle").
		Preload("Customer")

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if vehicleID != "" {
		query = query.Where("vehicle_id = ?", vehicleID)
	}

	if customerID != "" {
		query = query.Where("customer_id = ?", customerID)
	}

	var testDrives []models.TestDrive
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Order("scheduled_time ASC").Find(&testDrives).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to retrieve test drives",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"test_drives": testDrives,
			"pagination": fiber.Map{
				"page":  page,
				"limit": limit,
				"total": total,
				"pages": (total + int64(limit) - 1) / int64(limit),
			},
		},
	})
}

// GetTestDrive retrieves a single test drive by ID
func (h *TestDriveHandler) GetTestDrive(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var testDrive models.TestDrive
	if err := database.DB.Preload("Vehicle").
		Preload("Customer").
		First(&testDrive, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Test drive not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   testDrive,
	})
}

// CreateTestDrive creates a new test drive booking
func (h *TestDriveHandler) CreateTestDrive(c *fiber.Ctx) error {
	var req CreateTestDriveRequest
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
			"message": "Vehicle is not available for test drive",
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

	// Check if scheduled time is in the future
	if req.ScheduledTime.Before(time.Now()) {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Scheduled time must be in the future",
		})
	}

	// Check for conflicting test drives
	var conflictCount int64
	database.DB.Model(&models.TestDrive{}).
		Where("vehicle_id = ? AND scheduled_time BETWEEN ? AND ? AND status IN ?", 
			req.VehicleID, 
			req.ScheduledTime.Add(-2*time.Hour), 
			req.ScheduledTime.Add(2*time.Hour),
			[]models.TestDriveStatus{models.TestDriveStatusPending, models.TestDriveStatusApproved}).
		Count(&conflictCount)

	if conflictCount > 0 {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Vehicle is already scheduled for test drive at this time",
		})
	}

	testDrive := models.TestDrive{
		VehicleID:     req.VehicleID,
		CustomerID:    req.CustomerID,
		ScheduledTime: req.ScheduledTime,
		Status:        models.TestDriveStatusPending,
		Notes:         req.Notes,
	}

	if err := database.DB.Create(&testDrive).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to create test drive",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("Vehicle").
		Preload("Customer").
		First(&testDrive, testDrive.ID)

	return c.Status(201).JSON(fiber.Map{
		"status": "success",
		"data":   testDrive,
	})
}

// UpdateTestDrive updates an existing test drive
func (h *TestDriveHandler) UpdateTestDrive(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var testDrive models.TestDrive
	if err := database.DB.First(&testDrive, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Test drive not found",
		})
	}

	var req UpdateTestDriveRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if !req.ScheduledTime.IsZero() {
		if req.ScheduledTime.Before(time.Now()) {
			return c.Status(400).JSON(fiber.Map{
				"status":  "error",
				"message": "Scheduled time must be in the future",
			})
		}
		testDrive.ScheduledTime = req.ScheduledTime
	}

	if req.Status != "" {
		testDrive.Status = req.Status
	}

	if req.Notes != "" {
		testDrive.Notes = req.Notes
	}

	if req.CustomerFeedback != "" {
		testDrive.CustomerFeedback = req.CustomerFeedback
	}

	if err := database.DB.Save(&testDrive).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update test drive",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("Vehicle").
		Preload("Customer").
		First(&testDrive, testDrive.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   testDrive,
	})
}

// DeleteTestDrive cancels a test drive
func (h *TestDriveHandler) DeleteTestDrive(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var testDrive models.TestDrive
	if err := database.DB.First(&testDrive, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Test drive not found",
		})
	}

	// Only allow cancellation of pending or approved test drives
	if testDrive.Status == models.TestDriveStatusCompleted {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Cannot cancel completed test drive",
		})
	}

	testDrive.Status = models.TestDriveStatusCanceled

	if err := database.DB.Save(&testDrive).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to cancel test drive",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Test drive canceled successfully",
	})
}

// GetTestDriveAnalytics returns test drive analytics data
func (h *TestDriveHandler) GetTestDriveAnalytics(c *fiber.Ctx) error {
	var analytics struct {
		TotalTestDrives     int64 `json:"total_test_drives"`
		PendingTestDrives   int64 `json:"pending_test_drives"`
		ApprovedTestDrives  int64 `json:"approved_test_drives"`
		CompletedTestDrives int64 `json:"completed_test_drives"`
		CanceledTestDrives  int64 `json:"canceled_test_drives"`
	}

	database.DB.Model(&models.TestDrive{}).Count(&analytics.TotalTestDrives)
	database.DB.Model(&models.TestDrive{}).Where("status = ?", models.TestDriveStatusPending).Count(&analytics.PendingTestDrives)
	database.DB.Model(&models.TestDrive{}).Where("status = ?", models.TestDriveStatusApproved).Count(&analytics.ApprovedTestDrives)
	database.DB.Model(&models.TestDrive{}).Where("status = ?", models.TestDriveStatusCompleted).Count(&analytics.CompletedTestDrives)
	database.DB.Model(&models.TestDrive{}).Where("status = ?", models.TestDriveStatusCanceled).Count(&analytics.CanceledTestDrives)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}