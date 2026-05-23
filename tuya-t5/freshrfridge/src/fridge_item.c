/**
 * @file fridge_item.c
 */

#include "fridge_item.h"

static const char *const s_category_names[FRIDGE_CAT_COUNT] = {
    "Produce", "Dairy", "Meat", "Seafood", "Leftovers", "Beverages", "Condiments", "Other",
};

const char *fridge_category_name(fridge_category_t cat)
{
    if (cat >= FRIDGE_CAT_COUNT) {
        return "Other";
    }
    return s_category_names[cat];
}
