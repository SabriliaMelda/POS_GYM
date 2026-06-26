package handler

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

type fnbTxItem struct {
	ItemID   uint64  `json:"item_id"`
	Name     string  `json:"name"`
	Price    float64 `json:"price"`
	Quantity int64   `json:"quantity"`
	Subtotal float64 `json:"subtotal"`
}

type fnbTransactionResponse struct {
	ID              uint64          `json:"id"`
	TransactionCode string          `json:"transaction_code"`
	MemberCode      *string         `json:"member_code"`
	CustomerName    string          `json:"customer_name"`
	Items           json.RawMessage `json:"items"`
	TotalAmount     float64         `json:"total_amount"`
	DiscountAmount  float64         `json:"discount_amount"`
	TaxAmount       float64         `json:"tax_amount"`
	FinalAmount     float64         `json:"final_amount"`
	PaymentMethod   string          `json:"payment_method"`
	Status          string          `json:"status"`
	Notes           *string         `json:"notes"`
	TransactionDate time.Time       `json:"transaction_date"`
}

type createFNBTransactionRequest struct {
	MemberID      *uint64 `json:"member_id"`
	PaymentMethod string  `json:"payment_method"`
	Notes         string  `json:"notes"`
	Items         []struct {
		ItemID   uint64  `json:"item_id"`
		Name     string  `json:"name"`
		Price    float64 `json:"price"`
		Quantity int64   `json:"quantity"`
	} `json:"items"`
}

// CreateFNBTransaction mencatat penjualan F&B kasir. Stok tiap item dikurangi
// secara atomik di dalam satu transaksi DB; bila stok kurang, semuanya batal.
func (h *AuthHandler) CreateFNBTransaction(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	var req createFNBTransactionRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	paymentMethod := strings.TrimSpace(req.PaymentMethod)
	if paymentMethod == "" {
		paymentMethod = "QRIS"
	}
	if len(req.Items) == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "keranjang tidak boleh kosong")
		return
	}

	items := make([]fnbTxItem, 0, len(req.Items))
	var total float64
	for _, it := range req.Items {
		if it.Quantity <= 0 {
			httpx.WriteError(w, http.StatusBadRequest, "jumlah item harus lebih dari 0")
			return
		}
		if it.Price < 0 {
			httpx.WriteError(w, http.StatusBadRequest, "harga item tidak valid")
			return
		}
		subtotal := it.Price * float64(it.Quantity)
		total += subtotal
		items = append(items, fnbTxItem{
			ItemID:   it.ItemID,
			Name:     strings.TrimSpace(it.Name),
			Price:    it.Price,
			Quantity: it.Quantity,
			Subtotal: subtotal,
		})
	}

	// Member opsional (pembeli non-member tidak mengirim member_id).
	var memberCode sql.NullString
	customerName := "Non-member"
	if req.MemberID != nil && *req.MemberID != 0 {
		var code, fullName string
		err := h.db.QueryRow(`SELECT member_code, full_name FROM members WHERE id = ? LIMIT 1`,
			*req.MemberID).Scan(&code, &fullName)
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

	itemsJSON, err := json.Marshal(items)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memproses item")
		return
	}

	code, err := randomFNBTransactionCode()
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

	// Kurangi stok tiap item secara atomik; tolak bila tidak mencukupi.
	for _, it := range items {
		res, err := tx.Exec(
			`UPDATE food_beverage_items SET stock = stock - ? WHERE id = ? AND stock >= ?`,
			it.Quantity, it.ItemID, it.Quantity)
		if err != nil {
			_ = tx.Rollback()
			httpx.WriteError(w, http.StatusInternalServerError, "gagal memperbarui stok")
			return
		}
		affected, _ := res.RowsAffected()
		if affected == 0 {
			_ = tx.Rollback()
			name := it.Name
			if name == "" {
				name = "menu"
			}
			httpx.WriteError(w, http.StatusConflict, "stok tidak cukup untuk "+name)
			return
		}
	}

	result, err := tx.Exec(`INSERT INTO food_beverage_transactions
		(transaction_code, member_code, customer_name, items, total_amount,
		 discount_amount, tax_amount, final_amount, payment_method, status, notes)
		VALUES (?, ?, ?, ?, ?, 0, 0, ?, ?, 'completed', ?)`,
		code, memberCode, customerName, string(itemsJSON), total, total, paymentMethod, notes)
	if err != nil {
		_ = tx.Rollback()
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan transaksi")
		return
	}
	txID, _ := result.LastInsertId()

	if err := tx.Commit(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyelesaikan transaksi")
		return
	}

	resp := fnbTransactionResponse{
		ID:              uint64(txID),
		TransactionCode: code,
		CustomerName:    customerName,
		Items:           itemsJSON,
		TotalAmount:     total,
		FinalAmount:     total,
		PaymentMethod:   paymentMethod,
		Status:          "completed",
		TransactionDate: time.Now(),
	}
	if memberCode.Valid {
		resp.MemberCode = &memberCode.String
	}
	if notes.Valid {
		resp.Notes = &notes.String
	}

	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message":     "transaksi F&B berhasil",
		"transaction": resp,
	})
}

// ListFNBTransactions mengembalikan transaksi F&B terbaru untuk panel riwayat.
func (h *AuthHandler) ListFNBTransactions(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	rows, err := h.db.Query(`SELECT id, transaction_code, member_code, customer_name,
		items, total_amount, discount_amount, tax_amount, final_amount,
		payment_method, status, notes, transaction_date
		FROM food_beverage_transactions
		ORDER BY transaction_date DESC, id DESC
		LIMIT 200`)
	if err != nil {
		h.writeFNBDatabaseError(w, err, "gagal mengambil transaksi F&B")
		return
	}
	defer rows.Close()

	items := make([]fnbTransactionResponse, 0)
	for rows.Next() {
		var item fnbTransactionResponse
		var memberCode, notes sql.NullString
		var itemsRaw []byte
		if err := rows.Scan(&item.ID, &item.TransactionCode, &memberCode,
			&item.CustomerName, &itemsRaw, &item.TotalAmount, &item.DiscountAmount,
			&item.TaxAmount, &item.FinalAmount, &item.PaymentMethod, &item.Status,
			&notes, &item.TransactionDate); err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi F&B")
			return
		}
		if len(itemsRaw) == 0 {
			itemsRaw = []byte("[]")
		}
		item.Items = json.RawMessage(itemsRaw)
		if memberCode.Valid {
			item.MemberCode = &memberCode.String
		}
		if notes.Valid {
			item.Notes = &notes.String
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi F&B")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

func randomFNBTransactionCode() (string, error) {
	buf := make([]byte, 5)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("generate code: %w", err)
	}
	return "FNB-" + strings.ToUpper(hex.EncodeToString(buf)), nil
}
