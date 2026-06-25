package config

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	AppEnv             string
	AppPort            string
	DBHost             string
	DBPort             string
	DBUser             string
	DBPassword         string
	DBName             string
	JWTSecret          string
	JWTTTL             time.Duration
	CORSAllowedOrigins []string
	SMTPHost           string
	SMTPPort           string
	SMTPUser           string
	SMTPPassword       string
	SMTPFrom           string
	SMTPFromName       string
}

func Load() (Config, error) {
	loadDotEnv(".env")
	loadDotEnv(filepath.Join("backend", ".env"))

	cfg := Config{
		AppEnv:     env("APP_ENV", "development"),
		AppPort:    env("APP_PORT", "8080"),
		DBHost:     env("DB_HOST", "127.0.0.1"),
		DBPort:     env("DB_PORT", "3306"),
		DBUser:     env("DB_USER", "root"),
		DBPassword: env("DB_PASSWORD", ""),
		DBName:     env("DB_NAME", "pos_gym"),
		JWTSecret:  env("JWT_SECRET", ""),

		SMTPHost:     env("SMTP_HOST", "smtp.gmail.com"),
		SMTPPort:     env("SMTP_PORT", "587"),
		SMTPUser:     env("SMTP_USER", ""),
		SMTPPassword: env("SMTP_PASSWORD", ""),
		SMTPFrom:     env("SMTP_FROM", ""),
		SMTPFromName: env("SMTP_FROM_NAME", "X-FIT Digital Indonesia"),
	}

	// SMTP_FROM default mengikuti akun pengirim jika tidak diisi terpisah.
	if cfg.SMTPFrom == "" {
		cfg.SMTPFrom = cfg.SMTPUser
	}

	ttlHours, err := strconv.Atoi(env("JWT_TTL_HOURS", "24"))
	if err != nil || ttlHours <= 0 {
		return Config{}, fmt.Errorf("JWT_TTL_HOURS harus berupa angka positif")
	}
	cfg.JWTTTL = time.Duration(ttlHours) * time.Hour

	origins := strings.TrimSpace(env("CORS_ALLOWED_ORIGINS", "*"))
	if origins == "" {
		cfg.CORSAllowedOrigins = []string{"*"}
	} else {
		for _, origin := range strings.Split(origins, ",") {
			origin = strings.TrimSpace(origin)
			if origin != "" {
				cfg.CORSAllowedOrigins = append(cfg.CORSAllowedOrigins, origin)
			}
		}
	}

	if cfg.JWTSecret == "" {
		if cfg.AppEnv == "production" {
			return Config{}, fmt.Errorf("JWT_SECRET wajib diisi pada production")
		}
		cfg.JWTSecret = "dev-only-change-this-secret"
		log.Println("warning: JWT_SECRET belum diisi, memakai secret development")
	}

	return cfg, nil
}

func env(key, fallback string) string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	return value
}

func loadDotEnv(path string) {
	file, err := os.Open(path)
	if err != nil {
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}

		key = strings.TrimSpace(key)
		value = strings.Trim(strings.TrimSpace(value), `"'`)
		if key != "" {
			_ = os.Setenv(key, value)
		}
	}
}
