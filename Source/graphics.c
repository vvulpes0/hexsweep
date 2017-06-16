#include "graphics.h"
#include "common.h"
#include "font.h"

void volatile * const VDP_DATA   = (void volatile *) 0xC00000;
void volatile * const VDP_CTRL   = (void volatile *) 0xC00004;

static void VRAM_addr(Word const, Word const);

void
delay(unsigned int const n)
{
	DWord const start = gTicks;
	while (gTicks - start < n)
	{
		/* wait for interrupt */
		__asm__ volatile ("trap #0" : : : "cc");
	}
	return;
}

void
VRAM_write(Word const addr)
{
	VRAM_addr(addr, 0x4000);
}

void
VRAM_read(Word const addr)
{
	VRAM_addr(addr, 0);
}

static void
VRAM_addr(Word const addr, Word const extra)
{
	*(Word volatile *)VDP_CTRL = (Word)((addr & 0x3FFF) | extra);
	*(Word volatile *)VDP_CTRL = (Word)((addr >> 14) & 3);
}

void
putc(char const x)
{
	VDATA_word((Word)(PRIORITY | PALETTE(3) | charmap[x - 32]));
}

void
puts(char const * const s)
{
	unsigned int i = 0;

	while (s[i] != '\0')
	{
		putc(s[i++]);
	}
}

void
set_window_position(Byte const left_right, Byte const xpos,
                    Byte const up_down, Byte const ypos)
{
	VREG_write(17, left_right | xpos);
	VREG_write(18, up_down | ypos);
}
