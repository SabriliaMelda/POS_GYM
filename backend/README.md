# POS Gym Backend

Backend Go untuk login admin/kasir POS Gym.

## Setup

1. Pastikan database dari `database.txt` sudah dibuat di MySQL/MariaDB Laragon.
2. Salin `backend/.env.example` menjadi `backend/.env`.
3. Sesuaikan konfigurasi database jika berbeda.
4. Jalankan backend:

```powershell
cd backend
go mod tidy
go run ./cmd/api
```

Server default berjalan di `http://localhost:8080`.

## Endpoint Login

```http
POST /api/auth/login
Content-Type: application/json
```

Body:

```json
{
  "username": "admin",
  "password": "Admin@123",
  "role": "admin"
}
```

`role` opsional. Jika dikirim, backend akan memastikan role akun sama dengan role yang diminta.

Respons sukses:

```json
{
  "message": "login berhasil",
  "token_type": "Bearer",
  "expires_in": 86400,
  "token": "...",
  "must_change_password": true,
  "user": {
    "id": 1,
    "username": "admin",
    "full_name": "Administrator",
    "role": "admin",
    "is_active": true,
    "must_change_password": true
  }
}
```
