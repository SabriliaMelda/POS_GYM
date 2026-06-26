# POS_GYM — X-FIT Digital Indonesia

Sistem Point of Sale gym (layanan gym, F&B, member, absensi, riwayat).

## Struktur

| Folder | Isi |
|--------|-----|
| `frontend/` | Aplikasi **Flutter** (kasir & admin). Jalankan dari sini. |
| `backend/`  | REST API **Go** + MySQL. |
| `module/`   | Skrip **SQL** (`*.txt`, `pos_gym.sql`) & dokumentasi/skripsi. |

## Menjalankan

**Backend** (butuh MySQL `pos_gym`, atur `backend/.env`):
```bash
cd backend
go run ./cmd/api
```

**Frontend** (atur `frontend/.env` → `API_BASE_URL`):
```bash
cd frontend
flutter pub get
flutter run
```

Skema database & langkah setup ada di folder `module/`.
