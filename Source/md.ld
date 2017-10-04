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
  __copy_source = .;
  __copy_dest = ORIGIN(ram);
  .text :
  SUBALIGN(2)
  {
    __text_start = .;
    *(SORT_BY_ALIGNMENT(.text*))
    *(.gnu.linkonce.t.*)

    . = ALIGN(2);
    __INIT_SECTION__ = .;
    KEEP (*(.init))
    SHORT (0x4E75)	/* rts */
    . = ALIGN(2);
    __FINI_SECTION__ = .;
    KEEP (*(.fini))
    SHORT (0x4E75)	/* rts */

    *(.eh_frame_hdr)
    KEEP (*(.eh_frame))
    *(.gcc_except_table)
    KEEP (*(.jcr))

/*
    . = ALIGN(16);
    __CTOR_LIST__ = .;
    ___CTOR_LIST__ = .;
    LONG((__CTOR_END__ - __CTOR_LIST__) / 4 - 2)
    KEEP (*(SORT(.ctors.*)))
    KEEP (*(.ctors))
    LONG(0)
    __CTOR_END__ = .;

    . = ALIGN(16);
    __DTOR_LIST__ = .;
    ___DTOR_LIST__ = .;
    LONG((__DTOR_END__ - __DTOR_LIST__) / 4 - 2)
    KEEP (*(SORT(.dtors.*)))
    KEEP (*(.dtors))
    LONG(0)
    __DTOR_END__ = .;
*/

    *(SORT_BY_ALIGNMENT(.rdata) SORT_BY_ALIGNMENT(.rodata*))
    *(.gnu.linkonce.r.*)
    . = ALIGN(16);
    __text_end = .;
  } > ram AT> rom :text =0xFF
  __text_size = __text_end - __text_start;

  .data :
  {
    __data_start = .;
    *(SORT_BY_ALIGNMENT(.data*))
    *(.gnu.linkonce.d.*)
    CONSTRUCTORS

    *(.lit8)
    *(.lit4)
    *(SORT_BY_ALIGNMENT(.sdata*))
    *(.gnu.linkonce.s.*)
    . = ALIGN(16);
    __data_end = .;
  } > ram AT> rom :data =0xFF
  __data_size = __data_end - __data_start;
  __copy_size = __text_size + __data_size;
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
  } > ram AT> rom
  __bss_size = __bss_end - __bss_start;

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
