# Systemic Fitness — Setup

Repository ini berisi source code platform Systemic Fitness.

| Folder | Stack | Deskripsi |
|--------|-------|-----------|
| `systemic-fitness-api` | Go | REST API + WebSocket backend |
| `systemic-fitness-web` | Next.js | Dashboard Admin / Trainer / Finance |
| `systemic-fitness-client-web` | Next.js | Web client (member) |
| `systemic-fitness-landing-page` | Next.js | Landing page / CMS publik |
| `systemic-fitness-mobile-new` | Flutter | Aplikasi mobile (Android/iOS) |

## Konfigurasi yang perlu disiapkan sendiri

File berikut **tidak disertakan** (berisi kredensial / spesifik environment) dan harus dibuat ulang:

- **`*/.env`** — salin dari `.env.example` di tiap app, isi sesuai server Anda (DATABASE_URL, JWT_SECRET, NEXTAUTH_SECRET, MIDTRANS_*, dll).
- **`systemic-fitness-mobile-new/android/app/google-services.json`** — unduh dari Firebase project Anda sendiri.
- **Object storage (S3/MinIO)** — siapkan bucket + access key sendiri (lihat variabel di `.env.example`).
- **Deployment / CI** — siapkan pipeline ke server Anda sendiri.

## Menjalankan (development)

### API (Go)
```
cd systemic-fitness-api
cp .env.example .env        # isi nilainya
go run ./cmd/server
```
Database: jalankan file di `database/migrations/` lalu `database/seeds/` secara berurutan.

### Web / Client-Web / Landing (Next.js)
```
cd systemic-fitness-web     # atau systemic-fitness-client-web / systemic-fitness-landing-page
cp .env.example .env.local  # isi nilainya
npm install
npm run dev
```

### Mobile (Flutter)
```
cd systemic-fitness-mobile-new
# tambahkan android/app/google-services.json milik Anda
flutter pub get
flutter run
```

## Akun seed default
Setelah seeding, admin default dibuat sesuai `database/seeds/003_seed_admin.sql`.
**Ganti password segera setelah login pertama.**
