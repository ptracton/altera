Qsys Tutorial Design Example README file
----------------------------------------
----------------------------------------

This readme file for the Qsys Tutorial Design Example contains information about
the design example package.

For more information on the Qsys tutorial design example, refer to the following
design example web page: 
http://www.altera.com/support/examples/design-entry-tools/qsys/exm-qsys-tut.html 

This file contains the following information:

-  Release History
-  Software and Board Requirements
-  Package Contents and Directory Structure
-  Design Porting Instructions
-  Contacting Altera(R)


Release History
================

Version 1.2 - Updated June 2012, with changes to simulation files
Version 1.1 - Updated May 2011
Version 1.0 - First release of example


Software and Board Requirements
====================================

This design example is for use with the following versions of the 
Altera Complete Design Suite and Quartus(R) II software:
	- 12.0 and later

Programming the hardware in this design example requires one of the following 
development boards:
	- Nios(R) II Embedded Evaluation Kit, Cyclone(R) III Edition
	- Altera Arria(R) II GX FPGA Development Kit 
	- Altera Stratix(R) IV GX FPGA Development Kits 

For information on porting the design example to a custom board, refer to the
Design Porting Instructions below.


Package Contents and Directory Structure
========================================

/tt_qsys_design

	/completed_subsystems
	Contains the completed systems resulting from the tutorial steps for the 
	memory tester design, if you want to skip steps or compare final results 
	with the system you create.

	/memory_tester_ip
	Contains all the memory tester microcores and the Nios II CPU subsystem 
	used in this tutorial.

	/quartus_ii_projects_for_boards
		/<development board>
		Contains Quartus II project file specific to the development board, 
		and the memory_tester_search_path.ipx file that adds the
		/memory_tester_ip directory to the Qsys search path.

		/backup_and_completed_top_system
		Contains systems you can use to restore the base design or
		view the complete top-level system.

			/base_top_system
			Contains the top_system.qsys file, which is a duplicate
			of the file from the <development board> directory so
			that you can restore it.

			/completed_top_system
			Contains the completed top_system.qsys file for the board.

			/completed_system_console_system
			Contains the top_system.qsys file for the board, including
			the JTAG to Avalon Master Bridge for the System Console.

		/system_console
		Contains the following scripts used in the System Console chapter 
		of the tutorial:
			base_address.tcl - contains base addresses of
			PRBS, multiplexer, demultiplexer, and ram controller
			slave ports
			test_cases.tcl - contains various test parameters
			run_sweep.tcl - responsible for scripting the
			test in hardware

	/simulation_tutorial
	Contains a Quartus II project and the simulation files used in the 
	Simulation chapter of the tutorial.


Design Porting Instructions
===========================

You can modify the design example to target any board. The tutorial shows you
how to ensure that the base addresses of all the component slave ports match the
expected values. You should maintain the same design directory structure
when porting one of the existing designs to your own board to minimize the
amount of changes necessary.


[A] Modifying Memory Data Width or Burst Length:

The tutorial targets a 32-bit datapath using a maximum burst count of 2. You
should match these parameterization options with the memory controller interface
characteristics. To adjust these parameters, follow these steps:

1) Set the maximum burst count in the pattern reader and writer cores to  match
the maximum (local) burst count of the memory controller.
2) Set the data width of all the memory tester cores to match the (local) data
width of the memory controller.


[B] Modifying Download Script to Match New Quartus II Project:

If your Quartus II project name differs, you must modify the software batch
script that you run to automate the downloading of the hardware and software
files and to open a terminal connection,
You can find this file in the following directory:

/quartus_ii_projects_for_boards/<development board>/software/batch_script.sh

If you retain the same directory structure as the provided designs,
you need only edit the variable "SOF_NAME" to match the .sof file name
that your Quartus II project uses. There are other variables defined that you
can modify if you change the directory structure.


[C] Modifying Nios II Software Settings for Changes to Memory Data Width, Burst
Length, or Address Span:

You must modify the software settings file if you change the data width or
memory span in the design files. To modify the test to match your own design,
navigate to the file in:

/quartus_ii_projects_for_boards/<development board>/software/src/settings.h.

The file includes instructions. In particular, confirm the values defined by
"DATA_WIDTH" and "RAM_SPAN". If you modify the base address of the memory
controller under test from the default of 0x0, you must also change the value
"RAM_BASE"; however, you should place the memory at a base address of 0x0 to
minimize changes. You can also change the value of "NUM_OF_TESTS" to increase
the duration of the testing, setting this value to -1 causes the test to operate
indefinitely or until an error is detected.


[D] Modifying System Console Scripts

If you locate the memory tester base addresses to nondefault locations 
or change the memory span under test, navigate to the following
directory to modify the addresses:
/quartus_ii_projects_for_boards/<development board>/system_console

To adjust the memory tester base addresses, modify the variables at the top of
the base_address.tcl file containing the postfix "_baseadd" to match your own
system.
To adjust the test parameters, such as the memory span under test, modify the
variable "memoryspan" in the test_cases.tcl file, to match the memory span of
your board.


Contacting Altera
=================

Although we have made every effort to ensure that this design example works
correctly, there might be problems that we have not encountered. If you have
a question or problem that is not answered by the information provided in this
readme file or the example's documentation, please contact Altera(R) support.

http://www.altera.com/mysupport/


Copyright (c) 2012 Altera Corporation. All rights reserved.

