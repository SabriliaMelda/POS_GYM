package handler

import (
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"errors"
	"net/http"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

type registerInfoResponse struct {
	TransactionCode   string `json:"transaction_code"`
	CustomerName      string `json:"customer_name"`
	PackageCode       string `json:"package_code"`
	PackageName       string `json:"package_name"`
	AlreadyRegistered bool   `json:"already_registered"`
	MemberCode        string `json:"member_code"`
}

// RegisterInfo (PUBLIK) — data untuk halaman registrasi member dari kode
// transaksi gym tipe "new". Dipakai HP member sebelum mengisi form.
func (h *AuthHandler) RegisterInfo(w http.ResponseWriter, r *http.Request) {
	trx := strings.ToUpper(strings.TrimSpace(r.URL.Query().Get("trx")))
	if trx == "" {
		httpx.WriteError(w, http.StatusBadRequest, "kode transaksi kosong")
		return
	}

	var resp registerInfoResponse
	var packageName, memberCode sql.NullString
	err := h.db.QueryRow(`SELECT t.transaction_code, t.customer_name, t.package_code,
		g.package_name, t.member_code
		FROM gym_transactions t
		LEFT JOIN gym_packages g ON g.package_code = t.package_code
		WHERE t.transaction_code = ? AND t.customer_type = 'new' LIMIT 1`, trx).Scan(
		&resp.TransactionCode, &resp.CustomerName, &resp.PackageCode,
		&packageName, &memberCode)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "transaksi registrasi tidak ditemukan")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi")
		return
	}
	if packageName.Valid {
		resp.PackageName = packageName.String
	} else {
		resp.PackageName = resp.PackageCode
	}
	if memberCode.Valid && memberCode.String != "" {
		resp.AlreadyRegistered = true
		resp.MemberCode = memberCode.String
	}
	httpx.WriteJSON(w, http.StatusOK, resp)
}

type registerMemberRequest struct {
	Trx         string `json:"trx"`
	FullName    string `json:"full_name"`
	Email       string `json:"email"`
	PhoneNumber string `json:"phone_number"`
	Address     string `json:"address"`
	Gender      string `json:"gender"`
	DateOfBirth string `json:"date_of_birth"` // YYYY-MM-DD
}

// RegisterMember (PUBLIK) — membuat member baru dari form HP, memakai paket dari
// transaksi gym, lalu menautkan member_code ke transaksi tersebut.
func (h *AuthHandler) RegisterMember(w http.ResponseWriter, r *http.Request) {
	var req registerMemberRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	trx := strings.ToUpper(strings.TrimSpace(req.Trx))
	fullName := strings.TrimSpace(req.FullName)
	email := strings.ToLower(strings.TrimSpace(req.Email))
	phone := strings.TrimSpace(req.PhoneNumber)
	address := strings.TrimSpace(req.Address)
	gender := strings.TrimSpace(req.Gender)
	dob := strings.TrimSpace(req.DateOfBirth)

	switch {
	case trx == "":
		httpx.WriteError(w, http.StatusBadRequest, "kode transaksi kosong")
		return
	case fullName == "":
		httpx.WriteError(w, http.StatusBadRequest, "nama wajib diisi")
		return
	case email == "" || !strings.Contains(email, "@"):
		httpx.WriteError(w, http.StatusBadRequest, "email tidak valid")
		return
	case phone == "":
		httpx.WriteError(w, http.StatusBadRequest, "nomor HP wajib diisi")
		return
	case address == "":
		httpx.WriteError(w, http.StatusBadRequest, "alamat wajib diisi")
		return
	case gender != "Male" && gender != "Female":
		httpx.WriteError(w, http.StatusBadRequest, "jenis kelamin harus Male atau Female")
		return
	}
	if _, err := time.Parse("2006-01-02", dob); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "tanggal lahir tidak valid (YYYY-MM-DD)")
		return
	}

	// Ambil paket + status registrasi dari transaksi.
	var packageCode string
	var existingMember sql.NullString
	err := h.db.QueryRow(`SELECT package_code, member_code FROM gym_transactions
		WHERE transaction_code = ? AND customer_type = 'new' LIMIT 1`, trx).Scan(
		&packageCode, &existingMember)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "transaksi registrasi tidak ditemukan")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca transaksi")
		return
	}
	if existingMember.Valid && existingMember.String != "" {
		httpx.WriteError(w, http.StatusConflict, "transaksi ini sudah terdaftar sebagai member")
		return
	}

	var durationDays int
	if err := h.db.QueryRow(`SELECT duration_days FROM gym_packages WHERE package_code = ? LIMIT 1`,
		packageCode).Scan(&durationDays); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "paket transaksi tidak ditemukan")
		return
	}

	memberCode, err := randomMemberCode()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat kode member")
		return
	}

	now := time.Now()
	regDate := now.Format("2006-01-02")
	expiry := now.AddDate(0, 0, durationDays).Format("2006-01-02")

	tx, err := h.db.Begin()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memulai transaksi")
		return
	}

	// package_code = initial_package_code = paket saat pertama daftar.
	_, err = tx.Exec(`INSERT INTO members
		(member_code, full_name, email, phone_number, address, gender, date_of_birth,
		 package_code, initial_package_code, registration_date, membership_expiry_date)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
		memberCode, fullName, email, phone, address, gender, dob,
		packageCode, packageCode, regDate, expiry)
	if err != nil {
		_ = tx.Rollback()
		msg := strings.ToLower(err.Error())
		if strings.Contains(msg, "duplicate") {
			if strings.Contains(msg, "email") {
				httpx.WriteError(w, http.StatusConflict, "email sudah terdaftar")
				return
			}
			httpx.WriteError(w, http.StatusConflict, "data sudah terdaftar")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan member")
		return
	}

	if _, err := tx.Exec(`UPDATE gym_transactions SET member_code = ? WHERE transaction_code = ?`,
		memberCode, trx); err != nil {
		_ = tx.Rollback()
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menautkan transaksi")
		return
	}

	if err := tx.Commit(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyelesaikan registrasi")
		return
	}

	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message":     "registrasi berhasil",
		"member_code": memberCode,
		"full_name":   fullName,
	})
}

func randomMemberCode() (string, error) {
	buf := make([]byte, 4)
	if _, err := rand.Read(buf); err != nil {
		return "", err
	}
	return "MBR-" + strings.ToUpper(hex.EncodeToString(buf)), nil
}
