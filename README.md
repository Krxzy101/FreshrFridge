# FreshrFridge

A fridge assistant that tracks what you have on hand and highlights which items to **use first** — sorted by expiry date, with FIFO ordering for items without a date.

Runs as a **web app** (browser) and as **firmware** for the **Tuya T5 AI** board (3.5" touchscreen on the fridge). Camera-based “scan food” is planned on the device; see [tuya-t5/README.md](tuya-t5/README.md).

## Features

- **Add items** with name, quantity, unit, category, optional expiry date, and notes
- **Use first** view — priority list (soonest expiry at the top)
- **Urgency badges** — expired, use today, use soon, this week, fresh
- **Full inventory** with category filter
- **Used 1** — decrement quantity when you consume something; item is removed at zero
- **Local storage** — data stays in your browser

## Getting started

```bash
npm install
npm run dev
```

Open the URL shown in the terminal (usually `http://localhost:5173`).

## Build for production

```bash
npm run build
npm run preview
```

## How “use first” works

1. Items **with** an expiry date are sorted soonest-first.
2. Items **without** an expiry date appear after dated items, sorted by the day you added them (oldest first).

Set expiry dates when you can for the most accurate priority list.

## AI assistant + database (PC)

1. `Website\Groq` — Groq API + SQLite (`freshrfridge.db`). Copy `.env.example` → `.env`, set `GROQ_API_KEY`.
2. Double-click **`START-BACKEND.bat`** (port 3000).
3. Double-click **`START-WEB.bat`** → http://localhost:5173 — use **Get suggestions** and **Speak summary**.

See **[SETUP-NEXT-STEPS.txt](SETUP-NEXT-STEPS.txt)** for the full checklist.

**Quick start (PowerShell):** `.\Run.ps1`

## Tuya T5 AI (touchscreen on the fridge)

- **Fridge UI (local flash storage):** `BUILD-FIRMWARE.bat` then `FLASH-FIRMWARE.bat`
- **WiFi + AI voice (English on screen and speaker):** `BUILD-FLASH-AI-BOARD.bat`

Manual SDK steps: **[tuya-t5/README.md](tuya-t5/README.md)**.

On the device:

- **Use first** list with color-coded urgency
- **Add item** via on-screen keyboard
- **Camera scan** — stub today; DVP camera hook for later food recognition

## Roadmap

- [ ] Camera capture + AI label → auto-fill item name (T5 AI DVP camera)
- [ ] Optional Tuya Cloud sync between web and device
- [ ] Barcode / receipt import on web

## Tech stack

**Web:** React, TypeScript, Vite, Tailwind CSS v4  

**Device:** TuyaOpen, C, LVGL, `tal_kv` flash storage
