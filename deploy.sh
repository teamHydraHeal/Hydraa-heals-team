#!/bin/bash
set -e

echo "═══════════════════════════════════════════"
echo "  Jalguard — Full Deploy"
echo "═══════════════════════════════════════════"

# 1. Pull latest code
echo "→ Pulling latest code..."
git pull --ff-only

# 2. Build Flutter web
echo "→ Building Flutter web (release)..."
flutter build web --release --no-tree-shake-icons

# 3. Build & start Docker containers
echo "→ Starting Docker containers..."
docker compose up -d --build

echo ""
echo "✅ Deploy complete!"
echo "   Web app:  http://$(curl -s ifconfig.me):9090"
echo "   Backend:  http://localhost:5001"
echo "   Ollama:   http://localhost:11434"
