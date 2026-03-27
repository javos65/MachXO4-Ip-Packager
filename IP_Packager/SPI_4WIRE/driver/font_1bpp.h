/*
 * Font library, see https://lvgl.io/tools/font_conv_v5_3
 *
 * J.Vos 2026
 *
 * 1bpp  font 1 pixel per bit, 1 pixels  = 8 byte
 * font is column oriented for SSD1306 Page
 * font width is fixed
 *
*/

#include "ssd1306.h" // needed for spi graphic routines

#ifdef SSD1306_DRIVER


#ifndef LVGL_FONT
#define LVGL_FONT

#include <stdio.h>

#define FIXEDFONT_WIDTH 6 // 6 bits wide
#define FIXEDFONT_HEIGHT 1 // 8 bits = 1 byte

#define TEXT_NORMAL		1
#define TEXT_INVERSE 	0

typedef struct {
  const uint8_t *fontmap;  // Glyph bitmaps, concatenated
  const uint16_t *fontindex;  //< Glyph bitmaps index
  uint16_t first;   ///< ASCII extents (first char)
  uint16_t last;    ///< ASCII extents (last char)
  uint8_t bpp;
  uint8_t height;
  char name[20];        // name in Text
  char table[20];       // table name required for font conversion
} font1bpp;

extern font1bpp fixed8x6;
extern const uint8_t fixedfont_table[96][FIXEDFONT_WIDTH];

void draw_text_ssd1306( const char *text, font1bpp myfont, uint8_t col, uint8_t page,uint16_t color1);
void draw_font_ssd1306(uint8_t *pSrc, uint8_t col, uint8_t page,uint8_t xSize, uint8_t ySize,uint16_t color);


#endif //LVGL_FONT

#endif
