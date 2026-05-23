/**
 * @file freshrfridge_main.c
 * @brief FreshrFridge entry for Tuya T5 AI (3.5" touch LCD).
 */

#include "tuya_cloud_types.h"

#include "board_com_api.h"
#include "camera_scan.h"
#include "fridge_store.h"
#include "lv_vendor.h"
#include "lvgl.h"
#include "tal_api.h"
#include "tkl_output.h"
#include "ui_fridge.h"

static void user_main(void)
{
    OPERATE_RET rt;

    tal_log_init(TAL_LOG_LEVEL_DEBUG, 4096, (TAL_LOG_OUTPUT_CB)tkl_log_output);

    PR_NOTICE("FreshrFridge on Tuya T5 AI");
    PR_NOTICE("Project: %s  version: %s", PROJECT_NAME, PROJECT_VERSION);
    PR_NOTICE("Board: %s", PLATFORM_BOARD);

    board_register_hardware();

    TUYA_CALL_ERR_LOG(fridge_store_init());
    TUYA_CALL_ERR_LOG(camera_scan_init());

    lv_vendor_init(DISPLAY_NAME);
    lv_vendor_disp_lock();
    ui_fridge_create();
    ui_fridge_refresh();
    lv_vendor_disp_unlock();

    lv_vendor_start(5, 1024 * 8);
}

#if OPERATING_SYSTEM == SYSTEM_LINUX
void main(int argc, char *argv[])
{
    (void)argc;
    (void)argv;
    user_main();
    while (1) {
        tal_system_sleep(500);
    }
}
#else

static THREAD_HANDLE ty_app_thread = NULL;

static void tuya_app_thread(void *arg)
{
    (void)arg;
    user_main();
    tal_thread_delete(ty_app_thread);
    ty_app_thread = NULL;
}

void tuya_app_main(void)
{
    THREAD_CFG_T thrd_param = {0};
    thrd_param.stackDepth = 1024 * 6;
    thrd_param.priority = THREAD_PRIO_1;
    thrd_param.thrdname = "freshrfridge";
    tal_thread_create_and_start(&ty_app_thread, NULL, NULL, tuya_app_thread, NULL, &thrd_param);
}
#endif
