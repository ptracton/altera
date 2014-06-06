#include "two_to_one_st_mux_regs.h"
#include "io.h"

int mux_input_select (unsigned long base, unsigned char select)
{
  int pass_or_fail = 0;
  if ((IORD_8DIRECT(base, (MUX_STATUS_REG + MUX_STATUS_PENDING_DATA_BYTE_OFFSET)) & (MUX_STATUS_PENDING_DATA_MASK >> MUX_STATUS_PENDING_DATA_BIT_OFFSET)) == 0)
  {
    IOWR_8DIRECT(base, (MUX_CONTROL_REG + MUX_CONTROL_INPUT_SELECT_BYTE_OFFSET), (select & MUX_CONTROL_INPUT_SELECT_MASK));
  }
  else  // there was pending data in the pipeline while attempting to switch the demux output resulting in a failure
  {
    pass_or_fail = -1;
  }
  return pass_or_fail;
}

void mux_clear_pipeline (unsigned long base)
{
  IOWR_8DIRECT(base, (MUX_CONTROL_REG + MUX_CONTROL_CLEAR_PIPELINE_BYTE_OFFSET), 1);
}

unsigned char mux_selected_output (unsigned long base)
{
  return (IORD_8DIRECT(base, (MUX_STATUS_REG + MUX_STATUS_SELECTED_INPUT_BYTE_OFFSET)) & MUX_STATUS_SELECTED_INPUT_MASK);
}

unsigned char mux_pending_data (unsigned long base)
{
  return (IORD_8DIRECT(base, (MUX_STATUS_REG + MUX_STATUS_PENDING_DATA_BYTE_OFFSET)) & (MUX_STATUS_PENDING_DATA_MASK >> MUX_STATUS_PENDING_DATA_BIT_OFFSET));
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
