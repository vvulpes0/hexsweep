#ifndef UI_H
#define UI_H

#include "common.h"
#include "mines.h"

void          event_loop  (void                                  )                       ;
void          new_game    (unsigned int const                    )                       ;
void          place_cursor(void                                  )                       ;
void          show_border (void                                  )                       ;
void          show_grid   (void                                  )                       ;
unsigned int  tile_for_loc(unsigned int const, unsigned int const) __attribute__((pure ));
unsigned int  title_screen(void                                  )                       ;
void          toggle_flag (Row  const         , Column const     )                       ;
Cell          uncover_cell(Row  const         , Column const     )                       ;

#endif
