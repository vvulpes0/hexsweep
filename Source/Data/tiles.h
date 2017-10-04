#ifndef TILES_H
#define TILES_H

#include "common.h"

enum {
	FILLED_BLOCK     =  0,
	DIGIT_ONE        =  1,
	DIGIT_TWO        =  2,
	DIGIT_THREE      =  3,
	DIGIT_FOUR       =  4,
	DIGIT_FIVE       =  5,
	DIGIT_SIX        =  6,
	MINE             =  7,
	VERT_BORDER      =  8,
	HEXAGON_TOP      =  9,
	HEXAGON_BOTTOM   = 10,
	LEFT_HALF_BLOCK  = 11,
	RIGHT_HALF_BLOCK = 12,
	FLAG             = 13,
	CURSOR           = 14
};

#define BASE_TILE 128

extern Byte           const * const tiles_huffman_table;
extern DWord          const * const tiles;
extern unsigned long  const         tileset_words;

#endif
