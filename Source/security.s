	.text
	.align 2

	.global is_checksum_valid
is_checksum_valid:
	movea.w #0x200, %a0
	movea.l #SIZE - 1, %a1          | build script defines SIZE
	moveq.l #0, %d0
1:	add.w   (%a0)+, %d0
	cmpa.l  %a0, %a1
	bcc.s   1b
	cmp.w   (0x18e).w, %d0          | checksum stored in ROM at 0x18e
	seq     %d0
	ext.w   %d0
	rts
