//                              -*- Mode: Verilog -*-
// Filename        : leds.v
// Description     : Altera DE2-115 LEDS Example
// Author          : Philip Tracton
// Created On      : Thu Jun  5 16:13:27 2014
// Last Modified By: Philip Tracton
// Last Modified On: Thu Jun  5 16:13:27 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module leds (/*AUTOARG*/
   // Outputs
   LEDR, LEDG,
   // Inputs
   CLK_50, RESET
   ) ;
   input CLK_50;
   input RESET;
   output [17:0] LEDR;
   output [7:0]  LEDG;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [7:0]		LEDG;
   reg [17:0]		LEDR;
   // End of automatics
    
   
   always @(posedge CLK_50)
     if (~RESET) begin
	LEDR <= 18'b0;	
     end else begin
	LEDR <= 18'h3_FFFF;	
     end

   always @(posedge CLK_50)
     if (~RESET) begin
	LEDG <= 8'b0;	
     end else begin
	LEDG <= 8'hFF;	
     end
   
   
endmodule // leds
