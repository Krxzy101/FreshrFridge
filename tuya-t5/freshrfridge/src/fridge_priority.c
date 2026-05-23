/**
 * @file fridge_priority.c
 */

#include "fridge_priority.h"

#include <stdio.h>
#include <string.h>
#include <time.h>

#include "tal_api.h"

static int parse_iso_date(const char *iso, struct tm *out)
{
    int y = 0, m = 0, d = 0;
    if (sscanf(iso, "%d-%d-%d", &y, &m, &d) != 3) {
        return -1;
    }
    memset(out, 0, sizeof(*out));
    out->tm_year = y - 1900;
    out->tm_mon = m - 1;
    out->tm_mday = d;
    return 0;
}

static time_t start_of_day(time_t t)
{
    struct tm tm_local;
    localtime_r(&t, &tm_local);
    tm_local.tm_hour = 0;
    tm_local.tm_min = 0;
    tm_local.tm_sec = 0;
    return mktime(&tm_local);
}

int fridge_days_until(const char *date_iso)
{
    struct tm target_tm;
    time_t now, target_day, today;

    if (!date_iso || date_iso[0] == '\0') {
        return 9999;
    }
    if (parse_iso_date(date_iso, &target_tm) != 0) {
        return 9999;
    }

    now = time(NULL);
    today = start_of_day(now);
    target_day = start_of_day(mktime(&target_tm));
    return (int)((target_day - today) / (24 * 60 * 60));
}

fridge_urgency_t fridge_get_urgency(const fridge_item_t *item)
{
    int days;

    if (!item || item->expiration_date[0] == '\0') {
        return FRIDGE_URGENCY_UNKNOWN;
    }

    days = fridge_days_until(item->expiration_date);
    if (days < 0) {
        return FRIDGE_URGENCY_EXPIRED;
    }
    if (days <= 1) {
        return FRIDGE_URGENCY_CRITICAL;
    }
    if (days <= 3) {
        return FRIDGE_URGENCY_WARNING;
    }
    if (days <= 7) {
        return FRIDGE_URGENCY_SOON;
    }
    return FRIDGE_URGENCY_OK;
}

const char *fridge_urgency_label(fridge_urgency_t urgency)
{
    switch (urgency) {
    case FRIDGE_URGENCY_EXPIRED:
        return "Expired";
    case FRIDGE_URGENCY_CRITICAL:
        return "Use today";
    case FRIDGE_URGENCY_WARNING:
        return "Use soon";
    case FRIDGE_URGENCY_SOON:
        return "This week";
    case FRIDGE_URGENCY_OK:
        return "Fresh";
    default:
        return "No expiry";
    }
}

void fridge_expiry_description(const fridge_item_t *item, char *buf, int buf_len)
{
    int days;

    if (!item || !buf || buf_len <= 0) {
        return;
    }

    if (item->expiration_date[0] == '\0') {
        snprintf(buf, buf_len, "Added %s", item->date_added);
        return;
    }

    days = fridge_days_until(item->expiration_date);
    if (days < 0) {
        snprintf(buf, buf_len, "Expired %d day%s ago", -days, (-days == 1) ? "" : "s");
    } else if (days == 0) {
        snprintf(buf, buf_len, "Expires today");
    } else if (days == 1) {
        snprintf(buf, buf_len, "Expires tomorrow");
    } else {
        snprintf(buf, buf_len, "Expires in %d days", days);
    }
}

static int item_cmp(const fridge_item_t *a, const fridge_item_t *b)
{
    int a_has = (a->expiration_date[0] != '\0');
    int b_has = (b->expiration_date[0] != '\0');

    if (a_has && b_has) {
        return strcmp(a->expiration_date, b->expiration_date);
    }
    if (a_has) {
        return -1;
    }
    if (b_has) {
        return 1;
    }
    return strcmp(a->date_added, b->date_added);
}

void fridge_sort_use_first(fridge_item_t *items, int count)
{
    int i, j;

    if (!items || count < 2) {
        return;
    }

    for (i = 0; i < count - 1; i++) {
        for (j = 0; j < count - i - 1; j++) {
            if (item_cmp(&items[j], &items[j + 1]) > 0) {
                fridge_item_t tmp = items[j];
                items[j] = items[j + 1];
                items[j + 1] = tmp;
            }
        }
    }
}
