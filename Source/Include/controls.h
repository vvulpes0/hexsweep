#ifndef CONTROLS_H
#define CONTROLS_H

#define CTRL_A     (1<<6)
#define CTRL_B     (1<<4)
#define CTRL_C     (1<<5)
#define CTRL_START (1<<7)
#define CTRL_RIGHT (1<<3)
#define CTRL_UP    (1<<0)
#define CTRL_LEFT  (1<<2)
#define CTRL_DOWN  (1<<1)

#define DPAD (CTRL_RIGHT | CTRL_UP | CTRL_LEFT | CTRL_DOWN)

unsigned int read_joypad(void);
/* Read the first joypad, updating variables for use by other routines,
 * namely get_joypad_state and get_button_down_events.  This routine also
 * returns the same data that get_joypad_state does, in the format
 * %000?MXYZSACBRLDU.  If a particular joypad does not have a specific
 * button, that bit will be a 0.
 */

unsigned int get_joypad_state(void);
/* Return %000?MXYZSACBRLDU of buttons currently depressed.
 */

unsigned int get_button_down_events(void);
/* Return %000?MXYZSACBRLDU of buttons depressed between the last two calls
 * to read_joypad.
 */

#endif
