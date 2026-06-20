package handler

import (
	"database/sql"
	"errors"
	"net"
	"net/http"
	"strconv"
	"strings"
	"time"

	"pos-gym/backend/internal/auth"
	"pos-gym/backend/internal/config"
	"pos-gym/backend/internal/httpx"
)

type AuthHandler struct {
	db  *sql.DB
	cfg config.Config
}

type loginRequest struct {
	Username string `json:"username"`
	Password string `json:"password"`
	Role     string `json:"role"`
}

type userRecord struct {
	ID                 uint64
	Username           string
	PasswordHash       string
	FullName           string
	Role               string
	IsActive           bool
	MustChangePassword bool
}

type userResponse struct {
	ID                 uint64 `json:"id"`
	Username           string `json:"username"`
	FullName           string `json:"full_name"`
	Role               string `json:"role"`
	IsActive           bool   `json:"is_active"`
	MustChangePassword bool   `json:"must_change_password"`
}

func NewAuthHandler(db *sql.DB, cfg config.Config) *AuthHandler {
	return &AuthHandler{db: db, cfg: cfg}
}

func (h *AuthHandler) Login(w http.ResponseWriter, r *http.Request) {
	var req loginRequest
	if err := httpx.ReadJSON(w, r, &req); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "request JSON tidak valid")
		return
	}

	req.Username = strings.TrimSpace(req.Username)
	req.Role = strings.ToLower(strings.TrimSpace(req.Role))

	if req.Username == "" || req.Password == "" {
		httpx.WriteError(w, http.StatusBadRequest, "username dan password wajib diisi")
		return
	}
	if req.Role != "" && req.Role != "admin" && req.Role != "kasir" {
		httpx.WriteError(w, http.StatusBadRequest, "role harus admin atau kasir")
		return
	}

	user, err := h.findUserByUsername(req.Username)
	if err != nil {
		if errors.Is(err, sql.ErrNoRows) {
			h.logLogin(nil, req.Username, "failed", r, "username tidak ditemukan")
			httpx.WriteError(w, http.StatusUnauthorized, "username atau password salah")
			return
		}
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memproses login")
		return
	}

	if !user.IsActive {
		h.logLogin(&user.ID, req.Username, "failed", r, "akun tidak aktif")
		httpx.WriteError(w, http.StatusForbidden, "akun tidak aktif")
		return
	}

	if req.Role != "" && user.Role != req.Role {
		h.logLogin(&user.ID, req.Username, "failed", r, "role tidak sesuai")
		httpx.WriteError(w, http.StatusForbidden, "role akun tidak sesuai")
		return
	}

	if err := auth.ComparePassword(user.PasswordHash, req.Password); err != nil {
		h.logLogin(&user.ID, req.Username, "failed", r, "password salah")
		httpx.WriteError(w, http.StatusUnauthorized, "username atau password salah")
		return
	}

	if err := h.updateLastLogin(user.ID); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal memperbarui waktu login")
		return
	}
	h.logLogin(&user.ID, req.Username, "success", r, "")

	now := time.Now()
	expiresAt := now.Add(h.cfg.JWTTTL)
	token, err := auth.GenerateToken(auth.TokenClaims{
		Subject:            strconv.FormatUint(user.ID, 10),
		Username:           user.Username,
		FullName:           user.FullName,
		Role:               user.Role,
		MustChangePassword: user.MustChangePassword,
		IssuedAt:           now.Unix(),
		ExpiresAt:          expiresAt.Unix(),
	}, h.cfg.JWTSecret)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat token")
		return
	}

	httpx.WriteJSON(w, http.StatusOK, map[string]any{
		"message":              "login berhasil",
		"token_type":           "Bearer",
		"expires_in":           int64(h.cfg.JWTTTL.Seconds()),
		"token":                token,
		"must_change_password": user.MustChangePassword,
		"user": userResponse{
			ID:                 user.ID,
			Username:           user.Username,
			FullName:           user.FullName,
			Role:               user.Role,
			IsActive:           user.IsActive,
			MustChangePassword: user.MustChangePassword,
		},
	})
}

func (h *AuthHandler) findUserByUsername(username string) (userRecord, error) {
	var user userRecord
	err := h.db.QueryRow(`
		SELECT id, username, password_hash, full_name, role, is_active, must_change_password
		FROM users
		WHERE username = ?
		LIMIT 1
	`, username).Scan(
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

func (h *AuthHandler) updateLastLogin(userID uint64) error {
	_, err := h.db.Exec(`UPDATE users SET last_login_at = NOW() WHERE id = ?`, userID)
	return err
}

func (h *AuthHandler) logLogin(userID *uint64, username, status string, r *http.Request, failureReason string) {
	var dbUserID any
	if userID != nil {
		dbUserID = *userID
	}

	var dbFailureReason any
	if failureReason != "" {
		dbFailureReason = failureReason
	}

	_, _ = h.db.Exec(`
		INSERT INTO login_logs (
			user_id,
			username_input,
			status,
			ip_address,
			user_agent,
			failure_reason
		) VALUES (?, ?, ?, ?, ?, ?)
	`, dbUserID, username, status, clientIP(r), truncate(r.UserAgent(), 255), dbFailureReason)
}

func clientIP(r *http.Request) string {
	if forwardedFor := strings.TrimSpace(r.Header.Get("X-Forwarded-For")); forwardedFor != "" {
		ip, _, _ := strings.Cut(forwardedFor, ",")
		return truncate(strings.TrimSpace(ip), 45)
	}
	if realIP := strings.TrimSpace(r.Header.Get("X-Real-IP")); realIP != "" {
		return truncate(realIP, 45)
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return truncate(host, 45)
	}
	return truncate(r.RemoteAddr, 45)
}

func truncate(value string, max int) string {
	if len(value) <= max {
		return value
	}
	return value[:max]
}
