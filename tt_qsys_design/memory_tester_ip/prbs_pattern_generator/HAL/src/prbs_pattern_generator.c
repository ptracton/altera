#include "prbs_pattern_generator_regs.h"
#include "io.h"


// register write functions
void prbs_generator_set_payload_length (unsigned long base, unsigned long length)
{
  IOWR_32DIRECT(base, PRBS_GENERATOR_PAYLOAD_LENGTH_REG, length);
}

void prbs_generator_enable_infinite_payload_length (unsigned long base)
{
  IOWR_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_INFINITE_PAYLOAD_LENGTH_ENABLE_BYTE_OFFSET), 1);
}

void prbs_generator_disable_infinite_payload_length (unsigned long base)
{
  IOWR_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_INFINITE_PAYLOAD_LENGTH_ENABLE_BYTE_OFFSET), 0);
}

void prbs_generator_seed_enable (unsigned long base)
{
  IOWR_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_SEED_BYTE_OFFSET), 1);
}

void prbs_generator_enable_start (unsigned long base)
{
  IOWR_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_RUN_BYTE_OFFSET), 1);
}

void prbs_generator_disable_start (unsigned long base)
{
  IOWR_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_RUN_BYTE_OFFSET), 0);
}

void prbs_generator_set_polynomial (unsigned long base, unsigned char *polynomial, long polynomial_length)
{
  long i;
  
  for (i = 0; i < polynomial_length; i++)
  {
    IOWR_8DIRECT(base, (PRBS_GENERATOR_POLYNOMIAL_31_0_REG + i), polynomial[i]);
  }
  
  for (i = polynomial_length; i < 16; i++)  // padding the other bytes for good measure, extra byte lanes that exceed the pattern data width will be ignored by the hardware
  {
    IOWR_8DIRECT(base, (PRBS_GENERATOR_POLYNOMIAL_31_0_REG + i), 0);
  }
}


// register read functions
unsigned long prbs_generator_read_payload_length (unsigned long base)
{
  return (IORD_32DIRECT(base, PRBS_GENERATOR_PAYLOAD_LENGTH_REG));
}

unsigned char prbs_generator_read_infinite_payload_length (unsigned long base)
{
  return (IORD_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_INFINITE_PAYLOAD_LENGTH_ENABLE_BYTE_OFFSET)) & (PRBS_GENERATOR_INFINITE_PAYLOAD_LENGTH_ENABLE_MASK >> PRBS_GENERATOR_INFINITE_PAYLOAD_LENGTH_ENABLE_BIT_OFFSET));
}

unsigned char prbs_generator_read_start (unsigned long base)
{
  return (IORD_8DIRECT(base, (PRBS_GENERATOR_CONTROL_REG + PRBS_GENERATOR_RUN_BYTE_OFFSET)) & (PRBS_GENERATOR_RUN_MASK >> PRBS_GENERATOR_RUN_BIT_OFFSET));
}

void prbs_generator_read_polynomial (unsigned long base, unsigned char *polynomial, long polynomial_length)
{
  long i;
  
  for (i = 0; i < polynomial_length; i++)
  {
    *polynomial++ = IORD_8DIRECT(base, (PRBS_GENERATOR_POLYNOMIAL_31_0_REG + i));
  }
  
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
