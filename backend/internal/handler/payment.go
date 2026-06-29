package handler

import (
	"bytes"
	"crypto/rand"
	"crypto/sha512"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

// Endpoint pembayaran via Midtrans Snap.
//   POST /api/payment/snap    -> buat transaksi, balikan token + redirect_url
//   GET  /api/payment/status  -> cek status pembayaran (polling)

func (h *AuthHandler) midtransAPIBase() string {
	if h.cfg.MidtransIsProduction {
		return "https://api.midtrans.com"
	}
	return "https://api.sandbox.midtrans.com"
}

func (h *AuthHandler) midtransSnapBase() string {
	if h.cfg.MidtransIsProduction {
		return "https://app.midtrans.com"
	}
	return "https://app.sandbox.midtrans.com"
}

func (h *AuthHandler) midtransAuthHeader() string {
	return "Basic " + base64.StdEncoding.EncodeToString([]byte(h.cfg.MidtransServerKey+":"))
}

type createPaymentRequest struct {
	Amount int64  `json:"amount"`
	Label  string `json:"label"` // prefix order_id, mis. "GYM" / "FNB"
}

// CreateSnapPayment membuat transaksi Snap di Midtrans dan mengembalikan
// token + redirect_url untuk ditampilkan/di-scan pelanggan.
func (h *AuthHandler) CreateSnapPayment(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}
	if h.cfg.MidtransServerKey == "" {
		httpx.WriteError(w, http.StatusServiceUnavailable,
			"Midtrans belum dikonfigurasi (MIDTRANS_SERVER_KEY kosong)")
		return
	}

	var req createPaymentRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}
	if req.Amount <= 0 {
		httpx.WriteError(w, http.StatusBadRequest, "nominal tidak valid")
		return
	}

	label := strings.ToUpper(strings.TrimSpace(req.Label))
	if label == "" {
		label = "TRX"
	}
	buf := make([]byte, 5)
	if _, err := rand.Read(buf); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat order id")
		return
	}
	orderID := label + "-" + strings.ToUpper(hex.EncodeToString(buf))

	payload, _ := json.Marshal(map[string]any{
		"transaction_details": map[string]any{
			"order_id":     orderID,
			"gross_amount": req.Amount,
		},
	})

	httpReq, _ := http.NewRequest(http.MethodPost,
		h.midtransSnapBase()+"/snap/v1/transactions", bytes.NewReader(payload))
	httpReq.Header.Set("Authorization", h.midtransAuthHeader())
	httpReq.Header.Set("Content-Type", "application/json")
	httpReq.Header.Set("Accept", "application/json")

	resp, err := (&http.Client{Timeout: 20 * time.Second}).Do(httpReq)
	if err != nil {
		httpx.WriteError(w, http.StatusBadGateway, "gagal menghubungi Midtrans")
		return
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)

	var snap struct {
		Token         string   `json:"token"`
		RedirectURL   string   `json:"redirect_url"`
		ErrorMessages []string `json:"error_messages"`
	}
	_ = json.Unmarshal(body, &snap)

	if resp.StatusCode != http.StatusCreated || snap.Token == "" {
		msg := "gagal membuat pembayaran Midtrans"
		if len(snap.ErrorMessages) > 0 {
			msg = strings.Join(snap.ErrorMessages, "; ")
		}
		httpx.WriteError(w, http.StatusBadGateway, msg)
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"order_id":     orderID,
		"token":        snap.Token,
		"redirect_url": snap.RedirectURL,
		"client_key":   h.cfg.MidtransClientKey,
		"is_production": h.cfg.MidtransIsProduction,
	})
}

