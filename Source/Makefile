KILOBIT=  64
SIZE!=    (printf '$(KILOBIT) 128 * p q' | dc)

AR=       m68k-elf-ar
AS=       m68k-elf-as
CC=       m68k-elf-gcc
LD=       m68k-elf-gcc
Z80AS=    z80-coff-as
Z80LD=    z80-coff-ld
FDEBUG!=  (if [ "$(DEBUG)" ]; then printf '\x2dDDEBUG\n'; fi)

ASFLAGS:= -I. -IInclude -IData -m68000 -l\
 --strip-local-absolute --no-pad-sections\
 -defsym SIZE=$(SIZE) -defsym HAS_SMS_PAD=1
Z80ASFLAGS:= --no-pad-sections
CFLAGS:= -ansi -pedantic -Wall -Wconversion -Wextra -Werror\
 -DSIZE=$(SIZE) -DHAS_SMS_PAD=1 $(FDEBUG) -DSMALL_ARRAY -Wa,-l\
 -I./Include -I/opt/toolchains/m68k/m68k-elf/include\
 -ffreestanding -Os -pipe\
 -mcpu=68000 -march=68000 -mtune=68000 -m68000 -mpcrel -fpie\
 -fomit-frame-pointer -fira-region=all -fweb\
 -Wa,--no-pad-sections -flto -ffat-lto-objects
LDFLAGS:= $(CFLAGS)\
 -Wl,-z,max-page-size=256 -Wl,-s\
 -Wl,--gc-sections -Wl,--defsym=SIZE=$(SIZE)\
 -Wl,-T,md.ld -Wl,-Map,output.map -nostdlib\
 -Wl,--relax -Wl,-O1 -fuse-linker-plugin
Z80LDFLAGS:= -s --gc-sections -T z80.ld
LIBS:= -L/opt/toolchains/m68k/m68k-elf/lib\
 -L/opt/toolchains/m68k/m68k-elf/gcc\
 -LInstruments\
 -linstruments -lc -lgcc -lnosys
OBJS= controls.o crt0.o decompress.o graphics.o \
      hardware.o main.o mines.o random.o        \
      rom-header.o security.o sound.o ui.o      \
      Data/font.o Data/compressed-font.o        \
      Data/tiles.o Data/compressed-tiles.o      \
      Songs/playground.o

.SUFFIXES :
.SUFFIXES : .a .c .h .o .o80 .co .s .s80 .bin .weights .huffman .song .osong

.s.o :
	$(AS) $(ASFLAGS) -o $(.TARGET) -c $(.IMPSRC)

.s80.o80 :
	$(Z80AS) $(Z80ASFLAGS) -o $(.TARGET) -c $(.IMPSRC)

.song.osong :
	PATH="../PC-Bin:$${PATH}";\
	sc < $(.IMPSRC) > $(.TARGET)

.osong.s :
	NAME=$$(basename '$(.PREFIX)');\
	printf '.section .rodata, "a"\n.align 2\n.global %s\n%s: .long real\nreal:\n.incbin "%s"\n'\
	$${NAME} $${NAME} $(.IMPSRC) > $(.TARGET)

.osong.h :
	NAME=$$(basename '$(.PREFIX)');\
	printf '#ifndef %s_h\n#define %s_h\nextern char const * const %s;\n#endif\n'\
	$${NAME} $${NAME} $${NAME} > $(.TARGET)

.c.o :
	$(CC) $(CFLAGS) -o $(.TARGET) -c $(.IMPSRC)

.o.co :
	PATH="../PC-Bin:$${PATH}";\
	dump-bytes $(.IMPSRC)\
	| compress $(.ALLSRC:[2..-1]) > $(.TARGET)

.o.weights :
	PATH="../PC-Bin:$${PATH}";\
	dump-frequencies $(.IMPSRC) > $(.TARGET)

.weights.huffman :
	PATH="../PC-Bin:$${PATH}";\
	create-table < $(.IMPSRC) > $(.TARGET)

.MAIN : hexsweep.bin

hexsweep.bin            : $(OBJS) Instruments/libinstruments.a
	$(LD) $(LDFLAGS) $(OBJS) $(LIBS) -o $(.TARGET) &&\
	mdchksum -f $(.TARGET)

sound-driver : sound-driver.o80
	$(Z80LD) $(Z80LDFLAGS) $(.ALLSRC) -o $(.TARGET)

Instruments/libinstruments.a : Instruments/bassoon.o \
                               Instruments/clarinet.o \
                               Instruments/grand-piano.o
	$(AR) -rcs $(.TARGET) $(.ALLSRC)

graphics.o                   : graphics.c Include/common.h                  \
                               Include/graphics.h Data/font.h
main.o                       : main.c Include/common.h Include/decompress.h \
                               Include/graphics.h Include/random.h          \
                               Include/security.h Include/ui.h              \
                               Data/font.h Data/tiles.h                     \
                               Instruments/instruments.h                    \
                               Songs/playground.h
mines.o                      : mines.c Include/common.h Include/mines.h     \
                               Include/random.h
random.o                     : random.c Include/common.h Include/random.h
sound.o                      : sound.s sound-driver
ui.o                         : ui.c Include/common.h Include/controls.h     \
                               Include/graphics.h Include/mines.h           \
                               Include/random.h Include/ui.h                \
                               Data/font.h Data/tiles.h
Data/compressed-font.o       : Data/compressed-font.s                       \
                               Data/font.co Data/font.huffman
Data/compressed-tiles.o      : Data/compressed-tiles.s                      \
                               Data/tiles.co Data/tiles.huffman
Data/font.co                 : Data/font.o Data/font.weights
Data/tiles.co                : Data/tiles.o Data/tiles.weights

output.map                   : hexsweep.bin
	@true

.PHONY : show-size
show-size ! output.map
	grep '\(__text_size\|__data_size\)' $(.ALLSRC)\
	| awk 'BEGIN {print "10o\n16i\n"; FS="( *0x0*| *)"}\
 {print $$2}\
 END {print "+pq\n"}'\
	| tr 'a-f' 'A-F'\
	| dc

.PHONY : clean
clean ::
	rm -f\
	Data/font.o Data/compressed-font.o Data/font.co\
	Data/tiles.o Data/compressed-tiles.o Data/tiles.co\
	Data/font.weights Data/font.huffman\
	Data/tiles.weights Data/tiles.huffman\
	Instruments/bassoon.o\
	Instruments/clarinet.o\
	Instruments/grand-piano.o\
	Instruments/libinstruments.a\
	Songs/playground.o Songs/playground.h Songs/playground.s Songs/playground.osong\
	controls.o crt0.o decompress.o graphics.o hardware.o\
	main.o mines.o random.o rom-header.o security.o ui.o\
	sound.o sound-driver.o80 sound-driver\
	output.map

.PHONY : distclean
distclean :: clean
	rm -f hexsweep.bin
