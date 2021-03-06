#ifndef _KZ_H
#define _KZ_H

#include <stdint.h>
#include <vector/vector.h>
#include "z2.h"
#include "menu.h"
#include "settings.h"
#include "collision_view.h"

enum cheats {
    CHEAT_STICKS,
    CHEAT_NUTS,
    CHEAT_ARROWS,
    CHEAT_BOMBS,
    CHEAT_BOMBCHUS,
    CHEAT_POWDER_KEG,
    CHEAT_HEALTH,
    CHEAT_MAGIC,
    CHEAT_RAZOR_SWORD,
    CHEAT_BLAST_MASK,
    CHEAT_RESTRICTION,
    CHEAT_ISG,
    CHEAT_RUPEES,
    CHEAT_ISOT_SPEED,
    CHEAT_DEFAULT_SPEED,
    CHEAT_TIME_STOPPED,
};

typedef struct  {
    _Bool                   ready;    
    struct vector           watches;
    size_t                  watch_cnt;
    uint16_t                cheats;
    enum col_view_settings  collision_view_settings;
    enum col_view_status    collision_view_status;
    struct menu             main_menu;
    struct settings        *settings;
    _Bool                   menu_active;
    size_t test;
    int32_t                 frames_queued;
} kz_ctxt_t;

extern kz_ctxt_t kz;

struct menu *create_warps_menu();
struct menu *create_inventory_menu();
struct menu *create_scene_menu();
struct menu *create_watches_menu();
struct menu *create_cheats_menu();


#endif