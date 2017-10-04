	.include "common.inc"

| SEGA Genesis support code
	.section .rodata, "a"
	.align 2
	|| VDP Commands
VDPRAM:
	.word   0x8104, 0x8F01 | set registers 1 (display off) and 15 (INC = 1)
	.word   0xC000, 0x0000 | write CRAM address 0
	.word   0x4000, 0x0010 | write VSRAM address 0

	.section .rodata.str1.1, "a"
	|| VDP register initialization values
VDPRegs:
	.byte   0x04 | 8004 => write reg 0 = /IE1 (no HBL INT), /M3 (enable read H/V cnt)
	.byte   0x14 | 8114 => write reg 1 = /DISP (display off), /IE0 (no VBL INT), M1 (DMA enabled), /M2 (V28 mode)
	.byte   0x30 | 8230 => write reg 2 = Name Tbl A = 0xC000
	.byte   0x2C | 832C => write reg 3 = Name Tbl W = 0xB000
	.byte   0x07 | 8407 => write reg 4 = Name Tbl B = 0xE000
	.byte   0x54 | 8554 => write reg 5 = Sprite Attr Tbl = 0xA800
	.byte   0x00 | 8600 => write reg 6 = always 0
	.byte   0x00 | 8700 => write reg 7 = BG color
	.byte   0x00 | 8800 => write reg 8 = always 0
	.byte   0x00 | 8900 => write reg 9 = always 0
	.byte   0x00 | 8A00 => write reg 10 = HINT = 0
	.byte   0x00 | 8B00 => write reg 11 = /IE2 (no EXT INT), full scroll
	.byte   0x00 | 8C00 => write reg 12 = H32 mode, no lace, no shadow/hilite
	.byte   0x2B | 8D2B => write reg 13 = HScroll Tbl = 0xAC00
	.byte   0x00 | 8E00 => write reg 14 = always 0
	.byte   0x02 | 8F02 => write reg 15 = data INC = 2
	.byte   0x00 | 9000 => write reg 16 = Scroll Size = 32x32
	.byte   0x00 | 9100 => write reg 17 = W Pos H = left
	.byte   0x00 | 9200 => write reg 18 = W Pos V = top

FMReset:
	|| Disable LFO
	.byte   0, 0x22
	.byte   1, 0x00
	|| Disable timer & set channel 6 to normal mode
	.byte   0, 0x27
	.byte   1, 0x00
	|| All KEY_OFF
	.byte   0, 0x28
	.byte   1, 0x00
	.byte   1, 0x04
	.byte   1, 0x01
	.byte   1, 0x05
	.byte   1, 0x02
	.byte   1, 0x06
	|| Disable DAC
	.byte   0, 0x2A
	.byte   1, 0x80
	.byte   0, 0x2B
	.byte   1, 0x00
	|| Turn off channels
	.byte   0, 0xB4
	.byte   1, 0x00
	.byte   0, 0xB5
	.byte   1, 0x00
	.byte   0, 0xB6
	.byte   1, 0x00
	.byte   2, 0xB4
	.byte   3, 0x00
	.byte   2, 0xB5
	.byte   3, 0x00
	.byte   2, 0xB6
	.byte   3, 0x00

	|| PSG register initialization values
PSGReset:
	.byte   0x9f | set ch0 attenuation to max
	.byte   0xbf | set ch1 attenuation to max
	.byte   0xdf | set ch2 attenuation to max
	.byte   0xff | set ch3 attenuation to max

	.text
	.align  2

	|| Initialize the hardware
	.global init_hardware
init_hardware:
	movem.l %d2-%d7/%a2-%a6,-(%sp)

	|| halt Z80
	move.b  #1, (Z80_Reset)
	movea.l #Z80_BusReq, %a0
	move.b  #1, (%a0)
1:	btst.b  #0, (%a0)
	bne.b   1b

	|| Controllers
	lea     IO_SPACE, %a5
	move.b  #0x40, 0x09(%a5)
	move.b  #0x40, 0x0B(%a5)
	move.b  #0x40, 0x03(%a5)
	move.b  #0x40, 0x05(%a5)

	|| Screen
	lea     VDP_DATA, %a3
	lea     VDP_STATUS, %a4

	|| wait on DMA (in case we reset in the middle of DMA)
	move.w  #0x8114, (%a4)
1:	move.w  (%a4), %d0
	btst    #1, %d0
	bne.b   1b

	moveq   #0, %d0
	move.w  #0x8000, %d5
	move.w  #0x0100, %d7

	|| Set VDP registers
	lea     VDPRegs(%pc), %a5
	moveq   #18, %d1
1:	move.b  (%a5)+, %d5
	move.w  %d5, (%a4)
	add.w   %d7, %d5
	dbra    %d1, 1b

	|| clear VRAM
	move.w  #0x8F02, (%a4)
	move.l  #0x40000000, (%a4)
	move.w  #0x7FFF, %d1
1:	move.w  %d0, (%a3)
	dbra    %d1, 1b

| The VDP state at this point is: Display disabled, ints disabled,
| Name Tbl A at 0xC000, Name Tbl B at 0xE000, Name Tbl W at 0xB000,
| Sprite Attr Tbl at 0xA800, HScroll Tbl at 0xAC00, H40 V28 mode,
| and Scroll size is 64x32.

	|| Clear CRAM
	lea     VDPRAM(%pc), %a5
	move.l  (%a5)+, (%a4)
	move.l  (%a5)+, (%a4)
	moveq   #31, %d3
1:	move.l  %d0, (%a3)
	dbra    %d3, 1b

	|| Clear VSRAM
	move.l  (%a5)+, (%a4)
	moveq   #19, %d4
1:	move.l  %d0, (%a3)
	dbra    %d4, 1b

	|| reset YM2612
	lea     FMReset(%pc), %a5
	lea     (Z80_SRAM), %a0
	move.b  #0x76, (%a0)
	move.w  #0x4000, %d1
	moveq   #26, %d2
1:	move.b  (%a5)+, %d1
	move.b  (%a5)+, 0(%a0, %d1.w)
	dbra    %d2, 1b

	moveq   #0x30, %d0
	moveq   #0x5F, %d2
1:	move.b  %d0, 0x4000(%a0)
	move.b  #0xFF, 0x4001(%a0)
	move.b  %d0, 0x4002(%a0)
	move.b  #0xFF, 0x4003(%a0)
	addq.b  #1, %d0
	dbra    %d2, 1b
	move.b  #0, (Z80_Reset)
	move.b  #0, (Z80_BusReq)
	move.b  #1, (Z80_Reset)

	|| reset PSG
	lea     PSGReset(%pc), %a5
	lea     VDP_DATA, %a0
	move.b  (%a5)+, 0x0011(%a0)
	move.b  (%a5)+, 0x0011(%a0)
	move.b  (%a5)+, 0x0011(%a0)
	move.b  (%a5), 0x0011(%a0)

	move.w  #0x2000, %sr

	movem.l (%sp)+, %d2-%d7/%a2-%a6
	rts

| short set_sr(short new_sr);
| set SR, return previous SR
| entry: arg = SR value
| exit:  d0 = previous SR value
	.global set_sr
set_sr:
	moveq   #0, %d0
	move.w  %sr, %d0
	move.l  4(%sp), %d1
	move.w  %d1, %sr
	rts
