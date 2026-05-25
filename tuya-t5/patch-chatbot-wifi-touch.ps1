# Makes the WiFi icon on the chatbot UI tappable → starts Tuya BLE/AP provisioning.
# Patches TuyaOpen ai_ui_chat_chatbot.c (run before each build).

$ErrorActionPreference = "Stop"

$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$file = Join-Path $tuyaOpen "apps\tuya.ai\ai_components\ai_ui\src\ai_ui_chat_chatbot.c"

if (-not (Test-Path $file)) {
    Write-Host "  ai_ui_chat_chatbot.c not found: $file" -ForegroundColor Red
    exit 1
}

$content = Get-Content $file -Raw

if ($content -match 'FreshrFridge: WiFi icon touch') {
    Write-Host "  WiFi touch patch already applied." -ForegroundColor Green
    exit 0
}

$includes = @"
#include "netmgr.h"
#include "netcfg.h"
#include "lang_config.h"
"@

if ($content -notmatch '#include "netmgr\.h"') {
    $content = $content -replace '(#include "ai_ui_chat_chatbot\.h")', "`$1`n`n$includes"
}

$handler = @'

/* FreshrFridge: WiFi icon touch → open provisioning (Tuya app / AP) */
static void __ui_wifi_icon_click_cb(lv_event_t *e)
{
    if (lv_event_get_code(e) != LV_EVENT_CLICKED) {
        return;
    }

    PR_NOTICE("WiFi icon tapped — starting network provisioning");

    if (sg_ui.status_label) {
        lv_vendor_disp_lock();
        lv_label_set_text(sg_ui.status_label, ENTERING_WIFI_CONFIG_MODE);
        lv_vendor_disp_unlock();
    }

    netmgr_conn_set(NETCONN_WIFI, NETCONN_CMD_NETCFG,
                    &(netcfg_args_t){ .type = NETCFG_TUYA_BLE | NETCFG_TUYA_WIFI_AP });
}

'@

if ($content -notmatch '__ui_wifi_icon_click_cb') {
    $content = $content -replace '(static void __ui_light_theme_init)', "$handler`n`$1"
}

$touchSetup = @'
    lv_obj_add_flag(sg_ui.network_label, LV_OBJ_FLAG_CLICKABLE);
    lv_obj_set_ext_click_area(sg_ui.network_label, 24);
    lv_obj_add_event_cb(sg_ui.network_label, __ui_wifi_icon_click_cb, LV_EVENT_CLICKED, NULL);
'@

if ($content -notmatch 'lv_obj_add_event_cb\(sg_ui\.network_label') {
    $content = $content -replace '(lv_obj_align\(sg_ui\.network_label, LV_ALIGN_RIGHT_MID, -5, 0\);)', "`$1`n$touchSetup"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($file, $content, $utf8NoBom)
Write-Host "  WiFi icon touch patch applied: $file" -ForegroundColor Green
