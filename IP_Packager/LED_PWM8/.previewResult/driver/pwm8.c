/*
 * pwm8.c
 *
 *  Created on: 5 Jan 2025 / reviewed Mar 2026
 *      Author: jayfox
 *
 *     Driver code is independ from sys_platform.h definitions
 *     Initialize the pwm-driver with the right address, or let it search for the address
 *
 *     Check pwm8 for use details
 *
 */
#include <stdio.h>
#include "pwm8.h"
#include "reg_access.h"

uint32_t G_pwm8_base =0; // Global variable for base address of pwm8

// initialise base memory address to Global variable G_pwm8_base
uint32_t pwm8_init(uint32_t base)
{
	G_pwm8_base = base;
	return(G_pwm8_base);
}

// get Base address LocalMem Peripheral
uint32_t pwm8_getbase()
{
	return(G_pwm8_base);
}


uint32_t pwm8_getreg(uint8_t reg_index)
{
uint32_t reg,addr;
if(reg_index > REGPWMMAX || G_pwm8_base==0) return(0);
else
	{
	addr = G_pwm8_base + reg_index;
	reg_32b_read(addr,&reg ); 				// read register
	return(reg);
	}
}

uint8_t pwm8_setreg(uint8_t reg_index,uint32_t data)
{
uint32_t addr;
if(reg_index > REGPWMMAX || G_pwm8_base==0) return(0);
else
	{
	addr = G_pwm8_base + reg_index;
	reg_32b_write(addr,data ); 				// read register
	return(1);
	}
}

//send 32 bit PWM data to PWM register
uint8_t  pwm8_setpwm(uint32_t data)
{
uint32_t addr;
addr =G_pwm8_base + REG1_PWM_IN;
if(G_pwm8_base==0) return(0);
else
	{
	reg_32b_write(addr ,  (uint32_t) data);  	// set hex-in data
	return(1);
	}
}

//get the 32bit PWM regiater data - no error checking
uint32_t  pwm8_getpwm()
{
uint32_t addr,reg;
addr =G_pwm8_base + REG1_PWM_IN;
if(G_pwm8_base==0) return(0);
else
	{
	reg_32b_read(addr,&reg ); 				// read register
	return(reg);
	}
}




