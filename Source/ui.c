#include "ui.h"
#include "common.h"
#include "controls.h"
#include "mines.h"
#include "graphics.h"
#include "random.h"
#include "sound.h"
#include "font.h"
#include "tiles.h"

#define BASE_ROW 3
#define BASE_COL 5

#define BOARD_WIDTH  (GRID_SIZE * 2 + 1)
#define BOARD_HEIGHT BOARD_WIDTH

#define MIN(x, y) \
	((y) ^ (((x) ^ (y)) & (~(0U+BOOL((x) < (y))) + 1U)))
#define SCORE\
	((gTicks - start_time) / 60U)

static          DWord  delay_start;
static          DWord  start_time;
static unsigned int    best_score[3] = {999, 999, 999};
static unsigned int    player_row    = GRID_SIZE / 2;
static unsigned int    player_col    = GRID_SIZE / 2;
static unsigned int    difficulty    = 1;
static unsigned int    num_flagged;
static unsigned int    num_mines;
static unsigned int    num_uncovered;
static unsigned int    prev_dir;
static          int    lost;

static Word add_palette_bit(Word const, int const);
static int handle_input (void );
static int is_flagged (Row const, Column const) __attribute__((pure));
static int is_open (Row const, Column const) __attribute__((pure));
static unsigned int screen_row (Row const);
static unsigned int screen_col (Row const, Column const);
static void print_best(void);
static int pause_game(void);
static void place_cursor_at(Row const, Column const);
static void write_count(unsigned int const);
static void write_score(unsigned int const);
static unsigned int get_menu_item(unsigned int const, Word const, int const);

void
new_game(unsigned int const d)
{
	initialize_grid();
	difficulty    =  d;
	lost          =  0;
	num_flagged   =  0;
	num_uncovered =  0;
	start_time    =  gTicks;
	num_mines     =  15 + 5 * difficulty;
	VRAM_write(Plane_A(BASE_ROW + BOARD_HEIGHT + 1, BASE_COL + 2));
	putc('/');
	write_count(num_mines);
	print_best();
	place_cursor();
	show_grid();
	return;
}

static void
print_best(void)
{
	VRAM_write(Plane_A(BASE_ROW - 1,
	                   BASE_COL + BOARD_WIDTH - 8));
	puts("Best: ");
	write_score(best_score[difficulty]);
}

void
event_loop(void)
{
	do
	{
		delay(1);
		VRAM_write(Plane_A(BASE_ROW + BOARD_HEIGHT + 1, BASE_COL));
		write_count(num_flagged);
		VRAM_write(Plane_A(BASE_ROW + BOARD_HEIGHT + 1,
		                   BASE_COL + BOARD_WIDTH - 2));
		write_score(SCORE);
		read_joypad();
	} while (likely(handle_input()
	                && !lost
	                && (SCORE < 999U)
	                && (num_uncovered < NUM_CELLS - num_mines)));
	place_cursor_at(0, 0);
	VRAM_write(Plane_A(BASE_ROW + BOARD_HEIGHT + 1,
	                   BASE_COL + (BOARD_WIDTH / 2) - 2));
	if (lost || (num_uncovered == NUM_CELLS - num_mines))
	{
		puts("You ");
		puts(lost ? "lose" : "win");
		if (!lost)
		{
			best_score[difficulty] = MIN(best_score[difficulty],
			                             SCORE);
		}
		do {
			delay(1);
			read_joypad();
		} while(!(get_button_down_events()
		          & (CTRL_A | CTRL_B | CTRL_C | CTRL_START)));
	}
	player_row = GRID_SIZE / 2;
	player_col = GRID_SIZE / 2;
}

