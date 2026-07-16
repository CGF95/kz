/*
 * zu.h
 *
 * zelda utilities
 */

#ifndef _ZU_H
#define _ZU_H

#include <stdint.h>
#include <stdlib.h>

typedef struct {
  uint32_t work_p;     /* 0x0000 */
  uint32_t work_d;     /* 0x0004 */
  uint32_t poly_opa_p; /* 0x0008 */
  uint32_t poly_opa_d; /* 0x000C */
  uint32_t poly_xlu_p; /* 0x0010 */
  uint32_t poly_xlu_d; /* 0x0014 */
  uint32_t overlay_p;  /* 0x0018 */
  uint32_t overlay_d;  /* 0x001C */
  uint32_t unk_1b8_p;  /* 0x0020 */
  uint32_t unk_1b8_d;  /* 0x0024 */
} zu_disp_ptr_t;       /* 0x0028 */

int zu_is_ingame(void);
void zu_file_load(uint32_t vrom_addr, void *ram, size_t size);
void zu_file_idx_load(int idx, void *ram);
void *zu_segment_reloc(void *phy_seg_addr);
void *zu_segment_find(uint32_t seg_addr);
void zu_disp_ptr_save(zu_disp_ptr_t *disp_ptr);
void zu_disp_ptr_load(zu_disp_ptr_t *disp_ptr);
void zu_gfx_reloc(int src_disp_idx, int src_cimg_idx);

#define ZU_SEQ_PLAYER_BGM_MAIN 0
#define ZU_SEQ_PLAYER_FANFARE 1
#define ZU_SEQ_PLAYER_SFX 2
#define ZU_SEQ_PLAYER_BGM_SUB 3
#define ZU_SEQ_PLAYER_AMBIENCE 4

void zu_seq_vol(int player, float vol);
void zu_seq_chan_vol(int player, int chan, float vol);
void zu_seq_chan_mute(int player, int chan, _Bool mute);
void zu_seq_stop(int player);

#endif
