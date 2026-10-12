#!/bin/bash
# PhotoPainter Studio — lanceur (colima + docker + navigateur)
PORT=8765
URL="http://localhost:$PORT"
NAME="photopainter-studio"
LOG="$HOME/Library/Logs/photopainter-studio.log"
exec >>"$LOG" 2>&1
echo "=== $(date '+%Y-%m-%d %H:%M:%S') — lancement ==="

say_ok()  { osascript -e "display notification \"$1\" with title \"PhotoPainter Studio\"" 2>/dev/null; }
say_err() { osascript -e "display dialog \"$1\" buttons {\"OK\"} with title \"PhotoPainter Studio\" with icon stop" 2>/dev/null; }

# 1) déjà en ligne ?
if docker ps --format '{{.Names}}' 2>/dev/null | grep -qx "$NAME" && curl -sf -o /dev/null --max-time 2 "$URL/"; then
  open "$URL"
  say_ok "Déjà en ligne — $URL"
  exit 0
fi

# 2) colima / docker
if ! docker info >/dev/null 2>&1; then
  echo "colima inactif — démarrage…"
  colima start || { say_err "Échec du démarrage de colima (voir $LOG)."; exit 1; }
fi
for i in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done
if ! docker info >/dev/null 2>&1; then
  say_err "Docker (colima) est indisponible (voir $LOG)."
  exit 1
fi

# 3) libérer le port 8765 (ancien serveur python éventuel)
if [ -n "$(lsof -ti:$PORT 2>/dev/null)" ]; then
  echo "port $PORT occupé (pid $(lsof -ti:$PORT | tr '\n' ' ')) — libération"
  lsof -ti:$PORT 2>/dev/null | xargs kill 2>/dev/null
  sleep 1
  lsof -ti:$PORT 2>/dev/null | xargs kill -9 2>/dev/null || true
fi

# 4) conteneur
docker rm -f "$NAME" >/dev/null 2>&1
if ! docker run -d --name "$NAME" -p $PORT:80 photopainter-studio:latest >/dev/null; then
  say_err "Échec du démarrage du conteneur (voir $LOG)."
  exit 1
fi

# 5) attendre le HTTP
ok=0
for i in $(seq 1 15); do
  curl -sf -o /dev/null --max-time 2 "$URL/" && { ok=1; break; }
  sleep 1
done
if [ $ok -eq 1 ]; then
  open "$URL"
  say_ok "Outil en ligne — $URL"
else
  say_err "Le conteneur a démarré mais $URL ne répond pas (voir $LOG)."
  exit 1
fi
exit 0
