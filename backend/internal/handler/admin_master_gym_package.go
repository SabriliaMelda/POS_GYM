package handler

import (
	"database/sql"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"pos-gym/backend/internal/httpx"
)

type gymPackageResponse struct {
	ID           uint64    `json:"id"`
	PackageCode  string    `json:"package_code"`
	PackageName  string    `json:"package_name"`
	Description  string    `json:"description"`
	Price        float64   `json:"price"`
	PackageType  string    `json:"package_type"`
	DurationDays uint64    `json:"duration_days"`
	IsActive     bool      `json:"is_active"`
	CreatedAt    time.Time `json:"created_at"`
	UpdatedAt    time.Time `json:"updated_at"`
}

type saveGymPackageRequest struct {
	PackageCode  string  `json:"package_code"`
	PackageName  string  `json:"package_name"`
	Description  string  `json:"description"`
	Price        float64 `json:"price"`
	PackageType  string  `json:"package_type"`
	DurationDays int64   `json:"duration_days"`
	IsActive     bool    `json:"is_active"`
}

const gymPackageColumns = `
	id, package_code, package_name, COALESCE(description, ''), price,
	package_type, duration_days, is_active, created_at, updated_at
`

func (h *AuthHandler) ListGymPackages(w http.ResponseWriter, r *http.Request) {
	// Admin & kasir sama-sama boleh membaca daftar paket.
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}
	rows, err := h.db.Query(`SELECT ` + gymPackageColumns + `
		FROM gym_packages ORDER BY package_type, duration_days, id`)
	if err != nil {
		h.writeGymPackageDatabaseError(w, err, "gagal mengambil paket gym")
		return
	}
	defer rows.Close()

	items := make([]gymPackageResponse, 0)
	for rows.Next() {
		item, err := scanGymPackage(rows)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca paket gym")
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca paket gym")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *AuthHandler) CreateGymPackage(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	req, ok := readAndValidateGymPackage(w, r)
	if !ok {
		return
	}
	result, err := h.db.Exec(`INSERT INTO gym_packages
		(package_code, package_name, description, price, package_type, duration_days, is_active)
		VALUES (?, ?, NULLIF(?, ''), ?, ?, ?, ?)`, req.PackageCode, req.PackageName,
		req.Description, req.Price, req.PackageType, req.DurationDays, req.IsActive)
	if err != nil {
		h.writeGymPackageMutationError(w, err)
		return
	}
	id, err := result.LastInsertId()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "paket dibuat, tetapi ID gagal dibaca")
		return
	}
	item, err := h.findGymPackage(uint64(id))
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "paket dibuat, tetapi data gagal dibaca")
		return
	}
	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message": "paket gym berhasil ditambahkan", "item": item,
	})
}

func (h *AuthHandler) UpdateGymPackage(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	id, ok := parseGymPackageID(w, r)
	if !ok {
		return
	}
	req, ok := readAndValidateGymPackage(w, r)
	if !ok {
		return
	}
	if _, err := h.findGymPackage(id); err != nil {
		h.writeGymPackageDatabaseError(w, err, "gagal membaca paket gym")
		return
	}
	_, err := h.db.Exec(`UPDATE gym_packages SET package_code = ?, package_name = ?,
		description = NULLIF(?, ''), price = ?, package_type = ?, duration_days = ?, is_active = ?
		WHERE id = ?`, req.PackageCode, req.PackageName, req.Description, req.Price,
		req.PackageType, req.DurationDays, req.IsActive, id)
	if err != nil {
		h.writeGymPackageMutationError(w, err)
		return
	}
	item, err := h.findGymPackage(id)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "paket diperbarui, tetapi data gagal dibaca")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"message": "paket gym berhasil diperbarui", "item": item,
	})
}

