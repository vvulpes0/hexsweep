	.include "common.inc"

	.bss
	.align  2

	.global new
new:
	.word   0x0000
	.global current
current:
	.word   0x0000

	.text
	.align  2
	
	.global read_joypad
	|| Result: %000?MXYZSACBRLDU
read_joypad:
	movea.l #0xA10003, %a0          | pad control register
	move.l  %d2, -(%sp)
	move.b  #1, (Z80_BusReq)        | Begin Z80 bus request
1:	btst.b  #0, (Z80_BusReq)
	bne.b   1b                      | Wait for Z80 to be ready
	bsr.b   get_input               | - 0 s a 0 0 d u - 1 c b r l d u
	move.w  %d0, %d1
	andi.w  #0x0C00, %d0
	bne.b   no_pad
	bsr.b   get_input               | - 0 s a 0 0 d u - 1 c b r l d u
	bsr.b   get_input               | - 0 s a 0 0 0 0 - 1 c b m x y z
	move.w  %d0, %d2
	bsr.b   get_input               | - 0 s a 1 1 1 1 - 1 c b r l d u
	move.b  #0, (Z80_BusReq)        | Release Z80 bus
	andi.w  #0x0F00, %d0            | 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0
	cmpi.w  #0x0F00, %d0
	beq.b   common                  | six button pad
	move.w  #0x010F, %d2            | three button pad
common:
	lsl.b   #4, %d2                 | - 0 s a 0 0 0 0 m x y z 0 0 0 0
	lsl.w   #4, %d2                 | 0 0 0 0 m x y z 0 0 0 0 0 0 0 0
	andi.w  #0x303F, %d1            | 0 0 s a 0 0 0 0 0 0 c b r l d u
	move.b  %d1, %d2                | 0 0 0 0 m x y z 0 0 c b r l d u
	lsr.w   #6, %d1                 | 0 0 0 0 0 0 0 0 s a 0 0 0 0 0 0
	or.w    %d1, %d2                | 0 0 0 0 m x y z s a c b r l d u
	eori.w  #0x1FFF, %d2            | 0 0 0 1 M X Y Z S A C B R L D U
	moveq   #0, %d1
	move.w  %d2, %d1
	move.w  (current), %d0
	eor.w   %d0, %d1
	and.w   %d2, %d1
	move.w  %d1, (new)
	move.w  %d2, (current)
	move.w  %d2, %d0
	move.l  (%sp)+, %d2
	rts

	|| 3-/6-button pad not found
no_pad:
	move.b  #0, (Z80_BusReq)        | Release Z80 bus
	.ifdef  HAS_SMS_PAD
	move.b  (%a0), %d0              |                 - 1 c b r l d u
	andi.w  #0x003F, %d0            | 0 0 0 0 0 0 0 0 0 0 c b r l d u
	eori.w  #0x003F, %d0            | 0 0 0 0 0 0 0 0 0 0 C B R L D U
	.else
	move.w  #0xF000, %d0            | CTRL_NONE
	.endif
	move.l  (%sp)+, %d2
	rts

	|| Read single phase from controller
	|| The timing of this function is extremely important
get_input:
	move.b  #0x00, (%a0)
	nop
	nop
	move.b  (%a0), %d0
	move.b  #0x40, (%a0)
	asl.w   #8, %d0
	move.b  (%a0), %d0
	rts


	.global get_button_down_events
get_button_down_events:
	| This routine is just like get_joypad_state in that it does not
	| update values and has the same return format, but it returns only
	| buttons that have been depressed since the last time the joypad
	| was read.
	moveq   #0, %d0
	move.w  (new), %d0
	rts

	.global get_joypad_state
get_joypad_state:
	| This routine does _not_ read the joypad.  In order to update the
	| values this routine uses, call read_joypad.  The return value of
	| this routine is the word value describing currently-held buttons:
	| %000?MXYZSACBRLDU
	moveq   #0, %d0
	move.w  (current), %d0
	rts
