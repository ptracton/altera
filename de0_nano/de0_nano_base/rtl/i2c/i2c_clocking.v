//                              -*- Mode: Verilog -*-
// Filename        : i2c_clocking.v
// Description     : DE 0 Nano I2C Clocking
// Author          : Philip Tracton
// Created On      : Tue May 20 17:20:40 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 20 17:20:40 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module i2c_clocking (/*AUTOARG*/
   // Outputs
   sclk,
   // Inputs
   clk, reset, select_clk_400k
   ) ;
   input clk;
   input reset;
   input select_clk_400k;
   
   output sclk;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			sclk;
   // End of automatics

   //
   // Divided down 50M/100K = 500
   // Divided down 50M/400K = 125
   //
   
   reg [8:0] clk_count;
   wire      clk_count_done = (select_clk_400k) ? (clk_count == 9'd125) :(clk_count == 9'd500);   
   always @(posedge clk)
     if (reset) begin
	clk_count <= 'b0;	
     end else begin
	if (clk_count_done) begin
	   clk_count <= 'b0;	   
	end else begin
	   clk_count <= clk_count + 1;	   
	end
     end

   always @(posedge clk)
     if (reset) begin
	sclk <= 1'b0;	
     end else begin
	if (clk_count_done) begin
	   sclk <= ~sclk;	   
	end
     end
   
endmodule // i2c_clocking
