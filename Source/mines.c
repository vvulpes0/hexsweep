#include "mines.h"
#include "common.h"
#include "random.h"

/**
 * If memory is tight but extra program storage space is available,
 * you may consider defining SMALL_ARRAY.  When placing mines, the
 * available indices are permuted using an inside-out Fisher-Yates
 * shuffle.  This option modifies the shuffle to store only in the
 * part of the array that will be used.
 */

#ifdef SMALL_ARRAY
/* Note: Cannot place more mines than INDEX_ARRAY_SIZE */
#define INDEX_ARRAY_SIZE 25
#define CHECK_INDEX(x) ((x) < INDEX_ARRAY_SIZE)
#else
#define INDEX_ARRAY_SIZE (NUM_CELLS - 1U)
#define CHECK_INDEX(x) 1
#endif

static void set_cell (Row const, Column const, Cell const);
static void increment_cell (Row const , Column const)                       ;

static Cell grid[NUM_CELLS];
static unsigned int indices[INDEX_ARRAY_SIZE];

void
initialize_grid(void)
{
	int i;

	for (i = 0; likely(i < (int)NUM_CELLS); i++)
	{
		grid[i] = 0;
	}
	return;
}

int
is_in_range(Row const row, Column const col)
{
	return likely(row < GRID_SIZE
	              && col < GRID_SIZE);
}

static void
increment_cell(Row const row, Column const col)
{
	if (likely(is_in_range(row, col))
	    && likely(!is_mine(cell(row, col))))
	{
		set_cell(row, col, (Cell)(cell(row, col) + 1));
	}
	return;
}

Cell
cell(Row const row, Column const col)
{
	return (grid[row * GRID_SIZE + col]);
}

static void
set_cell(Row const row, Column const col, Cell const value)
{
	grid[row * GRID_SIZE + col] = value;
}

void
place_mine(Row const row, Column const col)
{
	int const displacement = (int)(((row & 1) << 1) - 1);

	if (likely(is_in_range(row, col)))
	{
		set_cell(row, col, Mine);
		increment_cell(row, col - 1);
		increment_cell(row, col + 1);
		increment_cell(row - 1, col);
		increment_cell(row + 1, col);
		increment_cell(row - 1, (Column)((int)col - displacement));
		increment_cell(row + 1, (Column)((int)col - displacement));
	}
	return;
}

void
place_mines(unsigned int const num_mines, Row const row, Column const col)
{
	unsigned int i;
	unsigned int j;

	for (i = 0; likely(i < NUM_CELLS - 1U); ++i)
	{
		j = rand_range(0, i);
		if (CHECK_INDEX(i))
		{
			indices[i] = indices[j];
		}
		if (CHECK_INDEX(j))
		{
			indices[j] = i + (i >= row * GRID_SIZE + col);
		}
	}
	for (i = 0; likely(i < num_mines); ++i)
	{
		place_mine(indices[i] / GRID_SIZE, indices[i] % GRID_SIZE);
	}
}
