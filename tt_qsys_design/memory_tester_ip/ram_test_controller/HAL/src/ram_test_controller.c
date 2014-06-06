#include "ram_test_controller_regs.h"
#include "io.h"


// register write functions
void ram_test_controller_set_base_address (unsigned long csr_base, unsigned long long ram_base)
{
  IOWR_32DIRECT(csr_base, RAM_TEST_CONTROLLER_LOW_BASE_REG, ram_base & 0xFFFFFFFF);
  IOWR_32DIRECT(csr_base, RAM_TEST_CONTROLLER_HIGH_BASE_REG, (ram_base >> 32) & 0xFFFFFFFF);
}

int ram_test_controller_set_transfer_length (unsigned long csr_base, unsigned long length)
{
  int fail = 0;
  if (length <= 32)
  {
    length = 32;          // default block size in hardware is 32 so might as well fall back to this
    fail = 1;
  }
  IOWR_32DIRECT(csr_base, RAM_TEST_CONTROLLER_LENGTH_REG, length);
  return fail;  // returns 0 when a valid transfer length is passed in otherwise 1 will be returned
}

int ram_test_controller_set_block_size (unsigned long csr_base, unsigned long block_size)
{
  int fail = 0;
  if (block_size <= 32)
  {
    block_size = 32;      // default that the hardware uses
    fail = 1;
  }
  IOWR_16DIRECT(csr_base, (RAM_TEST_CONTROLLER_BLOCK_REG + RAM_TEST_CONTROLLER_BLOCK_SIZE_BYTE_OFFSET), block_size & 0x0000FFFF);
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_BLOCK_REG + RAM_TEST_CONTROLLER_BLOCK_SIZE_BYTE_OFFSET + 2), (block_size >> 16) & 0x000000FF);
  return fail;  // returns 0 when a valid block size is passed in otherwise 1 will be returned
}

int ram_test_controller_set_block_trail_distance (unsigned long csr_base, unsigned char trail_distance)
{
  int fail = 0;
  if (trail_distance == 0)
  {
    trail_distance = 1;    // default that the hardware uses
    fail = 1;
  }
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_BLOCK_REG + RAM_TEST_CONTROLLER_BLOCK_TRAIL_DISTANCE_BYTE_OFFSET), trail_distance);
  return fail;  // returns 0 when a valid trail distance is passed in otherwise 1 will be returned
}

void ram_test_controller_enable_concurrent_accesses (unsigned long csr_base)
{
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_BYTE_OFFSET), 1);
}

void ram_test_controller_disable_concurrent_accesses (unsigned long csr_base)
{
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_BYTE_OFFSET), 0);
}

void ram_test_controller_enable_start (unsigned long csr_base)
{
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_START_BYTE_OFFSET), 1);
}

void ram_test_controller_disable_start (unsigned long csr_base)
{
  IOWR_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_START_BYTE_OFFSET), 0);
}

int ram_test_controller_set_timer_resolution (unsigned long csr_base, unsigned short resolution)
{
  int fail = 0;
  if (resolution < 2)   // the resolution acts as a clock divider so it must be 2 or greater
  {
    resolution = 10;    // default that the hardware uses
    fail = 1;
  }
  IOWR_16DIRECT(csr_base, RAM_TEST_CONTROLLER_TIMER_RES_REG, resolution);
  return fail;  // returns 0 when a valid timer resolution is passed in otherwise 1 will be returned
}

void ram_test_controller_set_timer (unsigned long csr_base, unsigned long timer)  // use this to reset the timer by passing in timer = 0
{
  IOWR_32DIRECT(csr_base, RAM_TEST_CONTROLLER_TIMER_REG, timer);
}



// register read functions
unsigned long long ram_test_controller_read_base_address (unsigned long csr_base)
{
  unsigned long long base_address;
  base_address = IORD_32DIRECT(csr_base, RAM_TEST_CONTROLLER_LOW_BASE_REG);
  base_address = (base_address << 32) | IORD_32DIRECT(csr_base, RAM_TEST_CONTROLLER_HIGH_BASE_REG);
  return base_address;
}

unsigned long ram_test_controller_read_transfer_length (unsigned long csr_base)
{
  return IORD_32DIRECT(csr_base, RAM_TEST_CONTROLLER_LENGTH_REG);
}

unsigned long ram_test_controller_read_block_size (unsigned long csr_base)
{
  return (IORD_32DIRECT(csr_base, (RAM_TEST_CONTROLLER_BLOCK_REG + RAM_TEST_CONTROLLER_BLOCK_SIZE_BYTE_OFFSET)) & 0x00FFFFFF);
}

unsigned long ram_test_controller_read_block_trail_distance (unsigned long csr_base)
{
  return IORD_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_BLOCK_REG + RAM_TEST_CONTROLLER_BLOCK_TRAIL_DISTANCE_BYTE_OFFSET));
}

unsigned char ram_test_controller_read_concurrent_accesses (unsigned long csr_base)
{
  return (IORD_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_BYTE_OFFSET)) & 0x01);
}

unsigned char ram_test_controller_read_start (unsigned long csr_base)
{
  return (IORD_8DIRECT(csr_base, (RAM_TEST_CONTROLLER_CONTROL_REG + RAM_TEST_CONTROLLER_CONTROL_START_BYTE_OFFSET)) & 0x01);
}

unsigned short ram_test_controller_read_timer_resolution (unsigned long csr_base)
{
  return IORD_16DIRECT(csr_base, RAM_TEST_CONTROLLER_TIMER_RES_REG);
}

unsigned long ram_test_controller_read_timer (unsigned long csr_base) 
{
  return IORD_32DIRECT(csr_base, RAM_TEST_CONTROLLER_TIMER_REG);
}


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
