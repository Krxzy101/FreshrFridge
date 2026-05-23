/**
 * @file fridge_priority.h
 * @brief Use-first sorting and expiry urgency (matches web src/lib/priority.ts).
 */

#ifndef FRIDGE_PRIORITY_H
#define FRIDGE_PRIORITY_H

#include "fridge_item.h"

#ifdef __cplusplus
extern "C" {
#endif

int fridge_days_until(const char *date_iso);

fridge_urgency_t fridge_get_urgency(const fridge_item_t *item);

const char *fridge_urgency_label(fridge_urgency_t urgency);

void fridge_expiry_description(const fridge_item_t *item, char *buf, int buf_len);

void fridge_sort_use_first(fridge_item_t *items, int count);

#ifdef __cplusplus
}
#endif

#endif
