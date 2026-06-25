# Catatan Konfigurasi LOKAL ↔ SERVER (POS Gym)

> Dibuat: 20 Juni 2026
> Tujuan: catatan apa saja yang harus diubah saat develop di **lokal** (Laragon + Flutter)
> lalu di-deploy ke **server**, dan sebaliknya. Backend = **Go**, DB = **MySQL**, Frontend = **Flutter**.

---

## 0. Gambaran Arsitektur

POS Gym terdiri dari 3 bagian yang jalan TERPISAH:

| Bagian   | Teknologi | Lokal                          | Server                          |
|----------|-----------|--------------------------------|---------------------------------|
| Database | MySQL     | Laragon (port 3306)            | MySQL di server/Docker          |
| Backend  | Go        | `go run ./cmd/api` (port 8080) | `api.exe` / Docker / Render     |
| Frontend | Flutter   | `flutter run`                  | build web → hosting             |

**PENTING:** Laragon/phpMyAdmin HANYA menyalakan MySQL. Backend Go HARUS dijalankan sendiri,
kalau tidak Flutter akan error *"Tidak bisa terhubung ke backend. Pastikan server aktif."*

Urutan menjalankan di lokal:
**(1) Laragon/MySQL nyala → (2) Backend Go nyala → (3) `flutter run`**

---

## 1. Yang Sudah Diubah untuk LOKAL (20 Juni 2026)

### a. `backend/.env`
Diubah `DB_HOST` dari `db` (nama service Docker) menjadi `127.0.0.1` (alamat MySQL lokal).

```
SEBELUM:  DB_HOST=db
SESUDAH:  DB_HOST=127.0.0.1
```

Alasan: `db` hanya bisa di-resolve di dalam jaringan Docker. Di lokal (Laragon) harus IP localhost.

### b. Menjalankan backend
Backend dinyalakan dengan: `go run ./cmd/api` dari folder `backend/`.
Tanda berhasil: `backend running on port:8080` dan `http://localhost:8080/health` → `{"status":"ok"}`.

### c. Frontend Flutter
Dijalankan dengan override URL backend ke localhost (lihat bagian 3):
```
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

---

## 2. File `backend/.env` — beda LOKAL vs SERVER

Inilah satu-satunya file backend yang berbeda antar lingkungan.

### Versi LOKAL (Laragon)
```env
APP_ENV=development          # boleh production, asal JWT_SECRET diisi
APP_PORT=8080
DB_HOST=127.0.0.1            # <-- localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=                 # Laragon default root: kosong
DB_NAME=pos_gym
DB_TLS=false
JWT_SECRET=<rahasia-acak-panjang>
JWT_TTL_HOURS=24
CORS_ALLOWED_ORIGINS=*
```

### Versi SERVER (Docker / VPS / Render)
```env
APP_ENV=production
APP_PORT=8080
DB_HOST=db                   # <-- nama service MySQL di docker-compose, ATAU IP/host DB server
DB_PORT=3306
DB_USER=root                 # sebaiknya buat user khusus, bukan root
DB_PASSWORD=<password-asli>  # WAJIB diisi di server
DB_NAME=pos_gym
DB_TLS=false                 # true bila DB butuh TLS
JWT_SECRET=<rahasia-acak-panjang-berbeda-dari-lokal>
JWT_TTL_HOURS=24
CORS_ALLOWED_ORIGINS=https://domain-frontend-kamu.com   # batasi ke domain frontend, jangan * di production
```

**Checklist saat LOKAL → SERVER:**
- [ ] `APP_ENV=production`
- [ ] `DB_HOST` = nama service Docker / host DB server
- [ ] `DB_PASSWORD` diisi password asli
- [ ] `JWT_SECRET` diganti rahasia baru (jangan sama dengan lokal)
- [ ] `CORS_ALLOWED_ORIGINS` dibatasi ke domain frontend

**Checklist saat SERVER → LOKAL:**
- [ ] `DB_HOST=127.0.0.1`
- [ ] `DB_PASSWORD` = kosong (Laragon default) atau sesuai MySQL lokal
- [ ] `CORS_ALLOWED_ORIGINS=*` (biar mudah ngetes)

> Catatan: `backend/.gitignore` mengabaikan `.env`, jadi file ini TIDAK ikut ke git.
> Patokannya ada di `backend/.env.example`. Tiap pindah lingkungan, salin & sesuaikan.

---

## 3. Frontend Flutter — alamat backend

Flutter membaca URL backend dari `--dart-define=API_BASE_URL=...`.
Kalau tidak diisi, dipakai nilai **default hardcoded** di kode:

| File                                                         | Baris | Default              |
|-------------------------------------------------------------|-------|----------------------|
| `lib/auth/auth_service.dart`                                | 22    | `http://192.168.1.106:8080` |
| `lib/admin/screens/account/admin_account_service.dart`      | 16    | `http://192.168.1.106:8080` |

Selain itu ada `ATTENDANCE_BASE_URL` di `lib/kasir/screens/attendance/attendance_screen.dart:406`
(untuk QR check-in member). Kalau kosong, otomatis pakai URL halaman web yang sedang dibuka (`Uri.base`).

### Cara menjalankan per lingkungan (TANPA mengubah kode)

**LOKAL (web/Chrome):**
```
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```

