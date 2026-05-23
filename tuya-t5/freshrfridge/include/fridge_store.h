/**
 * @file fridge_store.h
 * @brief Persistent inventory on device flash (tal_kv).
 */

#ifndef FRIDGE_STORE_H
#define FRIDGE_STORE_H

#include "fridge_item.h"
#include "tuya_cloud_types.h"

#ifdef __cplusplus
extern "C" {
#endif

OPERATE_RET fridge_store_init(void);

int fridge_store_count(void);

const fridge_item_t *fridge_store_items(void);

OPERATE_RET fridge_store_reload(void);

OPERATE_RET fridge_store_add(const fridge_item_t *item);

OPERATE_RET fridge_store_use_one(const char *id);

OPERATE_RET fridge_store_remove(const char *id);

void fridge_store_today_iso(char *buf, int buf_len);

void fridge_store_new_id(char *buf, int buf_len);

#ifdef __cplusplus
}
#endif

#endif