static int
handle_input(void)
{
	unsigned int input   = get_joypad_state();

	if (unlikely((input & DPAD)
	             && (!(input & prev_dir)
	                 || (gTicks - delay_start >= 10))))
	{
		if (input & (CTRL_UP | CTRL_DOWN))
		{
			player_row += (BOOL(input & CTRL_DOWN) << 1U) + (GRID_SIZE - 1U);
			player_row  %= GRID_SIZE;
		}
		if (input & (CTRL_LEFT | CTRL_RIGHT))
		{
			player_col += (BOOL(input & CTRL_RIGHT) << 1U) + (GRID_SIZE - 1U);
			player_col  %= GRID_SIZE;
		}
		prev_dir     = input;
		delay_start  = gTicks;
		place_cursor();
	}

	input = get_button_down_events();
	if (unlikely((input & (CTRL_A | CTRL_C))))
	{
		toggle_flag(player_row, player_col);
	}
	else if (unlikely(input & CTRL_B))
	{
		if (unlikely(num_uncovered == 0))
		{
			place_mines(num_mines, player_row, player_col);
			show_grid();
		}
		lost = is_mine(uncover_cell(player_row, player_col));
	}
	else if (unlikely(input & CTRL_START))
	{
		return (pause_game());
	}
	return 1;
}

void
place_cursor(void)
{
	unsigned int const vpos = 8 * screen_row(player_row) + 0x84;
	unsigned int const hpos = 8 * screen_col(player_row, player_col) + 0x84;

	place_cursor_at(vpos, hpos);
}

static void
place_cursor_at(Row const vpos, Column const hpos)
{
	set_autoincrement(6);
	VRAM_write(0xA800);
	VDATA_word((Word)vpos);
	VDATA_word((Word)hpos);
	set_autoincrement(2);
}

static int
is_flagged(Row const row, Column const col)
{
	Word data;

	VRAM_read(Plane_B(screen_row(row), screen_col(row, col)));
	data = *(Word volatile *)VDP_DATA;
	return ((data & PRIORITY) != 0);
}

static int
is_open(Row const row, Column const col)
{
	Word data;

	VRAM_read(Plane_A(screen_row(row), screen_col(row, col)));
	data = *(Word volatile *)VDP_DATA;
	return ((data & PALETTE(2)) != 0);
}

void
toggle_flag(Row const row, Column const col)
{
	Word address = Plane_B(screen_row(row), screen_col(row, col));
	Word data;

	if (likely(is_in_range(row, col) && !(is_open(row, col))))
	{
		VRAM_read(address);
		data = *(Word volatile *)VDP_DATA;
		num_flagged += (BOOL(!(data & PRIORITY)) << 1U) - 1U;
		VRAM_write(address);
		VDATA_word(data ^ PRIORITY);
	}
	return;
}

Cell
uncover_cell(Row const row, Column const col)
{
	unsigned int const s_row = screen_row(row);
	unsigned int const s_col = screen_col(row, col);
	unsigned int const d     = (row & 1) * 2 - 1;
	Cell         const c     = cell(row, col);

	if (unlikely((!is_in_range(row, col))
	             || (is_flagged(row, col))
	             || (add_palette_bit(Plane_A(s_row, s_col), 2)
	                 & PALETTE(2))))
	{
		return 0;
	}
	++num_uncovered;
	add_palette_bit(Plane_A(s_row    , s_col - 1), 1);
	add_palette_bit(Plane_A(s_row    , s_col + 1), 2);
	add_palette_bit(Plane_A(s_row - 1, s_col    ), 2);
	add_palette_bit(Plane_A(s_row - 1, s_col + 1), 2);
	add_palette_bit(Plane_A(s_row + 1, s_col    ), 1);
	add_palette_bit(Plane_A(s_row + 1, s_col - 1), 1);
	if (unlikely(c == 0))
	{
		uncover_cell(row    , col - 1);
		uncover_cell(row    , col + 1);
		uncover_cell(row - 1, col    );
		uncover_cell(row + 1, col    );
		uncover_cell(row - 1, col - d);
		uncover_cell(row + 1, col - d);
	}
	return c;
}

