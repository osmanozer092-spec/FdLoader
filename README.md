# FdLoader

Minimal ARM64 bare-metal chainloader for the Samsung Galaxy A04s (Exynos 850, S5E3830).
It shows a small menu on the screen to boot to binary image or reboot.

| Key    | Action                                        |
|--------|-----------------------------------------------|
| VOL +  | Copy the target binary to `0xA0000000` and jump to it |
| VOL -  | Reboot via PMU software reset                 |

The target binary is typically a UEFI firmware volume (e.g. `SILICIUM_UEFI.fd`) but can be any
flat binary whose size is a multiple of 8 bytes and which is position dependent on `0xA0000000`.

## Build

Requirements: `aarch64-linux-gnu-` binutils and gcc, a dtb file.

Build Command:

```
make TARGET=/path/to/SILICIUM_UEFI.fd DTB=/path/to/a13.dtb MKBOOTIMG=/path/to/mkbootimg.py
```

## Status

- [X] Tested on Galaxy A04s

Flashing a custom boot image can leave a device unbootable. Use at your own risk.
Note: Needs a unlocked bootloader.

## License

GPL-2.0-only. See `LICENSE`.

`src/font.h` is based on `lib/fonts/font_8x16.c` from the Linux kernel (GPL-2.0-only) and was taken
from the UniLoader project (GPL-2.0). Because it is part of this work, the whole project is distributed
under GPL-2.0-only.
