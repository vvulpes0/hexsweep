OUTPUT_ARCH(m68k)
OUTPUT_FORMAT(binary)
EXTERN (_start)
ENTRY (_start)
__DYNAMIC  =  0;

/*
 * The memory map look like this:
 * +--------------------+ <- 0x00000000
 * | .text              |
 * |                    |
 * |          _text_end |
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * +--------------------+ <- 0x00FF0000
 * | Copy of .text      |
 * |  ROM copy not used |
 * +--------------------+
 * | .data              | initialized data goes here
 * |                    |
 * |          _data_end |
 * +--------------------+
 * | .bss               |
 * |         _bss_start | start of bss, cleared by crt0
 * |                    |
 * |          _bss__end | start of heap, used by sbrk()
 * +--------------------+
 * .                    .
 * .                    .
 * .                    .
 * |             _stack | top of stack
 * +--------------------+ <- 0x01000000
 */

PHDRS
{
  headers PT_PHDR PHDRS FLAGS(4);
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}

MEMORY
{
  rom (rx) : ORIGIN = 0x00000000, LENGTH = 0x00400000
  ram (wx) : ORIGIN = 0x00FF0000, LENGTH = 0x00010000
}

/*
 * Allocate the stack to be at the top of memory, since the stack
 * grows down
 */

PROVIDE (__stack = ORIGIN(ram) + LENGTH(ram));
PROVIDE(SIZE = LENGTH(rom));
ASSERT(SIZE <= LENGTH(rom), "Error: requested object too large");

SECTIONS
{
  . = 0x00000000;
  .header :
  SUBALIGN(2)
  {
    KEEP(rom-header.o(.rodata))
  } > rom AT> rom :text =0x20

  .startup :
  SUBALIGN(2)
  {
    KEEP(crt0.o(.text))
  } > rom AT> rom :text =0xff

  .text :
  SUBALIGN(2)
  {
    __text_start = .;
    *(SORT_BY_ALIGNMENT(.text*))
    *(.gnu.linkonce.t.*)

    __INIT_SECTION__ = .;
    KEEP (*(.init))
    SHORT (0x4E75)	/* rts */
    __FINI_SECTION__ = .;
    KEEP (*(.fini))
    SHORT (0x4E75)	/* rts */

    *(.eh_frame_hdr)
    KEEP (*(.eh_frame))
    *(.gcc_except_table)
    KEEP (*(.jcr))

    /* . = ALIGN(16); */
    /* __CTOR_LIST__ = .; */
    /* ___CTOR_LIST__ = .; */
    /* LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2) */
    /* KEEP (*(SORT(.ctors.*))) */
    /* KEEP (*(.ctors)) */
    /* LONG(0) */
    /* __CTOR_END__ = .; */

    /* . = ALIGN(16); */
    /* __DTOR_LIST__ = .; */
    /* ___DTOR_LIST__ = .; */
    /* LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2) */
    /* KEEP (*(SORT(.dtors.*))) */
    /* KEEP (*(.dtors)) */
    /* LONG(0) */
    /* __DTOR_END__ = .; */
  } > ram AT> rom :text =0xFF

  .rodata :
  {
    *(SORT_BY_ALIGNMENT(.rdata) SORT_BY_ALIGNMENT(.rodata*))
    *(.gnu.linkonce.r.*)
    __text_end = .;
    __text_size = __text_end - __text_start;
  } > ram AT> rom :text =0xFF

  .data :
  ALIGN(4)
  SUBALIGN(2)
  {
    /* (BUG -- mine or the toolchain's?)        */
    /* With GCC 7.2.0 and Binutils 2.29.1, the  */
    /* preceding ALIGN expression prevents a    */
    /* strange failure where data is improperly */
    /* read.  I don't think misaligned accesses */
    /* are at fault, though, because the m68k   */
    /* only requires word-alignment, but values */
    /* other than multiples of 4 do not work.   */
    __data_start = .;
    *(SORT_BY_ALIGNMENT(.data*))
    *(.gnu.linkonce.d.*)
    CONSTRUCTORS

    *(.lit8)
    *(.lit4)
    *(SORT_BY_ALIGNMENT(.sdata*))
    *(.gnu.linkonce.s.*)
    __data_end = .;
    __data_size = __data_end - __data_start;
  } > ram AT> rom :data =0xFF

  .empty (NOLOAD) :
  {
    __copy_source = LOADADDR(.text);
    __copy_size = ABSOLUTE(.) - __copy_source;
    __copy_dest = ORIGIN(ram);
  } > rom AT> rom :data =0xFF

  .bss (NOLOAD) :
  {
    __bss_start = .;
    *(.bss*)
    *(.gnu.linkonce.b.*)
    *(.sbss*)
    *(.gnu.linkonce.sb.*)
    *(.scommon)
    *(COMMON)
    end = .;
    _end = ALIGN (8);
    __end = _end;
    __bss_end = .;
    __bss_size = __bss_end - __bss_start;
  } > ram AT> rom

  .fill :
  {
    ASSERT(ABSOLUTE(.) < SIZE, "Error: capacity exceeded.  Try changing KILOBIT in the Makefile.");
    . = MAX(ABSOLUTE(.), ORIGIN(rom) + SIZE - 1);
    BYTE(0xFF);
  } > rom AT> rom :text =0xFF

  /DISCARD/ (NOLOAD) :
  {
    *(*)
  }
}
