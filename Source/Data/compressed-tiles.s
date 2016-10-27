	.section .rodata, "a"
	.align 2
	.global compressed_tiles
compressed_tiles:
	.incbin "tiles.co"

	.global tiles_huffman_table_data
tiles_huffman_table_data:
	.incbin "tiles.huffman"
