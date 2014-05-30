//                              -*- Mode: Verilog -*-
// Filename        : avalon_slave.v
// Description     : Avalon MM Slave Example
// Author          : Philip Tracton
// Created On      : Fri May 30 16:55:10 2014
// Last Modified By: Philip Tracton
// Last Modified On: Fri May 30 16:55:10 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!


module avalon_slave (/*AUTOARG*/
   // Outputs
   READDATA, WAITREQUEST, READDATAVALID,
   // Inputs
   CLK, RESET, ADDRESS, BEGINTRANSFER, BYTE_ENABLE, READ, WRITE,
   WRITEDATA, LOCK, BURSTCOUNT, BEGINBURSTTRANSFER
   ) ;


   //
   // Fundamental Signals
   //
   input CLK;
   input RESET;

   input [31:0] ADDRESS;   
   input BEGINTRANSFER;
   input [3:0] BYTE_ENABLE;
   input       READ;
   output [31:0] READDATA;
   input 	WRITE;
   input [31:0] WRITEDATA;

   //
   // Wait State Signals
   //
   input       LOCK;
   output      WAITREQUEST;

   //
   // Pipline
   //
   output      READDATAVALID;
   input [2:0] BURSTCOUNT;
   input       BEGINBURSTTRANSFER;
   

   
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		READDATA;
   reg			READDATAVALID;
   // End of automatics
   /*AUTOWIRE*/

   wire			WAITREQUEST;
   reg			WAITREQUEST_read;
   reg			WAITREQUEST_write;
   reg [31:0] 		reg1;
   reg [31:0] 		reg2;


   //
   //
   //
   assign WAITREQUEST = WAITREQUEST_read || WAITREQUEST_write;
   
   //
   // WRITE LOGIC
   //
   always @(posedge CLK)
     if (RESET) begin
	reg1 <= 32'b0;
	reg2 <= 32'b0;
	WAITREQUEST_write <= 1'b0;	
     end else if (!WAITREQUEST && WRITE) begin
	WAITREQUEST_write <= 1'b0;	
	case (ADDRESS)
	  32'h0000_0004: begin
	     case (BYTE_ENABLE)
	       4'b1111:  reg1[31:00] <= WRITEDATA[31:00];
	       4'b1100:  reg1[31:16] <= WRITEDATA[31:16];
	       4'b0011:  reg1[15:00] <= WRITEDATA[15:00];
	       4'b1000:  reg1[31:24] <= WRITEDATA[31:24];
	       4'b0100:  reg1[23:16] <= WRITEDATA[23:16];
	       4'b0010:  reg1[15:08] <= WRITEDATA[15:08];
	       4'b0001:  reg1[07:00] <= WRITEDATA[07:00];
	     endcase // case (BYTE_ENABLE)
	     
	  end
	  32'h0000_0008:
	     case (BYTE_ENABLE)
	       4'b1111:  reg2[31:00] <= WRITEDATA[31:00];
	       4'b1100:  reg2[31:16] <= WRITEDATA[31:16];
	       4'b0011:  reg2[15:00] <= WRITEDATA[15:00];
	       4'b1000:  reg2[31:24] <= WRITEDATA[31:24];
	       4'b0100:  reg2[23:16] <= WRITEDATA[23:16];
	       4'b0010:  reg2[15:08] <= WRITEDATA[15:08];
	       4'b0001:  reg2[07:00] <= WRITEDATA[07:00];
	     endcase // case (BYTE_ENABLE)
	endcase // case (ADDRESS)
     end else begin
	WAITREQUEST_write <= 1'b0;	
     end

   //
   // READ LOGIC
   //
   always @(posedge CLK)
     if (RESET) begin

	WAITREQUEST_read <= 1'b0;	
     end else if (!WAITREQUEST && READ) begin
	WAITREQUEST_read <= 1'b0;	
     end else begin
	WAITREQUEST_read <= 1'b0;	
     end

   always @(*)
     if (RESET) begin
	READDATAVALID <= 1'b0;
	READDATA <= 32'b0;
     end else if (!WAITREQUEST && READ) begin
	READDATAVALID <= 1'b1;
	case (ADDRESS)
	  32'h0000_0004: READDATA <= reg1;	     
	  32'h0000_0008: READDATA <= reg2;
	endcase // case (ADDRESS)	
     end else begin
	READDATA <= 32'b0;
	READDATAVALID <= 1'b0;	
     end
   
endmodule // avalon_slave
