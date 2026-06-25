package handler

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

// Biaya pendaftaran member baru (sinkron dengan logika kasir di Flutter).
const newMemberAdminFee = 100000

type gymTransactionResponse struct {
	ID              uint64    `json:"id"`
	TransactionCode string    `json:"transaction_code"`
	MemberCode      *string   `json:"member_code"`
	PackageCode     string    `json:"package_code"`
	PackageName     string    `json:"package_name"`
	CustomerType    string    `json:"customer_type"`
	CustomerName    string    `json:"customer_name"`
	Amount          float64   `json:"amount"`
	AdminFee        float64   `json:"admin_fee"`
	PaymentMethod   string    `json:"payment_method"`
	Status          string    `json:"status"`
	Notes           *string   `json:"notes"`
	NewExpiryDate   *string   `json:"new_expiry_date"`
	TransactionDate time.Time `json:"transaction_date"`
}

type createGymTransactionRequest struct {
	CustomerType  string `json:"customer_type"`
	MemberID      uint64 `json:"member_id"`
	PackageCode   string `json:"package_code"`
	PaymentMethod string `json:"payment_method"`
	CustomerName  string `json:"customer_name"`
	Notes         string `json:"notes"`
}

// CreateGymTransaction mencatat pembayaran layanan gym. Untuk customer_type
// "member" sekaligus menambah riwayat perpanjangan & memperbarui masa berlaku.
func (h *AuthHandler) CreateGymTransaction(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	var req createGymTransactionRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	customerType := strings.ToLower(strings.TrimSpace(req.CustomerType))
	if customerType != "member" && customerType != "new" && customerType != "guest" {
		httpx.WriteError(w, http.StatusBadRequest, "tipe pelanggan tidak valid")
		return
	}
	paymentMethod := strings.TrimSpace(req.PaymentMethod)
	if paymentMethod == "" {
		httpx.WriteError(w, http.StatusBadRequest, "metode pembayaran wajib diisi")
		return
	}

	// Paket
	packageCode := strings.TrimSpace(req.PackageCode)
	var durationDays int
	var price float64
	var packageName string
	err := h.db.QueryRow(`SELECT duration_days, price, package_name
		FROM gym_packages WHERE package_code = ? LIMIT 1`, packageCode).Scan(
		&durationDays, &price, &packageName)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusBadRequest, "paket gym tidak ditemukan")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca paket gym")
		return
	}

	adminFee := 0.0
	if customerType == "new" {
		adminFee = newMemberAdminFee
	}
	amount := price + adminFee

	// Data member (khusus tipe member/perpanjangan)
	var memberCode sql.NullString
	customerName := strings.TrimSpace(req.CustomerName)
	var currentExpiry time.Time
	if customerType == "member" {
		if req.MemberID == 0 {
			httpx.WriteError(w, http.StatusBadRequest, "member wajib dipilih untuk perpanjangan")
			return
		}
		var code, fullName string
		err := h.db.QueryRow(`SELECT member_code, full_name, membership_expiry_date
			FROM members WHERE id = ? LIMIT 1`, req.MemberID).Scan(
			&code, &fullName, &currentExpiry)
		if err != nil {
			if errors.Is(err, sql.ErrNoRows) {
				httpx.WriteError(w, http.StatusNotFound, "member tidak ditemukan")
				return
			}
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data member")
			return
		}
		memberCode = sql.NullString{String: code, Valid: true}
		customerName = fullName
	}
	if customerName == "" {
		if customerType == "new" {
			customerName = "Member Baru"
		} else {
			customerName = "Pelanggan Harian"
		}
	}

	code, err := randomTransactionCode()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat kode transaksi")
		return
	}

	var notes sql.NullString
	if n := strings.TrimSpace(req.Notes); n != "" {
		notes = sql.NullString{String: n, Valid: true}
	}

	tx, err := h.db.Begin()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memulai transaksi")
		return
	}

	result, err := tx.Exec(`INSERT INTO gym_transactions
		(transaction_code, member_code, package_code, customer_type, customer_name,
		 amount, admin_fee, payment_method, status, notes)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'completed', ?)`,
		code, memberCode, packageCode, customerType, customerName,
		amount, adminFee, paymentMethod, notes)
	if err != nil {
		_ = tx.Rollback()
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan transaksi")
		return
	}
	txID, _ := result.LastInsertId()

	var newExpiryStr *string
	if customerType == "member" {
		now := time.Now()
		today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
		base := time.Date(currentExpiry.Year(), currentExpiry.Month(), currentExpiry.Day(),
			0, 0, 0, 0, time.Local)
		if base.Before(today) {
			base = today
		}
		newExpiry := base.AddDate(0, 0, durationDays)

		if _, err := tx.Exec(`INSERT INTO member_renewals
			(member_code, package_code, previous_expiry_date, new_expiry_date, amount, renewed_at)
			VALUES (?, ?, ?, ?, ?, CURDATE())`,
			memberCode.String, packageCode, currentExpiry, newExpiry, price); err != nil {
			_ = tx.Rollback()
			httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan perpanjangan")
			return
		}
		if _, err := tx.Exec(`UPDATE members
			SET membership_expiry_date = ?, package_code = ? WHERE id = ?`,
			newExpiry, packageCode, req.MemberID); err != nil {
			_ = tx.Rollback()
			httpx.WriteError(w, http.StatusInternalServerError, "gagal memperbarui member")
			return
		}
		s := newExpiry.Format("2006-01-02")
		newExpiryStr = &s
	}

	if err := tx.Commit(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyelesaikan transaksi")
		return
	}

	resp := gymTransactionResponse{
		ID:              uint64(txID),
		TransactionCode: code,
		PackageCode:     packageCode,
		PackageName:     packageName,
		CustomerType:    customerType,
		CustomerName:    customerName,
		Amount:          amount,
		AdminFee:        adminFee,
		PaymentMethod:   paymentMethod,
		Status:          "completed",
		NewExpiryDate:   newExpiryStr,
		TransactionDate: time.Now(),
	}
	if memberCode.Valid {
		resp.MemberCode = &memberCode.String
	}
	if notes.Valid {
		resp.Notes = &notes.String
	}

	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message":     "transaksi berhasil",
		"transaction": resp,
	})
}

