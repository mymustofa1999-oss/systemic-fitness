#!/bin/bash
set -e

SERVER_IP="192.168.12.16"
REPO_URL="https://github.com/mymustofa1999-oss/systemic-fitness.git"
APP_DIR="/home/fitadmin/systemic-fitness"

echo "=============================================="
echo " Systemic Fitness - Auto Deploy Script"
echo " Server: $SERVER_IP"
echo "=============================================="

# ── 1. Update system ──────────────────────────────
echo "[1/7] Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y

# ── 2. Install Docker ─────────────────────────────
echo "[2/7] Installing Docker..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com | sudo sh
  sudo usermod -aG docker $USER
  echo "Docker installed successfully."
else
  echo "Docker already installed, skipping."
fi

# ── 3. Install Docker Compose ─────────────────────
echo "[3/7] Installing Docker Compose..."
if ! command -v docker compose &> /dev/null; then
  sudo apt-get install -y docker-compose-plugin
fi
docker compose version

# ── 4. Clone / update repository ─────────────────
echo "[4/7] Cloning repository..."
if [ -d "$APP_DIR" ]; then
  echo "Directory exists, pulling latest changes..."
  cd "$APP_DIR" && git pull
else
  git clone "$REPO_URL" "$APP_DIR"
  cd "$APP_DIR"
fi
cd "$APP_DIR"

# ── 5. Write .env file ────────────────────────────
echo "[5/7] Writing environment configuration..."
cat > .env << 'ENVEOF'
# ── API ──────────────────────────────────────────
DATABASE_URL=postgres://fitadmin:Fitcoach2026!@db:5432/systemic_fitness?sslmode=disable
JWT_SECRET=systemic-fitness-super-secret-jwt-key-2026-production
CORS_ALLOWED_ORIGINS=http://192.168.12.16:3000,http://localhost:3000,http://vpn.smkn6garut.sch.id:8888,http://vpn.smkn6garut.sch.id:3000
BASE_URL=http://192.168.12.16:8080

# ── Web ───────────────────────────────────────────
NEXT_PUBLIC_API_URL=
NEXTAUTH_URL=http://vpn.smkn6garut.sch.id:8888
NEXTAUTH_SECRET=systemic-fitness-nextauth-secret-2026-production
ENVEOF
echo ".env file created."

# ── 6. Build & start containers ───────────────────
echo "[6/7] Building and starting all services..."
sudo docker compose down --remove-orphans 2>/dev/null || true
sudo docker compose build --no-cache
sudo docker compose up -d

# ── 7. Run database migrations ────────────────────
echo "[7/7] Running database migrations..."
sleep 5
sudo docker compose exec api ./fitcoach-api migrate 2>/dev/null || \
  echo "Migration via exec skipped - migrations run on API startup automatically."

echo ""
echo "=============================================="
echo " DEPLOYMENT COMPLETE!"
echo "=============================================="
echo " Web App  : http://$SERVER_IP:3000"
echo " API      : http://$SERVER_IP:8080"
echo " Health   : http://$SERVER_IP:8080/health"
echo "=============================================="
echo ""
echo "To check logs: sudo docker compose logs -f"
