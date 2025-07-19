package models

import (
	"time"

	"gorm.io/gorm"
)

type UserRole string

const (
	RoleAdmin    UserRole = "admin"
	RoleSales    UserRole = "sales"
	RoleCashier  UserRole = "cashier"
	RoleCustomer UserRole = "customer"
)

type User struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Email     string   `json:"email" gorm:"uniqueIndex;not null"`
	Password  string   `json:"-" gorm:"not null"`
	Name      string   `json:"name" gorm:"not null"`
	Phone     string   `json:"phone"`
	Role      UserRole `json:"role" gorm:"not null;default:'customer'"`
	IsActive  bool     `json:"is_active" gorm:"default:true"`
	AvatarURL string   `json:"avatar_url"`

	// Relationships
	Sales          []Sale        `json:"sales,omitempty" gorm:"foreignKey:SalesPersonID"`
	CustomerOrders []Sale        `json:"customer_orders,omitempty" gorm:"foreignKey:CustomerID"`
	Transactions   []Transaction `json:"transactions,omitempty" gorm:"foreignKey:ProcessedByID"`
}

type VehicleStatus string

const (
	VehicleStatusAvailable VehicleStatus = "available"
	VehicleStatusSold      VehicleStatus = "sold"
	VehicleStatusReserved  VehicleStatus = "reserved"
	VehicleStatusService   VehicleStatus = "service"
)

type Vehicle struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Make         string        `json:"make" gorm:"not null"`
	Model        string        `json:"model" gorm:"not null"`
	Year         int           `json:"year" gorm:"not null"`
	Color        string        `json:"color"`
	VIN          string        `json:"vin" gorm:"uniqueIndex"`
	LicensePlate string        `json:"license_plate"`
	Price        float64       `json:"price" gorm:"not null"`
	Mileage      int           `json:"mileage"`
	Status       VehicleStatus `json:"status" gorm:"default:'available'"`
	Description  string        `json:"description"`

	// Relationships
	Images    []VehicleImage `json:"images,omitempty" gorm:"foreignKey:VehicleID"`
	TestDrives []TestDrive   `json:"test_drives,omitempty" gorm:"foreignKey:VehicleID"`
	Sales     []Sale         `json:"sales,omitempty" gorm:"foreignKey:VehicleID"`
}

type VehicleImage struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	VehicleID uint   `json:"vehicle_id" gorm:"not null"`
	URL       string `json:"url" gorm:"not null"`
	IsPrimary bool   `json:"is_primary" gorm:"default:false"`

	// Relationships
	Vehicle Vehicle `json:"vehicle,omitempty" gorm:"foreignKey:VehicleID"`
}

type TestDriveStatus string

const (
	TestDriveStatusPending   TestDriveStatus = "pending"
	TestDriveStatusApproved  TestDriveStatus = "approved"
	TestDriveStatusCompleted TestDriveStatus = "completed"
	TestDriveStatusCanceled  TestDriveStatus = "canceled"
)

type TestDrive struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	VehicleID        uint            `json:"vehicle_id" gorm:"not null"`
	CustomerID       uint            `json:"customer_id" gorm:"not null"`
	ScheduledTime    time.Time       `json:"scheduled_time" gorm:"not null"`
	Status           TestDriveStatus `json:"status" gorm:"default:'pending'"`
	Notes            string          `json:"notes"`
	CustomerFeedback string          `json:"customer_feedback"`

	// Relationships
	Vehicle  Vehicle `json:"vehicle,omitempty" gorm:"foreignKey:VehicleID"`
	Customer User    `json:"customer,omitempty" gorm:"foreignKey:CustomerID"`
}

type SaleStatus string

const (
	SaleStatusPending   SaleStatus = "pending"
	SaleStatusApproved  SaleStatus = "approved"
	SaleStatusCompleted SaleStatus = "completed"
	SaleStatusCanceled  SaleStatus = "canceled"
)

type Sale struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	VehicleID      uint       `json:"vehicle_id" gorm:"not null"`
	CustomerID     uint       `json:"customer_id" gorm:"not null"`
	SalesPersonID  uint       `json:"sales_person_id" gorm:"not null"`
	SalePrice      float64    `json:"sale_price" gorm:"not null"`
	Status         SaleStatus `json:"status" gorm:"default:'pending'"`
	Notes          string     `json:"notes"`
	CompletedAt    *time.Time `json:"completed_at"`

	// Relationships
	Vehicle     Vehicle `json:"vehicle,omitempty" gorm:"foreignKey:VehicleID"`
	Customer    User    `json:"customer,omitempty" gorm:"foreignKey:CustomerID"`
	SalesPerson User    `json:"sales_person,omitempty" gorm:"foreignKey:SalesPersonID"`
}

type PaymentMethod string

const (
	PaymentMethodCash         PaymentMethod = "cash"
	PaymentMethodCard         PaymentMethod = "card"
	PaymentMethodBankTransfer PaymentMethod = "bank_transfer"
	PaymentMethodFinancing    PaymentMethod = "financing"
)

type TransactionStatus string

const (
	TransactionStatusPending   TransactionStatus = "pending"
	TransactionStatusCompleted TransactionStatus = "completed"
	TransactionStatusFailed    TransactionStatus = "failed"
	TransactionStatusRefunded  TransactionStatus = "refunded"
)

type Transaction struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	SaleID          uint              `json:"sale_id" gorm:"not null"`
	Amount          float64           `json:"amount" gorm:"not null"`
	PaymentMethod   PaymentMethod     `json:"payment_method" gorm:"not null"`
	Status          TransactionStatus `json:"status" gorm:"default:'pending'"`
	ProcessedByID   uint              `json:"processed_by_id" gorm:"not null"`
	ProcessedAt     *time.Time        `json:"processed_at"`
	TransactionRef  string            `json:"transaction_ref"`
	Notes           string            `json:"notes"`

	// Relationships
	Sale        Sale `json:"sale,omitempty" gorm:"foreignKey:SaleID"`
	ProcessedBy User `json:"processed_by,omitempty" gorm:"foreignKey:ProcessedByID"`
}

type Lead struct {
	ID        uint           `json:"id" gorm:"primaryKey"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"deleted_at" gorm:"index"`

	Name           string `json:"name" gorm:"not null"`
	Email          string `json:"email"`
	Phone          string `json:"phone"`
	InterestedIn   string `json:"interested_in"`
	Budget         float64 `json:"budget"`
	AssignedToID   *uint   `json:"assigned_to_id"`
	Status         string  `json:"status" gorm:"default:'new'"`
	Notes          string  `json:"notes"`
	LastContactAt  *time.Time `json:"last_contact_at"`

	// Relationships
	AssignedTo *User `json:"assigned_to,omitempty" gorm:"foreignKey:AssignedToID"`
}