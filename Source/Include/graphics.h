/* Declarations for Graphics Processing
 *
 * Copyright 2016, Dakotah Lambert.
 * All Rights Reserved.
 */
#ifndef GRAPHICS_H
#define GRAPHICS_H

#include "common.h"

/*
 * VDP (Video Display Processor) Control Port Addresses
 */
extern DWord volatile   const gTicks;
extern void  volatile * const VDP_DATA;
extern void  volatile * const VDP_CTRL;

#define VDP_STATUS VDP_CTRL

#define VREG_write(r, d) \
	(*(Word volatile *)VDP_CTRL = (Word)((0x80U | (r))<<8U | (d)))
#define set_autoincrement(x) \
	VREG_write(15, (x))
#define set_border_color(pindex, cindex) \
	(VREG_write(7, (Byte)(((pindex) & 3) << 4 | ((cindex) & 0xF))))
#define enable_display(x) \
	(VREG_write(1, 0x64U & (~(BOOL(x)) + 1U)))
#define VDATA_word(x) \
	(*(Word volatile *)VDP_DATA = (Word)(x))
#define VDATA_dword(x) \
	(*(DWord volatile *)VDP_DATA = (DWord)(x))
#define CDATA_word VDATA_word
#define CRAM_write(pindex, cindex) \
	(*(DWord volatile *)VDP_CTRL = (DWord)(0xC0000000UL | ((DWord)(pindex)) << 21 | ((DWord)(cindex)) << 17))
#define Plane_A(r, c) \
	((Word)(0xC000 | (((r) << 6) + ((c) << 1))))
#define Plane_B(r, c) \
	((Word)(0xE000 | (((r) << 6) + ((c) << 1))))
#define Plane_W(r, c) \
	((Word)(0xB000 | (((r) << 6) + ((c) << 1))))
#define RGB(r, g, b)   \
	(((Byte)(b>>5))<<9 \
	 | (Byte)(g>>5)<<5 \
	 | (Byte)(r>>5)<<1)
#define RGB9(r, g, b) \
	((Byte) b<<9      \
	 | (Byte) g<<5    \
	 | (Byte) r<<1)
#define PALETTE(p) \
	((p & 3) << 13)
#define PRIORITY ((Word)(0x8000U))

/* Delay for n VBIs */
void delay(unsigned long const);
/* Switch to Read Mode and set the target address into VRAM
 * Parameters: address */
void VRAM_read(Word const);

/* Switch to Write Mode and set the target address into VRAM
 * Parameters: address to write to */
void VRAM_write(Word const);

void putc(char const);
void puts(char const * const);

#define W_RIGHT 1<<7
#define W_UP 0
#define W_LEFT 0
#define W_DOWN 1<<7
/* Set the ``Window'' display features.
 * Parameters: Left or Right?, H position, Up or Down?, V position */
void set_window_position(Byte const, Byte const, Byte const, Byte const);

#endif
