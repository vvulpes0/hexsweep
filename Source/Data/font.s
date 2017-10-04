	.section .rodata, "a"
	.align 2

	.macro index sym
	.if (\sym != 0)
	.byte   ((\sym - characters) / 32) + 32
	.else
	.byte 0
	.endif
	.endm

	.equ    space, 0

	.global font
font:
	.long   compressed_font

	.global font_huffman_table
font_huffman_table:
	.long   font_huffman_table_data

	.global font_words
font_words:
	.long   ((font_end - characters) / 2)

	.global charmap
charmap:
	.long   charmap_data
charmap_data:
	|| 0x20-0x2F
	index   space           | space
	index   exclam          | !
	index   quote           | "
	index   space           | #
	index   space           | $
	index   space           | %
	index   space           | &
	index   apostrophe      | '
	index   space           | (
	index   space           | )
	index   bullet          | *
	index   space           | +
	index   comma           | ,
	index   hyphen          | -
	index   period          | .
	index   slash           | /
	|| 0x30-0x3F
	index   digit_0         | 0
	index   digit_1         | 1
	index   digit_2         | 2
	index   digit_3         | 3
	index   digit_4         | 4
	index   digit_5         | 5
	index   digit_6         | 6
	index   digit_7         | 7
	index   digit_8         | 8
	index   digit_9         | 9
	index   colon           | :
	index   space           | ;
	index   space           | <
	index   space           | =
	index   space           | >
	index   question        | ?
	|| 0x40-0x4F
	index   space           | @
	index   a               | A
	index   b               | B
	index   c               | C
	index   d               | D
	index   e               | E
	index   f               | F
	index   g               | G
	index   h               | H
	index   i               | I
	index   j               | J
	index   k               | K
	index   l               | L
	index   m               | M
	index   n               | N
	index   o               | O
	|| 0x50-0x5F
	index   p               | P
	index   q               | Q
	index   r               | R
	index   s               | S
	index   t               | T
	index   u               | U
	index   v               | V
	index   w               | W
	index   x               | X
	index   y               | Y
	index   z               | Z
	index   space           | [
	index   space           | \\
	index   space           | ]
	index   space           | ^
	index   space           | _
	|| 0x60-0x6F
	index   space           | `
	index   a               | a
	index   b               | b
	index   c               | c
	index   d               | d
	index   e               | e
	index   f               | f
	index   g               | g
	index   h               | h
	index   i               | i
	index   j               | j
	index   k               | k
	index   l               | l
	index   m               | m
	index   n               | n
	index   o               | o
	|| 0x70-0x7F
	index   p               | p
	index   q               | q
	index   r               | r
	index   s               | s
	index   t               | t
	index   u               | u
	index   v               | v
	index   w               | w
	index   x               | x
	index   y               | y
	index   z               | z
	index   space           | {
	index   space           | |
	index   space           | }
	index   space           | ~
	index   space           | DEL

	.section .compressible
characters:
a:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFFFFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
b:
	.long   0xCCCCCCC0
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFFFFCC
	.long   0xCCCCCCC0
c:
	.long   0x0CCCCCCC
	.long   0xCCFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFCCCCC
	.long   0xCCFFFFFC
	.long   0x0CCCCCCC
d:
	.long   0xCCCCCCC0
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFFFFCC
	.long   0xCCCCCCC0
e:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFFFC00
	.long   0xCFFCCC00
	.long   0xCFFCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
f:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFFFC00
	.long   0xCFFCCC00
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
g:
	.long   0x0CCCCCCC
	.long   0xCCFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFCFFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFFC
	.long   0x0CCCCCC0
h:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFFFFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
i:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCFFCCC
	.long   0x00CFFC00
	.long   0x00CFFC00
	.long   0xCCCFFCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
j:
	.long   0x0CCCCCCC
	.long   0x0CFFFFFC
	.long   0x0CCCCFFC
	.long   0x0000CFFC
	.long   0xCCCCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
k:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCFFCC
	.long   0xCFFFFCC0
	.long   0xCFFCFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
l:
	.long   0xCCCC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
m:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFFFFFC
	.long   0xCFFFFFFC
	.long   0xCFFFFFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
n:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFFCFFC
	.long   0xCFFFFFFC
	.long   0xCFFCFFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
o:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
p:
	.long   0xCCCCCCC0
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFFFFCC
	.long   0xCFFCCCC0
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
q:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCFFFC
	.long   0xCFFCFFFC
	.long   0xCCFFFFFC
	.long   0x0CCCCCCC
r:
	.long   0xCCCCCCC0
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
s:
	.long   0x0CCCCCC0
	.long   0xCCFFFFC0
	.long   0xCFFCCCC0
	.long   0xCCFFFFCC
	.long   0xCCCCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
t:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCFFCCC
	.long   0x00CFFC00
	.long   0x00CFFC00
	.long   0x00CFFC00
	.long   0x00CFFC00
	.long   0x00CCCC00
u:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
v:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCFFCC0
	.long   0x00CCCC00
w:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFFFFFC
	.long   0xCFFFFFFC
	.long   0xCFFFFFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
x:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0xCCFCCFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
y:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCFFCC0
	.long   0x00CFFC00
	.long   0x00CFFC00
	.long   0x00CCCC00
z:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCFFCC
	.long   0x0CCFFCC0
	.long   0xCCFFCC00
	.long   0xCFFCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
digit_0:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCFFFC
	.long   0xCFFCFFFC
	.long   0xCFFFCFFC
	.long   0xCFFFCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
digit_1:
	.long   0x00CCCC00
	.long   0x0CCFFC00
	.long   0x0CFFFC00
	.long   0x0CCFFC00
	.long   0x00CFFC00
	.long   0xCCCFFCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
digit_2:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCCCCCFFC
	.long   0x0CCCFFCC
	.long   0xCCFFCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
digit_3:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCCCCFFCC
	.long   0xCCCCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
digit_4:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCFFFFFFC
	.long   0xCCCCCFFC
	.long   0x0000CFFC
	.long   0x0000CFFC
	.long   0x0000CCCC
digit_5:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFFFFCC
	.long   0xCCCCCFFC
	.long   0xCCCCCFFC
	.long   0xCFFFFFCC
	.long   0xCCCCCCC0
digit_6:
	.long   0x0CCCCCCC
	.long   0xCCFFFFFC
	.long   0xCFFCCCCC
	.long   0xCFFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
digit_7:
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCFFC
	.long   0x000CFFCC
	.long   0x00CCFFC0
	.long   0x00CFFCC0
	.long   0x00CFFC00
	.long   0x00CCCC00
digit_8:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
digit_9:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCCFFFFFC
	.long   0xCCCCCFFC
	.long   0xCFFCCFFC
	.long   0xCCFFFFCC
	.long   0x0CCCCCC0
period:
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0x0CC00000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0x0CC00000
comma:
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0x000CC000
	.long   0x00CFFC00
	.long   0x000CFC00
	.long   0x000CC000
question:
	.long   0x0CCCCCC0
	.long   0xCCFFFFCC
	.long   0xCFFCCFFC
	.long   0xCCCCFFCC
	.long   0x00CFFCC0
	.long   0x00CCCC00
	.long   0x00CFFC00
	.long   0x00CCCC00
exclam:
	.long   0xCCCC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
quote:
	.long   0xCCCCCCCC
	.long   0xCFFCCFFC
	.long   0xCFFCCFFC
	.long   0xCCCCCCCC
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
apostrophe:
	.long   0x00CCCC00
	.long   0x00CFFC00
	.long   0x00CCFC00
	.long   0x000CFC00
	.long   0x000CCC00
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
colon:
	.long   0x00000000
	.long   0xCCCC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
	.long   0xCFFC0000
	.long   0xCFFC0000
	.long   0xCCCC0000
hyphen:
	.long   0x00000000
	.long   0x00000000
	.long   0x00000000
	.long   0xCCCCCCCC
	.long   0xCFFFFFFC
	.long   0xCCCCCCCC
	.long   0x00000000
	.long   0x00000000
bullet:
	.long   0x00000000
	.long   0x000FF000
	.long   0x00FCCF00
	.long   0x0FCCCCF0
	.long   0x0FCCCCF0
	.long   0x00FCCF00
	.long   0x000FF000
	.long   0x00000000
slash:
	.long   0x000000CC
	.long   0x00000CFC
	.long   0x0000CFC0
	.long   0x000CFC00
	.long   0x00CFC000
	.long   0x0CFC0000
	.long   0xCFC00000
	.long   0xCC000000
font_end:
