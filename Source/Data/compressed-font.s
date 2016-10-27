	.section .rodata, "a"
	.align 2
	.global compressed_font
compressed_font:
	.incbin "font.co"

	.global font_huffman_table_data
font_huffman_table_data:
	.incbin "font.huffman"