// ListGymTransactions mengembalikan transaksi gym terbaru untuk panel riwayat.
func (h *AuthHandler) ListGymTransactions(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	rows, err := h.db.Query(`SELECT t.id, t.transaction_code, t.member_code,
		t.package_code, COALESCE(g.package_name, t.package_code), t.customer_type,
		t.customer_name, t.amount, t.admin_fee, t.payment_method, t.status,
		t.notes, t.transaction_date
		FROM gym_transactions t
		LEFT JOIN gym_packages g ON g.package_code = t.package_code
		ORDER BY t.transaction_date DESC, t.id DESC
		LIMIT 200`)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal mengambil transaksi gym")
		return
	}
	defer rows.Close()

	items := make([]gymTransactionResponse, 0)
	for rows.Next() {
		var item gymTransactionResponse
		var memberCode, notes sql.NullString
		if err := rows.Scan(&item.ID, &item.TransactionCode, &memberCode,
			&item.PackageCode, &item.PackageName, &item.CustomerType,
			&item.CustomerName, &item.Amount, &item.AdminFee, &item.PaymentMethod,
			&item.Status, &notes, &item.TransactionDate); err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi gym")
			return
		}
		if memberCode.Valid {
			item.MemberCode = &memberCode.String
		}
		if notes.Valid {
			item.Notes = &notes.String
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi gym")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

func randomTransactionCode() (string, error) {
	buf := make([]byte, 5)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("generate code: %w", err)
	}
	return "GYM-" + strings.ToUpper(hex.EncodeToString(buf)), nil
}
