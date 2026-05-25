# Enables Tuya "emoji + settings" UI (display2) and wires AI events + WiFi button.
$ErrorActionPreference = "Stop"

$tuyaOpen = if ($env:TUYA_OPEN_ROOT) { $env:TUYA_OPEN_ROOT } else { "C:\Users\shivr\TuyaOpen" }
$appRoot = Join-Path $tuyaOpen "apps\tuya.ai\your_chat_bot"
$mark = "FreshrFridge: emoji display2 UI"

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($Path, $Text, $enc)
}

# --- app_display.h (missing in some SDK trees) ---
$displayH = Join-Path $appRoot "include\app_display.h"
if (-not (Test-Path (Split-Path $displayH -Parent))) {
    New-Item -ItemType Directory -Force -Path (Split-Path $displayH -Parent) | Out-Null
}
if (-not (Test-Path $displayH)) {
    @'
#ifndef __APP_DISPLAY_H__
#define __APP_DISPLAY_H__

#include "tuya_cloud_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    TY_DISPLAY_TP_EMOTION = 0,
    TY_DISPLAY_TP_STATUS,
    TY_DISPLAY_TP_USER_MSG,
    TY_DISPLAY_TP_ASSISTANT_MSG,
    TY_DISPLAY_TP_SYSTEM_MSG,
} TY_DISPLAY_TYPE_E;

OPERATE_RET app_display_init(void);
OPERATE_RET app_display_send_msg(TY_DISPLAY_TYPE_E type, uint8_t *data, int len);
OPERATE_RET app_display_camera_start(uint16_t width, uint16_t height);
OPERATE_RET app_display_camera_flush(uint8_t *data, uint16_t width, uint16_t height);
OPERATE_RET app_display_camera_end(void);

#ifdef __cplusplus
}
#endif

#endif
'@ | Set-Content -Path $displayH -Encoding utf8
    Write-Host "  Created app_display.h" -ForegroundColor Green
}

# --- CMakeLists: link display2 in embedded builds ---
$cmake = Join-Path $appRoot "CMakeLists.txt"
$cmakeText = Get-Content $cmake -Raw
if ($cmakeText -notmatch $mark) {
    $cmakeText = $cmakeText -replace '(add_subdirectory\(\$\{APP_PATH\}/\.\./ai_components\)\s*\r?\nendif\(\))', @"
add_subdirectory(`${APP_PATH}/src/display2)

# $mark
add_subdirectory(`${APP_PATH}/../ai_components)
endif()
"@
    Write-Utf8NoBom $cmake $cmakeText
    Write-Host "  Patched your_chat_bot CMakeLists.txt" -ForegroundColor Green
}

