package handlers

import (
	"time"

	"vehicle-sales-backend/internal/database"
	"vehicle-sales-backend/internal/models"

	"github.com/gofiber/fiber/v2"
)

type DashboardHandler struct{}

func NewDashboardHandler() *DashboardHandler {
	return &DashboardHandler{}
}

type DashboardData struct {
	Summary    SummaryData    `json:"summary"`
	Charts     ChartsData     `json:"charts"`
	RecentData RecentData     `json:"recent_data"`
}

type SummaryData struct {
	TotalVehicles   int64   `json:"total_vehicles"`
	AvailableVehicles int64 `json:"available_vehicles"`
	TotalSales      int64   `json:"total_sales"`
	TotalRevenue    float64 `json:"total_revenue"`
	TotalCustomers  int64   `json:"total_customers"`
	PendingTestDrives int64 `json:"pending_test_drives"`
	NewLeads        int64   `json:"new_leads"`
	MonthlyRevenue  float64 `json:"monthly_revenue"`
}

type ChartsData struct {
	SalesChart      []SalesChartData      `json:"sales_chart"`
	VehicleStatus   []VehicleStatusData   `json:"vehicle_status"`
	LeadConversion  []LeadConversionData  `json:"lead_conversion"`
	MonthlyRevenue  []MonthlyRevenueData  `json:"monthly_revenue"`
}

type SalesChartData struct {
	Date  string `json:"date"`
	Sales int64  `json:"sales"`
	Revenue float64 `json:"revenue"`
}

type VehicleStatusData struct {
	Status string `json:"status"`
	Count  int64  `json:"count"`
}

type LeadConversionData struct {
	Status string `json:"status"`
	Count  int64  `json:"count"`
}

type MonthlyRevenueData struct {
	Month   string  `json:"month"`
	Revenue float64 `json:"revenue"`
}

type RecentData struct {
	RecentSales      []models.Sale      `json:"recent_sales"`
	RecentTestDrives []models.TestDrive `json:"recent_test_drives"`
	RecentLeads      []models.Lead      `json:"recent_leads"`
}

// GetDashboard returns comprehensive dashboard data
func (h *DashboardHandler) GetDashboard(c *fiber.Ctx) error {
	userRole := c.Locals("user_role").(models.UserRole)
	userID := c.Locals("user_id").(uint)

	var dashboard DashboardData

	// Get summary data
	dashboard.Summary = h.getSummaryData(userRole, userID)

	// Get charts data
	dashboard.Charts = h.getChartsData(userRole, userID)

	// Get recent data
	dashboard.RecentData = h.getRecentData(userRole, userID)

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   dashboard,
	})
}

func (h *DashboardHandler) getSummaryData(role models.UserRole, userID uint) SummaryData {
	var summary SummaryData

	// Vehicle counts
	database.DB.Model(&models.Vehicle{}).Count(&summary.TotalVehicles)
	database.DB.Model(&models.Vehicle{}).Where("status = ?", models.VehicleStatusAvailable).Count(&summary.AvailableVehicles)

	// Sales data
	database.DB.Model(&models.Sale{}).Count(&summary.TotalSales)
	database.DB.Model(&models.Sale{}).
		Where("status = ?", models.SaleStatusCompleted).
		Select("COALESCE(SUM(sale_price), 0)").
		Scan(&summary.TotalRevenue)

	// Monthly revenue (current month)
	now := time.Now()
	startOfMonth := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())
	database.DB.Model(&models.Sale{}).
		Where("status = ? AND completed_at >= ?", models.SaleStatusCompleted, startOfMonth).
		Select("COALESCE(SUM(sale_price), 0)").
		Scan(&summary.MonthlyRevenue)

	// Customer count
	database.DB.Model(&models.User{}).Where("role = ?", models.RoleCustomer).Count(&summary.TotalCustomers)

	// Test drives
	database.DB.Model(&models.TestDrive{}).Where("status = ?", models.TestDriveStatusPending).Count(&summary.PendingTestDrives)

	// Leads
	database.DB.Model(&models.Lead{}).Where("status = ?", "new").Count(&summary.NewLeads)

	// Role-specific adjustments
	if role == models.RoleSales {
		// Filter data for specific sales person
		database.DB.Model(&models.Sale{}).Where("sales_person_id = ?", userID).Count(&summary.TotalSales)
		database.DB.Model(&models.Sale{}).
			Where("sales_person_id = ? AND status = ?", userID, models.SaleStatusCompleted).
			Select("COALESCE(SUM(sale_price), 0)").
			Scan(&summary.TotalRevenue)
		database.DB.Model(&models.Lead{}).Where("assigned_to_id = ?", userID).Count(&summary.NewLeads)
	}

	return summary
}

