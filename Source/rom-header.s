	.section .rodata, "a"
	.long   __stack , _start , aerr , aerr , err    , err , err    , err
	.long   err     , err    , err  , err  , err    , err , err    , err
	.long   err     , err    , err  , err  , err    , err , err    , err
	.long   err     , err    , err  , err  , hblank , err , vblank , err
	.long   trap0   , err    , err  , err  , err    , err , err    , err
	.long   err     , err    , err  , err  , err    , err , err    , err
	.long   err     , err    , err  , err  , err    , err , err    , err
	.long   err     , err    , err  , err  , err    , err , err    , err

| Sega Genesis / Mega Drive ROM header at 0x100, 256 bytes long
	.ascii "SEGA GENESIS    "
	.ascii "(C) DJL 2017.OCT"
	.ascii "HEX SWEEPER                                     " | JP
	.ascii "HEX SWEEPER                                     " | US/EU
	.ascii "GM T-999999 00"
	.word 0x0000 |; checksum -- not really necessary, as the build script
	             |;             replaces it in the final binary.
	.ascii "J0              "
	.long 0x00000000, SIZE
	.long 0x00FF0000, 0x00FFFFFF

	.ifdef HAS_SAVE_RAM
	.ascii "RA"
	.byte 0xF8
	.byte 0x20
	.long 0x00200001, 0x0020FFFF
	.else
	.ascii "            "
	.endif

	.ascii "            "
	.ascii "                                        " | Notes
	.ascii "F               " | Compatible with all hardware types.
	                          | This uses the newer region codes, set
	                          | forth in 1994.

	.text
	.align 2
	|| Interrupt Handlers
aerr:
	move.l  aerr_vector, -(%sp)
	beq.s   1f
	rts
err:
	move.l  2(%sp), err_loc
	move.l  err_vector, -(%sp)
	beq.s   1f
	rts
hblank:
	move.l  hblank_vector, -(%sp)
	beq.s   1f
	rts
vblank:
	move.l  vblank_vector, -(%sp)
	beq.s   2f
	rts

2:	addq.l  #1, (gTicks)
1:	addq.l  #4, %sp
	rte

trap0:
	stop #0x2000
	rte

	.bss
	.align 2
	|| If overriding any interrupt vectors,
	|| set these to function addresses
	.global aerr_vector
aerr_vector:
	.long   0
	.global err_vector
err_vector:
	.long   0

	.global hblank_vector
hblank_vector:
	.long   0

	.global vblank_vector
vblank_vector:
	.long   0

	.global err_loc
err_loc:
	.long 0
