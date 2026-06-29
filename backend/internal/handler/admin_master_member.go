package handler

import (
	"database/sql"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
	"pos-gym/backend/internal/mailer"
)

type memberResponse struct {
	ID                   uint64                      `json:"id"`
	MemberCode           string                      `json:"member_code"`
	FullName             string                      `json:"full_name"`
	Email                string                      `json:"email"`
	PhoneNumber          string                      `json:"phone_number"`
	Address              string                      `json:"address"`
	Gender               string                      `json:"gender"`
	DateOfBirth          time.Time                   `json:"date_of_birth"`
	PackageCode          string                      `json:"package_code"`
	InitialPackageCode   string                      `json:"initial_package_code"`
	RegistrationDate     time.Time                   `json:"registration_date"`
	MembershipExpiryDate time.Time                   `json:"membership_expiry_date"`
	TotalVisits          uint64                  `json:"total_visits"`
	PhotoPath            *string                 `json:"photo_path"`
	IsActive             bool                    `json:"is_active"`
	Vouchers             []memberVoucherResponse `json:"vouchers"`
	Renewals             []renewalResponse       `json:"renewals"`
	FollowUps            []followUpResponse      `json:"follow_ups"`
	CreatedAt            time.Time               `json:"created_at"`
	UpdatedAt            time.Time               `json:"updated_at"`
}

type followUpResponse struct {
	RecipientEmail string    `json:"recipient_email"`
	Subject        string    `json:"subject"`
	Type           string    `json:"type"`
	SentAt         time.Time `json:"sent_at"`
}

type renewalResponse struct {
	PackageCode        string     `json:"package_code"`
	PackageName        string     `json:"package_name"`
	PreviousExpiryDate *time.Time `json:"previous_expiry_date"`
	NewExpiryDate      time.Time  `json:"new_expiry_date"`
	Amount             float64    `json:"amount"`
	RenewedAt          time.Time  `json:"renewed_at"`
}

// is_active dihitung dari tanggal: member dianggap aktif selama masa
// berlakunya belum lewat (mengikuti logika view member_status).
const memberColumns = `
	id, member_code, full_name, email, phone_number, address, gender,
	date_of_birth, package_code, COALESCE(initial_package_code, package_code),
	registration_date, membership_expiry_date,
	total_visits, photo_path, (membership_expiry_date >= CURDATE()) AS is_active,
	created_at, updated_at
`

