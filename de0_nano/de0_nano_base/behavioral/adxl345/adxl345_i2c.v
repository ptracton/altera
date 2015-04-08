//                              -*- Mode: Verilog -*-
// Filename        : adxl345_i2c.v
// Description     : ADXL345 I2C Interface
// Author          : Philip Tracton
// Created On      : Tue May 20 16:54:53 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 20 16:54:53 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module adxl345_i2c (/*AUTOARG*/
   // Outputs
   sdata_oe, write, read, write_data,
   // Inouts
   sdata,
   // Inputs
   sclk, read_data
   ) ;
   input sclk;
   inout sdata;
   output sdata_oe;
   
   output write;
   output read;
   output [7:0] write_data;
   input  [7:0] read_data;

   reg 		start_bit;
   reg 		stop_bit;
   reg [3:0] 	bit_count;
   reg [7:0] 	shift_reg;
   wire 	byte_received;

   //
   // Start Bit Detection
   //
   always @(negedge sdata)
     if (sclk) begin
	start_bit <= 1'b1;
	stop_bit <=1'b0;
	bit_count <= 4'h0;	
     end

   //
   // Stop Bit Detection
   //
   always @(posedge sdata)
     if (sclk) begin
	start_bit <=1'b0;
	stop_bit <=1'b1;
	bit_count <= 4'hA;	
     end

   //
   // Shift Register 
   //
   always @(posedge sclk)
     shift_reg <= {shift_reg[7:1], sdata};   

   //
   // Count bits
   //
   assign byte_recevied = (bit_count == 4'h8);
   
   always @(posedge sclk)
     if (bit_count <10) begin
	bit_count <= bit_count + 1;	
     end
   
endmodule // adxl345_i2c
