CROSS     ?= aarch64-linux-gnu-
PYTHON    ?= python3

TARGET    ?= images/kernel
DTB       ?= images/dtb
MKBOOTIMG ?= scripts/mkbootimg.py

BUILD     := build
CC        := $(CROSS)gcc
LD        := $(CROSS)ld
OBJCOPY   := $(CROSS)objcopy

CFLAGS    := -ffreestanding -nostdlib -mgeneral-regs-only -mstrict-align -Isrc

FD_SIZE    = $(shell stat -c %s "$(TARGET)")

.PHONY: all clean check help

all: $(BUILD)/FdLoader.img

help:
	@echo "make              build $(BUILD)/FdLoader.img"
	@echo "make clean        remove build output"
	@echo "variables: CROSS TARGET DTB MKBOOTIMG PYTHON"

check:
	@command -v $(CC) >/dev/null || { echo "missing $(CC)"; exit 1; }

$(TARGET) $(DTB) $(MKBOOTIMG):
	@echo "missing $@ (see images/README.md)"; exit 1

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/FdLoader.o: src/FdLoader.S $(TARGET) | check $(BUILD)
	$(CC) -c -DFD_SIZE=$(FD_SIZE) $< -o $@

$(BUILD)/FdLoader_c.o: src/FdLoader.c src/font.h | check $(BUILD)
	$(CC) -c $(CFLAGS) $< -o $@

$(BUILD)/FdLoader.elf: $(BUILD)/FdLoader.o $(BUILD)/FdLoader_c.o src/FdLoader.ld
	$(LD) -T src/FdLoader.ld $(BUILD)/FdLoader.o $(BUILD)/FdLoader_c.o -o $@

$(BUILD)/FdLoader.bin: $(BUILD)/FdLoader.elf
	$(OBJCOPY) -O binary $< $@

$(BUILD)/FdLoader.img: $(BUILD)/FdLoader.bin $(TARGET) $(DTB) scripts/build_kernel.py
	$(PYTHON) scripts/build_kernel.py \
		--loader $(BUILD)/FdLoader.bin \
		--target "$(TARGET)" \
		--dtb "$(DTB)" \
		--mkbootimg "$(MKBOOTIMG)" \
		--payload $(BUILD)/FdLoader-payload.bin \
		--output $@

clean:
	rm -f $(BUILD)/*.o $(BUILD)/*.elf $(BUILD)/*.bin $(BUILD)/*.img
