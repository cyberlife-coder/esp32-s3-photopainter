# PhotoPainter Studio — notes de travail

Outil web 100 % local (`index.html` + `vendor/libheif-bundle.js`) qui convertit
JPG/PNG/WebP/GIF/BMP/HEIC en BMP 800×480 · 24 bpp · 6 couleurs pour le cadre
e-paper ESP32-S3 (firmware `GUI_ReadBmp_RGB_6Color`, dossier `06_user_Foundation_img`).

## Build / run

- `docker build -t photopainter-studio:latest .` puis `docker run -d --name photopainter-studio -p 8765:80 photopainter-studio:latest` (ou l'app Desktop / `launch-app.sh`).
- ATTENTION : le port 8765 est parfois squatté par un `python -m http.server` ou un
  forward SSH (`lsof -nP -iTCP:8765 -sTCP:LISTEN`) — `launch-app.sh` libère le port.

## HEIC — points critiques (ne pas régresser)

- `HeifDecoder.decode()` exige un `Uint8Array`, PAS un `ArrayBuffer`
  (`BindingError: Cannot pass non-string to std::string` sinon).
- **Ce bundle applique déjà `irot`/`imir` dans `img.display()`** : les pixels sont
  restitués orientés. Ne PAS re-tourner par `irot` (bug passé = double rotation ;
  les anciens tests ne vérifiaient que les dims → faux positif).
- `decode()` ne retourne que l'image primaire (1 élément), même sur des HEIC à
  ~100 items (iPhone récents : dérivés, HDR, miniatures).
- `sips`/`magick` n'appliquent PAS `irot` à l'export PNG → ne pas les utiliser
  comme référence d'orientation. Vérité = pixels de `display()`.

## Tests

- `e2e-heic.html` et `test-e2e.html` chargent le VRAI `index.html` en iframe et
  injectent des `File` via `handleFiles()` — servir le dossier en HTTP
  (`python3 -m http.server`) et ouvrir dans Chrome.
- Headless : `~/Library/Caches/ms-playwright/chromium_headless_shell-*/chrome-headless-shell --dump-dom --virtual-time-budget=60000 <url>`.
- Checks automatisés : BMP = 1 152 054 o, 800×480, 24 bpp, pixels ⊆ palette 6 couleurs.
  L'orientation se contrôle visuellement (les dims seules ne prouvent rien).
- Fixtures publiques : `test-*.heic/.png`, `test-photo.heic` (synthétiques —
  les vrais HEIC iPhone restent privés, jamais commités).
- Fichiers de debug supprimés avant publication : `test-heic.html`,
  `heic-debug.html`, `libheif-test.html`, `verify-orient.js`, `debug-test.heic`,
  `v_*.png`, `o_*.png`.
