package handlers

import (
	"strconv"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

type UserHandler struct{}

func NewUserHandler() *UserHandler {
	return &UserHandler{}
}

type CreateUserRequest struct {
	Email    string           `json:"email" validate:"required,email"`
	Password string           `json:"password" validate:"required,min=6"`
	Name     string           `json:"name" validate:"required"`
	Phone    string           `json:"phone"`
	Role     models.UserRole  `json:"role" validate:"required"`
}

type UpdateUserRequest struct {
	Name      string          `json:"name,omitempty"`
	Phone     string          `json:"phone,omitempty"`
	Role      models.UserRole `json:"role,omitempty"`
	IsActive  *bool           `json:"is_active,omitempty"`
	AvatarURL string          `json:"avatar_url,omitempty"`
}

type ChangePasswordRequest struct {
	CurrentPassword string `json:"current_password" validate:"required"`
	NewPassword     string `json:"new_password" validate:"required,min=6"`
}

// GetUsers retrieves users with filtering and pagination
func (h *UserHandler) GetUsers(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	role := c.Query("role")
	search := c.Query("search")
	isActive := c.Query("is_active")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.User{})

	if role != "" {
		query = query.Where("role = ?", role)
	}

	if isActive != "" {
		active := isActive == "true"
		query = query.Where("is_active = ?", active)
	}

	if search != "" {
		query = query.Where("name ILIKE ? OR email ILIKE ? OR phone ILIKE ?", 
			"%"+search+"%", "%"+search+"%", "%"+search+"%")
	}

	var users []models.User
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&users).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to retrieve users",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"users": users,
			"pagination": fiber.Map{
				"page":  page,
				"limit": limit,
				"total": total,
				"pages": (total + int64(limit) - 1) / int64(limit),
			},
		},
	})
}

// GetUser retrieves a single user by ID
func (h *UserHandler) GetUser(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var user models.User
	if err := database.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   user,
	})
}

// CreateUser creates a new user (Admin only)
func (h *UserHandler) CreateUser(c *fiber.Ctx) error {
	var req CreateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Check if email already exists
	var existingUser models.User
	if err := database.DB.Where("email = ?", req.Email).First(&existingUser).Error; err == nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Email already exists",
		})
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to hash password",
		})
	}

	user := models.User{
		Email:    req.Email,
		Password: string(hashedPassword),
		Name:     req.Name,
		Phone:    req.Phone,
		Role:     req.Role,
		IsActive: true,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to create user",
			"error":   err.Error(),
		})
	}

	return c.Status(201).JSON(fiber.Map{
		"status": "success",
		"data":   user,
	})
}

// UpdateUser updates an existing user
func (h *UserHandler) UpdateUser(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var user models.User
	if err := database.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	var req UpdateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Phone != "" {
		user.Phone = req.Phone
	}
	if req.Role != "" {
		user.Role = req.Role
	}
	if req.IsActive != nil {
		user.IsActive = *req.IsActive
	}
	if req.AvatarURL != "" {
		user.AvatarURL = req.AvatarURL
	}

	if err := database.DB.Save(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update user",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   user,
	})
}

// DeleteUser deactivates a user (soft delete)
func (h *UserHandler) DeleteUser(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var user models.User
	if err := database.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	// Deactivate instead of hard delete
	user.IsActive = false
	
	if err := database.DB.Save(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to deactivate user",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "User deactivated successfully",
	})
}

// ChangePassword changes user's password
func (h *UserHandler) ChangePassword(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var user models.User
	if err := database.DB.First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	var req ChangePasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Verify current password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.CurrentPassword)); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Current password is incorrect",
		})
	}

	// Hash new password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(req.NewPassword), bcrypt.DefaultCost)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to hash password",
		})
	}

	user.Password = string(hashedPassword)

	if err := database.DB.Save(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update password",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Password changed successfully",
	})
}

// GetUserAnalytics returns user analytics data
func (h *UserHandler) GetUserAnalytics(c *fiber.Ctx) error {
	var analytics struct {
		TotalUsers      int64 `json:"total_users"`
		ActiveUsers     int64 `json:"active_users"`
		AdminUsers      int64 `json:"admin_users"`
		SalesUsers      int64 `json:"sales_users"`
		CashierUsers    int64 `json:"cashier_users"`
		CustomerUsers   int64 `json:"customer_users"`
	}

	database.DB.Model(&models.User{}).Count(&analytics.TotalUsers)
	database.DB.Model(&models.User{}).Where("is_active = ?", true).Count(&analytics.ActiveUsers)
	database.DB.Model(&models.User{}).Where("role = ?", models.RoleAdmin).Count(&analytics.AdminUsers)
	database.DB.Model(&models.User{}).Where("role = ?", models.RoleSales).Count(&analytics.SalesUsers)
	database.DB.Model(&models.User{}).Where("role = ?", models.RoleCashier).Count(&analytics.CashierUsers)
	database.DB.Model(&models.User{}).Where("role = ?", models.RoleCustomer).Count(&analytics.CustomerUsers)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}

// GetProfile returns current user's profile
func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   user,
	})
}

// UpdateProfile updates current user's profile
func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	userID := c.Locals("user_id").(uint)
	
	var user models.User
	if err := database.DB.First(&user, userID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "User not found",
		})
	}

	var req struct {
		Name      string `json:"name,omitempty"`
		Phone     string `json:"phone,omitempty"`
		AvatarURL string `json:"avatar_url,omitempty"`
	}
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if req.Name != "" {
		user.Name = req.Name
	}
	if req.Phone != "" {
		user.Phone = req.Phone
	}
	if req.AvatarURL != "" {
		user.AvatarURL = req.AvatarURL
	}

	if err := database.DB.Save(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update profile",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   user,
	})
}