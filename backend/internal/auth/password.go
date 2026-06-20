package auth

import (
	"strings"

	"golang.org/x/crypto/bcrypt"
)

func ComparePassword(passwordHash, plainPassword string) error {
	return bcrypt.CompareHashAndPassword(
		[]byte(normalizeBcryptHash(passwordHash)),
		[]byte(plainPassword),
	)
}

func HashPassword(plainPassword string) (string, error) {
	hash, err := bcrypt.GenerateFromPassword(
		[]byte(plainPassword),
		bcrypt.DefaultCost,
	)
	if err != nil {
		return "", err
	}
	return string(hash), nil
}

func normalizeBcryptHash(hash string) string {
	// Hash dari PHP sering memakai prefix $2y$. Go bcrypt menerima $2a$/$2b$.
	if strings.HasPrefix(hash, "$2y$") {
		return "$2a$" + strings.TrimPrefix(hash, "$2y$")
	}
	return hash
}
