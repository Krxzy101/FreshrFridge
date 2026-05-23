/**
 * @file camera_scan.h
 * @brief Future: DVP camera food recognition on T5 AI board.
 *
 * Stub today — enable CONFIG_FRESHR_CAMERA in board config when ready.
 */

#ifndef CAMERA_SCAN_H
#define CAMERA_SCAN_H

#include "fridge_item.h"
#include "tuya_cloud_types.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    char suggested_name[FRIDGE_ITEM_NAME_LEN];
    float confidence;
} camera_scan_result_t;

OPERATE_RET camera_scan_init(void);

void camera_scan_deinit(void);

BOOL_T camera_scan_is_available(void);

OPERATE_RET camera_scan_capture_food(camera_scan_result_t *result);

#ifdef __cplusplus
}
#endif

#endif
