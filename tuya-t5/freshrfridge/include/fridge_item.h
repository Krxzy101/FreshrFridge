/**
 * @file fridge_item.h
 * @brief Fridge inventory item model (shared rules with web app).
 */

#ifndef FRIDGE_ITEM_H
#define FRIDGE_ITEM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define FRIDGE_ITEM_NAME_LEN   48
#define FRIDGE_ITEM_UNIT_LEN   8
#define FRIDGE_ITEM_NOTES_LEN  64
#define FRIDGE_ITEM_DATE_LEN   11
#define FRIDGE_ITEM_ID_LEN     37
#define FRIDGE_MAX_ITEMS       32

typedef enum {
    FRIDGE_CAT_PRODUCE = 0,
    FRIDGE_CAT_DAIRY,
    FRIDGE_CAT_MEAT,
    FRIDGE_CAT_SEAFOOD,
    FRIDGE_CAT_LEFTOVERS,
    FRIDGE_CAT_BEVERAGES,
    FRIDGE_CAT_CONDIMENTS,
    FRIDGE_CAT_OTHER,
    FRIDGE_CAT_COUNT
} fridge_category_t;

typedef struct {
    char id[FRIDGE_ITEM_ID_LEN];
    char name[FRIDGE_ITEM_NAME_LEN];
    uint16_t quantity;
    char unit[FRIDGE_ITEM_UNIT_LEN];
    fridge_category_t category;
    char expiration_date[FRIDGE_ITEM_DATE_LEN];
    char date_added[FRIDGE_ITEM_DATE_LEN];
    char notes[FRIDGE_ITEM_NOTES_LEN];
} fridge_item_t;

typedef enum {
    FRIDGE_URGENCY_EXPIRED = 0,
    FRIDGE_URGENCY_CRITICAL,
    FRIDGE_URGENCY_WARNING,
    FRIDGE_URGENCY_SOON,
    FRIDGE_URGENCY_OK,
    FRIDGE_URGENCY_UNKNOWN,
} fridge_urgency_t;

const char *fridge_category_name(fridge_category_t cat);

#ifdef __cplusplus
}
#endif

#endif
