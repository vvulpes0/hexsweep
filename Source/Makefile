KILOBIT=  64
SIZE!=    awk 'BEGIN {print $(KILOBIT) * 128; quit}'

AR=       m68k-elf-ar
AS=       m68k-elf-as
CC=       m68k-elf-gcc
LD=       m68k-elf-gcc
Z80AS=    z80-coff-as
Z80LD=    z80-coff-ld
PATH:=    $(.CURDIR:H)/PC-Bin:$(PATH)
.export-env PATH

SHORT=

DIRS=Data Include Instruments Songs
INCLUDEDIRS=$(DIRS:S/^/-I$(.CURDIR)\//) -I$(.CURDIR) -I$(.OBJDIR)
ASFLAGS:= $(INCLUDEDIRS) -m68000 -l\
 $(SHORT:D--defsym USING_MSHORT=1)\
 --strip-local-absolute --no-pad-sections\
 -defsym SIZE=$(SIZE) -defsym HAS_SMS_PAD=1
Z80ASFLAGS:= --no-pad-sections
OPTFLAGS=-Os -mpcrel $(SHORT:D-mshort) -fomit-frame-pointer\
 -Wa,-l -Wa,--no-pad-sections
WARNINGS=-Wall -Wconversion -Wextra -Werror
CFLAGS:= -m68000 $(OPTFLAGS) -ansi -pedantic $(WARNINGS) $(INCLUDEDIRS)\
 -DSIZE=$(SIZE) -DHAS_SMS_PAD=1 $(DEBUG:D-DDEBUG)\
 -ffreestanding -pipe\
# -flto -ffat-lto-objects
LDFLAGS:= $(CFLAGS)\
 -Wl,-z,max-page-size=256 -Wl,-s -Wl,--cref\
 -Wl,--gc-sections -Wl,--defsym=SIZE=$(SIZE)\
 -Wl,-T,$(.CURDIR)/md.ld -Wl,-Map,output.map -nostartfiles\
 -Wl,--relax -Wl,-O1 -fuse-linker-plugin
Z80LDFLAGS:= -s --gc-sections -T $(.CURDIR)/z80.ld
LIBS:= -L$(.OBJDIR) -linstruments
OBJS= compressed-font.o compressed-tiles.o controls.o crt0.o\
 decompress.o font.o graphics.o hardware.o main.o mines.o playground.o\
 random.o rom-header.o security.o sound.o tiles.o ui.o

.SUFFIXES :
.SUFFIXES : .a .c .h .o .o80 .co .s .s80 .bin .weights .huffman .song .osong

.PATH : $(.CURDIR)/Data $(.CURDIR)/Include $(.CURDIR)/Instruments
.PATH.song : $(.CURDIR)/Songs

.c.o             : ; $(CC) $(CFLAGS) -o $(.TARGET) -c $(.IMPSRC)
.s.o             : ; $(AS) $(ASFLAGS) -o $(.TARGET) -c $(.IMPSRC)
.s80.o80         : ; $(Z80AS) $(Z80ASFLAGS) -o $(.TARGET) -c $(.IMPSRC)
.o80             : ; $(Z80LD) $(Z80LDFLAGS) $(.ALLSRC:O) -o $(.TARGET)
.song.osong      : ; sc < $(.IMPSRC) > $(.TARGET)
.o.co            : ; dump-bytes $(.IMPSRC)\
                   | compress $(.ALLSRC:[2..-1]) > $(.TARGET)
.o.weights       : ; dump-frequencies $(.IMPSRC) > $(.TARGET)
.weights.huffman : ; create-table < $(.IMPSRC) > $(.TARGET)
.osong.s         : ; printf '.section .rodata, "a"\n.align 2\n.global %s\n%s: .long real\nreal:\n.incbin "%s"\n'\
                     $(.PREFIX) $(.PREFIX) $(.IMPSRC) > $(.TARGET)
.osong.h         : ; printf '\#ifndef %s_h\n\#define %s_h\nextern char const * const %s;\n\#endif\n'\
                     $(.PREFIX) $(.PREFIX) $(.PREFIX) > $(.TARGET)

.MAIN : hexsweep.bin

hexsweep.bin       : $(OBJS) libinstruments.a
	$(LD) $(LDFLAGS) $(.ALLSRC:M*.o:O) $(LIBS) -o $(.TARGET)
	mdchksum -if $(.TARGET)
output.map         : hexsweep.bin ; :

libinstruments.a   : bassoon.o clarinet.o grand-piano.o
	$(AR) -rcs $(.TARGET) $(.ALLSRC:O)

graphics.o         : graphics.c common.h font.h graphics.h
main.o             : main.c common.h decompress.h font.h    \
                     graphics.h instruments.h playground.h  \
                     random.h security.h tiles.h ui.h
mines.o            : mines.c common.h mines.h random.h
random.o           : random.c common.h random.h
sound.o            : sound.s sound-driver
ui.o               : ui.c common.h controls.h font.h \
                     graphics.h mines.h random.h tiles.h ui.h
compressed-font.o  : compressed-font.s font.co font.huffman
compressed-tiles.o : compressed-tiles.s tiles.co tiles.huffman
font.co            : font.o font.weights
tiles.co           : tiles.o tiles.weights

.PHONY : show-size
show-size ! output.map ; awk '\
	function parsehex(V,OUT)                             \
	{                                                    \
		if ( V ~ /^0x/)                              \
		{                                            \
			V = substr(V, 3)                     \
		}                                            \
		for (N = 1; N <= length(V); ++N)             \
		{                                            \
			OUT = 16 * OUT + H[substr(V, N, 1)]  \
		}                                            \
		return OUT                                   \
	}                                                    \
	BEGIN                                                \
	{                                                    \
		for (N = 0; N < 16; ++N)                     \
		{                                            \
			H[sprintf("%x", N)] = N;             \
			H[sprintf("%X", N)] = N              \
		}                                            \
	}                                                    \
	/^\.fill/ { print parsehex($$2) }'                   \
	$(.ALLSRC:[1])

.PHONY : clean
clean ::
	rm -f\
	bassoon.o clarinet.o compressed-font.o compressed-tiles.o      \
	controls.o crt0.o decompress.o font.co font.huffman font.o     \
	font.weights grand-piano.o graphics.o hardware.o               \
	libinstruments.a main.o mines.o output.map playground.h        \
	playground.o playground.osong playground.s random.o            \
	rom-header.o security.o sound-driver sound-driver.o80 sound.o  \
	tiles.co tiles.huffman tiles.o tiles.weights ui.o

.PHONY : distclean
distclean :: clean
	rm -f hexsweep.bin
