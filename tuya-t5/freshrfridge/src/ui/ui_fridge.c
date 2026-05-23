/**
 * @file ui_fridge.c
 * @brief Touch UI for 3.5" LCD (320x480) on Tuya T5 AI board.
 */

#include "ui_fridge.h"

#include <stdio.h>
#include <string.h>

#include "camera_scan.h"
#include "fridge_priority.h"
#include "fridge_store.h"
#include "lvgl.h"

static lv_obj_t *s_scr_main;
static lv_obj_t *s_list_panel;
static lv_obj_t *s_scr_add;
static lv_obj_t *s_ta_name;
static lv_obj_t *s_ta_expiry;
static lv_obj_t *s_dd_category;
static lv_obj_t *s_kb;

static void show_main_screen(void);
static void show_add_screen(void);

static lv_color_t urgency_color(fridge_urgency_t u)
{
    switch (u) {
    case FRIDGE_URGENCY_EXPIRED:
        return lv_palette_main(LV_PALETTE_RED);
    case FRIDGE_URGENCY_CRITICAL:
        return lv_palette_main(LV_PALETTE_ORANGE);
    case FRIDGE_URGENCY_WARNING:
        return lv_palette_darken(LV_PALETTE_ORANGE, 1);
    case FRIDGE_URGENCY_SOON:
        return lv_palette_main(LV_PALETTE_YELLOW);
    case FRIDGE_URGENCY_OK:
        return lv_palette_main(LV_PALETTE_GREEN);
    default:
        return lv_palette_main(LV_PALETTE_GREY);
    }
}

static void item_btn_event(lv_event_t *e)
{
    const char *id = (const char *)lv_event_get_user_data(e);
    lv_event_code_t code = lv_event_get_code(e);

    if (code == LV_EVENT_LONG_PRESSED) {
        fridge_store_remove(id);
        ui_fridge_refresh();
    } else if (code == LV_EVENT_CLICKED) {
        fridge_store_use_one(id);
        ui_fridge_refresh();
    }
}

static void add_save_event(lv_event_t *e)
{
    (void)e;
    const char *name = lv_textarea_get_text(s_ta_name);
    const char *expiry = lv_textarea_get_text(s_ta_expiry);
    fridge_item_t item;

    if (!name || name[0] == '\0') {
        return;
    }

    memset(&item, 0, sizeof(item));
    fridge_store_new_id(item.id, sizeof(item.id));
    strncpy(item.name, name, sizeof(item.name) - 1);
    item.quantity = 1;
    strncpy(item.unit, "pcs", sizeof(item.unit) - 1);
    item.category = (fridge_category_t)lv_dropdown_get_selected(s_dd_category);
    fridge_store_today_iso(item.date_added, sizeof(item.date_added));
    if (expiry && expiry[0] != '\0') {
        strncpy(item.expiration_date, expiry, sizeof(item.expiration_date) - 1);
    }

    fridge_store_add(&item);
    lv_textarea_set_text(s_ta_name, "");
    lv_textarea_set_text(s_ta_expiry, "");
    show_main_screen();
    ui_fridge_refresh();
}

static void add_cancel_event(lv_event_t *e)
{
    (void)e;
    show_main_screen();
}

static void open_add_event(lv_event_t *e)
{
    (void)e;
    show_add_screen();
}

static void scan_stub_event(lv_event_t *e)
{
    (void)e;
    camera_scan_result_t result;
    if (camera_scan_capture_food(&result) != OPRT_OK) {
        return;
    }
    lv_textarea_set_text(s_ta_name, result.suggested_name);
    show_add_screen();
}

static void ta_focus_event(lv_event_t *e)
{
    lv_obj_t *ta = lv_event_get_target(e);
    if (lv_event_get_code(e) == LV_EVENT_FOCUSED) {
        lv_keyboard_set_textarea(s_kb, ta);
        lv_obj_clear_flag(s_kb, LV_OBJ_FLAG_HIDDEN);
    }
    if (lv_event_get_code(e) == LV_EVENT_DEFOCUSED) {
        lv_keyboard_set_textarea(s_kb, NULL);
        lv_obj_add_flag(s_kb, LV_OBJ_FLAG_HIDDEN);
    }
}

