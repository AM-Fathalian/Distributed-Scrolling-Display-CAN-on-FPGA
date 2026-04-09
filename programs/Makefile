
TOOLCHAIN=/import/public/Linux/riscv/riscv-rv32imc/bin/
AS=/import/public/Linux/riscv/riscv-rv32imc/bin/riscv32-unknown-elf-as
LD=/import/public/Linux/riscv/riscv-rv32imc/bin/riscv32-unknown-elf-ld
OBJCOPY=/import/public/Linux/riscv/riscv-rv32imc/bin/riscv32-unknown-elf-objcopy
RM= rm -f
LINKERSCRIPT=platform.ld
FORMROM=python3 format_rom.py

SRCS= $(wildcard *.s)
# OBJS= $(SRCS:.prog=.ram)
# MAPS= $(SRCS:.prog=.map)
OBJS= $(SRCS:.s=.o)
LOBJS= $(SRCS:.s=.elf)
VTXT= $(SRCS:.s=.txt)
VROM= $(SRCS:.s=.rom)
BOOTSRCS= $(wildcard boot/*.s)
BOOTOBJS= $(BOOTSRCS:.s=.o)

all: $(VROM)

maps: $(LOBJS)

boot/%.o: boot/%.s
	$(AS) $< -o $@
	
%.o: %.s
	$(AS) $< -o $@

%.elf: %.o $(BOOTOBJS)
	$(LD) -o $@ -T $(LINKERSCRIPT) $^

%.txt: %.elf
	$(OBJCOPY) -O verilog $< $@

%.rom: %.txt
	$(FORMROM) $< $@

clean:
	$(RM) $(OBJS) $(LOBJS) $(VTXT) $(VROM)

.PHONY: all
