package handler

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"pos-gym/backend/internal/httpx"
)

const maxFNBImageSize = 5 << 20

var allowedFNBImageTypes = map[string]string{
	"image/jpeg": ".jpg",
	"image/png":  ".png",
	"image/webp": ".webp",
}

func (h *AuthHandler) UploadFNBImage(w http.ResponseWriter, r *http.Request) {
	if _, ok := h.requireAdmin(w, r); !ok {
		return
	}

	r.Body = http.MaxBytesReader(w, r.Body, maxFNBImageSize+1<<20)
	if err := r.ParseMultipartForm(maxFNBImageSize); err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "gambar tidak valid atau melebihi 5 MB")
		return
	}

	file, _, err := r.FormFile("image")
	if err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "file gambar wajib dipilih")
		return
	}
	defer file.Close()

	data, err := io.ReadAll(io.LimitReader(file, maxFNBImageSize+1))
	if err != nil {
		httpx.WriteError(w, http.StatusBadRequest, "gagal membaca gambar")
		return
	}
	if len(data) == 0 || len(data) > maxFNBImageSize {
		httpx.WriteError(w, http.StatusBadRequest, "ukuran gambar harus antara 1 byte dan 5 MB")
		return
	}

	contentType := http.DetectContentType(data)
	extension, allowed := allowedFNBImageTypes[contentType]
	if !allowed {
		httpx.WriteError(w, http.StatusBadRequest, "format gambar harus JPG, PNG, atau WEBP")
		return
	}

	name, err := randomImageName(extension)
	if err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat nama gambar")
		return
	}
	uploadDir := filepath.Join("uploads", "fnb")
	if err := os.MkdirAll(uploadDir, 0755); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal membuat folder upload")
		return
	}
	if err := os.WriteFile(filepath.Join(uploadDir, name), data, 0644); err != nil {
		httpx.WriteError(w, http.StatusInternalServerError, "gagal menyimpan gambar")
		return
	}

	path := "/uploads/fnb/" + name
	httpx.WriteJSON(w, http.StatusCreated, map[string]string{
		"message": "gambar berhasil diunggah",
		"path":    path,
	})
}

func (h *AuthHandler) ServeFNBImage(w http.ResponseWriter, r *http.Request) {
	name := r.PathValue("name")
	if name == "" || filepath.Base(name) != name {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Cache-Control", "public, max-age=86400")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	http.ServeFile(w, r, filepath.Join("uploads", "fnb", name))
}

func randomImageName(extension string) (string, error) {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return "", fmt.Errorf("generate random name: %w", err)
	}
	return hex.EncodeToString(bytes) + extension, nil
}

func removeManagedFNBImage(path string) {
	const prefix = "/uploads/fnb/"
	if !strings.HasPrefix(path, prefix) {
		return
	}
	name := filepath.Base(strings.TrimPrefix(path, prefix))
	if name == "." || name == "" {
		return
	}
	_ = os.Remove(filepath.Join("uploads", "fnb", name))
}
