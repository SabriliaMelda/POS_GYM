package handler

import (
	"database/sql"
	"errors"
	"net/http"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

type attendanceResponse struct {
	ID             uint64    `json:"id"`
	MemberCode     string    `json:"member_code"`
	MemberName     string    `json:"member_name"`
	AttendanceDate string    `json:"attendance_date"`
	CheckInTime    string    `json:"check_in_time"`
	Method         string    `json:"method"`
	CheckInAt      time.Time `json:"check_in_at"`
}

type checkInRequest struct {
	MemberCode string `json:"member_code"`
}

// CheckInAttendance dipanggil dari HP member (PUBLIK, tanpa login) saat memindai
// barcode absensi. Mencatat kehadiran hari ini bila belum ada; bila sudah,
// mengembalikan status "sudah hadir".
func (h *AuthHandler) CheckInAttendance(w http.ResponseWriter, r *http.Request) {
	var req checkInRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "permintaan tidak valid")
		return
	}
	code := strings.ToUpper(strings.TrimSpace(req.MemberCode))
	if code == "" {
		httpx.WriteError(w, http.StatusBadRequest, "kode member kosong")
		return
	}

	var fullName string
	var expiry time.Time
	err := h.db.QueryRow(
		`SELECT full_name, membership_expiry_date FROM members WHERE member_code = ? LIMIT 1`,
		code).Scan(&fullName, &expiry)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "barcode tidak terdaftar")
			return
		}
		h.writeAttendanceDBError(w, err, "gagal membaca data member")
		return
	}

	// Tolak bila masa berlaku membership sudah lewat.
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	expDay := time.Date(expiry.Year(), expiry.Month(), expiry.Day(), 0, 0, 0, 0, time.Local)
	if expDay.Before(today) {
		httpx.WriteError(w, http.StatusForbidden, "membership "+fullName+" sudah tidak aktif")
		return
	}

	// Catat kehadiran hari ini. UNIQUE(member_code, attendance_date) mencegah ganda.
	res, err := h.db.Exec(
		`INSERT IGNORE INTO attendance (member_code, member_name, attendance_date, method)
		 VALUES (?, ?, CURDATE(), 'barcode')`, code, fullName)
	if err != nil {
		h.writeAttendanceDBError(w, err, "gagal mencatat kehadiran")
		return
	}
	affected, _ := res.RowsAffected()
	already := affected == 0

	var checkInAt time.Time
	_ = h.db.QueryRow(
		`SELECT check_in_at FROM attendance WHERE member_code = ? AND attendance_date = CURDATE() LIMIT 1`,
		code).Scan(&checkInAt)

	status := http.StatusCreated
	message := "Hadir tercatat. Selamat berlatih, " + fullName + "!"
	if already {
		status = http.StatusOK
		message = fullName + " sudah tercatat hadir hari ini."
	}

	httpx.WriteJSON(w, status, map[string]any{
		"message":       message,
		"member_name":   fullName,
		"already":       already,
		"check_in_time": checkInAt.Format("15:04"),
	})
}

// LookupMemberForCheckIn (PUBLIK) mengembalikan nama member dari member_code,
// dipakai halaman konfirmasi di HP untuk menampilkan nama sebelum tekan "Hadir".
func (h *AuthHandler) LookupMemberForCheckIn(w http.ResponseWriter, r *http.Request) {
	code := strings.ToUpper(strings.TrimSpace(r.URL.Query().Get("code")))
	if code == "" {
		httpx.WriteError(w, http.StatusBadRequest, "kode member kosong")
		return
	}

	var fullName string
	var expiry time.Time
	err := h.db.QueryRow(
		`SELECT full_name, membership_expiry_date FROM members WHERE member_code = ? LIMIT 1`,
		code).Scan(&fullName, &expiry)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusNotFound, "barcode tidak terdaftar")
			return
		}
		h.writeAttendanceDBError(w, err, "gagal membaca data member")
		return
	}

	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	expDay := time.Date(expiry.Year(), expiry.Month(), expiry.Day(), 0, 0, 0, 0, time.Local)

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"member_code": code,
		"member_name": fullName,
		"active":      !expDay.Before(today),
	})
}

// ListAttendance mengembalikan data absensi untuk panel kasir (butuh login).
func (h *AuthHandler) ListAttendance(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	rows, err := h.db.Query(`SELECT id, member_code, member_name, attendance_date,
		check_in_at, method
		FROM attendance
		ORDER BY check_in_at DESC
		LIMIT 300`)
	if err != nil {
		h.writeAttendanceDBError(w, err, "gagal mengambil data absensi")
		return
	}
	defer rows.Close()

	items := make([]attendanceResponse, 0)
	for rows.Next() {
		var item attendanceResponse
		var date, checkInAt time.Time
		if err := rows.Scan(&item.ID, &item.MemberCode, &item.MemberName,
			&date, &checkInAt, &item.Method); err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data absensi")
			return
		}
		item.AttendanceDate = date.Format("2006-01-02")
		item.CheckInAt = checkInAt
		item.CheckInTime = checkInAt.Format("15:04")
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data absensi")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *AuthHandler) writeAttendanceDBError(w http.ResponseWriter, err error, fallback string) {
	if strings.Contains(strings.ToLower(err.Error()), "doesn't exist") {
		httpx.WriteError(w, http.StatusServiceUnavailable,
			"tabel absensi belum tersedia; jalankan module/absensi.txt")
		return
	}
	httpx.WriteError(w, http.StatusInternalServerError, fallback)
}
