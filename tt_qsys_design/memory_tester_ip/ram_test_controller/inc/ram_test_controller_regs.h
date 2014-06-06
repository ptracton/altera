#ifndef __RAM_TEST_CONTROLLER_REGS_H__
#define __RAM_TEST_CONTROLLER_REGS_H__


// individual 32-bit registers with byte address
#define RAM_TEST_CONTROLLER_LOW_BASE_REG                              0x0     /* r/w */
#define RAM_TEST_CONTROLLER_HIGH_BASE_REG                             0x4     /* r/w */
#define RAM_TEST_CONTROLLER_LENGTH_REG                                0x8     /* r/w */
#define RAM_TEST_CONTROLLER_BLOCK_REG                                 0xC     /* r/w */
#define RAM_TEST_CONTROLLER_CONTROL_REG                               0x10    /* r/w */
#define RAM_TEST_CONTROLLER_TIMER_RES_REG                             0x18    /* r/w */
#define RAM_TEST_CONTROLLER_TIMER_REG                                 0x1C    /* r/w */



// block registers
#define RAM_TEST_CONTROLLER_BLOCK_SIZE_MASK                           0x00FFFFFF
#define RAM_TEST_CONTROLLER_BLOCK_SIZE_BYTE_OFFSET                    0
#define RAM_TEST_CONTROLLER_BLOCK_SIZE_BIT_OFFSET                     0

#define RAM_TEST_CONTROLLER_BLOCK_TRAIL_DISTANCE_MASK                 0xFF000000
#define RAM_TEST_CONTROLLER_BLOCK_TRAIL_DISTANCE_BYTE_OFFSET          3
#define RAM_TEST_CONTROLLER_BLOCK_TRAIL_DISTANCE_BIT_OFFSET           24


// control registers
#define RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_MASK            0x00000001
#define RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_BYTE_OFFSET     0
#define RAM_TEST_CONTROLLER_CONTROL_CONCURRENT_ACCESS_BIT_OFFSET      0

#define RAM_TEST_CONTROLLER_CONTROL_START                             0x01000000
#define RAM_TEST_CONTROLLER_CONTROL_START_BYTE_OFFSET                 3
#define RAM_TEST_CONTROLLER_CONTROL_START_BIT_OFFSET                  24


#endif /* __RAM_TEST_CONTROLLER_REGS_H__ */


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
