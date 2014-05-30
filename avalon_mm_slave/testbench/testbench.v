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

   altera_avalon_mm_master_bfm #(
                                 .AV_ADDRESS_W               (32),
                                 .AV_SYMBOL_W                (8),
                                 .AV_NUMSYMBOLS              (4),
                                 .AV_BURSTCOUNT_W            (3),
                                 .AV_READRESPONSE_W          (8),
                                 .AV_WRITERESPONSE_W         (8),
                                 .USE_READ                   (1),
                                 .USE_WRITE                  (1),
                                 .USE_ADDRESS                (1),
                                 .USE_BYTE_ENABLE            (1),
                                 .USE_BURSTCOUNT             (1),
                                 .USE_READ_DATA              (1),
                                 .USE_READ_DATA_VALID        (1),
                                 .USE_WRITE_DATA             (1),
                                 .USE_BEGIN_TRANSFER         (0),
                                 .USE_BEGIN_BURST_TRANSFER   (0),
                                 .USE_WAIT_REQUEST           (1),
                                 .USE_TRANSACTIONID          (0),
                                 .USE_WRITERESPONSE          (0),
                                 .USE_READRESPONSE           (0),
                                 .USE_CLKEN                  (0),
                                 .AV_CONSTANT_BURST_BEHAVIOR (1),
                                 .AV_BURST_LINEWRAP          (1),
                                 .AV_BURST_BNDR_ONLY         (1),
                                 .AV_MAX_PENDING_READS       (0),
                                 .AV_MAX_PENDING_WRITES      (0),
                                 .AV_FIX_READ_LATENCY        (1),
                                 .AV_READ_WAIT_TIME          (1),
                                 .AV_WRITE_WAIT_TIME         (0),
                                 .REGISTER_WAITREQUEST       (0),
                                 .AV_REGISTERINCOMINGSIGNALS (0),
                                 .VHDL_ID                    (0)
                                 ) mm_master_bfm_0 (
                                                    .clk                      (CLK),         //       clk.clk
                                                    .reset                    (RESET), // clk_reset.reset
                                                    .avm_address              (ADDRESS),                                //        m0.address
                                                    .avm_burstcount           (BURSTCOUNT),                                //          .burstcount
                                                    .avm_readdata             (READDATA),                                //          .readdata
                                                    .avm_writedata            (WRITEDATA),                                //          .writedata
                                                    .avm_waitrequest          (WAITREQUEST),                                //          .waitrequest
                                                    .avm_write                (WRITE),                                //          .write
                                                    .avm_read                 (READ),                                //          .read
                                                    .avm_byteenable           (BYTE_ENABLE),                                //          .byteenable
                                                    .avm_readdatavalid        (READDATAVALID),                                //          .readdatavalid
                                                    .avm_begintransfer        (BEGINTRANSFER),                                // (terminated)
                                                    .avm_beginbursttransfer   (BEGINBURSTTRANSFER),                                // (terminated)
                                                    .avm_arbiterlock          (),                                // (terminated)
                                                    .avm_lock                 (LOCK),                            // (terminated)
                                                    .avm_debugaccess          (),                                // (terminated)
                                                    .avm_transactionid        (),                                // (terminated)
                                                    .avm_readid               (8'b00000000),                     // (terminated)
                                                    .avm_writeid              (8'b00000000),                     // (terminated)
                                                    .avm_clken                (),                                // (terminated)
                                                    .avm_response             (2'b00),                           // (terminated)
                                                    .avm_writeresponserequest (),                                // (terminated)
                                                    .avm_writeresponsevalid   (1'b0),                            // (terminated)
                                                    .avm_readresponse         (8'b00000000),                     // (terminated)
                                                    .avm_writeresponse        (8'b00000000)                      // (terminated)
                                                    );

   
   //---------------------------------------------------------------------------
   //   
   // DUT
   //
   //---------------------------------------------------------------------------

   avalon_slave dut(/*AUTOINST*/
                    // Outputs
                    .READDATA           (READDATA[31:0]),
                    .WAITREQUEST        (WAITREQUEST),
                    .READDATAVALID      (READDATAVALID),
                    // Inputs
                    .CLK                (CLK),
                    .RESET              (RESET),
                    .ADDRESS            (ADDRESS[31:0]),
                    .BEGINTRANSFER      (BEGINTRANSFER),
                    .BYTE_ENABLE        (BYTE_ENABLE[3:0]),
                    .READ               (READ),
                    .WRITE              (WRITE),
                    .WRITEDATA          (WRITEDATA[31:0]),
                    .LOCK               (LOCK),
                    .BURSTCOUNT         (BURSTCOUNT),
                    .BEGINBURSTTRANSFER (BEGINBURSTTRANSFER)); 
   


   //---------------------------------------------------------------------------
   //
   // TASKS
   // 
   //---------------------------------------------------------------------------   
   task bfm_master_push_command;
      input Request_t request;
      input [31:0] address;
      input [3:0]  byte_enable;
      input [31:0] data;
      
      begin
         //$display("BFM MASTER PUSH: Addr 0x%h Data 0x%h Byte Enable 0x%h @ %d", address, data, byte_enable, $time);
         mm_master_bfm_0.set_command_request( request ); 
         mm_master_bfm_0.set_command_address(address);
         mm_master_bfm_0.set_command_byte_enable(byte_enable,0);
         mm_master_bfm_0.set_command_idle(0, 0);
         mm_master_bfm_0.set_command_init_latency(0);
         mm_master_bfm_0.set_command_burst_count(1);
         mm_master_bfm_0.set_command_burst_size(1);

         if (request == REQ_WRITE)begin
            mm_master_bfm_0.set_command_data(data, 0);      
         end
         
         mm_master_bfm_0.push_command();         
      end
   endtask //

   task bfm_master_pop_response;
      output [31:0] data;
      
      Request_t request;
      reg [31:0]    addr;      
      
      begin
         mm_master_bfm_0.pop_response();
         request = Request_t' (mm_master_bfm_0.get_response_request());  
         addr =  mm_master_bfm_0.get_response_address();
         data =   mm_master_bfm_0.get_response_data(0);
         //$display("BFM MASTER POP: Addr 0x%h Data 0x%h @ %d", addr, data, $time);
      end
   endtask //
   
   task avalon_write;
      input [31:0] address;
      input [3:0]  byte_enable;
      input [31:0] data;
      reg [31:0]   response;
      begin
         $display("AVALON WRITE: Address 0x%h Bytes 0x%h Data 0x%h @ %d", address, byte_enable, data, $time);
         
         bfm_master_push_command(REQ_WRITE, address, byte_enable, data);
         repeat (2)  @(posedge  CLK);
         bfm_master_pop_response(response);      
      end
   endtask //

   task avalon_read;
      input [31:0] address;
      input [3:0]  byte_enable;
      input [31:0] expected;
      reg [31:0]   response;
      begin
         bfm_master_push_command(REQ_READ, address, byte_enable, 0);
         repeat (2)  @(posedge  CLK);
         bfm_master_pop_response(response); 
         if (expected !== response) begin
            $display("AVALON READ FAIL: Addr 0x%h response (0x%h) != expected (0x%h) @ %d", address, response, expected, $time);
            //SIGNAL FAIL!
         end else begin
            $display("AVALON READ: Addr 0x%h response 0x%h @ %d", address, response, $time);
         end
      end
   endtask //
   
   
   //---------------------------------------------------------------------------
   //
   // TEST CASES
   // 
   //---------------------------------------------------------------------------
   
   initial begin

      #5 @(negedge RESET);
      $display("RESET RELEASED @ %d", $time);

      mm_master_bfm_0.init();
      mm_master_bfm_0.set_clken(1'b1);

      //
      // 32 bit write/read
      //
      avalon_write(32'h0000_0004, 4'hF, 32'hdead_beef);
      avalon_write(32'h0000_0008, 4'hF, 32'h5555_AA66);

      avalon_read(32'h0000_0004, 4'hF, 32'hdead_beef);
      avalon_read(32'h0000_0008, 4'hF, 32'h5555_AA66);

      //
      // 16 bit upper write/read
      //
      avalon_write(32'h0000_0004, 4'hC, 32'haaaa_1111);
      avalon_write(32'h0000_0008, 4'hC, 32'hbbbb_2222);

      avalon_read(32'h0000_0004, 4'hC, 32'haaaa_beef);
      avalon_read(32'h0000_0008, 4'hC, 32'hbbbb_AA66); 

      //
      // 16 bit lower write/read
      //
      avalon_write(32'h0000_0004, 4'h3, 32'h8888_9999);
      avalon_write(32'h0000_0008, 4'h3, 32'h7777_6666);

      avalon_read(32'h0000_0004, 4'h3, 32'haaaa_9999);
      avalon_read(32'h0000_0008, 4'h3, 32'hbbbb_6666);  


      //
      // LSB Write/Read
      //
      avalon_write(32'h0000_0004, 4'h1, 32'h8888_9901);
      avalon_write(32'h0000_0008, 4'h1, 32'h7777_6634);
      
      avalon_read(32'h0000_0004, 4'h1, 32'haaaa_9901);
      avalon_read(32'h0000_0008, 4'h1, 32'hbbbb_6634);  

      //
      // 2nd LSB Write/Read
      //
      avalon_write(32'h0000_0004, 4'h2, 32'h8888_1001);
      avalon_write(32'h0000_0008, 4'h2, 32'h7777_5934);
      
      avalon_read(32'h0000_0004, 4'h2, 32'haaaa_1001);
      avalon_read(32'h0000_0008, 4'h2, 32'hbbbb_5934);  

      //
      // 2nd MSB Write/Read
      //
      avalon_write(32'h0000_0004, 4'h4, 32'h8811_1001);
      avalon_write(32'h0000_0008, 4'h4, 32'h7722_5934);
      
      avalon_read(32'h0000_0004, 4'h4, 32'haa11_1001);
      avalon_read(32'h0000_0008, 4'h4, 32'hbb22_5934);  

      //
      // MSB Write/Read
      //
      avalon_write(32'h0000_0004, 4'h8, 32'h0011_1001);
      avalon_write(32'h0000_0008, 4'h8, 32'hAC22_5934);
      
      avalon_read(32'h0000_0004, 4'h8, 32'h0011_1001);
      avalon_read(32'h0000_0008, 4'h8, 32'hAC22_5934);  
      
      
      repeat (10) @(posedge  CLK);
      $display("SIM COMPLETE @ %d", $time);      
      $finish;
   end
   
endmodule // testbench


