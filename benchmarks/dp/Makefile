TOOLCHAIN := gcc

# Paths
RISCV_PREFIX = riscv64-unknown-elf
GCC_TOOLCHAIN = /opt/homebrew

# GCC toolchain settings
CC = $(GCC_TOOLCHAIN)/bin/$(RISCV_PREFIX)-gcc
OBJDUMP = $(GCC_TOOLCHAIN)/bin/$(RISCV_PREFIX)-objdump
SIZE = $(GCC_TOOLCHAIN)/bin/$(RISCV_PREFIX)-size
CFLAGS = -O0 -march=rv32imac -mabi=ilp32 -Wall
LDFLAGS = -march=rv32imac -specs=semihost.specs -mabi=ilp32 -T link.ld

# Sources
DRIVER = dp_main.c
DATA = data.S

SCALAR_SRC = dp_scalar.c
VLIW_SRC = dp_vliw_better.S
EMPTY_SRC = dp_empty.c

SCALAR_ELF = dp_scalar.elf
VLIW_ELF = dp_vliw.elf
EMPTY_ELF = dp_empty.elf

.PHONY: all scalar vliw dump clean

all: scalar vliw

scalar: $(SCALAR_ELF)
vliw:  $(VLIW_ELF)
empty: $(EMPTY_ELF)

$(SCALAR_ELF): $(DRIVER) $(SCALAR_SRC) $(DATA)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

$(VLIW_ELF): $(DRIVER) $(VLIW_SRC) $(DATA)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

$(EMPTY_ELF): $(DRIVER) $(EMPTY_SRC) $(DATA)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(SIZE) $@

dump:
	$(OBJDUMP) -D $(SCALAR_ELF) > $(SCALAR_ELF).dump
	$(OBJDUMP) -D $(VLIW_ELF)   > $(VLIW_ELF).dump

clean:
	rm -f *.o *.elf *.bin *.hex *.dump