func (h *AuthHandler) ListMembers(w http.ResponseWriter, r *http.Request) {
	// Admin & kasir sama-sama boleh membaca daftar member.
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	// Voucher & riwayat perpanjangan dibaca lebih dulu dalam satu query
	// masing-masing agar tidak N+1. Jika tabelnya belum ada, fitur tetap
	// jalan (peta kosong).
	vouchers := h.loadMemberVouchers()
	renewals := h.loadRenewals()
	followUps := h.loadFollowUps()

	rows, err := h.db.Query(`SELECT ` + memberColumns + `
		FROM members ORDER BY membership_expiry_date, full_name, id`)
	if err != nil {
		h.writeMemberDatabaseError(w, err, "gagal mengambil data member")
		return
	}
	defer rows.Close()

	items := make([]memberResponse, 0)
	for rows.Next() {
		item, err := scanMember(rows)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data member")
			return
		}
		if list, ok := vouchers[item.MemberCode]; ok {
			item.Vouchers = list
		} else {
			item.Vouchers = []memberVoucherResponse{}
		}
		if list, ok := renewals[item.MemberCode]; ok {
			item.Renewals = list
		} else {
			item.Renewals = []renewalResponse{}
		}
		if list, ok := followUps[item.MemberCode]; ok {
			item.FollowUps = list
		} else {
			item.FollowUps = []followUpResponse{}
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data member")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

// loadRenewals mengelompokkan riwayat perpanjangan per member_code, sudah
// diurutkan dari yang terbaru. Error (mis. tabel belum dibuat) di-skip.
func (h *AuthHandler) loadRenewals() map[string][]renewalResponse {
	result := map[string][]renewalResponse{}
	rows, err := h.db.Query(`SELECT r.member_code, r.package_code,
		COALESCE(g.package_name, r.package_code), r.previous_expiry_date,
		r.new_expiry_date, r.amount, r.renewed_at
		FROM member_renewals r
		LEFT JOIN gym_packages g ON g.package_code = r.package_code
		ORDER BY r.renewed_at DESC, r.id DESC`)
	if err != nil {
		return result
	}
	defer rows.Close()
	for rows.Next() {
		var code string
		var rr renewalResponse
		var prev sql.NullTime
		if err := rows.Scan(&code, &rr.PackageCode, &rr.PackageName, &prev,
			&rr.NewExpiryDate, &rr.Amount, &rr.RenewedAt); err != nil {
			continue
		}
		if prev.Valid {
			t := prev.Time
			rr.PreviousExpiryDate = &t
		}
		result[code] = append(result[code], rr)
	}
	return result
}

// loadFollowUps mengelompokkan riwayat follow-up per member_code, terbaru
// dulu. Error (mis. tabel belum dibuat) di-skip.
func (h *AuthHandler) loadFollowUps() map[string][]followUpResponse {
	result := map[string][]followUpResponse{}
	rows, err := h.db.Query(`SELECT member_code, recipient_email, subject, follow_up_type, sent_at
		FROM member_follow_ups ORDER BY sent_at DESC, id DESC`)
	if err != nil {
		return result
	}
	defer rows.Close()
	for rows.Next() {
		var code string
		var f followUpResponse
		if err := rows.Scan(&code, &f.RecipientEmail, &f.Subject, &f.Type, &f.SentAt); err != nil {
			continue
		}
		result[code] = append(result[code], f)
	}
	return result
}

type sendFollowUpRequest struct {
	Subject string `json:"subject"`
	Message string `json:"message"`
	Type    string `json:"type"`
}

// SendMemberFollowUp mengirim email follow-up ke alamat email member (diambil
// dari database, bukan dari klien) lalu mencatatnya ke member_follow_ups.
func (h *AuthHandler) SendMemberFollowUp(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	id, ok := parseMemberID(w, r)
	if !ok {
		return
	}

	var req sendFollowUpRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}
	req.Subject = strings.TrimSpace(req.Subject)
	req.Message = strings.TrimSpace(req.Message)
	req.Type = strings.TrimSpace(req.Type)
	if req.Subject == "" || req.Message == "" {
		httpx.WriteError(w, http.StatusBadRequest, "subjek dan pesan wajib diisi")
		return
	}
	if req.Type == "" {
		req.Type = "renewal"
	}

	var code, fullName, email string
	err := h.db.QueryRow(`SELECT member_code, full_name, email FROM members WHERE id = ? LIMIT 1`, id).
		Scan(&code, &fullName, &email)
	if err != nil {
		h.writeMemberDatabaseError(w, err, "gagal membaca data member")
		return
	}

	m := mailer.New(h.cfg)
	if !m.Configured() {
		httpx.WriteError(w, http.StatusServiceUnavailable,
			"email belum dikonfigurasi; isi SMTP_USER dan SMTP_PASSWORD di .env backend")
		return
	}
	if err := m.Send(email, fullName, req.Subject, req.Message); err != nil {
		httpx.WriteError(w, http.StatusBadGateway, "gagal mengirim email: "+err.Error())
		return
	}

	// Pencatatan riwayat bersifat best-effort; kegagalan log tidak
	// membatalkan email yang sudah terkirim.
	_, _ = h.db.Exec(`INSERT INTO member_follow_ups
		(member_code, recipient_email, subject, follow_up_type)
		VALUES (?, ?, ?, ?)`, code, email, req.Subject, req.Type)

	httpx.WriteJSON(w, http.StatusOK, map[string]string{
		"message": "follow-up terkirim ke " + email,
	})
}

func (h *AuthHandler) DeleteMember(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	id, ok := parseMemberID(w, r)
	if !ok {
		return
	}
	result, err := h.db.Exec(`DELETE FROM members WHERE id = ?`, id)
	if err != nil {
		h.writeMemberMutationError(w, err)
		return
	}
	deleted, err := result.RowsAffected()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca hasil hapus member")
		return
	}
	if deleted == 0 {
		httpx.WriteError(w, http.StatusNotFound, "member tidak ditemukan")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]string{"message": "member berhasil dihapus"})
}

type renewMemberRequest struct {
	PackageCode string   `json:"package_code"`
	Amount      *float64 `json:"amount"`
}

