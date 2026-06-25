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

type fnbItemResponse struct {
	ID          uint64    `json:"id"`
	ItemID      string    `json:"item_id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	Category    string    `json:"category"`
	MemberPrice float64   `json:"member_price"`
	Price       float64   `json:"price"`
	Stock       uint64    `json:"stock"`
	ImagePath   *string   `json:"image_path"`
	IsActive    bool      `json:"is_active"`
	CreatedAt   time.Time `json:"created_at"`
	UpdatedAt   time.Time `json:"updated_at"`
}

type saveFNBItemRequest struct {
	ItemID      string  `json:"item_id"`
	Name        string  `json:"name"`
	Description string  `json:"description"`
	Category    string  `json:"category"`
	MemberPrice float64 `json:"member_price"`
	Price       float64 `json:"price"`
	Stock       int64   `json:"stock"`
	ImagePath   string  `json:"image_path"`
	IsActive    bool    `json:"is_active"`
}

const fnbItemColumns = `
	id, item_id, name, description, category, member_price, price, stock,
	image_path, is_active, created_at, updated_at
`

func (h *AuthHandler) ListFNBItems(w http.ResponseWriter, r *http.Request) {
	// Baca menu boleh oleh semua user terautentikasi (admin maupun kasir),
	// konsisten dengan ListGymPackages. Mutasi tetap khusus admin.
	if _, ok := h.requireAuthenticated(w, r); !ok {
		return
	}

	rows, err := h.db.Query(`SELECT ` + fnbItemColumns + `
		FROM food_beverage_items
		ORDER BY category, name, id`)
	if err != nil {
		h.writeFNBDatabaseError(w, err, "gagal mengambil master data F&B")
		return
	}
	defer rows.Close()

	items := make([]fnbItemResponse, 0)
	for rows.Next() {
		item, err := scanFNBItem(rows)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca master data F&B")
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca master data F&B")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{"items": items})
}

func (h *AuthHandler) CreateFNBItem(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	req, ok := readAndValidateFNBItem(w, r)
	if !ok {
		return
	}

	result, err := h.db.Exec(`
		INSERT INTO food_beverage_items (
			item_id, name, description, category, member_price, price,
			stock, image_path, is_active
		) VALUES (?, ?, ?, ?, ?, ?, ?, NULLIF(?, ''), ?)
	`, req.ItemID, req.Name, req.Description, req.Category, req.MemberPrice,
		req.Price, req.Stock, req.ImagePath, req.IsActive)
	if err != nil {
		h.writeFNBMutationError(w, err)
		return
	}

	id, err := result.LastInsertId()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "menu dibuat, tetapi ID gagal dibaca")
		return
	}
	item, err := h.findFNBItem(uint64(id))
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "menu dibuat, tetapi data gagal dibaca")
		return
	}

	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message": "menu F&B berhasil ditambahkan",
		"item":    item,
	})
}

func (h *AuthHandler) UpdateFNBItem(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	id, ok := parseFNBItemID(w, r)
	if !ok {
		return
	}
	req, ok := readAndValidateFNBItem(w, r)
	if !ok {
		return
	}
	oldItem, err := h.findFNBItem(id)
	if err != nil {
		h.writeFNBDatabaseError(w, err, "gagal membaca menu F&B")
		return
	}

	_, err = h.db.Exec(`
		UPDATE food_beverage_items
		SET item_id = ?, name = ?, description = ?, category = ?,
			member_price = ?, price = ?, stock = ?, image_path = NULLIF(?, ''),
			is_active = ?
		WHERE id = ?
	`, req.ItemID, req.Name, req.Description, req.Category, req.MemberPrice,
		req.Price, req.Stock, req.ImagePath, req.IsActive, id)
	if err != nil {
		h.writeFNBMutationError(w, err)
		return
	}
	if oldItem.ImagePath != nil && *oldItem.ImagePath != req.ImagePath {
		removeManagedFNBImage(*oldItem.ImagePath)
	}

	item, err := h.findFNBItem(id)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "menu diperbarui, tetapi data gagal dibaca")
		return
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"message": "menu F&B berhasil diperbarui",
		"item":    item,
	})
}

func (h *AuthHandler) DeleteFNBItem(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}
	id, ok := parseFNBItemID(w, r)
	if !ok {
		return
	}
	item, err := h.findFNBItem(id)
	if err != nil {
		h.writeFNBDatabaseError(w, err, "gagal membaca menu F&B")
		return
	}

	result, err := h.db.Exec(`DELETE FROM food_beverage_items WHERE id = ?`, id)
	if err != nil {
		h.writeFNBMutationError(w, err)
		return
	}
	deleted, err := result.RowsAffected()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca hasil hapus menu")
		return
	}
	if deleted == 0 {
		httpx.WriteError(w, http.StatusNotFound, "menu F&B tidak ditemukan")
		return
	}
	if item.ImagePath != nil {
		removeManagedFNBImage(*item.ImagePath)
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]string{"message": "menu F&B berhasil dihapus"})
}

func readAndValidateFNBItem(w http.ResponseWriter, r *http.Request) (saveFNBItemRequest, bool) {
	var req saveFNBItemRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return req, false
	}
	req.ItemID = strings.ToUpper(strings.TrimSpace(req.ItemID))
	req.Name = strings.TrimSpace(req.Name)
	req.Description = strings.TrimSpace(req.Description)
	req.Category = normalizeFNBCategory(req.Category)
	req.ImagePath = strings.TrimSpace(req.ImagePath)

	switch {
	case req.ItemID == "" || req.Name == "":
		httpx.WriteError(w, http.StatusBadRequest, "kode dan nama wajib diisi")
	case req.Category == "":
		httpx.WriteError(w, http.StatusBadRequest, "kategori harus Makanan, Minuman, atau Appetizer")
	case len(req.ItemID) > 20:
		httpx.WriteError(w, http.StatusBadRequest, "kode menu maksimal 20 karakter")
	case len(req.Name) > 150:
		httpx.WriteError(w, http.StatusBadRequest, "nama menu terlalu panjang")
	case req.MemberPrice < 0 || req.Price < 0:
		httpx.WriteError(w, http.StatusBadRequest, "harga tidak boleh negatif")
	case req.MemberPrice > req.Price:
		httpx.WriteError(w, http.StatusBadRequest, "harga member tidak boleh melebihi harga non-member")
	case req.Stock < 0:
		httpx.WriteError(w, http.StatusBadRequest, "stok tidak boleh negatif")
	default:
		return req, true
	}
	return req, false
}

// normalizeFNBCategory membatasi kategori ke tiga pilihan tetap.
// Mengembalikan bentuk kanonik berkapital, atau "" bila tidak valid.
func normalizeFNBCategory(raw string) string {
	switch strings.ToLower(strings.TrimSpace(raw)) {
	case "makanan":
		return "Makanan"
	case "minuman":
		return "Minuman"
	case "appetizer":
		return "Appetizer"
	case "additional":
		return "Additional"
	default:
		return ""
	}
}

func parseFNBItemID(w http.ResponseWriter, r *http.Request) (uint64, bool) {
	id, err := strconv.ParseUint(r.PathValue("id"), 10, 64)
	if err != nil || id == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "ID menu tidak valid")
		return 0, false
	}
	return id, true
}

type rowScanner interface {
	Scan(dest ...any) error
}

func scanFNBItem(row rowScanner) (fnbItemResponse, error) {
	var item fnbItemResponse
	var imagePath sql.NullString
	err := row.Scan(&item.ID, &item.ItemID, &item.Name, &item.Description,
		&item.Category, &item.MemberPrice, &item.Price, &item.Stock,
		&imagePath, &item.IsActive, &item.CreatedAt, &item.UpdatedAt)
	if imagePath.Valid {
		item.ImagePath = &imagePath.String
	}
	return item, err
}

func (h *AuthHandler) findFNBItem(id uint64) (fnbItemResponse, error) {
	return scanFNBItem(h.db.QueryRow(`SELECT `+fnbItemColumns+`
		FROM food_beverage_items WHERE id = ? LIMIT 1`, id))
}

func (h *AuthHandler) writeFNBMutationError(w http.ResponseWriter, err error) {
	message := strings.ToLower(err.Error())
	if strings.Contains(message, "duplicate") || strings.Contains(message, "uq_food_beverage_items_item_id") {
		httpx.WriteError(w, http.StatusConflict, "kode menu sudah digunakan")
		return
	}
	if strings.Contains(message, "foreign key") {
		httpx.WriteError(w, http.StatusConflict, "menu sudah dipakai dalam transaksi dan tidak dapat dihapus")
		return
	}
	h.writeFNBDatabaseError(w, err, "gagal menyimpan master data F&B")
}

func (h *AuthHandler) writeFNBDatabaseError(w http.ResponseWriter, err error, fallback string) {
	if errors.Is(err, sql.ErrNoRows) {
		httpx.WriteError(w, http.StatusNotFound, "menu F&B tidak ditemukan")
		return
	}
	if strings.Contains(strings.ToLower(err.Error()), "doesn't exist") {
		httpx.WriteError(w, http.StatusServiceUnavailable, "tabel F&B belum tersedia; jalankan module/masterdata.txt")
		return
	}
	httpx.WriteError(w, http.StatusInternalServerError, fallback)
}
