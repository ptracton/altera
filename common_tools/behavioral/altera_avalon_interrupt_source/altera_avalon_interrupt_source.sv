// (C) 2001-2013 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_interrupt_source/altera_avalon_interrupt_source.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//------------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_interrupt_source
// =head1 SYNOPSIS
// Avalon Interrupt Source Bus Functional Model (BFM)
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This is an Avalon Interrupt Source Bus Functional Model (BFM)
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_interrupt_source (
				       clk, 
				       reset,
				       
				       irq
					 );
   
   // =head1 PARAMETERS
   parameter ASSERT_HIGH_IRQ           = 1; // active high irq
   parameter ASYNCHRONOUS_INTERRUPT    = 0; // asynchronous irq signal to its associated clock
   parameter AV_IRQ_W                  = 1; // width of the interrupt signal
   parameter VHDL_ID                   = 0; // VHDL BFM ID number
   // =head1 PINS
   // =head2 Clock Interface   
   input                         clk;
   // =head2 Reset Interface
   input                         reset;	  

   // =head2 Avalon Interrupt Source Interface   
   output [AV_IRQ_W-1:0]         irq;   

   // =cut
   
// synthesis translate_off
   import verbosity_pkg::*;   

   localparam VERSION = "9.1.0";

   //--------------------------------------------------------------------------
   // Internal Machinery
   //--------------------------------------------------------------------------
   function automatic void hello();
      // Introduction Message to console      
      $sformat(message, "%m: - Hello from altera_avalon_interrupt_source");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/08/11 $");
      print(VERBOSITY_INFO, message);
   endfunction

   initial begin
      hello();
   end

   bit                    irq_bit_active  = (ASSERT_HIGH_IRQ)? 1'b1 : 1'b0;
   logic [AV_IRQ_W-1:0]   irq_inactive    = (ASSERT_HIGH_IRQ)? {AV_IRQ_W{1'b0}} : {AV_IRQ_W{1'b1}};
   logic [AV_IRQ_W-1:0]   interrupt       = irq_inactive;
   logic [AV_IRQ_W-1:0]   irq             = irq_inactive;

   if (ASYNCHRONOUS_INTERRUPT == 1)
      always @(reset or interrupt) begin
         if (reset)
            irq = irq_inactive;
         else
            irq = interrupt;
      end
   else
      always @(posedge clk or posedge reset) begin
         if (reset)
            irq <= irq_inactive;
         else
            irq <= interrupt;
      end

   
   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). In this case the application program is the test bench
   // which instantiates and controls and queries state in this BFM component.
   // Test programs must only use these public access methods and events to 
   // communicate with this BFM component. The API and the module pins
   // are the only interfaces in this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------

   function automatic string get_version();  // public
      // Return BFM version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "10.1";
      return ret_version;
   endfunction
   
   function automatic void set_irq( // public
      int interrupt_bit = 0
   );
      $sformat(message, "%m: called set_irq");
      print(VERBOSITY_DEBUG, message);
      
      if (interrupt_bit < AV_IRQ_W) begin
         interrupt[interrupt_bit] = irq_bit_active;
      end else begin     
         $sformat(message, "%m: Command ignored. IRQ width is only %0d bit", AV_IRQ_W);
         print(VERBOSITY_WARNING, message);
      end
   endfunction 

   function automatic void clear_irq( // public
      int interrupt_bit = 0
   );
      $sformat(message, "%m: called clear_irq");
      print(VERBOSITY_DEBUG, message);
   
      if (interrupt_bit < AV_IRQ_W) begin
         interrupt[interrupt_bit] = ~irq_bit_active;
      end else begin     
         $sformat(message, "%m: Command ignored. IRQ width is only %0d bit", AV_IRQ_W);
         print(VERBOSITY_WARNING, message);
      end           
   endfunction 
   
// synthesis translate_on
endmodule 

