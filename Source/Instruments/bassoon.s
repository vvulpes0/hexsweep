	.section .rodata, "a"
	.align 2
	.global bassoon
bassoon:
	.long r_bassoon
r_bassoon:
	.byte  0x04
	.byte  0x00, 0x02, 0x12, 0x00
	.byte  0x7f, 0x2a, 0x02, 0x01
	.byte  0x00, 0x1f, 0x1f, 0x1f
	.byte  0x00, 0x00, 0x00, 0x00
	.byte  0x00, 0x0a, 0x0a, 0x0a
	.byte  0x00, 0xff, 0xff, 0xff