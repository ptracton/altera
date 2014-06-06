#ifndef __RAM_TEST_CONTROLLER_H__
#define __RAM_TEST_CONTROLLER_H__

// register write functions (functions with return values use error code 0 for pass and 1 for failures)
void ram_test_controller_set_base_address (unsigned long csr_base, unsigned long long ram_base);
int ram_test_controller_set_transfer_length (unsigned long csr_base, unsigned long length);
int ram_test_controller_set_block_size (unsigned long csr_base, unsigned long block_size);
int ram_test_controller_set_block_trail_distance (unsigned long csr_base, unsigned char trail_distance);
void ram_test_controller_enable_concurrent_accesses (unsigned long csr_base);
void ram_test_controller_disable_concurrent_accesses (unsigned long csr_base);
void ram_test_controller_enable_start (unsigned long csr_base);
void ram_test_controller_disable_start (unsigned long csr_base);
int ram_test_controller_set_timer_resolution (unsigned long csr_base, unsigned short resolution);
void ram_test_controller_set_timer (unsigned long csr_base, unsigned long timer);


// register read functions
unsigned long long ram_test_controller_read_base_address (unsigned long csr_base);
unsigned long ram_test_controller_read_transfer_length (unsigned long csr_base);
unsigned long ram_test_controller_read_block_size (unsigned long csr_base);
unsigned long ram_test_controller_read_block_trail_distance (unsigned long csr_base);
unsigned char ram_test_controller_read_concurrent_accesses (unsigned long csr_base);
unsigned char ram_test_controller_read_start (unsigned long csr_base);
unsigned short ram_test_controller_read_timer_resolution (unsigned long csr_base);
unsigned long ram_test_controller_read_timer (unsigned long csr_base);

#endif /* __RAM_TEST_CONTROLLER_H__ */


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
