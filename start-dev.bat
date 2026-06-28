@echo off
echo ===================================================
echo Memulai Systemic Fitness (Development Mode)
echo ===================================================

echo Menjalankan API (Go)...
start "Systemic Fitness API" cmd /k "cd systemic-fitness-api && go run ./cmd/server"

echo Menjalankan Web Admin (Next.js)...
start "Systemic Fitness Web Admin" cmd /k "cd systemic-fitness-web && npm run dev"

echo Menjalankan Web Client (Next.js)...
start "Systemic Fitness Client Web" cmd /k "cd systemic-fitness-client-web && npm run dev"

echo Menjalankan Landing Page (Next.js)...
start "Systemic Fitness Landing Page" cmd /k "cd systemic-fitness-landing-page && npm run dev"

echo ===================================================
echo Semua layanan sedang dijalankan di window baru!
echo API: http://localhost:8080
echo Web Admin: http://localhost:3000
echo Web Client: http://localhost:3002
echo Landing Page: http://localhost:3003 (atau port lain yang tersedia)
echo ===================================================
pause
