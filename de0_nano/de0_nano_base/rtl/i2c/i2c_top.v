//                              -*- Mode: Verilog -*-
// Filename        : i2c_top.v
// Description     : DE 0 Nano I2C Module
// Author          : Philip Tracton
// Created On      : Tue May 20 17:16:57 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 20 17:16:57 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module i2c (
	    sclk, sda, sda_oe,
	    clk, reset
	    );
   
   input clk;
   input reset;

   output sclk;
   output sda;
   output sda_oe;

   /*AUTOREG*/
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			sclk;			// From clocking of i2c_clocking.v
   // End of automatics
   
   reg [2:0] i;
   reg [7:0] write_data;
   reg 	     write;
   reg 	     sda;
   reg 	     sda_oe;
   
   initial begin
      write_data = 8'hA7;
      i = 0;
      write = 1;      
   end
      
   i2c_clocking clocking(/*AUTOINST*/
			 // Outputs
			 .sclk			(sclk),
			 // Inputs
			 .clk			(clk),
			 .reset			(reset),
			 .select_clk_400k	(select_clk_400k));
      
      
   
   always @(posedge sclk)
     if (write) begin
        sda_oe <= 1'b1;
        sda <= write_data[i];
	i <= i+1;
	if (i==8) begin
	   i=0;	   
	end
     end
   
endmodule // i2c
