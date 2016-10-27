OUTPUT_ARCH(z80)
OUTPUT_FORMAT(binary)
ENTRY (driver_start)
__DYNAMIC  =  0;

PHDRS
{
  headers PT_PHDR PHDRS FLAGS(4);
  text PT_LOAD FLAGS(7);
  data PT_LOAD FLAGS(6);
}

MEMORY
{
  ram (rx) : ORIGIN = 0x0000, LENGTH = 0x2000
}

PROVIDE (__stack = ORIGIN(ram) + LENGTH(ram));

SECTIONS
{
  .text 0x0000 :
  {
    *(.text*)
    *(.rodata*)
    *(.data*)
  } > ram AT> ram :text =0x00

  .bss (NOLOAD) :
  {
    *(.bss*)
  } > ram :data = 0x00

  /DISCARD/ (NOLOAD) :
  {
    *(*)
  }
}
