/*
 * seg7.h
 *
 *  Created on: 5 Jan 2025
 *      Author: jayFox
 *
 *
 *    Send 7 seg hex data out.
 *    7-bit numbers coded, special characters defined
 *    bit 8 is always dp-segment
 *
 */

#ifndef seg7_H_
#define seg7_H_

#include <stdint.h>
#include <stdbool.h>

#define SEG7_ID 0xDEADBEEF 	// IP defined ID number in VHDL-code
#define REG0_ID		0x0		// read address for ID
#define REG1_IN		0x4		// read and write address for Hex input data
#define REG2_OUT	0x8		// read address for 7Seg output data
#define REGMAX		0xA

#define SEG_X 0x10			// define special characters
#define SEG_O 0x11
#define SEG_4 0x12
#define SEG_A 0x13
#define SEG_B 0x14
#define SEG_C 0x15
#define SEG_D 0x16
#define SEG_E 0x17
#define SEG_F 0x18
#define SEG_G 0x19
#define SEG_HIGHO 0x23
#define SEG_LOWO 0x24

uint32_t seg7_init(uint32_t base);
uint8_t  seg7_senddata(uint8_t data);
uint8_t seg7_getdata(uint8_t reg_index, uint8_t *data);
uint32_t seg7_getreg(uint8_t reg_index);
uint32_t seg7_getbase();

#endif /* seg7_H_ */
