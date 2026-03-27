
/*
 *
 * SSD1306 Include file
 *
 * J.Vos 2026
 *
 *  Define Control set
 *  Define Memory mapped registers to SPI
 *
 *
 *  ABP interface Memory MApped : see sys_platform.h for base address ie SPI0_INST_BASE_ADDR 0x40008000
 *	Adress	 mapping	description
 *	00xx		00		IDREGISTER
 *	01xx		04		STATUS REGISTER
 *						[31:9]	xx
 *						[18] 	ABP Write error while full
 *						[17]	FIFO Write error bit
 *						[16]	FIFO FULL bit
 *						[15:3]	xx
 *						[2]		FIFO Read error bit
 *						[1]		FIFO EMPTY bit
 *						[1]		SPI READY bit
 *	10xx		08		CONTROL REGISTER - not used
 *	11xx		0C		DATA WRITE REGISTER
 *						[31:9]	xx
 *						[8] 	DC~
 *						[7:0]	DATAIN
 *
 */

#define SSD1306_DRIVER // UNMARK THIS TO USE THIS DRIVER INCL 1BPP FONT !!!
#ifdef SSD1306_DRIVER

#include <stdio.h> // for printf funtion
#include "utils.h" // for delay function

#ifndef SSD1306H_
#define SSD1306_H_

#define ID_REGISTER 		0x00		// offset ID 		read only
#define STATUS_REGISTER 	0x04		// offset Status 	read only
#define CONTROL_REGISTER 	0x08		// offset Control 	read / write
#define DATA_REGISTER 		0x0c		// offset Data 		read / write

#define STATUS_SPI_READY  0
#define STATUS_SPI_ERROR 17
#define STATUS_SPI_SEND  16

#define SSD1306_H 32 // height
#define SSD1306_W 128 // width
#define SSD1306_D 512 // full screen data = 128*32 / 8 = 512 bytes
#define SSD1306_BLACK 0   //< Draw 'off' pixels
#define SSD1306_WHITE 1   //< Draw 'on' pixels
#define SSD1306_INVERSE 2 //< Invert pixels

#define SSD1306_MEMORYMODE 0x20          //< See datasheet
#define SSD1306_COLUMNADDR 0x21          //< See datasheet
#define SSD1306_PAGEADDR 0x22            //< See datasheet
#define SSD1306_SETCONTRAST 0x81         //< See datasheet
#define SSD1306_CHARGEPUMP 0x8D          //< See datasheet
#define SSD1306_SEGREMAP 0xA0            //< See datasheet
#define SSD1306_DISPLAYALLON_RESUME 0xA4 //< See datasheet
#define SSD1306_DISPLAYALLON 0xA5        //< Not currently used
#define SSD1306_NORMALDISPLAY 0xA6       //< See datasheet
#define SSD1306_INVERTDISPLAY 0xA7       //< See datasheet
#define SSD1306_SETMULTIPLEX 0xA8        //< See datasheet
#define SSD1306_DISPLAYOFF 0xAE          //< See datasheet
#define SSD1306_DISPLAYON 0xAF           //< See datasheet
#define SSD1306_COMSCANINC 0xC0          //< Not currently used
#define SSD1306_COMSCANDEC 0xC8          //< See datasheet
#define SSD1306_PAGESTART 0xB0          //< See datasheet
#define SSD1306_SETDISPLAYCLKDIV 0xD5  //< See datasheet
#define SSD1306_SETDISPLAYOFFSET 0xD3    //< See datasheet

#define SSD1306_SETPRECHARGE 0xD9        //< See datasheet
#define SSD1306_SETCOMPINS 0xDA          //< See datasheet
#define SSD1306_SETVCOMDETECT 0xDB       //< See datasheet

#define SSD1306_SETLOWCOLUMN 0x00  //< Not currently used
#define SSD1306_SETHIGHCOLUMN 0x10 //< Not currently used
#define SSD1306_SETSTARTLINE 0x40  //< See datasheet

#define SSD1306_EXTERNALVCC 0x01  //< External display voltage source
#define SSD1306_SWITCHCAPVCC 0x02 //< Gen. display voltage from 3.3V

#define SSD1306_RIGHT_HORIZONTAL_SCROLL 0x26              //< Init rt scroll
#define SSD1306_LEFT_HORIZONTAL_SCROLL 0x27               //< Init left scroll
#define SSD1306_VERTICAL_AND_RIGHT_HORIZONTAL_SCROLL 0x29 //< Init diag scroll
#define SSD1306_VERTICAL_AND_LEFT_HORIZONTAL_SCROLL 0x2A  //< Init diag scroll
#define SSD1306_DEACTIVATE_SCROLL 0x2E                    //< Stop scroll
#define SSD1306_ACTIVATE_SCROLL 0x2F                      //< Start scroll
#define SSD1306_SET_VERTICAL_SCROLL_AREA 0xA3             //< Set scroll range

#define OLED_GRAPH_SIZE 6
#define OLED_ON_SIZE 2
#define OLED_OFF_SIZE 1
#define OLED_NORMAL_SIZE 1
#define OLED_INVERSE_SIZE 1

// SPI memory mapped routines
uint32_t readSPIMemory_ssd1306(uint8_t offset);
void writeSPIMemory_ssd1306(uint8_t offset,uint32_t data);

// SPI ssd1306 routines
void set_base_ssd1306(uint32_t address);
uint32_t get_base_ssd1306();
uint32_t get_id_ssd1306();

void  commandlist_ssd1306(const uint8_t* list,uint8_t size);
uint8_t command_ssd1306(uint8_t command);
uint8_t data_ssd1306(uint8_t data);
void oled_clear_ssd1306(uint8_t pattern);
void oled_lattice_ssd1306(uint8_t column,uint8_t page,uint8_t type); // custom routine
void oled_setblock_ssd1306(uint8_t column,uint8_t page,uint8_t width, uint8_t height);

// Graphics Array defs
#define LATTICE_HEIGHT 24 // 24 pixels = 3 pages
#define LATTICE_WIDTH 120 // 120 pixels = 120 columns
#define LATTICE_SIZE 360  // 120x24 / 8 = 360

// define  command arrays
extern  uint8_t oled_graph[6];
extern const uint8_t oled_init[26];
extern const uint8_t oled_on[2];
extern const uint8_t oled_off[1];
extern const uint8_t oled_normal[1];
extern const uint8_t oled_inverse[1];
extern const uint8_t lattice_logo[ LATTICE_SIZE];


#endif				/* SSD1306_H_ */
#endif 				/* SSD1306_DRIVER */
