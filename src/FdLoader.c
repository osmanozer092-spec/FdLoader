#include "font.h"
#include <stdint.h>

#define FB_BASE       0xFA000000UL
#define FB_WIDTH      720
#define FB_HEIGHT     1600

#define PIN_BASE      0x11850000UL
#define VOL_UP_REG    (PIN_BASE + 0x04)
#define VOL_DOWN_REG  (PIN_BASE + 0x24)

#define PMU_SWRESET   (0x11860000UL + 0x3A00)

#define COLOR_WHITE   0xFFFFFFFF
#define COLOR_BLACK   0x00000000

static uint64_t rd_cnt(void)
{
    uint64_t v;
    __asm__ volatile("isb\n mrs %0, cntvct_el0" : "=r"(v) :: "memory");
    return v;
}

static uint64_t rd_frq(void)
{
    uint64_t v;
    __asm__ volatile("mrs %0, cntfrq_el0" : "=r"(v));
    return v;
}

static void wait_ms(uint32_t ms)
{
    uint64_t f = rd_frq();
    if (!f) f = 26000000ULL;
    uint64_t e = rd_cnt() + f * ms / 1000;
    while ((long long)(rd_cnt() - e) < 0) { }
}

static void busy_wait(uint32_t n)
{
    for (volatile uint32_t i = 0; i < n; i++);
}

static void fb_clear(void)
{
    volatile uint32_t *fb = (volatile uint32_t *)FB_BASE;
    for (int i = 0; i < FB_WIDTH * FB_HEIGHT; i++) {
        fb[i] = COLOR_BLACK;
    }
}

static void fb_pixel(int x, int y, uint32_t color)
{
    volatile uint32_t *fb = (volatile uint32_t *)FB_BASE;
    fb[y * FB_WIDTH + x] = color;
}

static void fb_draw_char(int x, int y, char c, uint32_t color, int scale)
{
    int idx = font_index(c);
    if (idx < 0 || idx >= 256) {
        idx = 0;
    }
    const uint8_t *glyph = letters[idx];
    for (int row = 0; row < 16; row++) {
        for (int col = 0; col < 8; col++) {
            if (!(glyph[row] & (1 << (7 - col)))) {
                continue;
            }
            for (int sy = 0; sy < scale; sy++) {
                for (int sx = 0; sx < scale; sx++) {
                    fb_pixel(x + col * scale + sx, y + row * scale + sy, color);
                }
            }
        }
    }
}

static void fb_draw_string(int x, int y, const char *str, uint32_t color, int scale)
{
    while (*str) {
        fb_draw_char(x, y, *str, color, scale);
        x += 8 * scale;
        str++;
    }
}

static int vol_up_pressed(void)
{
    volatile uint32_t *reg = (volatile uint32_t *)VOL_UP_REG;
    if ((*reg >> 7) & 1) {
        return 0;
    }
    busy_wait(100000);
    return !((*reg >> 7) & 1);
}

static int vol_down_pressed(void)
{
    volatile uint32_t *reg = (volatile uint32_t *)VOL_DOWN_REG;
    if (*reg & 1) {
        return 0;
    }
    busy_wait(100000);
    return !(*reg & 1);
}

static void reboot(void)
{
    fb_draw_string(50, 250, "Rebooting...", COLOR_WHITE, 2);
    wait_ms(1000);
    *(volatile uint32_t *)PMU_SWRESET = 0x2;
    while (1) { }
}

void main(void)
{
    fb_clear();

    fb_draw_string(50, 50, "Welcome to FdLoader!", COLOR_WHITE, 2);
    fb_draw_string(50, 110, "VOL+ to load UEFI", COLOR_WHITE, 2);
    fb_draw_string(50, 140, "VOL- to reboot", COLOR_WHITE, 2);

    while (1) {
        if (vol_up_pressed()) {
            fb_draw_string(50, 170, "Loading UEFI...", COLOR_WHITE, 2);
            return;
        }
        if (vol_down_pressed()) {
            reboot();
        }
        busy_wait(10000);
    }
}
