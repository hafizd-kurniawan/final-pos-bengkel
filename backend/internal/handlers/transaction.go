package handlers

import (
	"strconv"
	"time"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type TransactionHandler struct{}

func NewTransactionHandler() *TransactionHandler {
	return &TransactionHandler{}
}

type CreateTransactionRequest struct {
	SaleID        uint                          `json:"sale_id" validate:"required"`
	Amount        float64                       `json:"amount" validate:"required,min=0"`
	PaymentMethod models.PaymentMethod          `json:"payment_method" validate:"required"`
	Notes         string                        `json:"notes"`
}

type UpdateTransactionRequest struct {
	Status         models.TransactionStatus      `json:"status,omitempty"`
	TransactionRef string                        `json:"transaction_ref,omitempty"`
	Notes          string                        `json:"notes,omitempty"`
}

// GetTransactions retrieves transactions with filtering and pagination
func (h *TransactionHandler) GetTransactions(c *fiber.Ctx) error {
	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "10"))
	status := c.Query("status")
	saleID := c.Query("sale_id")
	paymentMethod := c.Query("payment_method")

	offset := (page - 1) * limit

	query := database.DB.Model(&models.Transaction{}).
		Preload("Sale").
		Preload("Sale.Vehicle").
		Preload("Sale.Customer").
		Preload("ProcessedBy")

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if saleID != "" {
		query = query.Where("sale_id = ?", saleID)
	}

	if paymentMethod != "" {
		query = query.Where("payment_method = ?", paymentMethod)
	}

	var transactions []models.Transaction
	var total int64

	query.Count(&total)
	
	if err := query.Offset(offset).Limit(limit).Order("created_at DESC").Find(&transactions).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to retrieve transactions",
			"error":   err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"transactions": transactions,
			"pagination": fiber.Map{
				"page":  page,
				"limit": limit,
				"total": total,
				"pages": (total + int64(limit) - 1) / int64(limit),
			},
		},
	})
}

// GetTransaction retrieves a single transaction by ID
func (h *TransactionHandler) GetTransaction(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var transaction models.Transaction
	if err := database.DB.Preload("Sale").
		Preload("Sale.Vehicle").
		Preload("Sale.Customer").
		Preload("ProcessedBy").
		First(&transaction, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Transaction not found",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   transaction,
	})
}

// CreateTransaction creates a new transaction
func (h *TransactionHandler) CreateTransaction(c *fiber.Ctx) error {
	var req CreateTransactionRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Get current user (cashier/admin)
	userID := c.Locals("user_id").(uint)

	// Verify sale exists and is approved
	var sale models.Sale
	if err := database.DB.First(&sale, req.SaleID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Sale not found",
		})
	}

	if sale.Status != models.SaleStatusApproved {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Sale must be approved before processing payment",
		})
	}

	// Generate transaction reference
	transactionRef := "TXN-" + uuid.New().String()[:8]

	transaction := models.Transaction{
		SaleID:          req.SaleID,
		Amount:          req.Amount,
		PaymentMethod:   req.PaymentMethod,
		Status:          models.TransactionStatusPending,
		ProcessedByID:   userID,
		TransactionRef:  transactionRef,
		Notes:           req.Notes,
	}

	if err := database.DB.Create(&transaction).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to create transaction",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("Sale").
		Preload("Sale.Vehicle").
		Preload("Sale.Customer").
		Preload("ProcessedBy").
		First(&transaction, transaction.ID)

	return c.Status(201).JSON(fiber.Map{
		"status": "success",
		"data":   transaction,
	})
}

// UpdateTransaction updates an existing transaction
func (h *TransactionHandler) UpdateTransaction(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var transaction models.Transaction
	if err := database.DB.First(&transaction, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Transaction not found",
		})
	}

	var req UpdateTransactionRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Invalid request body",
		})
	}

	// Update fields if provided
	if req.Status != "" {
		transaction.Status = req.Status
		
		// If completed, set processed timestamp and update sale status
		if req.Status == models.TransactionStatusCompleted {
			now := time.Now()
			transaction.ProcessedAt = &now
			
			// Update sale status to completed
			database.DB.Model(&models.Sale{}).
				Where("id = ?", transaction.SaleID).
				Updates(map[string]interface{}{
					"status": models.SaleStatusCompleted,
					"completed_at": now,
				})

			// Update vehicle status to sold
			var sale models.Sale
			database.DB.First(&sale, transaction.SaleID)
			database.DB.Model(&models.Vehicle{}).
				Where("id = ?", sale.VehicleID).
				Update("status", models.VehicleStatusSold)
		}
	}

	if req.TransactionRef != "" {
		transaction.TransactionRef = req.TransactionRef
	}

	if req.Notes != "" {
		transaction.Notes = req.Notes
	}

	if err := database.DB.Save(&transaction).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to update transaction",
			"error":   err.Error(),
		})
	}

	// Load relationships for response
	database.DB.Preload("Sale").
		Preload("Sale.Vehicle").
		Preload("Sale.Customer").
		Preload("ProcessedBy").
		First(&transaction, transaction.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   transaction,
	})
}

