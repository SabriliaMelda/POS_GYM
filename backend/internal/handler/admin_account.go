package handler

import (
	"database/sql"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"time"

	"pos-gym/backend/internal/auth"
	"pos-gym/backend/internal/httpx"
)

type createCashierRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	FullName string `json:"full_name"`
}

type updateProfileRequest struct {
	Username        string `json:"username"`
	FullName        string `json:"full_name"`
	CurrentPassword string `json:"current_password"`
	NewPassword     string `json:"new_password"`
}

type resetCashierPasswordRequest struct {
	Password string `json:"password"`
}

func (h *AuthHandler) ListCashiers(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	rows, err := h.db.Query(`
		SELECT id, username, full_name, role, is_active, must_change_password
		FROM users
		WHERE role = 'kasir'
		ORDER BY created_at DESC, id DESC
	`)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal mengambil data kasir")
		return
	}
	defer rows.Close()

	cashiers := make([]userResponse, 0)
	for rows.Next() {
		var cashier userResponse
		if err := rows.Scan(
			&cashier.ID,
			&cashier.Username,
			&cashier.FullName,
			&cashier.Role,
			&cashier.IsActive,
			&cashier.MustChangePassword,
		); err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data kasir")
			return
		}
		cashiers = append(cashiers, cashier)
	}
	if err := rows.Err(); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data kasir")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"cashiers": cashiers,
	})
}

func (h *AuthHandler) CreateCashier(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireAdmin(w, r)
	if !ok {
		return
	}

	adminID, err := strconv.ParseUint(claims.Subject, 10, 64)
	if err != nil || adminID == 0 {
		httpx.WriteError(w, http.StatusUnauthorized, "token tidak valid")
		return
	}

	var req createCashierRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	req.Username = strings.TrimSpace(req.Username)
	req.FullName = strings.TrimSpace(req.FullName)
	if validationError := validateAccountInput(req.Username, req.FullName, req.Password); validationError != "" {
		httpx.WriteError(w, http.StatusBadRequest, validationError)
		return
	}

	passwordHash, err := auth.HashPassword(req.Password)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat hash password")
		return
	}

	result, err := h.db.Exec(`
		INSERT INTO users (
			username,
			password_hash,
			full_name,
			role,
			is_active,
			must_change_password,
			created_by
		) VALUES (?, ?, ?, 'kasir', 1, 1, ?)
	`, req.Username, passwordHash, req.FullName, adminID)
	if err != nil {
		h.writeUserMutationError(w, err)
		return
	}

	id, err := result.LastInsertId()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "akun kasir dibuat, tetapi ID gagal dibaca")
		return
	}

	httpx.WriteJSON(w, http.StatusCreated, map[string]any{
		"message": "akun kasir berhasil dibuat",
		"user": userResponse{
			ID:                 uint64(id),
			Username:           req.Username,
			FullName:           req.FullName,
			Role:               "kasir",
			IsActive:           true,
			MustChangePassword: true,
		},
	})
}

func (h *AuthHandler) DeleteCashier(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	cashierID, err := strconv.ParseUint(r.PathValue("id"), 10, 64)
	if err != nil || cashierID == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "ID kasir tidak valid")
		return
	}

	result, err := h.db.Exec(`
		DELETE FROM users
		WHERE id = ?
			AND role = 'kasir'
	`, cashierID)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menghapus akun kasir")
		return
	}

	deleted, err := result.RowsAffected()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca hasil hapus akun")
		return
	}
	if deleted == 0 {
		httpx.WriteError(w, http.StatusNotFound, "akun kasir tidak ditemukan")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]string{
		"message": "akun kasir berhasil dihapus",
	})
}

func (h *AuthHandler) ResetCashierPassword(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	cashierID, err := strconv.ParseUint(r.PathValue("id"), 10, 64)
	if err != nil || cashierID == 0 {
		httpx.WriteError(w, http.StatusBadRequest, "ID kasir tidak valid")
		return
	}

	var req resetCashierPasswordRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}
	if len(req.Password) < 6 {
		httpx.WriteError(w, http.StatusBadRequest, "password baru minimal 6 karakter")
		return
	}

	passwordHash, err := auth.HashPassword(req.Password)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat hash password")
		return
	}

	result, err := h.db.Exec(`
		UPDATE users
		SET password_hash = ?,
			must_change_password = 1,
			password_changed_at = NOW()
		WHERE id = ?
			AND role = 'kasir'
	`, passwordHash, cashierID)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan password kasir")
		return
	}

	updated, err := result.RowsAffected()
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca hasil reset password")
		return
	}
	if updated == 0 {
		httpx.WriteError(w, http.StatusNotFound, "akun kasir tidak ditemukan")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]string{
		"message": "password kasir berhasil diperbarui",
	})
}

