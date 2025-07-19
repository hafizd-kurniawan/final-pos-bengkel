package handlers

import (
	"vehicle-sales-backend/internal/auth"
	"vehicle-sales-backend/internal/config"
	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	config *config.Config
}

func NewAuthHandler(config *config.Config) *AuthHandler {
	return &AuthHandler{config: config}
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type RegisterRequest struct {
	Email    string          `json:"email" validate:"required,email"`
	Password string          `json:"password" validate:"required,min=6"`
	Name     string          `json:"name" validate:"required"`
	Phone    string          `json:"phone"`
	Role     models.UserRole `json:"role"`
}

type AuthResponse struct {
	Token string       `json:"token"`
	User  *models.User `json:"user"`
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Find user by email
	var user models.User
	if err := database.DB.Where("email = ? AND is_active = ?", req.Email, true).First(&user).Error; err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid credentials",
		})
	}

	// Check password
	if !auth.CheckPasswordHash(req.Password, user.Password) {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "Invalid credentials",
		})
	}

	// Generate token
	token, err := auth.GenerateToken(&user, h.config.JWT.Secret)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate token",
		})
	}

	// Clear password from response
	user.Password = ""

	return c.JSON(AuthResponse{
		Token: token,
		User:  &user,
	})
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Set default role if not provided
	if req.Role == "" {
		req.Role = models.RoleCustomer
	}

	// Hash password
	hashedPassword, err := auth.HashPassword(req.Password)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to process password",
		})
	}

	// Create user
	user := models.User{
		Email:    req.Email,
		Password: hashedPassword,
		Name:     req.Name,
		Phone:    req.Phone,
		Role:     req.Role,
		IsActive: true,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{
			"error": "Email already exists",
		})
	}

	// Generate token
	token, err := auth.GenerateToken(&user, h.config.JWT.Secret)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to generate token",
		})
	}

	// Clear password from response
	user.Password = ""

	return c.Status(fiber.StatusCreated).JSON(AuthResponse{
		Token: token,
		User:  &user,
	})
}