package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"strings"
	"time"
)

type TokenClaims struct {
	Subject            string `json:"sub"`
	Username           string `json:"username"`
	FullName           string `json:"full_name"`
	Role               string `json:"role"`
	MustChangePassword bool   `json:"must_change_password"`
	IssuedAt           int64  `json:"iat"`
	ExpiresAt          int64  `json:"exp"`
}

func GenerateToken(claims TokenClaims, secret string) (string, error) {
	header := map[string]string{
		"alg": "HS256",
		"typ": "JWT",
	}

	headerJSON, err := json.Marshal(header)
	if err != nil {
		return "", err
	}

	claimsJSON, err := json.Marshal(claims)
	if err != nil {
		return "", err
	}

	encodedHeader := base64.RawURLEncoding.EncodeToString(headerJSON)
	encodedPayload := base64.RawURLEncoding.EncodeToString(claimsJSON)
	unsignedToken := encodedHeader + "." + encodedPayload

	signature := sign(unsignedToken, secret)
	return unsignedToken + "." + signature, nil
}

func ValidateToken(token, secret string, now time.Time) (TokenClaims, error) {
	parts := strings.Split(token, ".")
	if len(parts) != 3 {
		return TokenClaims{}, fmt.Errorf("format token tidak valid")
	}

	unsignedToken := parts[0] + "." + parts[1]
	expectedSignature := sign(unsignedToken, secret)
	if !hmac.Equal([]byte(parts[2]), []byte(expectedSignature)) {
		return TokenClaims{}, fmt.Errorf("signature token tidak valid")
	}

	payload, err := base64.RawURLEncoding.DecodeString(parts[1])
	if err != nil {
		return TokenClaims{}, err
	}

	var claims TokenClaims
	if err := json.Unmarshal(payload, &claims); err != nil {
		return TokenClaims{}, err
	}

	if claims.ExpiresAt <= now.Unix() {
		return TokenClaims{}, fmt.Errorf("token sudah kedaluwarsa")
	}

	return claims, nil
}

func sign(value, secret string) string {
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(value))
	return base64.RawURLEncoding.EncodeToString(mac.Sum(nil))
}
