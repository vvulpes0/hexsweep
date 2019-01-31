	.text
	.align 2
	.global _start
_start:
	move    #0x2700, %sr
	tst.l   (0xA10008)
	bne.b   1f
	tst.w   (0xA1000C)
1:	bne.b   skip_tmss

	|| SEGA's code for TMSS handling
	move.b  (0xA10001), %d0
	andi.b  #0x0F, %d0
	beq.b   skip_tmss
	move.l  (0x100), (0xA14000)
skip_tmss:
	move.w  #0x8104, (0xC00004)
	move.w  (0xC00004), %d0
	|| End of TMSS

	|| Clear work RAM (including bss ...)
	lea     (0xFF0000), %a0
	moveq   #0, %d0
	move.w  #0x3FFF, %d1
1:	move.w  %d0, (%a0)+
	dbra    %d1, 1b

	|| Copy initialized variables to RAM
	lea     (__copy_source), %a0
	lea     (__copy_dest), %a1
	move.l  #__copy_size, %d0       | bytes to copy
	lsr.l   #1, %d0                 |  shift to get words
	subq.w  #1, %d0                 |  subtract one for loop counter
1:	move.w  (%a0)+, (%a1)+          | copy word to RAM
	dbra    %d0, 1b

	lea     (__stack), %sp
	link.w  %a6, #-8
	jsr     init_hardware
	jsr     __INIT_SECTION__
	jsr     main
	jsr     __FINI_SECTION__
1:	bra.b   1b                      | infinite loop (reached on exit)
