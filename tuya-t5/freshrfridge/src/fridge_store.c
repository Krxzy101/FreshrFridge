/**
 * @file fridge_store.c
 */

#include "fridge_store.h"

#include <stdio.h>
#include <string.h>
#include "tal_api.h"

#define FRIDGE_KV_KEY "freshr_inv"

static fridge_item_t s_items[FRIDGE_MAX_ITEMS];
static int s_count = 0;

static OPERATE_RET persist(void)
{
    uint8_t blob[2 + sizeof(s_items)];
    uint16_t count = (uint16_t)s_count;

    blob[0] = (uint8_t)(count & 0xff);
    blob[1] = (uint8_t)((count >> 8) & 0xff);
    memcpy(blob + 2, s_items, sizeof(s_items));

    return tal_kv_set(FRIDGE_KV_KEY, blob, sizeof(blob));
}

OPERATE_RET fridge_store_init(void)
{
    tal_kv_init(&(tal_kv_cfg_t){
        .seed = "freshrfridge01",
        .key = "freshrfridgekv01",
    });
    return fridge_store_reload();
}

int fridge_store_count(void)
{
    return s_count;
}

const fridge_item_t *fridge_store_items(void)
{
    return s_items;
}

OPERATE_RET fridge_store_reload(void)
{
    uint8_t *read_buf = NULL;
    size_t read_len = 0;
    OPERATE_RET rt;
    uint16_t count;

    s_count = 0;
    memset(s_items, 0, sizeof(s_items));

    rt = tal_kv_get(FRIDGE_KV_KEY, &read_buf, &read_len);
    if (rt != OPRT_OK || read_buf == NULL || read_len < 2) {
        if (read_buf) {
            tal_kv_free(read_buf);
        }
        return OPRT_OK;
    }

    count = (uint16_t)read_buf[0] | ((uint16_t)read_buf[1] << 8);
    if (count > FRIDGE_MAX_ITEMS) {
        count = FRIDGE_MAX_ITEMS;
    }

    if (read_len >= 2 + sizeof(s_items)) {
        memcpy(s_items, read_buf + 2, sizeof(s_items));
        s_count = count;
    }

    tal_kv_free(read_buf);
    return OPRT_OK;
}

OPERATE_RET fridge_store_add(const fridge_item_t *item)
{
    if (!item || s_count >= FRIDGE_MAX_ITEMS) {
        return OPRT_INVALID_PARM;
    }

    s_items[s_count++] = *item;
    return persist();
}

OPERATE_RET fridge_store_use_one(const char *id)
{
    int i;

    if (!id) {
        return OPRT_INVALID_PARM;
    }

    for (i = 0; i < s_count; i++) {
        if (strcmp(s_items[i].id, id) == 0) {
            if (s_items[i].quantity > 1) {
                s_items[i].quantity--;
            } else {
                int j;
                for (j = i; j < s_count - 1; j++) {
                    s_items[j] = s_items[j + 1];
                }
                s_count--;
            }
            return persist();
        }
    }
    return OPRT_NOT_FOUND;
}

OPERATE_RET fridge_store_remove(const char *id)
{
    int i;

    if (!id) {
        return OPRT_INVALID_PARM;
    }

    for (i = 0; i < s_count; i++) {
        if (strcmp(s_items[i].id, id) == 0) {
            int j;
            for (j = i; j < s_count - 1; j++) {
                s_items[j] = s_items[j + 1];
            }
            s_count--;
            return persist();
        }
    }
    return OPRT_NOT_FOUND;
}

void fridge_store_today_iso(char *buf, int buf_len)
{
    POSIX_TM_S tm = {0};

    if (!buf || buf_len < FRIDGE_ITEM_DATE_LEN) {
        return;
    }

    if (tal_time_get(&tm) != OPRT_OK) {
        strncpy(buf, "1970-01-01", buf_len - 1);
        return;
    }
    snprintf(buf, buf_len, "%04d-%02d-%02d", tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday);
}

void fridge_store_new_id(char *buf, int buf_len)
{
    static uint32_t counter = 0;
    TIME_T now;

    if (!buf || buf_len < FRIDGE_ITEM_ID_LEN) {
        return;
    }
    now = tal_time_get_posix();
    snprintf(buf, buf_len, "ff-%08lx-%04x", (unsigned long)now, (unsigned)(++counter & 0xffff));
}
