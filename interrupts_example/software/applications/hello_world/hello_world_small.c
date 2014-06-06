/* 
 * "Small Hello World" example. 
 * 
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example 
 * designs. It requires a STDOUT  device in your system's hardware. 
 *
 * The purpose of this example is to demonstrate the smallest possible Hello 
 * World application, using the Nios II HAL library.  The memory footprint
 * of this hosted application is ~332 bytes by default using the standard 
 * reference design.  For a more fully featured Hello World application
 * example, see the example titled "Hello World".
 *
 * The memory footprint of this example has been reduced by making the
 * following changes to the normal "Hello World" example.
 * Check in the Nios II Software Developers Manual for a more complete 
 * description.
 * 
 * In the SW Application project (small_hello_world):
 *
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 * In System Library project (small_hello_world_syslib):
 *  - In the C/C++ Build page
 * 
 *    - Set the Optimization Level to -Os
 * 
 *    - Define the preprocessor option ALT_NO_INSTRUCTION_EMULATION 
 *      This removes software exception handling, which means that you cannot 
 *      run code compiled for Nios II cpu with a hardware multiplier on a core 
 *      without a the multiply unit. Check the Nios II Software Developers 
 *      Manual for more details.
 *
 *  - In the System Library page:
 *    - Set Periodic system timer and Timestamp timer to none
 *      This prevents the automatic inclusion of the timer driver.
 *
 *    - Set Max file descriptors to 4
 *      This reduces the size of the file handle pool.
 *
 *    - Check Main function does not exit
 *    - Uncheck Clean exit (flush buffers)
 *      This removes the unneeded call to exit when main returns, since it
 *      won't.
 *
 *    - Check Don't use C++
 *      This builds without the C++ support code.
 *
 *    - Check Small C library
 *      This uses a reduced functionality C library, which lacks  
 *      support for buffering, file IO, floating point and getch(), etc. 
 *      Check the Nios II Software Developers Manual for a complete list.
 *
 *    - Check Reduced device drivers
 *      This uses reduced functionality drivers if they're available. For the
 *      standard design this means you get polled UART and JTAG UART drivers,
 *      no support for the LCD driver and you lose the ability to program 
 *      CFI compliant flash devices.
 *
 *    - Check Access device drivers directly
 *      This bypasses the device file system to access device drivers directly.
 *      This eliminates the space required for the device file system services.
 *      It also provides a HAL version of libc services that access the drivers
 *      directly, further reducing space. Only a limited number of libc
 *      functions are available in this configuration.
 *
 *    - Use ALT versions of stdio routines:
 *
 *           Function                  Description
 *        ===============  =====================================
 *        alt_printf       Only supports %s, %x, and %c ( < 1 Kbyte)
 *        alt_putstr       Smaller overhead than puts with direct drivers
 *                         Note this function doesn't add a newline.
 *        alt_putchar      Smaller overhead than putchar with direct drivers
 *        alt_getchar      Smaller overhead than getchar with direct drivers
 *
 */

#include "alt_types.h"
#include "sys/alt_stdio.h"
#include "sys/alt_irq.h"
#include "sys/alt_irq_entry.h"
#include "altera_avalon_pio_regs.h"

void IRQ_SWITCHES(void * context){
	//
	// Signal TEST BENCH that we are in the IRQ handler
	//
	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, 0xFE);

	//
	// Clear the IRQ from the PIO module, write 1 to clear!
	//
	IOWR_ALTERA_AVALON_PIO_EDGE_CAP(SWITCHES_BASE,0x01);
	return;
}

int main()
{ 
	//
	// Unmask all 8 bits as possible interrupt sources
	//
	IOWR_ALTERA_AVALON_PIO_IRQ_MASK(SWITCHES_BASE, 0xFF);

	//
	// Register the interrupt handler with the system
	//
	alt_ic_isr_register(SWITCHES_IRQ_INTERRUPT_CONTROLLER_ID,
			 	 	 	 SWITCHES_IRQ,
			 	 	 	 IRQ_SWITCHES,
			 	 	 	 0,0
			 	 	 	 );

	//
	// Let the CPU handle interrupts
	//
	alt_ic_irq_enable(SWITCHES_IRQ_INTERRUPT_CONTROLLER_ID,
	 	 	 	 	  SWITCHES_IRQ);

	alt_putstr("Hello from Nios II!\n");

	IOWR_ALTERA_AVALON_PIO_DATA(LEDS_BASE, 0x01);
	alt_putstr("IRQ DONE\n");

  /* Event loop never exits. */
  while (1);

  return 0;
}
