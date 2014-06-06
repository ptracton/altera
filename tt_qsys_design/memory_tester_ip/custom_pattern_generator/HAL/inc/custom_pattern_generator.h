#ifndef __CUSTOM_PATTERN_GENERATOR_H__
#define __CUSTOM_PATTERN_GENERATOR_H__


// public API to access the hardware
void generator_set_payload_length (unsigned long base, unsigned long length);
void generator_set_pattern_length (unsigned long base, unsigned short length);
void generator_set_pattern_position (unsigned long base, unsigned short position);
void generator_enable_infinite_payload_length (unsigned long base);
void generator_disable_infinite_payload_length (unsigned long base);
void generator_enable_start (unsigned long base);
void generator_disable_start (unsigned long base);

unsigned long generator_read_payload_length (unsigned long base);
unsigned short generator_read_pattern_length (unsigned long base);
unsigned short generator_read_pattern_position (unsigned long base);
unsigned char generator_read_infinite_payload_length (unsigned long base);
unsigned char generator_read_start (unsigned long base);


#endif /* __CUSTOM_PATTERN_GENERATOR_H__ */


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
