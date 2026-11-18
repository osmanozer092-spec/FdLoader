CROSS     ?= aarch64-linux-gnu-
PYTHON    ?= python3

TARGET    ?= images/kernel
DTB       ?= images/dtb
MKBOOTIMG ?= scripts/mkbootimg.py
BOARD     ?= a04s

BOARD_DIR := boards/$(BOARD)

ifeq ($(wildcard $(BOARD_DIR)/board.mk),)
$(error unknown BOARD '$(BOARD)', see boards/)
endif

include $(BOARD_DIR)/board.mk

BUILD     := build
CC        := $(CROSS)gcc
LD        := $(CROSS)ld
OBJCOPY   := $(CROSS)objcopy
ifeq ($(shell command -v $(CC)),)
$(error missing $(CC))
endif

CFLAGS    := -ffreestanding -nostdlib -mgeneral-regs-only -mstrict-align -Isrc -I$(BOARD_DIR)

FD_SIZE    = $(shell stat -c %s "$(TARGET)")

.PHONY: all clean help

all: $(BUILD)/FdLoader.img

help:
	@echo "make              build $(BUILD)/FdLoader.img"
	@echo "make clean        remove build output"
	@echo "variables: CROSS BOARD TARGET DTB MKBOOTIMG PYTHON"

$(TARGET) $(DTB) $(MKBOOTIMG):
	@echo "missing $@ (see images/README.md)"; exit 1

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/FdLoader.o: src/FdLoader.S $(BOARD_DIR)/board.h $(TARGET) | $(BUILD)
	$(CC) -c -I$(BOARD_DIR) -DFD_SIZE=$(FD_SIZE) $< -o $@

$(BUILD)/FdLoader_c.o: src/FdLoader.c src/font.h $(BOARD_DIR)/board.h | $(BUILD)
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
		--base $(BOOT_BASE) \
		--kernel-offset $(KERNEL_OFFSET) \
		--ramdisk-offset $(RAMDISK_OFFSET) \
		--tags-offset $(TAGS_OFFSET) \
		--header-version $(HEADER_VERSION) \
		--payload $(BUILD)/FdLoader-payload.bin \
		--output $@

clean:
	rm -f $(BUILD)/*.o $(BUILD)/*.elf $(BUILD)/*.bin $(BUILD)/*.img
