//                              -*- Mode: Verilog -*-
// Filename        : testbench_fifo.v
// Description     : Testbench for FIFO
// Author          : Philip Tracton
// Created On      : Tue May 27 17:04:38 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 17:04:38 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

`timescale 1ns/1ps

module testbench (/*AUTOARG*/) ;

   //
   // SystemVerilog importing of avalon specific packages 
   //
   // You must tell modelsim to compile as system verilog!
   //
   import avalon_mm_pkg::*;

   parameter READ_TRANSACTION = 1;
   parameter WRITE_TRANSACTION = 0;
   
   
   //---------------------------------------------------------------------------
   //
   // Free Running Clock
   //
   //---------------------------------------------------------------------------
   wire CLK;
   free_running_clk CLK_50MHZ (.CLK(CLK));

   //---------------------------------------------------------------------------
   //
   // System Reset
   //
   //---------------------------------------------------------------------------
   reg  RESET;
   initial begin
      RESET <= 1'b0;
      repeat (2) @(posedge CLK);
      #3 RESET <= 1'b1;
      repeat (20) @(posedge CLK);
      #2 RESET <= 1'b0;      
   end


   //
   // Fundamental Signals
   //
   wire [31:0] ADDRESS;   
   wire        BEGINTRANSFER;
   wire [3:0]  BYTE_ENABLE;
   wire        READ;
   wire [31:0] READDATA;
   wire        WRITE;
   wire [31:0] WRITEDATA;
   
   //
   // Wait State Signals
   //
   wire        LOCK;
   wire        WAITREQUEST;
   
   //
   // Pipline
   //
   wire        READDATAVALID;
   wire [2:0]  BURSTCOUNT;
   wire        BEGINBURSTTRANSFER;
   
   /*AUTOREG*/
   /*AUTOWIRE*/

   altera_avalon_mm_slave_bfm slave(
                                    .clk(CLK),   
                                    .reset(RESET),
                                    
                                    .avs_clken(1'b0),
                                    
                                    .avs_waitrequest(WAITREQUEST),
                                    .avs_write(WRITE),
                                    .avs_read(READ),
                                    .avs_address(ADDRESS),
                                    .avs_byteenable(BYTE_ENABLE),
                                    .avs_burstcount(BURSTCOUNT),
                                    .avs_beginbursttransfer(BEGINBURSTTRANSFER),
                                    .avs_begintransfer(BEGINTRANSFER),
                                    .avs_writedata(WRITEDATA),
                                    .avs_readdata(READDATA),
                                    .avs_readdatavalid(READDATAVALID),
                                    .avs_arbiterlock(1'b0),
                                    .avs_lock(LOCK),
                                    .avs_debugaccess(1'b0),
				    
                                    .avs_transactionid(8'b0),
                                    .avs_readresponse(),
                                    .avs_readid(),
                                    .avs_writeresponserequest(1'b0),
                                    .avs_writeresponsevalid(),
                                    .avs_writeresponse(),
                                    .avs_writeid(),
                                    .avs_response()
                                  );
   defparam slave.USE_BURSTCOUNT = 0;
   defparam slave.USE_BEGIN_TRANSFER = 0;
   defparam slave.USE_BEGIN_BURST_TRANSFER = 0;
   
   
   //---------------------------------------------------------------------------
   //   
   // DUT
   //
   //---------------------------------------------------------------------------

   //
   // Control Signals -- NOT part of AVALON
   //
   reg [31:0] 		data_to_write;
   reg 			rnw;
   reg 			start;
   reg [3:0] 		bytes;   
   reg [31:0] 		address_to_access;
   wire 		done;
   wire [31:0] 		data_read;
   
   avalon_mm_master dut(/*AUTOINST*/
			// Outputs
			.ADDRESS	(ADDRESS[31:0]),
			.BEGINTRANSFER	(BEGINTRANSFER),
			.BYTE_ENABLE	(BYTE_ENABLE[3:0]),
			.READ		(READ),
			.WRITE		(WRITE),
			.WRITEDATA	(WRITEDATA[31:0]),
			.LOCK		(LOCK),
			.BURSTCOUNT	(BURSTCOUNT),
			.done		(done),
			.data_read	(data_read[31:0]),
			// Inputs
			.CLK		(CLK),
			.RESET		(RESET),
			.READDATA	(READDATA[31:0]),
			.WAITREQUEST	(WAITREQUEST),
			.READDATAVALID	(READDATAVALID),
			.data_to_write	(data_to_write[31:0]),
			.rnw		(rnw),
			.start		(start),
			.bytes		(bytes[3:0]),
			.address_to_access(address_to_access[31:0]));
   
   


   //---------------------------------------------------------------------------
   //
   // TASKS
   // 
   //---------------------------------------------------------------------------   
   task master_transaction;
      input [31:0] address;
      input [31:0] data;
      input [3:0]  bytess;
      input 	   rnws;
      
      begin
	 @(posedge CLK);
	 address_to_access <= ADDRESS;
	 bytes <= bytess;
	 rnw <= rnws;	 
	 if (rnws == WRITE_TRANSACTION) begin
	    data_to_write <= data;	    
	 end
	 start <= 1;
	 @(posedge CLK);
	 address_to_access <= $random;
	 bytes <= $random;
	 rnw <=  $random;	 
	 data_to_write <= $random;	    
	 start <= 0;	 
	 
      end
   endtask // master_transaction
   
      
   
   
   //---------------------------------------------------------------------------
   //
   // TEST CASES
   // 
   //---------------------------------------------------------------------------
   
   initial begin

      data_to_write <= 'b0;
      rnw <= 1'b0;
      start <= 1'b0;
      bytes <= 4'b0;
      address_to_access <= 'b0;
      
      
      #5 @(negedge RESET);
      $display("RESET RELEASED @ %d", $time);

      slave.init();
      repeat (10) @(posedge  CLK);
      
      master_transaction(32'h0000_0004, 32'habcd_1234, 4'hF, WRITE);
      
   
      
      repeat (10) @(posedge  CLK);
      $display("SIM COMPLETE @ %d", $time);      
      $finish;
   end
   
endmodule // testbench


