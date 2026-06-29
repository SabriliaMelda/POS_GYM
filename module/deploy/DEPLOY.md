# Deploy POS_GYM ke VPS (Contabo, Ubuntu 22.04/24.04)

Hasil akhir: satu domain (mis. `https://posgym.example.com`) melayani aplikasi
Flutter web + REST API Go + MySQL. Member cukup **scan QR pakai kamera HP**
(tanpa instal aplikasi, boleh pakai data seluler) untuk absen.

Ganti yang bertanda `<...>` sesuai milikmu.

---

## 0. Prasyarat
- VPS Contabo + akses SSH sebagai root/sudo.
- (Disarankan) **domain** diarahkan (A record) ke IP VPS → wajib jika mau HTTPS.
  Tanpa domain tetap bisa, tapi hanya `http://<IP-VPS>` (tanpa SSL).
- Flutter SDK **di laptop** (untuk `flutter build web`). Tidak perlu instal Flutter di VPS.

---

## 1. Paket dasar di VPS
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx mysql-server golang-go git ufw
sudo ufw allow OpenSSH && sudo ufw allow 'Nginx Full' && sudo ufw --force enable
```
> Cek versi Go ≥ 1.24 (`go version`). Jika apt memberi versi lama, instal Go resmi dari https://go.dev/dl.

---

## 2. Database MySQL
```bash
sudo mysql_secure_installation        # set password root, dll
sudo mysql
```
Di prompt MySQL:
```sql
CREATE DATABASE pos_gym CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'posgym'@'localhost' IDENTIFIED BY '<PASSWORD_DB>';
GRANT ALL PRIVILEGES ON pos_gym.* TO 'posgym'@'localhost';
FLUSH PRIVILEGES; EXIT;
```
Import skema + jalankan modul SQL (urutkan: skema utama dulu, lalu tabel transaksi & absensi):
```bash
cd /opt/posgym/module
mysql -u posgym -p pos_gym < pos_gym.sql          # skema + data awal
mysql -u posgym -p pos_gym < fnb-transaksi.txt    # tabel transaksi F&B
mysql -u posgym -p pos_gym < absensi.txt          # tabel absensi
# (jalankan juga *.txt lain yang berisi CREATE TABLE bila belum ada di pos_gym.sql)
```

---

## 3. Ambil kode ke VPS
```bash
sudo mkdir -p /opt/posgym && sudo chown -R $USER:$USER /opt/posgym
git clone <URL_REPO_GIT> /opt/posgym
# atau upload manual folder backend/ dan module/ via scp.
```
Buat user khusus untuk service:
```bash
sudo useradd -r -s /usr/sbin/nologin posgym || true
```

---

## 4. Konfigurasi & build backend
Edit `/opt/posgym/backend/.env`:
```ini
APP_ENV=production
APP_PORT=8080
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=posgym
DB_PASSWORD=<PASSWORD_DB>
DB_NAME=pos_gym
JWT_SECRET=<KUNCI_ACAK_PANJANG>      # WAJIB ganti! mis. `openssl rand -hex 32`
JWT_TTL_HOURS=24
CORS_ALLOWED_ORIGINS=https://posgym.example.com
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=<email-gym@gmail.com>
SMTP_PASSWORD=<APP_PASSWORD_16_DIGIT>
SMTP_FROM=
SMTP_FROM_NAME=X-FIT Digital Indonesia
```
Build binari:
```bash
cd /opt/posgym/backend
go build -o posgym-api ./cmd/api
sudo chown -R posgym:posgym /opt/posgym
```
Pasang service:
```bash
sudo cp /opt/posgym/module/deploy/posgym-backend.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now posgym-backend
sudo systemctl status posgym-backend        # pastikan "active (running)"
curl http://127.0.0.1:8080/health           # harus {"status":"ok"}
```

---

## 5. Build aplikasi (di laptop)
Arsitektur: **kasir & admin pakai APK Android**, sedangkan **halaman absensi member
berupa web** yang di-host di server (member scan QR -> buka di browser HP, tanpa
instal apa pun). Jadi dari satu kode `frontend/` dibuat DUA build.

Atur dulu `frontend/.env`:
```ini
API_BASE_URL=https://posgym.example.com
QRIS_STATIC=<QRIS-STATIS-ASLI-GYM>          # kosongkan = mode demo
```

### 5a. Web — halaman check-in member (di-host di server)
```bash
cd frontend
flutter build web --release
```
Inilah yang dibuka HP member saat scan QR. Unggah `frontend/build/web/*` ke VPS:
```bash
# dari laptop:
scp -r frontend/build/web/* <user>@<IP-VPS>:/tmp/posgym-web/
# di VPS:
sudo mkdir -p /var/www/posgym
sudo cp -r /tmp/posgym-web/* /var/www/posgym/
sudo chown -R www-data:www-data /var/www/posgym
```

### 5b. APK — untuk kasir & admin (diinstal di HP/tablet kasir)
APK WAJIB tahu URL web di atas agar QR yang dibuatnya menunjuk ke halaman web yang
benar (di APK `Uri.base` bukan URL web, jadi harus disuntik saat build):
```bash
cd frontend
flutter build apk --release --dart-define=ATTENDANCE_BASE_URL=https://posgym.example.com
```
Hasil: `frontend/build/app/outputs/flutter-apk/app-release.apk` -> instal ke perangkat kasir.

> PENTING (HTTPS): APK Android memblokir HTTP polos secara default. Gunakan **https**
> (domain + certbot) agar APK bisa konek ke backend. Jika terpaksa pakai
> `http://<IP>:8080`, tambahkan `android:usesCleartextTraffic="true"` pada
> `<application>` di `frontend/android/app/src/main/AndroidManifest.xml` sebelum build
> (kurang aman, hanya untuk uji).

---

## 6. nginx
```bash
sudo cp /opt/posgym/module/deploy/nginx-posgym.conf /etc/nginx/sites-available/posgym
sudo nano /etc/nginx/sites-available/posgym     # ganti server_name -> domain/IP
sudo ln -s /etc/nginx/sites-available/posgym /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```
Sekarang `http://posgym.example.com` sudah membuka aplikasi.

---

## 7. HTTPS (butuh domain)
```bash
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --nginx -d posgym.example.com
```
Certbot otomatis menambah SSL + redirect ke https dan memperbarui sertifikat.

---

## 8. Uji
1. Buka `https://posgym.example.com` → halaman login muncul, banner merah hilang.
2. Login admin (`admin` / password yang sudah diset) & kasir.
3. Kasir → **Absensi** → pilih member → QR muncul (isinya `https://posgym.example.com/#/member-check-in?member=...`).
4. **Scan QR dengan kamera HP** (boleh data seluler) → Chrome buka halaman → **Hadir Sekarang** → tercatat. Cek di Absensi/Riwayat kasir.

---

## Update aplikasi nanti
- **Backend**: `git pull` → `go build -o posgym-api ./cmd/api` → `sudo systemctl restart posgym-backend`.
- **Frontend**: di laptop `flutter build web --release` → `scp` ulang isi `build/web` ke `/var/www/posgym`.

## Masalah umum
- **Banner "tidak bisa terhubung ke backend"** → cek `API_BASE_URL` di build frontend sama persis dengan domain, dan `systemctl status posgym-backend` aktif.
- **502 Bad Gateway** → backend mati / port bukan 8080. Cek `journalctl -u posgym-backend -e`.
- **QR mengarah ke localhost** → frontend tidak dibuka lewat domain saat build, atau pakai `--dart-define=ATTENDANCE_BASE_URL=https://posgym.example.com` saat build.
- **CORS error** → set `CORS_ALLOWED_ORIGINS` di backend/.env ke domain (atau `*` untuk sementara), restart backend.
