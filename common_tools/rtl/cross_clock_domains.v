//                              -*- Mode: Verilog -*-
// Filename        : cross_clock_domains.v
// Description     : Cross Clock Domain
// Author          : Philip Tracton
// Created On      : Tue May 27 15:42:50 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 15:42:50 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!
module cross_clock_domain (/*AUTOARG*/
   // Outputs
   DATA_OUT,
   // Inputs
   CLK_SRC, CLK_DST, RESET, ENABLE, DATA_IN
   ) ;


   //---------------------------------------------------------------------------
   //
   // PARAMETERS
   //
   //---------------------------------------------------------------------------
   parameter DATA_WIDTH = 32;
   
   //---------------------------------------------------------------------------
   //
   // PORTS
   //
   //---------------------------------------------------------------------------   
   input CLK_SRC;                         // CLK for DATA_IN
   input CLK_DST;                         // CLK for DATA_OUT
   input RESET;                           // SYNCHRONOUS to both CLOCKS, Active High
   input ENABLE;                          // When asserted (1'b1) the block is active
   input [DATA_WIDTH-1:0] DATA_IN;        // Data we want to move from CLK_SRC to CLK_DST
   output [DATA_WIDTH-1:0] DATA_OUT;      // Data valid in CLK_DST

   //---------------------------------------------------------------------------
   //
   // Registers 
   //
   //---------------------------------------------------------------------------
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [DATA_WIDTH-1:0]	DATA_OUT;
   // End of automatics

   reg [DATA_WIDTH-1:0] DATA_IN1;
   reg [DATA_WIDTH-1:0] DATA_IN2;
   
   //---------------------------------------------------------------------------
   //
   // WIRES
   //
   //---------------------------------------------------------------------------
   /*AUTOWIRE*/
   
   //---------------------------------------------------------------------------
   //
   // COMBINATIONAL LOGIC
   //
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   //
   // SEQUENTIAL LOGIC
   //
   //---------------------------------------------------------------------------

   //
   // Double buffer input to deal with metastability
   //
   always @(posedge CLK_SRC)
     if (RESET) begin
	DATA_IN1 <= 'b0;
     end else if (ENABLE) begin
	DATA_IN1 <= DATA_IN;
     end

   //
   // Move ouput from stabilizers to output
   //
   always @(posedge CLK_DST)
     if (RESET) begin
	DATA_OUT <= 'b0;
	DATA_IN2 <= 'b0;		
     end else if (ENABLE) begin
	DATA_IN2 <= DATA_IN1;	
	DATA_OUT <= DATA_IN2;	
     end
   
endmodule // cross_clock_domain
