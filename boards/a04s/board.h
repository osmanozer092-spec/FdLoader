#ifndef BOARD_H
#define BOARD_H

#define BOARD_FB_BASE            0xFA000000
#define BOARD_FB_WIDTH           720
#define BOARD_FB_HEIGHT          1600

#define BOARD_VOL_UP_REG         0x11850004
#define BOARD_VOL_UP_BIT         7
#define BOARD_VOL_DOWN_REG       0x11850024
#define BOARD_VOL_DOWN_BIT       0

#define BOARD_PMU_SWRESET_REG    0x11863A00
#define BOARD_PMU_SWRESET_VAL    0x2

#define BOARD_TARGET_ADDR        0xA0000000

#endif
