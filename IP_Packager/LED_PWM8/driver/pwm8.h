/*
 * pwm8.h
 *
 *  Created on: 5 Jan 2025
 *      Author: jayFox
 *
 *    Send 8 x 4-bit pwm to IO output - always running pwm
 *
 *	  Adress 0 = APB base + 0x00000000 : ID
 *    Adress 1 = APB base + 0x00000004 : PWM
 */

#ifndef pwm8_H_
#define pwm8_H_

#include <stdint.h>
#include <stdbool.h>

#define pwm8_ID 0xDEADB00B 	// IP defined ID number in VHDL-code
#define REG0_PWM_ID			0x00		// 32 bit address 0 index : Read address for ID
#define REG1_PWM_IN			0x04		// 32 bit address 1 index : Read/ Write PWM inputs
#define REGPWMMAX			0x04

uint32_t pwm8_init(uint32_t base);
uint32_t pwm8_getbase();

uint32_t pwm8_getreg(uint8_t reg_index);
uint8_t pwm8_setreg(uint8_t reg_index,uint32_t data);

uint8_t  pwm8_setpwm(uint32_t data);
uint32_t pwm8_getpwm();

#endif /* pwm8_H_ */
