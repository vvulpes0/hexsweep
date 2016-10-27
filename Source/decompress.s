	.text
	.global load_tiles
	|| Input: Word *          address (of compressed data)
	||        Byte *          address (of decompression table)
	||        unsigned int    num_words (of decompressed data)
	||        unsigned short  base_tile
load_tiles:
	move.l  16(%sp), %d0            | base_tile
	lsl.w   #5, %d0                 |  * 32 bytes
	move.l  %d0, -(%sp)
	bsr     VRAM_write
	addq    #4, %sp
	movea.l 4(%sp), %a0             | address
	move.l  12(%sp), %d0            | num_words
	subq    #1, %d0                 |  less one for looping
	movem.l %d2-%d5/%a2, -(%sp)
	moveq   #0, %d5
	move.l  28(%sp), %a2            | decompression table
	bsr.s   get_data
1:	moveq   #1, %d1                 | inner loop, bytes to write
2:	movea.l %a2, %a1                | go back to beginning of table
3:	btst.l  %d2, %d3                | check bit
	bne.s   go_right                | if set, go right
	addq    #1, %a1                 |  else go left
4:	subq    #1, %d2                 | move on to next bit
	bpl.s   5f
	bsr.s   get_data                |  if out, read more compressed data
5:	tst.b   (%a1)                   | if we're at a node
	bne.s   3b                      |  repeat.  Not done yet
	addq    #1, %a1                 | else shift data into %d4
	lsl.w   #8, %d4
	move.b  (%a1), %d4
	dbra    %d1, 2b                 | and loop back for the next byte
	move.w  %d4, (0xC00000).l       | here we have a word.  write it
	dbra    %d0, 1b                 | and loop back for the next word
	movem.l (%sp)+, %d2-%d5/%a2
	rts

go_right:
	move.b  (%a1)+, %d5             | Node label is offset to right child
	adda.l  %d5, %a1
	bra.s   4b

get_data:
	moveq   #31, %d2                | reset shift count
	move.l  (%a0)+, %d3             | grab 32 bits of data
	rts