func (h *AuthHandler) UpdateProfile(w http.ResponseWriter, r *http.Request) {
	claims, ok := h.requireAuthenticated(w, r)
	if !ok {
		return
	}

	userID, err := strconv.ParseUint(claims.Subject, 10, 64)
	if err != nil || userID == 0 {
		httpx.WriteError(w, http.StatusUnauthorized, "token tidak valid")
		return
	}

	var req updateProfileRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	req.Username = strings.TrimSpace(req.Username)
	req.FullName = strings.TrimSpace(req.FullName)
	if req.CurrentPassword == "" {
		httpx.WriteError(w, http.StatusBadRequest, "password saat ini wajib diisi")
		return
	}
	if validationError := validateAccountInput(req.Username, req.FullName, "Password1"); validationError != "" {
		httpx.WriteError(w, http.StatusBadRequest, validationError)
		return
	}
	if req.NewPassword != "" && len(req.NewPassword) < 6 {
		httpx.WriteError(w, http.StatusBadRequest, "password baru minimal 6 karakter")
		return
	}

	user, err := h.findUserByID(userID)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			httpx.WriteError(w, http.StatusUnauthorized, "user tidak ditemukan")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membaca data user")
		return
	}
	if !user.IsActive {
		httpx.WriteError(w, http.StatusForbidden, "akun tidak aktif")
		return
	}
	if err := auth.ComparePassword(user.PasswordHash, req.CurrentPassword); err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "password saat ini salah")
		return
	}

	passwordHash := user.PasswordHash
	mustChangePassword := user.MustChangePassword
	if req.NewPassword != "" {
		passwordHash, err = auth.HashPassword(req.NewPassword)
		if err != nil {
			httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat hash password")
			return
		}
		mustChangePassword = false
	}

	_, err = h.db.Exec(`
		UPDATE users
		SET username = ?,
			full_name = ?,
			password_hash = ?,
			must_change_password = ?,
			password_changed_at = CASE WHEN ? THEN NOW() ELSE password_changed_at END
		WHERE id = ?
	`, req.Username, req.FullName, passwordHash, mustChangePassword, req.NewPassword != "", userID)
	if err != nil {
		h.writeUserMutationError(w, err)
		return
	}

	updated := userResponse{
		ID:                 user.ID,
		Username:           req.Username,
		FullName:           req.FullName,
		Role:               user.Role,
		IsActive:           user.IsActive,
		MustChangePassword: mustChangePassword,
	}
	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"message": "profil berhasil diperbarui",
		"user":    updated,
	})
}

func (h *AuthHandler) requireAdmin(w http.ResponseWriter, r *http.Request) (auth.TokenClaims, bool) {
	claims, ok := h.requireAuthenticated(w, r)
	if !ok {
		return auth.TokenClaims{}, false
	}
	if claims.Role != "admin" {
		httpx.WriteError(w, http.StatusForbidden, "hanya admin yang boleh mengakses fitur ini")
		return auth.TokenClaims{}, false
	}
	return claims, true
}

func (h *AuthHandler) requireAuthenticated(w http.ResponseWriter, r *http.Request) (auth.TokenClaims, bool) {
	token := bearerToken(r)
	if token == "" {
		httpx.WriteError(w, http.StatusUnauthorized, "token wajib dikirim")
		return auth.TokenClaims{}, false
	}

	claims, err := auth.ValidateToken(token, h.cfg.JWTSecret, time.Now())
	if err != nil {
		httpx.WriteError(w, http.StatusUnauthorized, "token tidak valid atau kedaluwarsa")
		return auth.TokenClaims{}, false
	}

	return claims, true
}

func bearerToken(r *http.Request) string {
	header := strings.TrimSpace(r.Header.Get("Authorization"))
	if header == "" {
		return ""
	}

	tokenType, token, ok := strings.Cut(header, " ")
	if !ok || !strings.EqualFold(tokenType, "Bearer") {
		return ""
	}
	return strings.TrimSpace(token)
}

func validateAccountInput(username, fullName, password string) string {
	if username == "" || fullName == "" || password == "" {
		return "nama, username, dan password wajib diisi"
	}
	if len(username) > 50 {
		return "username maksimal 50 karakter"
	}
	if len(fullName) > 100 {
		return "nama maksimal 100 karakter"
	}
	if len(password) < 6 {
		return "password minimal 6 karakter"
	}
	return ""
}

func (h *AuthHandler) findUserByID(userID uint64) (userRecord, error) {
	var user userRecord
	err := h.db.QueryRow(`
		SELECT id, username, password_hash, full_name, role, is_active, must_change_password
		FROM users
		WHERE id = ?
		LIMIT 1
	`, userID).Scan(
		&user.ID,
		&user.Username,
		&user.PasswordHash,
		&user.FullName,
		&user.Role,
		&user.IsActive,
		&user.MustChangePassword,
	)
	return user, err
}

func (h *AuthHandler) writeUserMutationError(w http.ResponseWriter, err error) {
	message := strings.ToLower(err.Error())
	if strings.Contains(message, "duplicate") || strings.Contains(message, "uq_users_username") {
		httpx.WriteError(w, http.StatusConflict, "username sudah digunakan")
		return
	}
	if strings.Contains(message, "akun baru hanya boleh dibuat oleh admin aktif") {
		httpx.WriteError(w, http.StatusForbidden, "akun baru hanya boleh dibuat oleh admin aktif")
		return
	}
	httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan data akun")
}
