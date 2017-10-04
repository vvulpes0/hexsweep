	.include "common.inc"

	.text
	.align 2
	.global load_driver
	|| void load_driver(char const * const addr)
load_driver:
	movea.l  4(%sp), %a0
	moveq    #0, %d0
	move.w   (%a0)+, %d0
	subq     #1, %d0
	lea.l    (Z80_BusReq), %a1
	move.b   #1, (%a1)
1:	btst.b   #0, (%a1)
	bne.b    1b
	lea.l    (Z80_SRAM), %a1
1:	move.b   (%a0)+, (%a1)+
	dbra     %d0, 1b
	move.b   #0xc1, (COMMAND)
	lea.l    (Z80_Reset), %a0
	move.b   #0, (%a0)
	move.b   #0, (Z80_BusReq)
	move.b   #1, (%a0)
	rts

wait_for_ready:
	lea.l    (Z80_BusReq), %a1
	move.l   #1, -(%sp)
2:	move.b   #0, (%a1)
	bsr      delay
	move.b   #1, (%a1)
1:	btst.b   #0, (%a1)
	bne.b    1b
	cmp.b    #0, (COMMAND)
	bne.b    2b
	addq     #4, %sp
	rts


	.global load_voice
	|| void load_voice(char const * const addr)
load_voice:
	bsr      wait_for_ready
	movea.l  4(%sp), %a0
	lea.l    (VOICE_ADDR), %a1
	moveq    #0x18, %d0
1:	move.b   (%a0)+, (%a1)+
	dbra     %d0, 1b
	move.b   #0, (Z80_BusReq)
	rts

	.global load_song
	|| void load_song(char const * const addr)
load_song:
	bsr      wait_for_ready
	movea.l  4(%sp), %a0
	moveq    #0, %d0
	move.w   (%a0)+, %d0
	subq     #1, %d0

	lea.l    (SONG_ADDR), %a1
1:	move.b   (%a0)+, (%a1)+
	dbra     %d0, 1b
	move.b   #0, (Z80_BusReq)
	rts

	.global sound_command
sound_command:
	bsr      wait_for_ready
	.ifdef USING_MSHORT
	move.b   5(%sp), (COMMAND)
	.else
	move.b   7(%sp), (COMMAND)
	.endif
	move.b   #0, (Z80_BusReq)
	rts

	.section .rodata, "a"
	.align 2
	.global sound_driver
sound_driver:
	.long   r_sound_driver
r_sound_driver:
	.word   DRIVER_SIZE
r_sound_driver_start:
	.incbin "sound-driver"
r_sound_driver_end:

	.equ DRIVER_SIZE, (r_sound_driver_end - r_sound_driver_start)
	.equ SOUND_DRIVER_DATA, (Z80_SRAM + DRIVER_SIZE)
	.equ COMMAND,    (SOUND_DRIVER_DATA + 4 * 10)
	.equ VOICE_ADDR, (COMMAND + 1)
	.equ SONG_ADDR,  (VOICE_ADDR + 0x19)