static unsigned int
screen_row(Row const row)
{
	return (BASE_ROW + 2 * row + 1);
}

static unsigned int
screen_col(Row const row, Column const col)
{
	return (BASE_COL + 2 * col + 1 + !(row & 1));
}

static Word
add_palette_bit(Word const address, int const pindex)
{
	Word data;

	VRAM_read(address);
	data = *(Word volatile *)VDP_DATA;
	VRAM_write(address);
	VDATA_word((Word)(data | PALETTE(pindex)));
	return data;
}

void
show_border(void)
{
	unsigned int i;

	set_autoincrement(0x40);
	VRAM_write(Plane_B(BASE_ROW, BASE_COL));
	for (i = 0; likely(i < BOARD_HEIGHT); ++i)
	{
		VDATA_word(PRIORITY | (LEFT_HALF_BLOCK + BASE_TILE));
	}

	VRAM_write(Plane_B(BASE_ROW, BASE_COL + BOARD_WIDTH));
	for (i = 0; likely(i < BOARD_HEIGHT); ++i)
	{
		VDATA_word(PRIORITY | (RIGHT_HALF_BLOCK + BASE_TILE));
	}
	set_autoincrement(2);
}

void
show_grid(void)
{
	unsigned int  i;
	unsigned int  j;

	for (i = 0; likely(i < BOARD_HEIGHT); ++i)
	{
		VRAM_write(Plane_A(i + BASE_ROW, BASE_COL));
		for (j = 0; likely(j <= BOARD_WIDTH); ++j)
		{
			VDATA_word((Word)(0 << 13 | tile_for_loc(i, j)));
		}
	}

	set_autoincrement(4);
	for (i = 0; likely(i < GRID_SIZE); ++i)
	{
		VRAM_write(Plane_B(screen_row(i), screen_col(i, 0)));
		for (j = 0; likely(j < GRID_SIZE); ++j)
		{
			VDATA_word(FLAG + BASE_TILE);
		}
	}
	set_autoincrement(2);
}

unsigned int
tile_for_loc(unsigned int const row, unsigned int const col)
{
	unsigned int tile;
	unsigned int  grid_col;
	Cell          c;
	int const     is_odd = (col ^ (row >> 1)) & 1;

	if (row & 1)
	{
		if (is_odd)
		{
			tile = VERT_BORDER;
		}
		else
		{
			grid_col = ((col + !is_odd) >> 1) - 1;
			if (unlikely(grid_col >= 10))
			{
				tile = 0;
			}
			else
			{
				c = cell(row >> 1, grid_col);
				tile = is_mine(c) ? 7U : (unsigned int)c;
			}
		}
	}
	else
	{
		tile = ((col ^ (row >> 1)) & 1)
			? HEXAGON_BOTTOM
			: HEXAGON_TOP;
	}

	return (tile + BASE_TILE);
}

static void
write_count(unsigned int const x)
{
	unsigned int y = (x / 10) % 10;

	putc((char)(y ? y + '0' : ' '));
	y = x % 10;
	putc((char)(y + '0'));
}

static void
write_score(unsigned int const x)
{
	unsigned int y = (x / 100) % 10;

	putc((char)(y ? y + '0' : ' '));
	y = (x / 10) % 10;
	putc((char)(((x >= 100) || y) ? y + '0' : ' '));
	y = x % 10;
	putc((char)(y + '0'));
}

static unsigned int
get_menu_item(unsigned int const def, Word const addr, int const start_clears)
{
	static unsigned int const mask     = CTRL_A | CTRL_B | CTRL_C | CTRL_START;
	unsigned int              buttons  = 0;
	unsigned int              option   = def;

	set_autoincrement(0x40);
	do
	{
		delay(1);
		read_joypad();
		buttons = get_button_down_events();
		if (unlikely(buttons & (CTRL_UP | CTRL_DOWN)))
		{
			option += 3 + (BOOL(buttons & CTRL_DOWN) << 1U) - 1;
			option %= 3;
		}
		if (unlikely((buttons & CTRL_START) && start_clears))
		{
			option = 0;
		}
		VRAM_write(addr);
		puts(option == 0 ? "*  "
		     : option == 1 ? " * "
		     : "  *");
	} while (likely(!(buttons & mask)));
	set_autoincrement(2);
	return option;
}

