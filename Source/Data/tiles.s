	.section .rodata, "a"
	.align 2

	|| Pallete:
	|| 0: Transparent
	|| 1: Digit 1
	|| 2: Digit 2
	|| 3: Digit 3
	|| 4: Digit 4
	|| 5: Digit 5
	|| 6: Digit 6
	|| 7: Mine
	|| 8: Mine highlight
	|| 9: Cell shadow
	|| A: Cell A background
	|| B: Cell B background
	|| C: Cell highlight, text, right half-block
	|| D: -- unused --
	|| E: Flagpole, left half-block
	|| F: Flag

	.global tiles
tiles:
	.long   compressed_tiles

	.global tiles_huffman_table
tiles_huffman_table:
	.long   tiles_huffman_table_data

	.global tileset_words
tileset_words:
	.long   ((tiles_end - tileset) / 2)

	.section .compressible
tileset:
	|| Filled block
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 1
	.long   0xAAAA11AA
	.long   0xAAA111AA
	.long   0xAAAA11AA
	.long   0xAAAA11AA
	.long   0xAAAA11AA
	.long   0xAA111111
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 2
	.long   0xAAA2222A
	.long   0xAA2AAA22
	.long   0xAAAAAA22
	.long   0xAAAA222A
	.long   0xAAA2AAAA
	.long   0xAA222222
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 3
	.long   0xAAA3333A
	.long   0xAA3AAA33
	.long   0xAAAAA33A
	.long   0xAAAAAA33
	.long   0xAA3AAA33
	.long   0xAAA3333A
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 4
	.long   0xAA44A44A
	.long   0xAA44A44A
	.long   0xAA44A44A
	.long   0xAA444444
	.long   0xAAAAA44A
	.long   0xAAAAA44A
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 5
	.long   0xAA555555
	.long   0xAA55AAAA
	.long   0xAA55555A
	.long   0xAAAAAA55
	.long   0xAAAAAA55
	.long   0xAA55555A
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Digit 6
	.long   0xAAA6666A
	.long   0xAA66AAAA
	.long   0xAA66A66A
	.long   0xAA666A66
	.long   0xAA66AA66
	.long   0xAAA6666A
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Mine
	.long   0xAAAA7AAA
	.long   0xA7A777A7
	.long   0xAA78777A
	.long   0xA7777777
	.long   0xAA77777A
	.long   0xA7A777A7
	.long   0xAAAA7AAA
	.long   0xAAAAAAAA

	|| Hex-cell part: vertical border
	.long   0xAAAA0CCB
	.long   0xAAAA0CBB
	.long   0xAAAA0BBB
	.long   0xAAA90BBB
	.long   0xAAA90BBB
	.long   0xAA990BBB
	.long   0xAA990BBB
	.long   0xA9990BBB

	|| Hex-cell part: top
	.long   0x9990A0BB
	.long   0x990AAA0B
	.long   0x90AAAAA0
	.long   0x0AAAAAAA
	.long   0xCAAAAAAA
	.long   0xCAAAAAAA
	.long   0xAAAAAAAA
	.long   0xAAAAAAAA

	|| Hex-cell part: bottom
	.long   0xBBBBBBBB
	.long   0xBBBBBBB9
	.long   0xBBBBBB99
	.long   0x0BBB9999
	.long   0xA0999990
	.long   0xAA09990C
	.long   0xAAA090CC
	.long   0xAAAA0CCC

	|| Left half-block
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000
	.long   0xEEEEE000

	|| Right half-block
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC
	.long   0x0000CCCC

	|| Flag
	.long   0x00EFFFFF
	.long   0x00EFFFFF
	.long   0x00EFFFFF
	.long   0x00E00000
	.long   0x00E00000
	.long   0x00E00000
	.long   0x00E00000
	.long   0x00000000

	|| Cursor
	.long   0xCC000000
	.long   0xCEC00000
	.long   0xCEEC0000
	.long   0xCEEEC000
	.long   0xCEEEEC00
	.long   0xCEEECC00
	.long   0xCCCEC000
	.long   0x000CC000
tiles_end:
