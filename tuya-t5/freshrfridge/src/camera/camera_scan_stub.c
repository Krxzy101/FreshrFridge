/**
 * @file camera_scan_stub.c
 * @brief Placeholder until DVP camera + vision model is wired in.
 *
 * Next steps (see tuya-t5/README.md):
 * - Enable camera in board config (DVP GC2145 on T5 AI board)
 * - Register camera via tdd_camera_dvp_gc2145_register()
 * - Capture frame and run food label detection (Tuya AI or custom model)
 */

#include "camera_scan.h"

#include "tal_api.h"

OPERATE_RET camera_scan_init(void)
{
#if defined(CONFIG_FRESHR_CAMERA) && defined(CAMERA_NAME)
    PR_NOTICE("FreshrFridge: camera init hook — implement DVP capture here");
    return OPRT_OK;
#else
    PR_NOTICE("FreshrFridge: camera not enabled (CONFIG_FRESHR_CAMERA)");
    return OPRT_OK;
#endif
}

void camera_scan_deinit(void)
{
}

BOOL_T camera_scan_is_available(void)
{
#if defined(CONFIG_FRESHR_CAMERA) && defined(CAMERA_NAME)
    return TRUE;
#else
    return FALSE;
#endif
}

OPERATE_RET camera_scan_capture_food(camera_scan_result_t *result)
{
    if (!result) {
        return OPRT_INVALID_PARM;
    }

    memset(result, 0, sizeof(*result));

#if defined(CONFIG_FRESHR_CAMERA) && defined(CAMERA_NAME)
    /* TODO: tkl_vi capture → JPEG/frame → AI inference → suggested_name */
    PR_WARN("camera_scan_capture_food: not implemented yet");
    return OPRT_NOT_SUPPORTED;
#else
    PR_WARN("camera_scan: enable CONFIG_FRESHR_CAMERA in board config first");
    return OPRT_NOT_SUPPORTED;
#endif
}