func (h *AuthHandler) DeleteGymPackage(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	id, ok := parseGymPackageID(w, r)
	if !ok {
		return
	}
	result, err := h.db.Exec(`DELETE FROM gym_packages WHERE id = ?`, id)
	if err != nil {
		h.writeGymPackageMutationError(w, err)
		return
	}
	deleted, err := result.RowsAffected()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca hasil hapus paket")
		return
	}
	if deleted == 0 {
		httpx.WriteError(w, http.StatusNotFound, "paket gym tidak ditemukan")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]string{"message": "paket gym berhasil dihapus"})
}

func readAndValidateGymPackage(w http.ResponseWriter, r *http.Request) (saveGymPackageRequest, bool) {
	var req saveGymPackageRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return req, false
	}
	req.PackageCode = strings.ToUpper(strings.TrimSpace(req.PackageCode))
	req.PackageName = strings.TrimSpace(req.PackageName)
	req.Description = strings.TrimSpace(req.Description)
	req.PackageType = strings.ToLower(strings.TrimSpace(req.PackageType))
	switch {
	case req.PackageCode == "" || req.PackageName == "":
		httpx.WriteError(w, http.StatusBadRequest, "kode dan nama paket wajib diisi")
	case len(req.PackageCode) > 20 || len(req.PackageName) > 100:
		httpx.WriteError(w, http.StatusBadRequest, "kode atau nama paket terlalu panjang")
	case len(req.Description) > 255:
		httpx.WriteError(w, http.StatusBadRequest, "keterangan maksimal 255 karakter")
	case req.Price < 0:
		httpx.WriteError(w, http.StatusBadRequest, "harga tidak boleh negatif")
	case req.PackageType != "membership" && req.PackageType != "daily":
		httpx.WriteError(w, http.StatusBadRequest, "tipe paket harus membership atau daily")
	case req.DurationDays <= 0 || req.DurationDays > 3650:
		httpx.WriteError(w, http.StatusBadRequest, "durasi paket harus 1 sampai 3650 hari")
	default:
		return req, true
	}
	return req, false
}

func parseGymPackageID(w http.ResponseWriter, r *http.Request) (uint64, bool) {
	id, err := strconv.ParseUint(r.PathValue("id"), 10, 64)
	if err != nil || id == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "ID paket tidak valid")
		return 0, false
	}
	return id, true
}

func scanGymPackage(row rowScanner) (gymPackageResponse, error) {
	var item gymPackageResponse
	err := row.Scan(&item.ID, &item.PackageCode, &item.PackageName, &item.Description,
		&item.Price, &item.PackageType, &item.DurationDays, &item.IsActive,
		&item.CreatedAt, &item.UpdatedAt)
	return item, err
}

func (h *AuthHandler) findGymPackage(id uint64) (gymPackageResponse, error) {
	return scanGymPackage(h.db.QueryRow(`SELECT `+gymPackageColumns+`
		FROM gym_packages WHERE id = ? LIMIT 1`, id))
}

func (h *AuthHandler) writeGymPackageMutationError(w http.ResponseWriter, err error) {
	message := strings.ToLower(err.Error())
	if strings.Contains(message, "duplicate") || strings.Contains(message, "uq_gym_packages_code") {
		httpx.WriteError(w, http.StatusConflict, "kode paket sudah digunakan")
		return
	}
	if strings.Contains(message, "foreign key") {
		httpx.WriteError(w, http.StatusConflict, "paket sudah dipakai dalam transaksi dan tidak dapat dihapus")
		return
	}
	h.writeGymPackageDatabaseError(w, err, "gagal menyimpan paket gym")
}

func (h *AuthHandler) writeGymPackageDatabaseError(w http.ResponseWriter, err error, fallback string) {
	if errors.Is(err, sql.ErrNoRows) {
		httpx.WriteError(w, http.StatusNotFound, "paket gym tidak ditemukan")
		return
	}
	if strings.Contains(strings.ToLower(err.Error()), "doesn't exist") {
		httpx.WriteError(w, http.StatusServiceUnavailable, "tabel paket gym belum tersedia; jalankan module/gymsql.txt")
		return
	}
	httpx.WriteError(w, http.StatusInternalServerError, fallback)
}
