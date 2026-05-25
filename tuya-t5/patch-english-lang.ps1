# Sets Tuya AI chatbot UI strings to English (lang_config.h).
# Usage: powershell -ExecutionPolicy Bypass -File tuya-t5\patch-english-lang.ps1

$ErrorActionPreference = "Stop"

$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$langFile = Join-Path $tuyaOpen "apps\tuya.ai\ai_components\assets\include\lang_config.h"

if (-not (Test-Path $langFile)) {
    Write-Host "lang_config.h not found: $langFile" -ForegroundColor Red
    exit 1
}

$content = @'
// English language config (FreshrFridge)
#ifndef __LANGUAGE_CONFIG_H__
#define __LANGUAGE_CONFIG_H__

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

#define LANG_CODE "en-US"

#define VERSION "Version "
#define INITIALIZING "Initializing..."
#define PROVISIONING "Provisioning..."
#define REGISTERING_NETWORK "Waiting for network..."
#define CONNECT_SERVER "Connecting to server..."
#define STANDBY "Standby"
#define CONNECT_TO "Connect to "
#define CONNECTING "Connecting..."
#define CONNECTED_TO "Connected to "
#define LISTENING "Listening..."
#define UPLOADING "Uploading..."
#define THINKING "Thinking..."
#define SPEAKING "Speaking..."
#define HOLD_TALK "Hold to talk"
#define TRIG_TALK "Press to talk"
#define WAKEUP_TALK "Wake word"
#define FREE_TALK "Free talk"
#define ENTERING_WIFI_CONFIG_MODE "WiFi setup mode..."
#define VOLUME "Volume "
#define MUTED "Muted"
#define MAX_VOLUME "Max volume"
#define SYSTEM_MSG_POWER_ON "Power on"
#define SYSTEM_MSG_WIFI_SSID "WiFi connected"
#define SYSTEM_MSG_IP "IP address"
#define SYSTEM_MSG_WIFI_DISCONNECTED "WiFi disconnected"
#define SYSTEM_MSG_VOLUME "Volume set to"
#define VIEW_IMAGE "View image"

#ifdef __cplusplus
}
#endif

#endif // __LANGUAGE_CONFIG_H
'@

Set-Content -Path $langFile -Value $content -Encoding utf8
Write-Host "  English language applied: $langFile" -ForegroundColor Green
