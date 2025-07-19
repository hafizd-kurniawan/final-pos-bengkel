package middleware

import (
	"strings"

	"vehicle-sales-backend/internal/auth"
	"vehicle-sales-backend/internal/config"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type AuthContext struct {
	UserID uint
	Email  string
	Role   models.UserRole
}

func AuthRequired(config *config.Config) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Authorization header required",
			})
		}

		// Extract token from "Bearer <token>"
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid authorization format",
			})
		}

		claims, err := auth.ValidateToken(parts[1], config.JWT.Secret)
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "Invalid token",
			})
		}

		// Store auth context in locals
		c.Locals("auth", &AuthContext{
			UserID: claims.UserID,
			Email:  claims.Email,
			Role:   claims.Role,
		})

		return c.Next()
	}
}

func RoleRequired(allowedRoles ...models.UserRole) fiber.Handler {
	return func(c *fiber.Ctx) error {
		authCtx := c.Locals("auth").(*AuthContext)
		
		for _, role := range allowedRoles {
			if authCtx.Role == role {
				return c.Next()
			}
		}

		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "Insufficient permissions",
		})
	}
}

func GetAuthContext(c *fiber.Ctx) *AuthContext {
	return c.Locals("auth").(*AuthContext)
}