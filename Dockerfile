# PhotoPainter Studio — outil web de préparation de photos pour ESP32-S3 PhotoPainter
# Sert index.html + décodeur HEIC (WASM) via nginx.
#
# Après toute modification de l'outil, reconstruire :
#   docker build -t photopainter-studio:latest .
#
# Lancement (via l'app "PhotoPainter Studio" sur le Desktop, ou à la main) :
#   docker run -d --name photopainter-studio -p 8765:80 photopainter-studio:latest

FROM nginx:alpine

COPY . /usr/share/nginx/html/

EXPOSE 80
