# PhotoPainter Studio

**Convert iPhone HEIC / JPG / PNG / WebP / GIF / BMP photos into ready-to-display
800×480 6-color BMP images for the Waveshare ESP32-S3 PhotoPainter e-paper photo
frame — 100% in your browser, no upload, no server-side processing.**

The [Waveshare PhotoPainter](https://www.waveshare.com/photopainter.htm)
(ESP32-S3, 7.3-inch E6 Spectra™ 6-color e-ink display, 800×480) only renders a
very specific file: a **24-bit BMP, 800×480, quantized to its 6-color palette**
(black, white, red, green, blue, yellow). iPhone photos come out as HEIC, the
official upload page is a clunky web UI — this tool does the whole conversion
locally, offline, in one drag & drop.

## Why

- **HEIC/HEIF support** — the format every iPhone shoots by default. Decoded
  locally with a vendored libheif WASM build (`vendor/libheif-bundle.js`), so it
  works in Chrome, Edge, Firefox — even fully offline. Safari also decodes HEIC
  natively.
- **Correct orientation** — `irot`/`imir` display transforms and EXIF
  orientation are honored, so portrait shots and selfies never come out
  sideways.
- **Same result as the official tool** — resize/crop to 800×480, then
  Floyd–Steinberg dithering against the exact 6-color palette the firmware uses
  (`GUI_ReadBmp_RGB_6Color`). Output BMPs are byte-compatible with what the
  frame expects (1,152,054 bytes each).
- **Privacy** — everything runs client-side: your photos never leave your
  machine. The tool is a single static page; there is no backend.
- **Batch + direct SD write** — drop a whole folder of photos, then write them
  straight to the `06_user_Foundation_img` folder of the mounted SD card
  (Chrome/Edge, File System Access API) or download them all.

## Usage

The app is **two files**: `index.html` + `vendor/libheif-bundle.js`.
No build step, no dependencies to install.

- **Simplest:** open `index.html` in Chrome, Edge or Safari — done.
- **Or serve it statically** (any web server works):

  ```bash
  python3 -m http.server 8765
  # → http://localhost:8765/index.html
  ```

Then:

1. Drop your HEIC/JPG/PNG files onto the page.
2. Pick the fit mode: **cover-crop** (recommended, fills the screen) or
   **stretch** (like the official page).
3. Either **write directly to the SD card** (`06_user_Foundation_img` folder),
   **download** the BMPs, or **push to the frame over Wi-Fi** (`esp_network`,
   frame in mode 2 / `192.168.4.1`).

## Tested formats

| Input | Path | Status |
|---|---|---|
| HEIC / HEIF (iPhone) | libheif WASM, orientation applied | ✅ |
| JPEG (incl. EXIF orientation) | native browser decode | ✅ |
| PNG | native | ✅ |
| WebP | native | ✅ |
| GIF | first frame | ✅ |
| BMP | native | ✅ |

E2E-tested headlessly on 24 real iPhone HEIC files covering every `irot` value
(0/1/2/3): all produce a valid 800×480 24-bit BMP with pixels strictly inside
the 6-color palette.

## Notes & gotchas

- libheif's `decode()` wants a `Uint8Array` (not an `ArrayBuffer`), and this
  bundle **already applies `irot`/`imir`** inside `display()` — do not rotate a
  second time.
- `sips`/ImageMagick do **not** apply `irot` on export — don't use them as an
  orientation reference.
- The frame only renders landscape 800×480 BMPs correctly; portrait sources are
  center-cropped, small images are upscaled onto a white matte.

## License

MIT — see [LICENSE](LICENSE).
