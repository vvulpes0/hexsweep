#ifndef MINES_H
#define MINES_H

#define GRID_SIZE (10U)
#define NUM_CELLS (GRID_SIZE * GRID_SIZE)
#define Mine      (-1)
#define is_mine(x) \
	((Cell)(x) < 0)

typedef signed char   Cell;
typedef unsigned int  Row;
typedef Row           Column;

Cell  cell            (Row  const    , Column const               ) __attribute__((pure ));
void  initialize_grid (void                                       )                       ;
int   is_in_range     (Row const     , Column const               ) __attribute__((const));
void  place_mine      (Row  const    , Column const               )                       ;
void  place_mines     (unsigned int const, Row const, Column const)                       ;

#endif