func (h *DashboardHandler) getChartsData(role models.UserRole, userID uint) ChartsData {
	var charts ChartsData

	// Sales chart (last 7 days)
	for i := 6; i >= 0; i-- {
		date := time.Now().AddDate(0, 0, -i)
		dateStr := date.Format("2006-01-02")
		
		var sales int64
		var revenue float64
		
		query := database.DB.Model(&models.Sale{}).
			Where("DATE(created_at) = ? AND status = ?", dateStr, models.SaleStatusCompleted)
		
		if role == models.RoleSales {
			query = query.Where("sales_person_id = ?", userID)
		}
		
		query.Count(&sales)
		query.Select("COALESCE(SUM(sale_price), 0)").Scan(&revenue)
		
		charts.SalesChart = append(charts.SalesChart, SalesChartData{
			Date:    dateStr,
			Sales:   sales,
			Revenue: revenue,
		})
	}

	// Vehicle status distribution
	statuses := []models.VehicleStatus{
		models.VehicleStatusAvailable,
		models.VehicleStatusSold,
		models.VehicleStatusReserved,
		models.VehicleStatusService,
	}
	
	for _, status := range statuses {
		var count int64
		database.DB.Model(&models.Vehicle{}).Where("status = ?", status).Count(&count)
		charts.VehicleStatus = append(charts.VehicleStatus, VehicleStatusData{
			Status: string(status),
			Count:  count,
		})
	}

	// Lead conversion data
	leadStatuses := []string{"new", "contacted", "qualified", "converted", "lost"}
	for _, status := range leadStatuses {
		var count int64
		query := database.DB.Model(&models.Lead{}).Where("status = ?", status)
		
		if role == models.RoleSales {
			query = query.Where("assigned_to_id = ?", userID)
		}
		
		query.Count(&count)
		charts.LeadConversion = append(charts.LeadConversion, LeadConversionData{
			Status: status,
			Count:  count,
		})
	}

	// Monthly revenue (last 6 months)
	for i := 5; i >= 0; i-- {
		date := time.Now().AddDate(0, -i, 0)
		monthStr := date.Format("2006-01")
		startOfMonth := time.Date(date.Year(), date.Month(), 1, 0, 0, 0, 0, date.Location())
		endOfMonth := startOfMonth.AddDate(0, 1, 0)
		
		var revenue float64
		query := database.DB.Model(&models.Sale{}).
			Where("status = ? AND completed_at >= ? AND completed_at < ?", 
				models.SaleStatusCompleted, startOfMonth, endOfMonth)
		
		if role == models.RoleSales {
			query = query.Where("sales_person_id = ?", userID)
		}
		
		query.Select("COALESCE(SUM(sale_price), 0)").Scan(&revenue)
		
		charts.MonthlyRevenue = append(charts.MonthlyRevenue, MonthlyRevenueData{
			Month:   monthStr,
			Revenue: revenue,
		})
	}

	return charts
}

func (h *DashboardHandler) getRecentData(role models.UserRole, userID uint) RecentData {
	var recent RecentData

	// Recent sales
	salesQuery := database.DB.Preload("Vehicle").
		Preload("Customer").
		Preload("SalesPerson").
		Order("created_at DESC").
		Limit(5)
	
	if role == models.RoleSales {
		salesQuery = salesQuery.Where("sales_person_id = ?", userID)
	}
	
	salesQuery.Find(&recent.RecentSales)

	// Recent test drives
	testDriveQuery := database.DB.Preload("Vehicle").
		Preload("Customer").
		Order("created_at DESC").
		Limit(5)
	
	// All roles can see test drives, but filter by relevant data
	testDriveQuery.Find(&recent.RecentTestDrives)

	// Recent leads
	leadQuery := database.DB.Preload("AssignedTo").
		Order("created_at DESC").
		Limit(5)
	
	if role == models.RoleSales {
		leadQuery = leadQuery.Where("assigned_to_id = ?", userID)
	}
	
	leadQuery.Find(&recent.RecentLeads)

	return recent
}

// GetAnalytics returns detailed analytics data
func (h *DashboardHandler) GetAnalytics(c *fiber.Ctx) error {
	userRole := c.Locals("user_role").(models.UserRole)
	userID := c.Locals("user_id").(uint)

	// Only admin and sales can access detailed analytics
	if userRole != models.RoleAdmin && userRole != models.RoleSales {
		return c.Status(403).JSON(fiber.Map{
			"status":  "error",
			"message": "Access denied",
		})
	}

	period := c.Query("period", "month") // day, week, month, year

	var analytics fiber.Map

	switch period {
	case "day":
		analytics = h.getDailyAnalytics(userRole, userID)
	case "week":
		analytics = h.getWeeklyAnalytics(userRole, userID)
	case "month":
		analytics = h.getMonthlyAnalytics(userRole, userID)
	case "year":
		analytics = h.getYearlyAnalytics(userRole, userID)
	default:
		analytics = h.getMonthlyAnalytics(userRole, userID)
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   analytics,
	})
}

func (h *DashboardHandler) getDailyAnalytics(role models.UserRole, userID uint) fiber.Map {
	// Implementation for daily analytics
	return fiber.Map{
		"period": "daily",
		"data":   "Daily analytics data",
	}
}

func (h *DashboardHandler) getWeeklyAnalytics(role models.UserRole, userID uint) fiber.Map {
	// Implementation for weekly analytics
	return fiber.Map{
		"period": "weekly",
		"data":   "Weekly analytics data",
	}
}

func (h *DashboardHandler) getMonthlyAnalytics(role models.UserRole, userID uint) fiber.Map {
	// Implementation for monthly analytics
	return fiber.Map{
		"period": "monthly",
		"data":   "Monthly analytics data",
	}
}

func (h *DashboardHandler) getYearlyAnalytics(role models.UserRole, userID uint) fiber.Map {
	// Implementation for yearly analytics
	return fiber.Map{
		"period": "yearly",
		"data":   "Yearly analytics data",
	}
}