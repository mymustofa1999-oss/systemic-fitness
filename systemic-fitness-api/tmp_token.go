package main

import (
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func main() {
	secret := []byte("change-me-in-production-use-64-char-random-string") // from .env
	claims := jwt.MapClaims{
		"user_id": "00000000-0000-0000-0000-000000000000",
		"role":    "admin",
		"exp":     time.Now().Add(time.Hour).Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	t, _ := token.SignedString(secret)
	fmt.Println(t)
}
