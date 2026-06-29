package handler

import (
	"database/sql"
	"errors"
	"net/http"
	"strconv"
	"time"

	"pos-gym/backend/internal/httpx"
)

// Setiap kelipatan kunjungan ini member mendapat 1 voucher F&B.
const voucherVisitsPerMilestone = 50

// Siklus diskon voucher tiap kelipatan 50 kunjungan, berulang tiap 6 milestone
// (300 kunjungan): 10 -> 25 -> 35 -> 45 -> 55 -> 70 -> (ulang) 10 -> ...
var voucherCycle = []int{10, 25, 35, 45, 55, 70}

func startOfToday() time.Time {
	now := time.Now()
	return time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
}

func dateOnly(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.Local)
}

// memberVoucherResponse = satu voucher F&B lengkap dengan status lifecycle.
type memberVoucherResponse struct {
	Percent        int        `json:"percent"`
	VisitMilestone int        `json:"visit_milestone"`
	ActivatedAt    time.Time  `json:"activated_at"`
	ExpiresAt      time.Time  `json:"expires_at"`
	UsedAt         *time.Time `json:"used_at"`
	Status         string     `json:"status"` // active | used | expired
}

// loadMemberVouchers mengelompokkan voucher per member_code; status dihitung
// dari used_at/expires_at. Error (tabel belum ada) di-skip agar daftar member
// tetap tampil.
func (h *AuthHandler) loadMemberVouchers() map[string][]memberVoucherResponse {
	result := map[string][]memberVoucherResponse{}
	rows, err := h.db.Query(`SELECT member_code, voucher_percent, visit_milestone,
		activated_at, expires_at, used_at
		FROM member_vouchers ORDER BY visit_milestone`)
	if err != nil {
		return result
	}
	defer rows.Close()
	today := startOfToday()
	for rows.Next() {
		var code string
		var v memberVoucherResponse
		var used sql.NullTime
		if err := rows.Scan(&code, &v.Percent, &v.VisitMilestone,
			&v.ActivatedAt, &v.ExpiresAt, &used); err != nil {
			continue
		}
		switch {
		case used.Valid:
			t := used.Time
			v.UsedAt = &t
			v.Status = "used"
		case dateOnly(v.ExpiresAt).Before(today):
			v.Status = "expired"
		default:
			v.Status = "active"
		}
		result[code] = append(result[code], v)
	}
	return result
}

// createVoucherOnMilestone membuat voucher baru bila total kunjungan member
// menjadi kelipatan voucherVisitsPerMilestone. Follow-up email-nya dikirim
// manual oleh admin (bukan otomatis).
func (h *AuthHandler) createVoucherOnMilestone(memberCode string, totalVisits int) {
	if totalVisits <= 0 || totalVisits%voucherVisitsPerMilestone != 0 {
		return
	}
	index := totalVisits / voucherVisitsPerMilestone
	percent := voucherCycle[(index-1)%len(voucherCycle)]
	_, _ = h.db.Exec(`INSERT IGNORE INTO member_vouchers
		(member_code, visit_milestone, voucher_percent, activated_at, expires_at)
		VALUES (?, ?, ?, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY))`,
		memberCode, totalVisits, percent)
}

// RedeemVoucher menandai voucher AKTIF sebagai DIPAKAI (kasir/admin). Voucher
// yang sudah dipakai atau sudah lewat 30 hari (hangus) ditolak.
func (h *AuthHandler) RedeemVoucher(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}
	id, ok := parseMemberID(w, r)
	if !ok {
		return
	}
	milestone, err := strconv.Atoi(r.PathValue("milestone"))
	if err != nil || milestone <= 0 {
		httpx.WriteError(w, http.StatusBadRequest, "milestone voucher tidak valid")
		return
	}

	var memberCode string
	if err := h.db.QueryRow(`SELECT member_code FROM members WHERE id = ? LIMIT 1`, id).
		Scan(&memberCode); err != nil {
		h.writeMemberDatabaseError(w, err, "gagal membaca data member")
		return
	}

	res, err := h.db.Exec(`UPDATE member_vouchers SET used_at = CURDATE()
		WHERE member_code = ? AND visit_milestone = ?
		  AND used_at IS NULL AND expires_at >= CURDATE()`, memberCode, milestone)
	if err != nil {
		h.writeMemberDatabaseError(w, err, "gagal menukar voucher")
		return
	}
	if affected, _ := res.RowsAffected(); affected == 0 {
		var used sql.NullTime
		var expires time.Time
		qerr := h.db.QueryRow(`SELECT used_at, expires_at FROM member_vouchers
			WHERE member_code = ? AND visit_milestone = ? LIMIT 1`, memberCode, milestone).
			Scan(&used, &expires)
		switch {
		case errors.Is(qerr, sql.ErrNoRows):
			httpx.WriteError(w, http.StatusNotFound, "voucher tidak ditemukan")
		case qerr != nil:
			h.writeMemberDatabaseError(w, qerr, "gagal membaca voucher")
		case used.Valid:
			httpx.WriteError(w, http.StatusConflict, "voucher sudah dipakai")
		default:
			httpx.WriteError(w, http.StatusConflict, "voucher sudah hangus (lewat 30 hari)")
		}
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]string{"message": "voucher berhasil dipakai"})
}