// ProcessPayment completes a transaction
func (h *TransactionHandler) ProcessPayment(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var transaction models.Transaction
	if err := database.DB.First(&transaction, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Transaction not found",
		})
	}

	if transaction.Status != models.TransactionStatusPending {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Transaction is not pending",
		})
	}

	// Process payment based on method
	switch transaction.PaymentMethod {
	case models.PaymentMethodCash:
		// Cash payment - mark as completed immediately
		transaction.Status = models.TransactionStatusCompleted
	case models.PaymentMethodCard:
		// Card payment - simulate card processing
		transaction.Status = models.TransactionStatusCompleted
	case models.PaymentMethodBankTransfer:
		// Bank transfer - might need verification
		transaction.Status = models.TransactionStatusCompleted
	case models.PaymentMethodFinancing:
		// Financing - special handling required
		transaction.Status = models.TransactionStatusCompleted
	}

	now := time.Now()
	transaction.ProcessedAt = &now

	if err := database.DB.Save(&transaction).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to process payment",
			"error":   err.Error(),
		})
	}

	// Update sale and vehicle status if payment completed
	if transaction.Status == models.TransactionStatusCompleted {
		// Update sale status
		database.DB.Model(&models.Sale{}).
			Where("id = ?", transaction.SaleID).
			Updates(map[string]interface{}{
				"status": models.SaleStatusCompleted,
				"completed_at": now,
			})

		// Update vehicle status
		var sale models.Sale
		database.DB.First(&sale, transaction.SaleID)
		database.DB.Model(&models.Vehicle{}).
			Where("id = ?", sale.VehicleID).
			Update("status", models.VehicleStatusSold)
	}

	// Load relationships for response
	database.DB.Preload("Sale").
		Preload("Sale.Vehicle").
		Preload("Sale.Customer").
		Preload("ProcessedBy").
		First(&transaction, transaction.ID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   transaction,
		"message": "Payment processed successfully",
	})
}

// RefundTransaction refunds a completed transaction
func (h *TransactionHandler) RefundTransaction(c *fiber.Ctx) error {
	id := c.Params("id")
	
	var transaction models.Transaction
	if err := database.DB.First(&transaction, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Transaction not found",
		})
	}

	if transaction.Status != models.TransactionStatusCompleted {
		return c.Status(400).JSON(fiber.Map{
			"status":  "error",
			"message": "Only completed transactions can be refunded",
		})
	}

	// Update transaction status to refunded
	transaction.Status = models.TransactionStatusRefunded

	if err := database.DB.Save(&transaction).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "error",
			"message": "Failed to refund transaction",
			"error":   err.Error(),
		})
	}

	// Revert sale status
	database.DB.Model(&models.Sale{}).
		Where("id = ?", transaction.SaleID).
		Updates(map[string]interface{}{
			"status": models.SaleStatusCanceled,
			"completed_at": nil,
		})

	// Make vehicle available again
	var sale models.Sale
	database.DB.First(&sale, transaction.SaleID)
	database.DB.Model(&models.Vehicle{}).
		Where("id = ?", sale.VehicleID).
		Update("status", models.VehicleStatusAvailable)

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Transaction refunded successfully",
	})
}

// GetTransactionAnalytics returns transaction analytics data
func (h *TransactionHandler) GetTransactionAnalytics(c *fiber.Ctx) error {
	var analytics struct {
		TotalTransactions     int64   `json:"total_transactions"`
		CompletedTransactions int64   `json:"completed_transactions"`
		PendingTransactions   int64   `json:"pending_transactions"`
		FailedTransactions    int64   `json:"failed_transactions"`
		RefundedTransactions  int64   `json:"refunded_transactions"`
		TotalRevenue          float64 `json:"total_revenue"`
		AvgTransactionAmount  float64 `json:"avg_transaction_amount"`
		PaymentMethods        []struct {
			Method string `json:"method"`
			Count  int64  `json:"count"`
			Total  float64 `json:"total"`
		} `json:"payment_methods"`
	}

	database.DB.Model(&models.Transaction{}).Count(&analytics.TotalTransactions)
	database.DB.Model(&models.Transaction{}).Where("status = ?", models.TransactionStatusCompleted).Count(&analytics.CompletedTransactions)
	database.DB.Model(&models.Transaction{}).Where("status = ?", models.TransactionStatusPending).Count(&analytics.PendingTransactions)
	database.DB.Model(&models.Transaction{}).Where("status = ?", models.TransactionStatusFailed).Count(&analytics.FailedTransactions)
	database.DB.Model(&models.Transaction{}).Where("status = ?", models.TransactionStatusRefunded).Count(&analytics.RefundedTransactions)
	
	database.DB.Model(&models.Transaction{}).
		Where("status = ?", models.TransactionStatusCompleted).
		Select("COALESCE(SUM(amount), 0)").
		Scan(&analytics.TotalRevenue)
	
	database.DB.Model(&models.Transaction{}).
		Where("status = ?", models.TransactionStatusCompleted).
		Select("COALESCE(AVG(amount), 0)").
		Scan(&analytics.AvgTransactionAmount)

	// Payment method breakdown
	paymentMethods := []models.PaymentMethod{
		models.PaymentMethodCash,
		models.PaymentMethodCard,
		models.PaymentMethodBankTransfer,
		models.PaymentMethodFinancing,
	}

	for _, method := range paymentMethods {
		var count int64
		var total float64
		
		database.DB.Model(&models.Transaction{}).
			Where("payment_method = ? AND status = ?", method, models.TransactionStatusCompleted).
			Count(&count)
		
		database.DB.Model(&models.Transaction{}).
			Where("payment_method = ? AND status = ?", method, models.TransactionStatusCompleted).
			Select("COALESCE(SUM(amount), 0)").
			Scan(&total)
		
		analytics.PaymentMethods = append(analytics.PaymentMethods, struct {
			Method string `json:"method"`
			Count  int64  `json:"count"`
			Total  float64 `json:"total"`
		}{
			Method: string(method),
			Count:  count,
			Total:  total,
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}