package handlers

import (
	"strconv"
	"time"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type LeadHandler struct{}

func NewLeadHandler() *LeadHandler {
	return &LeadHandler{}
}

type CreateLeadRequest struct {
	Name         string  `json:"name" validate:"required"`
	Email        string  `json:"email" validate:"email"`
	Phone        string  `json:"phone"`
	InterestedIn string  `json:"interested_in"`
	Budget       float64 `json:"budget"`
	Notes        string  `json:"notes"`
}

type UpdateLeadRequest struct {
	Name           string     `json:"name,omitempty"`
	Email          string     `json:"email,omitempty"`
	Phone          string     `json:"phone,omitempty"`
	InterestedIn   string     `json:"interested_in,omitempty"`
	Budget         float64    `json:"budget,omitempty"`
	AssignedToID   *uint      `json:"assigned_to_id,omitempty"`
	Status         string     `json:"status,omitempty"`
	Notes          string     `json:"notes,omitempty"`
	LastContactAt  *time.Time `json:"last_contact_at,omitempty"`
}

// GetLeads retrieves leads with filtering and pagination
func (h *LeadHandler) GetLeads(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	status := c.Query("status")
	assignedToID := c.Query("assigned_to_id")
	search := c.Query("search")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.Lead{}).
		Preload("AssignedTo")

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if assignedToID != "" {
		query = query.Where("assigned_to_id = ?", assignedToID)
	}

	if search != "" {
		query = query.Where("name ILIKE ? OR email ILIKE ? OR phone ILIKE ? OR interested_in ILIKE ?", 
			"%"+search+"%", "%"+search+"%", "%"+search+"%", "%"+search+"%")
	}

	var leads []models.Lead
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&leads).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to retrieve leads",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"leads": leads,
			"pagination": fiber.Map{
				"page":  page,
				"limit": limit,
				"total": total,
				"pages": (total + int64(limit) - 1) / int64(limit),
			},
		},
	})
}

// GetLead retrieves a single lead by ID
func (h *LeadHandler) GetLead(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var lead models.Lead
	if err := database.DB.Preload("AssignedTo").First(&lead, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Lead not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   lead,
	})
}

// CreateLead creates a new lead
func (h *LeadHandler) CreateLead(c *fiber.Ctx) error {
	var req CreateLeadRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	lead := models.Lead{
		Name:         req.Name,
		Email:        req.Email,
		Phone:        req.Phone,
		InterestedIn: req.InterestedIn,
		Budget:       req.Budget,
		Status:       "new",
		Notes:        req.Notes,
	}

	if err := database.DB.Create(&lead).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to create lead",
			"error":   err.Error(),
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"status": "success",
		"data":   lead,
	})
}

// UpdateLead updates an existing lead
func (h *LeadHandler) UpdateLead(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var lead models.Lead
	if err := database.DB.First(&lead, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Lead not found",
		})
	}

	var req UpdateLeadRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if req.Name != "" {
		lead.Name = req.Name
	}
	if req.Email != "" {
		lead.Email = req.Email
	}
	if req.Phone != "" {
		lead.Phone = req.Phone
	}
	if req.InterestedIn != "" {
		lead.InterestedIn = req.InterestedIn
	}
	if req.Budget > 0 {
		lead.Budget = req.Budget
	}
	if req.AssignedToID != nil {
		// Verify the assigned user is sales or admin
		var assignedUser models.User
		if err := database.DB.Where("id = ? AND role IN ?", *req.AssignedToID, []models.UserRole{models.RoleSales, models.RoleAdmin}).First(&assignedUser).Error; err != nil {
			return c.Status(400).JSON(fiber.Map{
				"status":  "error",
				"message": "Invalid assigned user",
			})
		}
		lead.AssignedToID = req.AssignedToID
	}
	if req.Status != "" {
		lead.Status = req.Status
	}
	if req.Notes != "" {
		lead.Notes = req.Notes
	}
	if req.LastContactAt != nil {
		lead.LastContactAt = req.LastContactAt
	}

	if err := database.DB.Save(&lead).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update lead",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("AssignedTo").First(&lead, lead.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   lead,
	})
}

// DeleteLead deletes a lead
func (h *LeadHandler) DeleteLead(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var lead models.Lead
	if err := database.DB.First(&lead, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Lead not found",
		})
	}

	if err := database.DB.Delete(&lead).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to delete lead",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Lead deleted successfully",
	})
}

// GetLeadAnalytics returns lead analytics data
func (h *LeadHandler) GetLeadAnalytics(c *fiber.Ctx) error {
	var analytics struct {
		TotalLeads      int64   `json:"total_leads"`
		NewLeads        int64   `json:"new_leads"`
		ContactedLeads  int64   `json:"contacted_leads"`
		QualifiedLeads  int64   `json:"qualified_leads"`
		ConvertedLeads  int64   `json:"converted_leads"`
		AvgBudget       float64 `json:"avg_budget"`
	}

	database.DB.Model(&models.Lead{}).Count(&analytics.TotalLeads)
	database.DB.Model(&models.Lead{}).Where("status = ?", "new").Count(&analytics.NewLeads)
	database.DB.Model(&models.Lead{}).Where("status = ?", "contacted").Count(&analytics.ContactedLeads)
	database.DB.Model(&models.Lead{}).Where("status = ?", "qualified").Count(&analytics.QualifiedLeads)
	database.DB.Model(&models.Lead{}).Where("status = ?", "converted").Count(&analytics.ConvertedLeads)
	
	database.DB.Model(&models.Lead{}).
		Select("COALESCE(AVG(budget), 0)").
		Scan(&analytics.AvgBudget)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}

// AssignLead assigns a lead to a sales person
func (h *LeadHandler) AssignLead(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var lead models.Lead
	if err := database.DB.First(&lead, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Lead not found",
		})
	}

	var req struct {
		AssignedToID uint `json:"assigned_to_id" validate:"required"`
	}
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Verify the assigned user is sales or admin
	var assignedUser models.User
	if err := database.DB.Where("id = ? AND role IN ?", req.AssignedToID, []models.UserRole{models.RoleSales, models.RoleAdmin}).First(&assignedUser).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid assigned user",
		})
	}

	lead.AssignedToID = &req.AssignedToID
	if lead.Status == "new" {
		lead.Status = "assigned"
	}

	if err := database.DB.Save(&lead).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to assign lead",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("AssignedTo").First(&lead, lead.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   lead,
	})
}