#!/usr/bin/env bash
set -euo pipefail

# Jump to this script's folder (the backend/)
cd "$(dirname "$0")"

PORT="${PORT:-8000}"
HOST="${HOST:-0.0.0.0}"

echo "==> Ensuring Python venv…"
if [[ ! -d "../venv" ]]; then
  python -m venv ../venv
fi

# Activate venv (Linux/macOS or Git Bash on Windows)
if [[ -f "../venv/bin/activate" ]]; then
  # Linux/macOS
  # shellcheck disable=SC1091
  source ../venv/bin/activate
elif [[ -f "../venv/Scripts/activate" ]]; then
  # Windows (Git Bash)
  # shellcheck disable=SC1091
  source ../venv/Scripts/activate
else
  echo "Could not find venv activation script." >&2
  exit 1
fi

echo "==> Installing/Updating deps…"
python -m pip install -U pip >/dev/null
pip install -r requirements.txt

# Compute your LAN IP to show a nice hint
LAN_IP="$(python - <<'PY'
import socket
ip="127.0.0.1"
try:
    s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(("8.8.8.8",80))
    ip=s.getsockname()[0]
    s.close()
except Exception:
    pass
print(ip)
PY
)"

echo
echo "--------------------------------------------"
echo " Personalised Learning API launcher"
echo "--------------------------------------------"
echo " PC (browser/Postman):   http://127.0.0.1:${PORT}"
echo " Android emulator:       http://10.0.2.2:${PORT}"
echo " Same Wi-Fi devices:     http://${LAN_IP}:${PORT}"
echo " Health check:           /health   (e.g., http://127.0.0.1:${PORT}/health)"
echo "--------------------------------------------"
echo

# Optionally open /health in a browser
OPEN_URL="http://127.0.0.1:${PORT}/health"
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "$OPEN_URL" >/dev/null 2>&1 || true
elif [[ "$OSTYPE" == "darwin"* ]]; then
  open "$OPEN_URL" || true
elif command -v cmd.exe >/dev/null 2>&1; then
  cmd.exe /c start "" "$OPEN_URL" >/dev/null 2>&1 || true
fi

echo "==> Starting Flask on ${HOST}:${PORT} (Ctrl+C to stop)…"
# Your app already binds host/port inside app.py
python app.py
