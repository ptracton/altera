//                              -*- Mode: Verilog -*-
// Filename        : free_running_clk.v
// Description     : Behavioral Model: Free Running Clock
// Author          : Philip Tracton
// Created On      : Tue May 27 14:56:24 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 14:56:24 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

`timescale 1ns/1ns

module free_running_clk (/*AUTOARG*/
   // Outputs
   CLK
   ) ;
   parameter HIGH = 10;
   parameter LOW =  10;
   
   output CLK;
   reg 	  CLK;

   initial begin
      CLK <= 1'b1;
      forever begin
	 #HIGH CLK <= 1'b0;
	 #LOW  CLK <= 1'b1;	 
      end
   end
   
endmodule // free_running_clk
