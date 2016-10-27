#ifndef SOUND_H
#define SOUND_H

extern char const * const sound_driver;

typedef enum {
	LOAD_VOICE_1 = 0x01,
	LOAD_VOICE_2 = 0x02,
	LOAD_VOICE_3 = 0x03,
	LOAD_VOICE_4 = 0x04,
	PLAY         = 0xc0,
	PAUSE        = 0xc1,
	RESUME       = 0xc2
} Sound_Command;

void load_driver(char const * const);
void load_song(char const * const);
void load_voice(char const * const);
void sound_command(Sound_Command const);
#endif
