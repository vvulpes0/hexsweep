#ifndef FONT_H
#define FONT_H

#include "common.h"

extern Byte           const * const charmap;
extern Byte           const * const font_huffman_table;
extern DWord          const *       font;
extern unsigned int   const         font_words;

#define BASE_CHAR 32

#endif
