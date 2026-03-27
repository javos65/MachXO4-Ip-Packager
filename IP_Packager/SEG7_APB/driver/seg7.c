/*
 * seg7.c
 *
 *  Created on: 5 Jan 2025 / reviewed Oct 2025
 *      Author: jayfox
 *
 *     Driver code is independ from sys_platform.h definitions
 *     Initialize the pwm-driver with the right address, or let it search for the address
 *
 *     Check seg7.h for use details
 *
 */
#include <stdio.h>
#include "seg7.h"
#include "reg_access.h"

uint32_t G_seg7_base =0; // Global variable for base address of seg7
uint8_t G_dp_seg = 0x80;

// initialise base memory address to Global variable G_seg7_base
uint32_t seg7_init(uint32_t base)
{
	G_seg7_base = base;
	return(G_seg7_base);
}

// get Base address LocalMem Peripheral
uint32_t seg7_getbase()
{
	return(G_seg7_base);
}



//read from seg7 register : SEG0 = hex data SEG1 = SEG7-DATA, SEG2= ID
uint8_t seg7_getdata(uint8_t reg_index, uint8_t *data)
{
uint32_t reg,addr;
if(reg_index > REGMAX || G_seg7_base==0)
	{
	*data=0;
	return(0);
	}
else
	{
	addr = G_seg7_base + reg_index;
	reg_32b_read(addr,&reg ); 				// read register
	*data = (uint8_t) reg;     // lower 8 bits = data
	return(1);
	}
}

uint32_t seg7_getreg(uint8_t reg_index)
{
uint32_t reg,addr;
if(reg_index > REGMAX || G_seg7_base==0) return(0xFF);
else
	{
	addr = G_seg7_base + reg_index;
	reg_32b_read(addr,&reg ); 				// read register
	return( reg);
	}
}


//send data to hex input : lower 7 bits is data, bit 8 is always DP
uint8_t  seg7_senddata(uint8_t data)
{
uint32_t addr;
addr =G_seg7_base + REG1_IN;
if(G_seg7_base==0)
	{
	return(0);
	}
else
	{
	reg_32b_write(addr ,  (uint32_t) data);  	// set hex-in data
	return(1);
	}
}





