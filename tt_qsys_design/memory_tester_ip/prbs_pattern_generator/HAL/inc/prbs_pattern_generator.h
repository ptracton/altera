#ifndef __PRBS_PATTERN_GENERATOR_H__
#define __PRBS_PATTERN_GENERATOR_H__


// public API to access the hardware
void prbs_generator_set_payload_length (unsigned long base, unsigned long length);
void prbs_generator_enable_infinite_payload_length (unsigned long base);
void prbs_generator_disable_infinite_payload_length (unsigned long base);
void prbs_generator_seed_enable (unsigned long base);
void prbs_generator_enable_start (unsigned long base);
void prbs_generator_disable_start (unsigned long base);
void prbs_generator_set_polynomial (unsigned long base, unsigned char *polynomial, long polynomial_length);

unsigned long prbs_generator_read_payload_length (unsigned long base);
unsigned char prbs_generator_read_infinite_payload_length (unsigned long base);
unsigned char prbs_generator_read_start (unsigned long base);
void prbs_generator_read_polynomial (unsigned long base, unsigned char *polynomial, long polynomial_length);


#endif /* __PRBS_PATTERN_GENERATOR_H__ */


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
