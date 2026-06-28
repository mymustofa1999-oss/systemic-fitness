# =====================================================
#  Systemic Fitness — Auto Database Setup (FIXED)
# =====================================================

$ErrorActionPreference = "Continue"

function Log-Info  { param($msg) Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Log-Ok    { param($msg) Write-Host "[OK]    $msg" -ForegroundColor Green }
function Log-Warn  { param($msg) Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Log-Error { param($msg) Write-Host "[ERROR] $msg" -ForegroundColor Red }
function Log-Step  { param($msg) Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Cyan; Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan }

if (-not (Test-Path ".env")) { Log-Error "File .env tidak ditemukan!"; exit 1 }

$dbUrl = ""
foreach ($line in Get-Content ".env") { if ($line -match "^DATABASE_URL=(.+)$") { $dbUrl = $matches[1].Trim() } }

if (-not $dbUrl) { Log-Error "DATABASE_URL belum diisi di file .env!"; exit 1 }

Log-Ok ".env berhasil dimuat"

if ($dbUrl -match "postgres://([^:]+):([^@]+)@([^:]+):(\d+)/([^?]+)") {
    $DB_USER = $matches[1]; $DB_PASS = $matches[2]; $DB_HOST = $matches[3]
    $DB_PORT = $matches[4]; $DB_NAME = $matches[5]
} else {
    Log-Error "Format DATABASE_URL tidak valid!"; exit 1
}

$env:PGPASSWORD = $DB_PASS

if (-not (Get-Command "psql" -ErrorAction SilentlyContinue)) { Log-Error "psql tidak ditemukan!"; exit 1 }

Log-Step "Mengecek Koneksi Database"
$testResult = psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" 2>&1
if ($LASTEXITCODE -ne 0) { Log-Error "Gagal konek ke database."; exit 1 }
Log-Ok "Koneksi database berhasil!"

function Run-SQL {
    param($filepath)
    $filename = Split-Path $filepath -Leaf

    # --- TRIK BARU: Membuang bagian "DROP TABLE" ---
    $tempFile = "$env:TEMP\_fitcoach_temp.sql"
    $lines = Get-Content $filepath
    $validLines = @()
    foreach ($line in $lines) {
        if ($line -match "-- \+migrate Down") { break }
        $validLines += $line
    }
    $validLines | Set-Content $tempFile -Encoding UTF8
    # -----------------------------------------------

    # Eksekusi dengan aturan ON_ERROR_STOP agar jujur jika gagal
    $result = psql -v ON_ERROR_STOP=1 -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "`"$tempFile`"" 2>&1

    if ($LASTEXITCODE -eq 0) {
        Log-Ok "$filename"
    } else {
        Log-Error "$filename GAGAL!"
        Write-Host $result -ForegroundColor Red
        exit 1
    }
}

Log-Step "Menjalankan Migrations (Tanpa Self-Destruct)"
$migrationDir = "database\migrations"
$migrationFiles = Get-ChildItem "$migrationDir\*.sql" | Sort-Object Name
foreach ($file in $migrationFiles) { Run-SQL $file.FullName }
Log-Ok "Semua migration selesai!"

Log-Step "Menjalankan Seeds"
$seedDir = "database\seeds"
$seedFiles = Get-ChildItem "$seedDir\*.sql" | Sort-Object Name
foreach ($file in $seedFiles) { Run-SQL $file.FullName }
Log-Ok "Semua seed selesai!"

Log-Step "Setup Database Selesai!"