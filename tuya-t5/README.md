# FreshrFridge on Tuya T5 AI

Firmware for the **Tuya T5 AI** development board (3.5" touch LCD, optional **DVP camera**). Same “use first” rules as the web app in the repo root.

## What runs on the device

| Feature | Status |
|--------|--------|
| Touch UI — “Use first” list | Ready |
| Add item (name, category, expiry) | Ready |
| Tap item = used 1 · long-press = remove | Ready |
| Flash storage (`tal_kv`) | Ready |
| Camera scan → suggest food name | **Stub** (hook ready) |

## Hardware

- **Board:** Tuya T5 AI (T5AI-Board) with 3.5" LCD module (`35565LCD`)
- **Display:** 320×480, touch
- **Camera (optional):** DVP ~480×480 MJPEG — enable when you add the camera module

Official references:

- [TuyaOpen repo](https://github.com/tuya/TuyaOpen)
- [T5 AI quick start (Wukong / Wind IDE)](https://developer.tuya.com/en/docs/iot-device-dev/quick-start?id=Kectxdshpvsqr)
- [T5 AI board hardware](https://developer.tuya.com/en/docs/iot-device-dev/tuyaos-wukong-solutions?id=Kffrlr9f755wb)

## Device license (uuid + key)

Your Tuya license spreadsheet has two columns:

| Column | Meaning |
|--------|---------|
| **uuid** | Device UUID (one per board) |
| **key** | Device auth key (secret) |

**Use one row per physical T5 board.** If you have two rows, the second is for a second device or a spare license — do not put both in one firmware build.

1. Copy `config/device_secrets.config.example` → `config/device_secrets.config`
2. Paste **one** uuid and **one** key from your sheet, plus your product ID `d8vyu8pererkd5nx`
3. Merge into your board config before build (see below)

Do **not** commit `device_secrets.config` or share keys in chat/screenshots. If keys were exposed, regenerate licenses on the Tuya platform.

**Merge secrets (easy — Windows):** double-click:

`freshrfridge/config/merge-secrets.bat`

Or in PowerShell:

```powershell
cd tuya-t5\freshrfridge\config
.\merge-secrets.ps1
```

That copies your three `CONFIG_TUYA_*` lines into `TUYA_T5AI_BOARD_LCD_3.5.config` automatically. Run again anytime you change secrets.

## Install (one-time)

1. Clone **TuyaOpen** (follow their environment setup for Windows + Linux VM or native Linux).
2. Copy this app into the SDK apps folder:

   ```bash
   cp -r /path/to/FreshrFridge/tuya-t5/freshrfridge /path/to/TuyaOpen/apps/freshrfridge
   ```

3. Select the app and board (CLI names may vary slightly by SDK version):

   ```bash
   cd TuyaOpen
   tos.py config choice    # T5AI → 3.5" LCD board
   tos.py set_app freshrfridge
   ```

4. Build and flash:

   ```bash
   tos.py build
   tos.py flash
   ```

Use `config/TUYA_T5AI_BOARD_LCD_3.5.config` for LCD only, or `config/TUYA_T5AI_BOARD_LCD_CAMERA.config` when you are ready to enable camera defines.

## Using the UI

1. **Use first** — Items sorted by expiry (soonest first), then FIFO for items without a date.
2. **Add item** — Enter name, category, optional `YYYY-MM-DD` expiry.
3. **Tap** a row — Decrease quantity by 1.
4. **Long-press** a row — Remove the item.
5. **Scan (soon)** — Disabled until camera + vision are implemented.

## Camera (later)

The T5 AI board exposes a **DVP camera** (often GC2145). Tuya’s AI chatbot samples already register it on the board package.

Planned flow:

1. Capture frame from `CAMERA_NAME` / `tkl_vi`.
2. Run food recognition (Tuya AI multimodal API or an on-device model).
3. Fill the add form with `camera_scan_result_t.suggested_name`.

Code hooks:

- `include/camera_scan.h`
- `src/camera/camera_scan_stub.c`

To enable compile-time hooks, use `config/TUYA_T5AI_BOARD_LCD_CAMERA.config` and align with your board’s camera registration (see `your_chat_bot` / Wukong board `tuya_t5ai_board.c`).

## Project layout

```
freshrfridge/
├── src/
│   ├── freshrfridge_main.c   # Entry, LVGL init
│   ├── fridge_priority.c     # Use-first logic (matches web)
│   ├── fridge_store.c        # KV persistence
│   ├── ui/ui_fridge.c        # Touch screens
│   └── camera/camera_scan_stub.c
├── include/
├── config/                   # Board presets
└── CMakeLists.txt
```

## Web app vs device

| | Web (`npm run dev`) | T5 AI firmware |
|--|---------------------|----------------|
| Storage | Browser `localStorage` | Flash `tal_kv` |
| UI | React | LVGL |
| Camera | Not yet | Stub on device |

Sync between phone/PC and fridge display would need Tuya Cloud datapoints or your own API — not included in this MVP.

## Troubleshooting

- **Blank screen** — Confirm `CONFIG_ENABLE_LIBLVGL` and the 3.5" LCD board config match your hardware module.
- **Touch not working** — Enable `CONFIG_LVGL_ENABLE_TP=y`.
- **Build can’t find app** — Ensure the folder is named `freshrfridge` under `TuyaOpen/apps/` and `tos.py set_app` matches.
