#ifndef __ONE_TO_TWO_ST_DEMUX_REGS_H__
#define __ONE_TO_TWO_ST_DEMUX_REGS_H__

// individual 32-bit registers with byte addressing
#define DEMUX_CONTROL_REG                             0x0    /*  w  */
#define DEMUX_STATUS_REG                              0x4    /*  r  */


// control registers
#define DEMUX_CONTROL_OUTPUT_SELECT_MASK              0x00000001
#define DEMUX_CONTROL_OUTPUT_SELECT_BYTE_OFFSET       0
#define DEMUX_CONTROL_OUTPUT_SELECT_BIT_OFFSET        0

#define DEMUX_CONTROL_CLEAR_PIPELINE_MASK             0x00000100
#define DEMUX_CONTROL_CLEAR_PIPELINE_BYTE_OFFSET      1
#define DEMUX_CONTROL_CLEAR_PIPELINE_BIT_OFFSET       8


// status registers
#define DEMUX_STATUS_SELECTED_OUTPUT_MASK             0x00000001
#define DEMUX_STATUS_SELECTED_OUTPUT_BYTE_OFFSET      0
#define DEMUX_STATUS_SELECTED_OUTPUT_BIT_OFFSET       0

#define DEMUX_STATUS_PENDING_DATA_MASK                0x00000100
#define DEMUX_STATUS_PENDING_DATA_BYTE_OFFSET         1
#define DEMUX_STATUS_PENDING_DATA_BIT_OFFSET          8


#endif /* __ONE_TO_TWO_ST_DEMUX_REGS_H__ */


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
