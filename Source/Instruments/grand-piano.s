	.section .rodata, "a"
	.align 2
	.global grand_piano
grand_piano:
	.long r_grand_piano
	
	.section .rodata.str1.1, "a"
r_grand_piano:
	.byte  0x32
	.byte  0x71, 0x0d, 0x33, 0x01
	.byte  0x23, 0x2d, 0x26, 0x00
	.byte  0x5f, 0x99, 0x5f, 0x94
	.byte  0x05, 0x05, 0x05, 0x07
	.byte  0x02, 0x02, 0x02, 0x02
	.byte  0x11, 0x11, 0x11, 0xa6
