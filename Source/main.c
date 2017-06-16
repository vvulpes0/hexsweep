#include "common.h"
#include "decompress.h"
#include "graphics.h"
#include "security.h"
#include "sound.h"
#include "ui.h"
#include "font.h"
#include "tiles.h"
#include "instruments.h"
#include "playground.h"

#ifdef DEBUG
extern void (*err_vector)(void);
extern void (*aerr_vector)(void);
#endif

extern unsigned int volatile err_loc;

static void clear_planes    (void);
static void configure_window(void);
static void enable_cursor   (void);
static void load_palettes   (void);

/* Debugging functions */
static void gray_out(void);
#ifdef DEBUG
static void die(void);
static void addr_error(void);
#endif

int
main(void)
{
	unsigned int difficulty;

#ifdef DEBUG
	err_vector = &die;
	aerr_vector = &addr_error;
#endif
	set_autoincrement(2);
	enable_display(0);
	configure_window();
	load_palettes();
	load_tiles(font, font_huffman_table,
	           font_words, BASE_CHAR);
	load_tiles(tiles, tiles_huffman_table,
	           tileset_words, BASE_TILE);
	if (likely(is_checksum_valid()))
	{
		enable_display(1);
		load_driver(sound_driver);
		load_voice(grand_piano);
		sound_command(LOAD_VOICE_1);
		load_voice(clarinet);
		sound_command(LOAD_VOICE_2);
		load_voice(bassoon);
		sound_command(LOAD_VOICE_3);
		load_song(playground);
		sound_command(PLAY);
		enable_cursor();
		while(1)
		{
			clear_planes();
			difficulty = title_screen();
			clear_planes();
			show_border();
			new_game(difficulty);
			event_loop();
		}
		return 0;
	}

	gray_out();
	return 1;
}

#define NORMAL_MODE 1

static void
clear_planes(void)
{
	#if NORMAL_MODE
	unsigned int i;
	unsigned int  j;
	static Word const addrs[] = {Plane_B(0, 0),
	                             Plane_A(0, 0),
	                             Plane_W(0, 0)};

	for (j = 0; likely(j < sizeof(addrs) / sizeof(addrs[0])); ++j)
	{
		VRAM_write(addrs[j]);
		for (i = 32 * 32; likely(i); --i)
		{
			VDATA_word(0);
		}
	}
	#else
	VREG_write( 1, 0x54);
	VREG_write(19, 0x00);
	VREG_write(20, 0x04);
	VREG_write(23, 0x80);
	*(Word volatile * const)VDP_CTRL = (0xC000 & ~0xC000) | 0x4000;
	*(Word volatile * const)VDP_CTRL = (0xC000 >> 14) | 0x0080;
	*(Word volatile * const)VDP_DATA = 33;
	while (likely(*(Word volatile * const)VDP_STATUS & 0x2))
	{
		/* wait */
	}
	VREG_write( 1, 0x54);
	VREG_write(19, 0x00);
	VREG_write(20, 0x04);
	VREG_write(23, 0x80);
	*(Word volatile * const)VDP_CTRL = (0xE000 & ~0xC000) | 0x4000;
	*(Word volatile * const)VDP_CTRL = (0xE000 >> 14) | 0x0080;
	*(Word volatile * const)VDP_DATA = 33;
	while (likely(*(Word volatile * const)VDP_STATUS & 0x2))
	{
		/* wait */
	}
	VREG_write( 1, 0x54);
	VREG_write(19, 0x00);
	VREG_write(20, 0x04);
	VREG_write(23, 0x80);
	*(Word volatile * const)VDP_CTRL = (0xB000 & ~0xC000) | 0x4000;
	*(Word volatile * const)VDP_CTRL = (0xB000 >> 14) | 0x0080;
	*(Word volatile * const)VDP_DATA = 33;
	while (likely(*(Word volatile * const)VDP_STATUS & 0x2))
	{
		/* wait */
	}
	VREG_write( 1, 0x64);
	#endif
}

static void
configure_window(void)
{
	unsigned int i;

	VREG_write(17, 0);
	VREG_write(18, 0);
	VRAM_write(Plane_W(0, 0));
	for (i = 32 * 32; likely(i); --i)
	{
		putc(' ');
	}
}

static void
enable_cursor(void)
{
	VRAM_write(0xA800);
	VDATA_word(0x0000);
	VDATA_word(0x0000);
	VDATA_word(0x8000 | (CURSOR + BASE_TILE));
	VDATA_word(0x0000);
}

static void
load_palettes(void)
{
	unsigned int i;
	static Word const bg = RGB9(3,4,5);

	for (i = 0; likely(i < 4); ++i)
	{
		CRAM_write(i, 0);
		CDATA_word(          RGB9(1, 2, 3)     );
		CDATA_word((i & 2) ? RGB9(0, 3, 3) : bg);
		CDATA_word((i & 2) ? RGB9(0, 4, 1) : bg);
		CDATA_word((i & 2) ? RGB9(2, 3, 0) : bg);
		CDATA_word((i & 2) ? RGB9(3, 2, 0) : bg);
		CDATA_word((i & 2) ? RGB9(7, 1, 2) : bg);
		CDATA_word((i & 2) ? RGB9(6, 1, 7) : bg);
		CDATA_word((i & 2) ? RGB9(2, 2, 2) : bg);
		CDATA_word((i & 2) ? RGB9(7, 7, 7) : bg);
		CDATA_word(          RGB9(3, 3, 4)     );
		CDATA_word((i & 2) ? RGB9(5, 5, 5) : bg);
		CDATA_word((i & 1) ? RGB9(5, 5, 5) : bg);
		CDATA_word(          RGB9(6, 6, 6)     );
		CDATA_word(          RGB9(1, 2, 3)     );
		CDATA_word(          RGB9(2, 2, 2)     );
		CDATA_word(          RGB9(6, 1, 1)     );
	}
	return;
}

/* Debugging functions */
static void
gray_out(void)
{
	enable_display(0);
	clear_planes();
	CRAM_write(0, 0);
	CDATA_word(RGB9(3, 3, 3));
	enable_display(1);
}

#ifdef DEBUG
static void
die(void)
{
	unsigned int x = err_loc;
	unsigned int i;
	unsigned char y;

	gray_out();
	VRAM_write(Plane_B(12, 6));
	puts("error at ");
	puts("0x");
	for (i = 1; i <= 8; ++i)
	{
		y = (unsigned char)(x >> (32 - (i << 2))) & 0x0f;
		putc((char)(y < 10 ? '0' + y : 'a' + y - 10));
	}
	while (1);
}

static void
addr_error(void)
{
	gray_out();
	VRAM_write(Plane_B(12, 9));
	puts("address error");
	while (1);
}
#endif