static void build_main_screen(void)
{
    lv_obj_t *header;
    lv_obj_t *footer;
    lv_obj_t *btn_add;
    lv_obj_t *btn_scan;

    s_scr_main = lv_obj_create(NULL);
    lv_obj_set_style_bg_color(s_scr_main, lv_color_hex(0xf0fdf4), 0);

    header = lv_label_create(s_scr_main);
    lv_label_set_text(header, "FreshrFridge\nUse first");
    lv_obj_set_style_text_color(header, lv_color_hex(0x065f46), 0);
    lv_obj_set_style_text_align(header, LV_TEXT_ALIGN_CENTER, 0);
    lv_obj_align(header, LV_ALIGN_TOP_MID, 0, 8);

    s_list_panel = lv_obj_create(s_scr_main);
    lv_obj_set_size(s_list_panel, 300, 340);
    lv_obj_align(s_list_panel, LV_ALIGN_TOP_MID, 0, 56);
    lv_obj_set_flex_flow(s_list_panel, LV_FLEX_FLOW_COLUMN);
    lv_obj_set_flex_align(s_list_panel, LV_FLEX_ALIGN_START, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);
    lv_obj_set_style_pad_row(s_list_panel, 6, 0);
    lv_obj_add_flag(s_list_panel, LV_OBJ_FLAG_SCROLLABLE);

    footer = lv_obj_create(s_scr_main);
    lv_obj_set_size(footer, 300, 48);
    lv_obj_align(footer, LV_ALIGN_BOTTOM_MID, 0, -8);
    lv_obj_set_style_bg_opa(footer, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(footer, 0, 0);
    lv_obj_set_flex_flow(footer, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(footer, LV_FLEX_ALIGN_SPACE_EVENLY, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);

    btn_add = lv_btn_create(footer);
    lv_obj_set_size(btn_add, 130, 40);
    lv_obj_add_event_cb(btn_add, open_add_event, LV_EVENT_CLICKED, NULL);
    lv_obj_t *lbl_add = lv_label_create(btn_add);
    lv_label_set_text(lbl_add, "Add item");
    lv_obj_center(lbl_add);
    lv_obj_set_style_bg_color(btn_add, lv_color_hex(0x059669), 0);

    btn_scan = lv_btn_create(footer);
    lv_obj_set_size(btn_scan, 130, 40);
    lv_obj_add_event_cb(btn_scan, scan_stub_event, LV_EVENT_CLICKED, NULL);
    lv_obj_t *lbl_scan = lv_label_create(btn_scan);
    if (camera_scan_is_available()) {
        lv_label_set_text(lbl_scan, "Scan food");
    } else {
        lv_label_set_text(lbl_scan, "Scan (soon)");
        lv_obj_add_state(btn_scan, LV_STATE_DISABLED);
    }
    lv_obj_center(lbl_scan);
}

static void build_add_screen(void)
{
    lv_obj_t *lbl;
    lv_obj_t *btn_row;
    lv_obj_t *btn_save;
    lv_obj_t *btn_cancel;

    s_scr_add = lv_obj_create(NULL);
    lv_obj_set_style_bg_color(s_scr_add, lv_color_hex(0xffffff), 0);

    lbl = lv_label_create(s_scr_add);
    lv_label_set_text(lbl, "Add to fridge");
    lv_obj_align(lbl, LV_ALIGN_TOP_MID, 0, 8);

    s_ta_name = lv_textarea_create(s_scr_add);
    lv_obj_set_size(s_ta_name, 280, 44);
    lv_obj_align(s_ta_name, LV_ALIGN_TOP_MID, 0, 40);
    lv_textarea_set_placeholder_text(s_ta_name, "Item name");
    lv_obj_add_event_cb(s_ta_name, ta_focus_event, LV_EVENT_ALL, NULL);

    s_dd_category = lv_dropdown_create(s_scr_add);
    lv_dropdown_set_options(s_dd_category,
                            "Produce\nDairy\nMeat\nSeafood\nLeftovers\nBeverages\nCondiments\nOther");
    lv_obj_set_width(s_dd_category, 280);
    lv_obj_align(s_dd_category, LV_ALIGN_TOP_MID, 0, 96);

    lbl = lv_label_create(s_scr_add);
    lv_label_set_text(lbl, "Expiry YYYY-MM-DD (optional)");
    lv_obj_align(lbl, LV_ALIGN_TOP_MID, 0, 140);

    s_ta_expiry = lv_textarea_create(s_scr_add);
    lv_obj_set_size(s_ta_expiry, 280, 44);
    lv_obj_align(s_ta_expiry, LV_ALIGN_TOP_MID, 0, 164);
    lv_textarea_set_placeholder_text(s_ta_expiry, "2026-05-30");
    lv_textarea_set_one_line(s_ta_expiry, true);
    lv_obj_add_event_cb(s_ta_expiry, ta_focus_event, LV_EVENT_ALL, NULL);

    btn_row = lv_obj_create(s_scr_add);
    lv_obj_set_size(btn_row, 280, 48);
    lv_obj_align(btn_row, LV_ALIGN_BOTTOM_MID, 0, -72);
    lv_obj_set_style_bg_opa(btn_row, LV_OPA_TRANSP, 0);
    lv_obj_set_style_border_width(btn_row, 0, 0);
    lv_obj_set_flex_flow(btn_row, LV_FLEX_FLOW_ROW);
    lv_obj_set_flex_align(btn_row, LV_FLEX_ALIGN_SPACE_EVENLY, LV_FLEX_ALIGN_CENTER, LV_FLEX_ALIGN_CENTER);

    btn_save = lv_btn_create(btn_row);
    lv_obj_add_event_cb(btn_save, add_save_event, LV_EVENT_CLICKED, NULL);
    lv_obj_t *ls = lv_label_create(btn_save);
    lv_label_set_text(ls, "Save");
    lv_obj_center(ls);
    lv_obj_set_style_bg_color(btn_save, lv_color_hex(0x059669), 0);

    btn_cancel = lv_btn_create(btn_row);
    lv_obj_add_event_cb(btn_cancel, add_cancel_event, LV_EVENT_CLICKED, NULL);
    lv_obj_t *lc = lv_label_create(btn_cancel);
    lv_label_set_text(lc, "Back");
    lv_obj_center(lc);

    s_kb = lv_keyboard_create(s_scr_add);
    lv_obj_add_flag(s_kb, LV_OBJ_FLAG_HIDDEN);
}

static void show_main_screen(void)
{
    lv_scr_load(s_scr_main);
}

static void show_add_screen(void)
{
    lv_scr_load(s_scr_add);
}

void ui_fridge_create(void)
{
    build_main_screen();
    build_add_screen();
    show_main_screen();
}

void ui_fridge_refresh(void)
{
    fridge_item_t sorted[FRIDGE_MAX_ITEMS];
    int count = fridge_store_count();
    int i;
    char line[160];
    char detail[80];
    static char id_table[FRIDGE_MAX_ITEMS][FRIDGE_ITEM_ID_LEN];

    if (!s_list_panel) {
        return;
    }

    lv_obj_clean(s_list_panel);

    if (count == 0) {
        lv_obj_t *empty = lv_label_create(s_list_panel);
        lv_label_set_text(empty, "Fridge is empty.\nTap Add item below.");
        lv_obj_set_style_text_align(empty, LV_TEXT_ALIGN_CENTER, 0);
        return;
    }

    memcpy(sorted, fridge_store_items(), (size_t)count * sizeof(fridge_item_t));
    fridge_sort_use_first(sorted, count);

    for (i = 0; i < count; i++) {
        fridge_urgency_t urgency = fridge_get_urgency(&sorted[i]);
        lv_obj_t *btn = lv_btn_create(s_list_panel);
        lv_obj_set_width(btn, 280);
        lv_obj_set_style_bg_color(btn, urgency_color(urgency), 0);
        lv_obj_set_style_bg_opa(btn, LV_OPA_20, 0);

        strncpy(id_table[i], sorted[i].id, FRIDGE_ITEM_ID_LEN - 1);
        lv_obj_add_event_cb(btn, item_btn_event, LV_EVENT_CLICKED, id_table[i]);
        lv_obj_add_event_cb(btn, item_btn_event, LV_EVENT_LONG_PRESSED, id_table[i]);

        fridge_expiry_description(&sorted[i], detail, sizeof(detail));
        snprintf(line, sizeof(line), "#%d  %s\n%s · %s\nTap=used  Hold=remove", i + 1, sorted[i].name,
                 fridge_urgency_label(urgency), detail);

        lv_obj_t *lbl = lv_label_create(btn);
        lv_label_set_text(lbl, line);
        lv_obj_set_style_text_color(lbl, lv_color_hex(0x1e293b), 0);
    }
}
