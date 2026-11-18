# images

Place the input files for the build in this directory using these exact names:

| File            | Description                                                                 |
|-----------------|-----------------------------------------------------------------------------|
| `images/kernel` | Binary loaded by FdLoader on VOL+ (e.g. a UEFI firmware volume such as `UEFI.fd`) |
| `images/dtb`    | Device tree blob packed into the boot image                                 |

Example:

```
cp /path/to/kernel images/kernel
cp /path/to/dtb images/dtb
make BOARD=a04s
```

Requirements for `images/kernel`:

- Built to run at `0xA0000000`
- Size is a multiple of 8 bytes

These files are ignored by git and must not be committed.