# --- ai_chat_ui.c: route events to app_display when DISPLAY2 ---
$aiChatUi = Join-Path $tuyaOpen "apps\tuya.ai\ai_components\ai_main\src\ai_chat_ui.c"
$uiText = Get-Content $aiChatUi -Raw
if ($uiText -notmatch $mark) {
    $uiText = $uiText -replace '(#include "ai_chat_main.h")', @'
#include "app_display.h"

$1
'@
    $uiText = $uiText -replace 'static void __ai_chat_disp_mode_state\(AI_MODE_STATE_E state\)\s*\{', @'
#if defined(ENABLE_CHAT_DISPLAY2) && (ENABLE_CHAT_DISPLAY2 == 1)
static void __disp_status(AI_MODE_STATE_E state)
{
    switch (state) {
    case AI_MODE_STATE_INIT:
    case AI_MODE_STATE_IDLE:
        app_display_send_msg(TY_DISPLAY_TP_EMOTION, (uint8_t *)"NEUTRAL", 7);
        app_display_send_msg(TY_DISPLAY_TP_STATUS, (uint8_t *)STANDBY, strlen(STANDBY));
        break;
    case AI_MODE_STATE_LISTEN:
        app_display_send_msg(TY_DISPLAY_TP_STATUS, (uint8_t *)LISTENING, strlen(LISTENING));
        break;
    case AI_MODE_STATE_SPEAK:
        app_display_send_msg(TY_DISPLAY_TP_STATUS, (uint8_t *)SPEAKING, strlen(SPEAKING));
        break;
    case AI_MODE_STATE_UPLOAD:
        app_display_send_msg(TY_DISPLAY_TP_STATUS, (uint8_t *)UPLOADING, strlen(UPLOADING));
        break;
    default:
        break;
    }
}
#endif

static void __ai_chat_disp_mode_state(AI_MODE_STATE_E state)
{
#if defined(ENABLE_CHAT_DISPLAY2) && (ENABLE_CHAT_DISPLAY2 == 1)
    __disp_status(state);
    return;
#endif
'@
    $uiText = $uiText -replace 'void ai_chat_ui_handle_event\(AI_NOTIFY_EVENT_T \*event\)\s*\{', @'
void ai_chat_ui_handle_event(AI_NOTIFY_EVENT_T *event)
{
#if defined(ENABLE_CHAT_DISPLAY2) && (ENABLE_CHAT_DISPLAY2 == 1)
    AI_NOTIFY_TEXT_T *text = NULL;
    if (NULL == event) {
        return;
    }
    switch (event->type) {
    case AI_USER_EVT_EMOTION:
    case AI_USER_EVT_LLM_EMOTION: {
        AI_NOTIFY_EMO_T *emo = (AI_NOTIFY_EMO_T *)(event->data);
        if (emo && emo->name) {
            app_display_send_msg(TY_DISPLAY_TP_EMOTION, (uint8_t *)emo->name, strlen(emo->name));
        }
    } break;
    case AI_USER_EVT_MODE_STATE_UPDATE: {
        __disp_status((AI_MODE_STATE_E)(event->data));
    } break;
    default:
        break;
    }
    return;
#endif
'@
    $uiText = $uiText -replace 'OPERATE_RET ai_chat_ui_init\(void\)\s*\{', @'
OPERATE_RET ai_chat_ui_init(void)
{
#if defined(ENABLE_CHAT_DISPLAY2) && (ENABLE_CHAT_DISPLAY2 == 1)
    return app_display_init();
#endif
'@
    $uiText = $uiText -replace '#else\r?\n#error "please select ai chat present ui"', @"
#else
#if !defined(ENABLE_CHAT_DISPLAY2) || (ENABLE_CHAT_DISPLAY2 != 1)
#error `"please select ai chat present ui`"
#endif
"@
    Write-Utf8NoBom $aiChatUi $uiText
    Write-Host "  Patched ai_chat_ui.c" -ForegroundColor Green
}

# --- app_chat_bot.c: skip old text UI init when DISPLAY2 ---
$appChat = Join-Path $appRoot "src\app_chat_bot.c"
$botText = Get-Content $appChat -Raw
if ($botText -notmatch $mark) {
    $old = @'
#if defined(ENABLE_COMP_AI_DISPLAY) && (ENABLE_COMP_AI_DISPLAY == 1)
    ai_ui_disp_msg(AI_UI_DISP_NETWORK, (uint8_t *)&sg_wifi_status, sizeof(AI_UI_WIFI_STATUS_E));

    ai_ui_disp_msg(AI_UI_DISP_STATUS, (uint8_t *)INITIALIZING, strlen(INITIALIZING));
    ai_ui_disp_msg(AI_UI_DISP_EMOTION, (uint8_t *)EMOJI_NEUTRAL, strlen(EMOJI_NEUTRAL));

    // display status update
    tal_sw_timer_create(__display_status_tm_cb, NULL, &sg_disp_status_tm);
    tal_sw_timer_start(sg_disp_status_tm, DISP_NET_STATUS_TIME, TAL_TIMER_CYCLE);
#endif
'@
    $new = @"
#if defined(ENABLE_CHAT_DISPLAY2) && (ENABLE_CHAT_DISPLAY2 == 1)
    /* $mark */
#elif defined(ENABLE_COMP_AI_DISPLAY) && (ENABLE_COMP_AI_DISPLAY == 1)
    ai_ui_disp_msg(AI_UI_DISP_NETWORK, (uint8_t *)&sg_wifi_status, sizeof(AI_UI_WIFI_STATUS_E));
    ai_ui_disp_msg(AI_UI_DISP_STATUS, (uint8_t *)INITIALIZING, strlen(INITIALIZING));
    ai_ui_disp_msg(AI_UI_DISP_EMOTION, (uint8_t *)EMOJI_NEUTRAL, strlen(EMOJI_NEUTRAL));
    tal_sw_timer_create(__display_status_tm_cb, NULL, &sg_disp_status_tm);
    tal_sw_timer_start(sg_disp_status_tm, DISP_NET_STATUS_TIME, TAL_TIMER_CYCLE);
#endif
"@
    $botText = $botText.Replace($old, $new)
    Write-Utf8NoBom $appChat $botText
    Write-Host "  Patched app_chat_bot.c" -ForegroundColor Green
}

# --- WiFi icon in settings screen ---
$uiEvents = Join-Path $appRoot "src\display2\ui_chatbot\ui_events.c"
$evText = Get-Content $uiEvents -Raw
if ($evText -notmatch 'FreshrFridge: wifi settings tap') {
    $evText = $evText -replace '(#include "app_ui_helper.h")', @'
#include "netmgr.h"
#include "netcfg.h"
#include "lang_config.h"

$1
'@
    $wifiCb = @'

void wifi_icon_tap_callback(lv_event_t *e)
{
    if (lv_event_get_code(e) != LV_EVENT_CLICKED) {
        return;
    }
    PR_NOTICE("WiFi settings icon tapped - start provisioning");
    netmgr_conn_set(NETCONN_WIFI, NETCONN_CMD_NETCFG,
                    &(netcfg_args_t){ .type = NETCFG_TUYA_BLE | NETCFG_TUYA_WIFI_AP });
}

'@
    $evText = $evText -replace '(void volume_change_callback)', "$wifiCb`n`$1"
    $evText = $evText -replace '(ui_setting_wifi_update\(wifi_status\);\s*\r?\n    // get battery status)', @'
ui_setting_wifi_update(wifi_status);
    extern lv_obj_t * ui_wifi;
    if (ui_wifi) {
        lv_obj_add_event_cb(ui_wifi, wifi_icon_tap_callback, LV_EVENT_CLICKED, NULL);
    }
    // get battery status
'@
    Write-Utf8NoBom $uiEvents $evText
    Write-Host "  Patched ui_events.c (WiFi tap)" -ForegroundColor Green
}

Write-Host "  Emoji UI patch complete." -ForegroundColor Green