ENTRY(_start)

MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 16M
}

SECTIONS
{
  . = ORIGIN(RAM);

  .text : {
    *(.text.init)
    *(.text)
    *(.text.*)
  } > RAM

  .rodata : {
    *(.rodata)
    *(.rodata.*)
  } > RAM

  .data : {
    *(.data)
    *(.data.*)
    __global_pointer$ = . + 0x800;
  } > RAM

  .bss : {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    _end = .;
  } > RAM
}