static int
pause_game(void)
{
	unsigned int option      = 0;
	DWord        pause_time  = gTicks;

	sound_command(PAUSE);
	place_cursor_at(0, 0);
	VREG_write( 4, (Plane_W(0, 0) >> 13) & 7);
	VREG_write(18, BASE_ROW + BOARD_HEIGHT);
	VRAM_write(Plane_W(BASE_ROW + BOARD_HEIGHT / 2 - 3,
	                   BASE_COL + BOARD_WIDTH / 2 - 2));
	puts("Paused");
	VRAM_write(Plane_W(BASE_ROW + BOARD_HEIGHT / 2 - 1,
	                   BASE_COL + BOARD_WIDTH / 2 - 3));
	puts("Continue");
	VRAM_write(Plane_W(BASE_ROW + BOARD_HEIGHT / 2,
	                   BASE_COL + BOARD_WIDTH / 2 - 3));
	puts("New game");
	VRAM_write(Plane_W(BASE_ROW + BOARD_HEIGHT / 2 + 1,
	                   BASE_COL + BOARD_WIDTH / 2 - 3));
	puts("Quit");
	option = get_menu_item(0,
	                       Plane_W(BASE_ROW + BOARD_HEIGHT / 2 - 1,
	                               BASE_COL + BOARD_WIDTH / 2 - 4),
	                       1);
	start_time += gTicks - pause_time;
	if (unlikely(option == 1))
	{
		new_game(difficulty);
	}
	VREG_write(18, 0x00);
	VREG_write( 4, (Plane_B(0, 0) >> 13) & 7);
	place_cursor();
	sound_command(RESUME);
	return (option != 2);
}

unsigned int
title_screen(void)
{
	unsigned int d = difficulty;

	initialize_grid();
	srand(1);
	place_mines(20, 5, 5);
	delay(1);
	show_grid();
	show_border();
	place_cursor_at(0, 0);
	uncover_cell(5,5);
	VRAM_write(Plane_B(BASE_ROW + 4,
	                   BASE_COL + BOARD_WIDTH / 2 - 4));
	puts("HEX SWEEPER");
	VRAM_write(Plane_B(BASE_ROW + BOARD_HEIGHT - 5,
	                   BASE_COL + BOARD_WIDTH / 2 - 4));
	puts("Best times");
	VRAM_write(Plane_B(BASE_ROW + BOARD_HEIGHT - 4,
	                   BASE_COL + BOARD_WIDTH / 2 - 7));
	puts("Easy ");
	puts("Normal ");
	puts("Hard");
	VRAM_write(Plane_B(BASE_ROW + BOARD_HEIGHT - 3,
	                   BASE_COL + BOARD_WIDTH / 2 - 7));
	write_score(best_score[0]);
	puts("   ");
	write_score(best_score[1]);
	puts("   ");
	write_score(best_score[2]);
	VRAM_write(Plane_B(BASE_ROW + 6,
	                   BASE_COL + BOARD_WIDTH / 2 - 1));
	puts("Easy ");
	VRAM_write(Plane_B(BASE_ROW + 7,
	                   BASE_COL + BOARD_WIDTH / 2 - 1));
	puts("Normal ");
	VRAM_write(Plane_B(BASE_ROW + 8,
	                   BASE_COL + BOARD_WIDTH / 2 - 1));
	puts("Hard");
	
	d = get_menu_item(d,
	                  Plane_B(BASE_ROW + 6,
	                          BASE_COL + BOARD_WIDTH / 2 - 2),
	                  0);
	srand(gTicks);
	return d;
}