// RenewMember mencatat perpanjangan membership: menambah baris ke
// member_renewals dan memperbarui masa berlaku member.
func (h *AuthHandler) RenewMember(w http.ResponseWriter, r *http.Request) {
	// Perpanjangan dilakukan kasir di depan, admin juga boleh.
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}
	id, ok := parseMemberID(w, r)
	if !ok {
		return
	}

	var req renewMemberRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	var memberCode, currentPackage string
	var currentExpiry time.Time
	err := h.db.QueryRow(`SELECT member_code, package_code, membership_expiry_date
		FROM members WHERE id = ? LIMIT 1`, id).Scan(
		&memberCode, &currentPackage, &currentExpiry)
	if err != nil {
		h.writeMemberDatabaseError(w, err, "gagal membaca data member")
		return
	}

	packageCode := strings.TrimSpace(req.PackageCode)
	if packageCode == "" {
		packageCode = currentPackage
	}

	var durationDays int
	var price float64
	err = h.db.QueryRow(`SELECT duration_days, price FROM gym_packages
		WHERE package_code = ? LIMIT 1`, packageCode).Scan(&durationDays, &price)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusBadRequest, "paket gym tidak ditemukan")
			return
		}
		h.writeMemberDatabaseError(w, err, "gagal membaca paket gym")
		return
	}

	amount := price
	if req.Amount != nil && *req.Amount >= 0 {
		amount = *req.Amount
	}

	// Perpanjangan dihitung dari tanggal kedaluwarsa saat ini bila masih aktif,
	// atau dari hari ini bila sudah lewat.
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	base := time.Date(currentExpiry.Year(), currentExpiry.Month(), currentExpiry.Day(),
		0, 0, 0, 0, time.Local)
	if base.Before(today) {
		base = today
	}
	newExpiry := base.AddDate(0, 0, durationDays)

	tx, err := h.db.Begin()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memulai transaksi")
		return
	}
	if _, err := tx.Exec(`INSERT INTO member_renewals
		(member_code, package_code, previous_expiry_date, new_expiry_date, amount, renewed_at)
		VALUES (?, ?, ?, ?, ?, CURDATE())`,
		memberCode, packageCode, currentExpiry, newExpiry, amount); err != nil {
		_ = tx.Rollback()
		h.writeMemberMutationError(w, err)
		return
	}
	if _, err := tx.Exec(`UPDATE members
		SET membership_expiry_date = ?, package_code = ?
		WHERE id = ?`, newExpiry, packageCode, id); err != nil {
		_ = tx.Rollback()
		h.writeMemberMutationError(w, err)
		return
	}
	if err := tx.Commit(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan perpanjangan")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"message":         "perpanjangan berhasil",
		"new_expiry_date": newExpiry.Format("2006-01-02"),
		"amount":          amount,
	})
}

func parseMemberID(w http.ResponseWriter, r *http.Request) (uint64, bool) {
	id, err := strconv.ParseUint(r.PathValue("id"), 10, 64)
	if err != nil || id == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "ID member tidak valid")
		return 0, false
	}
	return id, true
}

func scanMember(row rowScanner) (memberResponse, error) {
	var item memberResponse
	var photoPath sql.NullString
	err := row.Scan(&item.ID, &item.MemberCode, &item.FullName, &item.Email,
		&item.PhoneNumber, &item.Address, &item.Gender, &item.DateOfBirth,
		&item.PackageCode, &item.InitialPackageCode, &item.RegistrationDate,
		&item.MembershipExpiryDate,
		&item.TotalVisits, &photoPath, &item.IsActive, &item.CreatedAt, &item.UpdatedAt)
	if photoPath.Valid {
		item.PhotoPath = &photoPath.String
	}
	return item, err
}

func (h *AuthHandler) writeMemberMutationError(w http.ResponseWriter, err error) {
	message := strings.ToLower(err.Error())
	if strings.Contains(message, "foreign key") {
		httpx.WriteError(w, http.StatusConflict, "member sudah dipakai dalam transaksi dan tidak dapat dihapus")
		return
	}
	h.writeMemberDatabaseError(w, err, "gagal menyimpan data member")
}

func (h *AuthHandler) writeMemberDatabaseError(w http.ResponseWriter, err error, fallback string) {
	if errors.Is(err, sql.ErrNoRows) {
		httpx.WriteError(w, http.StatusNotFound, "member tidak ditemukan")
		return
	}
	lower := strings.ToLower(err.Error())
	if strings.Contains(lower, "doesn't exist") {
		httpx.WriteError(w, http.StatusServiceUnavailable, "tabel member belum tersedia; jalankan module/member.txt")
		return
	}
	if strings.Contains(lower, "unknown column") {
		httpx.WriteError(w, http.StatusServiceUnavailable, "kolom kunjungan/voucher belum ada; jalankan module/kunjungan-voucher.txt")
		return
	}
	httpx.WriteError(w, http.StatusInternalServerError, fallback)
}
