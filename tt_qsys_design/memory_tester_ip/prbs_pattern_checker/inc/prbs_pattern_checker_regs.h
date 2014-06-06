#ifndef __PRBS_PATTERN_CHECKER_REGS_H__
#define __PRBS_PATTERN_CHECKER_REGS_H__


// individual 32-bit registers with byte addressing
#define PRBS_CHECKER_PAYLOAD_LENGTH_REG   					                0x0    /*    r/w    */
#define PRBS_CHECKER_CONTROL_REG                                    0x8    /*    r/w    */
#define PRBS_CHECKER_STATUS_REG                                     0xC    /*   r/clr   */
#define PRBS_CHECKER_POLYNOMIAL_31_0_REG                            0x10   /*    r/w    */
#define PRBS_CHECKER_POLYNOMIAL_63_32_REG                           0x14   /*    r/w    */
#define PRBS_CHECKER_POLYNOMIAL_95_64_REG                           0x18   /*    r/w    */
#define PRBS_CHECKER_POLYNOMIAL_127_96_REG                          0x1C   /*    r/w    */

// payload register
#define PRBS_CHECKER_PAYLOAD_LENGTH_MASK                            0xFFFFFFFF
#define PRBS_CHECKER_PAYLOAD_LENGTH_BYTE_OFFSET                     0
#define PRBS_CHECKER_PAYLOAD_LENGTH_BIT_OFFSET                      0


// control register
#define PRBS_CHECKER_INFINITE_PAYLOAD_LENGTH_ENABLE_MASK            0x00000001
#define PRBS_CHECKER_INFINITE_PAYLOAD_LENGTH_ENABLE_BYTE_OFFSET     0
#define PRBS_CHECKER_INFINITE_PAYLOAD_LENGTH_ENABLE_BIT_OFFSET      0

#define PRBS_CHECKER_STOP_ON_FAIL_MASK                              0x00000100
#define PRBS_CHECKER_STOP_ON_FAIL_BYTE_OFFSET                       1
#define PRBS_CHECKER_STOP_ON_FAIL_BIT_OFFSET                        8

#define PRBS_CHECKER_SEED_MASK                                      0x00010000
#define PRBS_CHECKER_SEED_BYTE_OFFSET                               2
#define PRBS_CHECKER_SEED_BIT_OFFSET                                16

#define PRBS_CHECKER_RUN_MASK                                       0x01000000
#define PRBS_CHECKER_RUN_BYTE_OFFSET                                3
#define PRBS_CHECKER_RUN_BIT_OFFSET                                 24


// status register
#define PRBS_CHECKER_FAILURE_DETECTED_MASK                          0x00000001
#define PRBS_CHECKER_FAILURE_DETECTED_BYTE_OFFSET                   0
#define PRBS_CHECKER_FAILURE_DETECTED_BIT_OFFSET                    0


// polynomial registers
#define PRBS_CHECKER_POLYNOMIAL_31_0_MASK                           0xFFFFFFFF
#define PRBS_CHECKER_POLYNOMIAL_31_0_BYTE_OFFSET                    0
#define PRBS_CHECKER_POLYNOMIAL_31_0_BIT_OFFSET                     0

#define PRBS_CHECKER_POLYNOMIAL_63_32_MASK                          0xFFFFFFFF
#define PRBS_CHECKER_POLYNOMIAL_63_32_BYTE_OFFSET                   0
#define PRBS_CHECKER_POLYNOMIAL_63_32_BIT_OFFSET                    0

#define PRBS_CHECKER_POLYNOMIAL_95_64_MASK                          0xFFFFFFFF
#define PRBS_CHECKER_POLYNOMIAL_95_64_BYTE_OFFSET                   0
#define PRBS_CHECKER_POLYNOMIAL_95_64_BIT_OFFSET                    0

#define PRBS_CHECKER_POLYNOMIAL_127_96_MASK                         0xFFFFFFFF
#define PRBS_CHECKER_POLYNOMIAL_127_96_BYTE_OFFSET                  0
#define PRBS_CHECKER_POLYNOMIAL_127_96_BIT_OFFSET                   0


#endif /* __PRBS_PATTERN_CHECKER_REGS_H__ */


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