**LOKAL (HP/emulator Android) — localhost tidak bisa, pakai:**
```
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080      # emulator Android
flutter run --dart-define=API_BASE_URL=http://<IP-laptop>:8080   # HP fisik 1 wifi, mis. 192.168.1.106
```

**SERVER (build web untuk di-deploy):**
```
flutter build web --dart-define=API_BASE_URL=https://api-domain-kamu.com
```

> Saran: nilai default `192.168.1.106` itu IP LAN spesifik dan mudah bikin bingung.
> Lebih aman selalu pakai `--dart-define` saat run/build, atau ubah default jadi `http://localhost:8080`.

---

## 4. Database — sinkron LOKAL ↔ SERVER

Skema & data ada di file SQL: `pos_gym.sql` (root) dan `backend/` punya catatan di `module/database.txt`.
Tabel saat ini: `users`, `login_logs`.

### Lokal → Server (push perubahan DB ke server)
1. Export dari lokal (Laragon):
   ```
   mysqldump -u root pos_gym > pos_gym_lokal.sql
   ```
2. Import di server:
   ```
   mysql -u <user> -p pos_gym < pos_gym_lokal.sql
   ```

### Server → Lokal (tarik data server ke lokal)
1. Export dari server:
   ```
   mysqldump -u <user> -p pos_gym > pos_gym_server.sql
   ```
2. Import di lokal (Laragon):
   ```
   mysql -u root pos_gym < pos_gym_server.sql
   ```

> HATI-HATI: import menimpa data. Backup dulu sebelum overwrite.
> Kalau hanya perubahan struktur (tambah kolom/tabel), lebih baik buat file migrasi SQL terpisah
> dan jalankan di kedua sisi, supaya data tidak hilang.

### Foto menu F&B (`backend/uploads/fnb/`) — WAJIB ikut dikirim ke server
Foto menu disimpan sebagai FILE di `backend/uploads/fnb/` dan di DB hanya tersimpan PATH-nya
(mis. `image_path = '/uploads/fnb/cat-coffee.jpg'`). Folder ini **di-ignore git**
(lihat `backend/.gitignore` baris `uploads/fnb/*`), jadi file gambar TIDAK ikut saat `git push`.

Akibatnya saat LOKAL → SERVER: kalau hanya sync DB, `image_path` ikut tapi FILE gambarnya tidak ada
di server → foto rusak/blank. Solusi: salin manual folder gambarnya, mis.:
```
scp -r backend/uploads/fnb/* user@server:/path/backend/uploads/fnb/
```
Begitu juga sebaliknya (server → lokal) bila foto diupload dari sisi server.

> Per 21 Juni 2026: 99 menu sudah diisi foto stok per-kategori (`cat-*.jpg`) yang diunduh dari
> LoremFlickr (Creative Commons). Ini gambar generik per kategori, bukan foto asli tiap hidangan;
> ganti per item lewat tombol edit di halaman Master bila perlu foto asli.

---

## 5. Troubleshooting yang sudah ketemu

| Gejala | Penyebab | Solusi |
|--------|----------|--------|
| Flutter: "Tidak bisa terhubung ke backend" | Backend Go belum jalan | Jalankan `go run ./cmd/api` di folder `backend/` |
| `listen tcp :8080: bind: Only one usage of each socket address...` | Port 8080 sudah dipakai backend lain yang masih nyala | `netstat -ano \| findstr :8080` lalu `taskkill /PID <PID> /F` |
| `ping database` / connection refused | `DB_HOST` salah (mis. `db` di lokal) | Set `DB_HOST=127.0.0.1` di `backend/.env` |
| Login gagal walau backend nyala | URL `API_BASE_URL` Flutter salah / tak terjangkau | Jalankan Flutter dgn `--dart-define=API_BASE_URL=http://localhost:8080` |
| "Respons server tidak valid" saat upload foto / fitur baru | Backend yang jalan adalah **`api.exe` versi LAMA**, belum punya route baru (mis. `POST /api/admin/master/fnb/image`). Server balas `405 Method Not Allowed` (teks, bukan JSON). | **Build ulang** binary tiap kali ubah kode Go: `taskkill /IM api.exe /F` lalu `go build -o api.exe ./cmd/api`. Atau jalankan via `go run ./cmd/api` (selalu pakai source terkini). |

> **PENTING — `api.exe` tidak otomatis ikut perubahan kode Go.**
> File `backend/api.exe` adalah binary hasil compile. Kalau kamu (atau aku) mengubah file `.go`,
> `api.exe` TIDAK berubah sampai di-build ulang. Gejala khasnya: fitur lama jalan, fitur baru error
> "Respons server tidak valid" / 404 / 405. Untuk lokal lebih aman pakai `go run ./cmd/api`.
> Untuk server, build ulang dulu: `go build -o api.exe ./cmd/api`, baru kirim `api.exe` baru ke server.

---

## 6. Ringkasan langkah cepat menjalankan LOKAL

```powershell
# 1. Pastikan Laragon (MySQL) nyala — phpMyAdmin bisa dibuka

# 2. Nyalakan backend (biarkan jendela terbuka)
cd d:\pos_gym\backend
go run ./cmd/api

# 3. Di terminal LAIN, nyalakan frontend
cd d:\pos_gym
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080
```