// CheckPaymentStatus menanyakan status transaksi ke Midtrans (untuk polling).
func (h *AuthHandler) CheckPaymentStatus(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}
	orderID := strings.TrimSpace(r.URL.Query().Get("order_id"))
	if orderID == "" {
		httpx.WriteError(w, http.StatusBadRequest, "order_id wajib diisi")
		return
	}

	// 1) Cek catatan dari webhook lebih dulu. Ini menangkap channel yang tidak
	//    terbaca lewat /v2/status (mis. DANA), asalkan webhook sudah dipasang.
	var dbStatus string
	var dbPaid int
	if err := h.db.QueryRow(
		`SELECT transaction_status, paid FROM payment_status WHERE order_id = ? LIMIT 1`,
		orderID).Scan(&dbStatus, &dbPaid); err == nil && dbPaid == 1 {
		httpx.WriteJSON(w, http.StatusOK, map[string]any{
			"order_id":           orderID,
			"transaction_status": dbStatus,
			"paid":               true,
		})
		return
	}

	// 2) Fallback: tanya langsung ke Midtrans (/v2/status).
	httpReq, _ := http.NewRequest(http.MethodGet,
		h.midtransAPIBase()+"/v2/"+orderID+"/status", nil)
	httpReq.Header.Set("Authorization", h.midtransAuthHeader())
	httpReq.Header.Set("Accept", "application/json")

	resp, err := (&http.Client{Timeout: 15 * time.Second}).Do(httpReq)
	if err != nil {
		httpx.WriteError(w, http.StatusBadGateway, "gagal menghubungi Midtrans")
		return
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)

	var st struct {
		TransactionStatus string `json:"transaction_status"`
		FraudStatus       string `json:"fraud_status"`
	}
	_ = json.Unmarshal(body, &st)

	status := st.TransactionStatus
	if status == "" {
		status = "pending" // belum ada pembayaran tercatat
	}
	paid := (status == "settlement") ||
		(status == "capture" && st.FraudStatus != "challenge")

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"order_id":           orderID,
		"transaction_status": status,
		"paid":               paid,
	})
}

type midtransNotification struct {
	OrderID           string `json:"order_id"`
	StatusCode        string `json:"status_code"`
	GrossAmount       string `json:"gross_amount"`
	SignatureKey      string `json:"signature_key"`
	TransactionStatus string `json:"transaction_status"`
	FraudStatus       string `json:"fraud_status"`
	PaymentType       string `json:"payment_type"`
}

// PaymentNotification menerima webhook dari Midtrans saat status pembayaran
// berubah (PUBLIK, dipanggil server Midtrans). Diverifikasi via signature_key,
// lalu status disimpan agar polling POS bisa membacanya — termasuk channel yang
// tidak terbaca lewat /v2/status (mis. DANA).
func (h *AuthHandler) PaymentNotification(w http.ResponseWriter, r *http.Request) {
	body, err := io.ReadAll(io.LimitReader(r.Body, 1<<20))
	if err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "gagal membaca notifikasi")
		return
	}
	var n midtransNotification
	if err := json.Unmarshal(body, &n); err != nil || n.OrderID == "" {
		httpx.WriteError(w, http.StatusBadRequest, "notifikasi tidak valid")
		return
	}

	// signature_key = SHA512(order_id + status_code + gross_amount + server_key)
	expected := sha512Hex(n.OrderID + n.StatusCode + n.GrossAmount + h.cfg.MidtransServerKey)
	if !strings.EqualFold(expected, n.SignatureKey) {
		httpx.WriteError(w, http.StatusUnauthorized, "signature tidak valid")
		return
	}

	paid := 0
	if n.TransactionStatus == "settlement" ||
		(n.TransactionStatus == "capture" && n.FraudStatus != "challenge") {
		paid = 1
	}

	_, _ = h.db.Exec(`INSERT INTO payment_status
		(order_id, transaction_status, fraud_status, paid, gross_amount, payment_type)
		VALUES (?, ?, ?, ?, ?, ?)
		ON DUPLICATE KEY UPDATE
			transaction_status = VALUES(transaction_status),
			fraud_status = VALUES(fraud_status),
			paid = VALUES(paid),
			gross_amount = VALUES(gross_amount),
			payment_type = VALUES(payment_type)`,
		n.OrderID, n.TransactionStatus, n.FraudStatus, paid, n.GrossAmount, n.PaymentType)

	httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
}

func sha512Hex(s string) string {
	sum := sha512.Sum512([]byte(s))
	return hex.EncodeToString(sum[:])
}
