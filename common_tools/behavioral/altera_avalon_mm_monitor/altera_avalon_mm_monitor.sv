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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_monitor_bfm/altera_avalon_mm_monitor.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_monitor
// =head1 SYNOPSIS
// Bridge with Avalon Bus Protocol Assertion Checker
// The macro DISABLE_ALTERA_AVALON_SIM_SVA is defined to disable SVA processing
// The macro ALTERA_AVALON_SIM_MTI must be defined to enable transaction tracing
// The macro ENABLE_ALTERA_AVALON_TRANSACTION_RECORDING must be defined to 
// enable transaction monitoring
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_monitor(
                                clk,
                                reset,
                                
                                avm_clken,
                                avs_clken,

                                avs_waitrequest,
                                avs_write,
                                avs_read,
                                avs_address,
                                avs_byteenable,
                                avs_burstcount,
                                avs_beginbursttransfer,
                                avs_begintransfer,
                                avs_writedata,
                                avs_readdata,
                                avs_readdatavalid,
                                avs_arbiterlock,
                                avs_lock,
                                avs_debugaccess,
                                avs_transactionid,
                                avs_readid,
                                avs_writeid,
                                avs_response,
                                avs_writeresponserequest,
                                avs_writeresponsevalid,
                                
                                // deprecated signals
                                avs_readresponse,
                                avs_writeresponse,
                                avm_readresponse,
                                avm_writeresponse,

                                avm_waitrequest,
                                avm_write,
                                avm_read,
                                avm_address,
                                avm_byteenable,
                                avm_burstcount,
                                avm_beginbursttransfer,
                                avm_begintransfer,
                                avm_writedata,
                                avm_readdata,
                                avm_readdatavalid,
                                avm_arbiterlock,
                                avm_lock,
                                avm_debugaccess,
                                avm_transactionid,
                                avm_readid,
                                avm_writeid,
                                avm_response,
                                avm_writeresponserequest,
                                avm_writeresponsevalid
                                );

   // =head1 PARAMETERS
   parameter AV_ADDRESS_W               = 32;   // address width
   parameter AV_SYMBOL_W                = 8;    // default symbol is byte
   parameter AV_NUMSYMBOLS              = 4;    // number of symbols per word
   parameter AV_BURSTCOUNT_W            = 3;    // burst port width
   
   // deprecated parameter
   parameter AV_WRITERESPONSE_W         = 8;
   parameter AV_READRESPONSE_W          = 8;
   
   parameter AV_CONSTANT_BURST_BEHAVIOR = 1;    // Address, burstcount, transactionid and
                                                // avm_writeresponserequest need to be held constant
                                                // in burst transaction
   parameter AV_BURST_LINEWRAP          = 0;    // line wrapping addr is set to 1
   parameter AV_BURST_BNDR_ONLY         = 0;    // addr is multiple of burst size
   parameter REGISTER_WAITREQUEST       = 0;    // Waitrequest is registered at the slave
   parameter AV_MAX_PENDING_READS       = 1;    // maximum pending read transfer count
   parameter AV_MAX_PENDING_WRITES      = 0;    // maximum pending write transfer count
   parameter AV_FIX_READ_LATENCY        = 0;    // fixed read latency in cycles

   parameter USE_READ                   = 1;    // use read port
   parameter USE_WRITE                  = 1;    // use write port
   parameter USE_ADDRESS                = 1;    // use address port
   parameter USE_BYTE_ENABLE            = 1;    // use byteenable port
   parameter USE_BURSTCOUNT             = 0;    // use burstcount port
   parameter USE_READ_DATA              = 1;    // use readdata port
   parameter USE_READ_DATA_VALID        = 1;    // use readdatavalid port
   parameter USE_WRITE_DATA             = 1;    // use writedata port
   parameter USE_BEGIN_TRANSFER         = 0;    // use begintransfer port
   parameter USE_BEGIN_BURST_TRANSFER   = 0;    // use begintbursttransfer port
   parameter USE_WAIT_REQUEST           = 1;    // use waitrequest port
   parameter USE_ARBITERLOCK            = 0;    // Use arbiterlock pin on interface
   parameter USE_LOCK                   = 0;    // Use lock pin on interface
   parameter USE_DEBUGACCESS            = 0;    // Use debugaccess pin on interface 
   parameter USE_TRANSACTIONID          = 0;    // Use transactionid interface pin
   parameter USE_WRITERESPONSE          = 0;    // Use write response interface pins
   parameter USE_READRESPONSE           = 0;    // Use read response interface pins
   parameter USE_CLKEN                  = 0;    // Use NTCM interface pins  

   parameter AV_READ_TIMEOUT            = 100;  // timeout period for read transfer
   parameter AV_WRITE_TIMEOUT           = 100;  // timeout period for write burst transfer
   parameter AV_WAITREQUEST_TIMEOUT     = 1024; // timeout period for continuous waitrequest
   parameter AV_MAX_READ_LATENCY        = 100;  // maximum read latency cycle for coverage
   parameter AV_MAX_WAITREQUESTED_READ  = 100;  // maximum waitrequested read cycle for coverage
   parameter AV_MAX_WAITREQUESTED_WRITE = 100;  // maximum waitrequested write cycle for coverage
   parameter AV_MAX_CONTINUOUS_READ          = 5;   // maximum continuous read cycle for coverage
   parameter AV_MAX_CONTINUOUS_WRITE         = 5;   // maximum continuous write cycle for coverage
   parameter AV_MAX_CONTINUOUS_WAITREQUEST   = 5;   // maximum continuous waitrequest cycle for coverage
   parameter AV_MAX_CONTINUOUS_READDATAVALID = 5;   // maximum continuous readdatavalid cycle for coverage
   parameter SLAVE_ADDRESS_TYPE = "SYMBOLS";   // Set slave interface address type, {SYMBOLS, WORDS}
   parameter MASTER_ADDRESS_TYPE = "SYMBOLS";  // Set master interface address type, {SYMBOLS, WORDS}
   
   parameter AV_READ_WAIT_TIME         = 0;  // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME        = 0;  // USE_WAIT_REQUEST is 0
   
   parameter AV_REGISTERINCOMINGSIGNALS = 0;  // Indicate that waitrequest is come from register
   parameter VHDL_ID                    = 0;   // VHDL BFM ID number

   localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam AV_MAX_BURST = USE_BURSTCOUNT ? 2**(AV_BURSTCOUNT_W-1) : 1;
   localparam INT_WIDTH = 32;
   localparam AV_TRANSACTIONID_W = 8;
   
   localparam AV_SLAVE_ADDRESS_W = (SLAVE_ADDRESS_TYPE != MASTER_ADDRESS_TYPE)? (AV_ADDRESS_W - log2(AV_NUMSYMBOLS)):AV_ADDRESS_W;
   
   localparam TAP_W = 1 +                                                  // clken
                      1 +                                                  // arbiterlock
                      1 +                                                  // lock
                      1 +                                                  // debugaccess
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // transactionid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // readid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // writeid
                      2 +                                                  // response
                      1 +                                                  // writeresponserequest
                      1 +                                                  // writeresponsevalid
                      1 +                                                  // waitrequest
                      1 +                                                  // readdatavalid
                      ((AV_DATA_W == 0)? 1:AV_DATA_W) +                    // readdata
                      1 +                                                  // write
                      1 +                                                  // read
                      ((AV_ADDRESS_W == 0)? 1:AV_ADDRESS_W) +              // address
                      ((AV_NUMSYMBOLS == 0)? 1:AV_NUMSYMBOLS) +            // byteenable
                      ((AV_BURSTCOUNT_W == 0)? 1:AV_BURSTCOUNT_W) +        // burstcount
                      1 +                                                  // beginbursttransfer
                      1 +                                                  // begintransfer
                      ((AV_DATA_W == 0)? 1:AV_DATA_W);                     // writedata

   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction  
                      
   // =head1 PINS
   // =head2 Clock Interface
   input                                           clk;
   input                                           reset;
   
   // =head2 Tightly Coupled Memory Interface
   output                                          avm_clken;
   input                                           avs_clken;

   // =head2 Avalon Master Interface
   input                                           avm_waitrequest;
   input                                           avm_readdatavalid;
   input  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avm_readdata;
   output                                          avm_write;
   output                                          avm_read;
   output [lindex(AV_ADDRESS_W):0]                 avm_address;
   output [lindex(AV_NUMSYMBOLS):0]                avm_byteenable;
   output [lindex(AV_BURSTCOUNT_W):0]              avm_burstcount;
   output                                          avm_beginbursttransfer;
   output                                          avm_begintransfer;
   output [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avm_writedata;
   output                                          avm_arbiterlock;
   output                                          avm_lock;
   output                                          avm_debugaccess;   

   output [lindex(AV_TRANSACTIONID_W):0]           avm_transactionid;
   input  [lindex(AV_TRANSACTIONID_W):0]           avm_readid;
   input  [lindex(AV_TRANSACTIONID_W):0]           avm_writeid;
   input  [1:0]                                    avm_response;
   output                                          avm_writeresponserequest;
   input                                           avm_writeresponsevalid;      
   
   // deprecated
   input  [lindex(AV_READRESPONSE_W):0]            avm_readresponse;
   input  [lindex(AV_WRITERESPONSE_W):0]           avm_writeresponse;

   // =head2 Avalon Slave Interface
   output                                          avs_waitrequest;
   output                                          avs_readdatavalid;
   output [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avs_readdata;
   input                                           avs_write;
   input                                           avs_read;
   input  [lindex(AV_SLAVE_ADDRESS_W):0]           avs_address;
   input  [lindex(AV_NUMSYMBOLS):0]                avs_byteenable;
   input  [lindex(AV_BURSTCOUNT_W):0]              avs_burstcount;
   input                                           avs_beginbursttransfer;
   input                                           avs_begintransfer;
   input  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avs_writedata;
   input                                           avs_arbiterlock;
   input                                           avs_lock;
   input                                           avs_debugaccess;
   
   input  [lindex(AV_TRANSACTIONID_W):0]           avs_transactionid;
   output [lindex(AV_TRANSACTIONID_W):0]           avs_readid;
   output [lindex(AV_TRANSACTIONID_W):0]           avs_writeid;
   output [1:0]                                    avs_response;
   input                                           avs_writeresponserequest;
   output                                          avs_writeresponsevalid;
   
   // deprecated
   output [lindex(AV_READRESPONSE_W):0]            avs_readresponse;
   output [lindex(AV_WRITERESPONSE_W):0]           avs_writeresponse;

   logic                                           avm_clken;
   logic                                           avs_clken;
   
   logic                                           avm_waitrequest;
   logic                                           avm_readdatavalid;
   logic  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avm_readdata;
   logic                                           avm_write;
   logic                                           avm_read;
   logic [lindex(AV_ADDRESS_W):0]                  avm_address;
   logic [lindex(AV_NUMSYMBOLS):0]                 avm_byteenable;
   logic [lindex(AV_BURSTCOUNT_W):0]               avm_burstcount;
   logic                                           avm_beginbursttransfer;
   logic                                           avm_begintransfer;
   logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]   avm_writedata;
   logic                                           avm_arbiterlock;
   logic                                           avm_lock;
   logic                                           avm_debugaccess;
   
   logic [lindex(AV_TRANSACTIONID_W):0]            avm_transactionid;
   logic [lindex(AV_TRANSACTIONID_W):0]            avm_readid;
   logic [lindex(AV_TRANSACTIONID_W):0]            avm_writeid;
   logic [1:0]                                     avm_response;
   logic                                           avm_writeresponserequest;
   logic                                           avm_writeresponsevalid;
   
   // deprecated
   logic [lindex(AV_READRESPONSE_W):0]             avm_readresponse;
   logic [lindex(AV_WRITERESPONSE_W):0]            avm_writeresponse;
   

   logic                                           avs_waitrequest;
   logic                                           avs_readdatavalid;
   logic  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]  avs_readdata;
   logic                                           avs_write;
   logic                                           avs_read;
   logic [lindex(AV_SLAVE_ADDRESS_W):0]            avs_address;
   logic [lindex(AV_NUMSYMBOLS):0]                 avs_byteenable;
   logic [lindex(AV_BURSTCOUNT_W):0]               avs_burstcount;
   logic                                           avs_beginbursttransfer;
   logic                                           avs_begintransfer;
   logic [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0]   avs_writedata;
   logic                                           avs_arbiterlock;
   logic                                           avs_lock;
   logic                                           avs_debugaccess;
   
   logic [lindex(AV_TRANSACTIONID_W):0]            avs_transactionid;
   logic [lindex(AV_TRANSACTIONID_W):0]            avs_readid;
   logic [lindex(AV_TRANSACTIONID_W):0]            avs_writeid;
   logic [1:0]                                     avs_response;
   logic                                           avs_writeresponserequest;
   logic                                           avs_writeresponsevalid;      
   
   // deprecated
   logic [lindex(AV_READRESPONSE_W):0]             avs_readresponse;
   logic [lindex(AV_WRITERESPONSE_W):0]            avs_writeresponse;
   
   logic [lindex(TAP_W):0]                         tap;
   
   logic [31:0] read_wait_time = 0;
   logic [31:0] write_wait_time = 0;
   logic local_avs_waitrequest;
   
   //--------------------------------------------------------------------------
   // =head1 DESCRIPTION
   // The component acts as a simple repeater or bridge with Avalon bus 
   // signals passed through from the slave to master interface.
   // The instantiated altera_avalon_mm_monitor snoops all passing Avalon
   // bus signals and performs assertion checking and measures coverage on
   // Avalon Memory Mapped protocol properties.   
   // =cut
   //--------------------------------------------------------------------------

   always_comb begin
      // repeater
      avm_clken                     <= avs_clken;
      
      if (USE_WAIT_REQUEST == 0) begin
         avs_waitrequest            <= local_avs_waitrequest;
      end else begin
         avs_waitrequest            <= avm_waitrequest;
      end

      avs_readdatavalid             <= avm_readdatavalid;
      avs_readdata                  <= avm_readdata;
   
      avm_write                     <= avs_write;
      avm_read                      <= avs_read;
      if (SLAVE_ADDRESS_TYPE != MASTER_ADDRESS_TYPE)
         avm_address                <= address_shift(avs_address);
      else
         avm_address                <= avs_address;
      avm_byteenable                <= avs_byteenable;
      avm_burstcount                <= avs_burstcount;
      avm_beginbursttransfer        <= avs_beginbursttransfer;
      avm_begintransfer             <= avs_begintransfer;
      avm_writedata                 <= avs_writedata;
      
      avm_arbiterlock               <= avs_arbiterlock;
      avm_lock                      <= avs_lock;
      avm_debugaccess               <= avs_debugaccess;
      avm_transactionid             <= avs_transactionid;
      avs_readid                    <= avm_readid;
      avs_writeid                   <= avm_writeid;
      avm_writeresponserequest      <= avs_writeresponserequest;
      avs_writeresponsevalid        <= avm_writeresponsevalid;
      avs_response                  <= avm_response;
      
      // snoop bus for assertion and coverage checking
      if (SLAVE_ADDRESS_TYPE != MASTER_ADDRESS_TYPE) begin
         tap <=  {
                 avs_clken,
                 avs_arbiterlock,
                 avs_lock,
                 avs_debugaccess,
                 avs_transactionid,
                 avm_readid,
                 avm_writeid,
                 avm_response,
                 avs_writeresponserequest,
                 avm_writeresponsevalid,
                 
                 (USE_WAIT_REQUEST == 0)? local_avs_waitrequest:avm_waitrequest,
                 avm_readdatavalid,
                 avm_readdata,

                 avs_write,
                 avs_read,
                 address_shift(avs_address),
                 avs_byteenable,
                 avs_burstcount,
                 avs_beginbursttransfer,
                 avs_begintransfer,
                 avs_writedata 
                 }; 
      end else begin
         tap <=  {
                 avs_clken,
                 avs_arbiterlock,
                 avs_lock,
                 avs_debugaccess,
                 avs_transactionid,
                 avm_readid,
                 avm_writeid,
                 avm_response,
                 avs_writeresponserequest,
                 avm_writeresponsevalid,
                 
                 (USE_WAIT_REQUEST == 0)? local_avs_waitrequest:avm_waitrequest,
                 avm_readdatavalid,
                 avm_readdata,

                 avs_write,
                 avs_read,
                 avs_address,
                 avs_byteenable,
                 avs_burstcount,
                 avs_beginbursttransfer,
                 avs_begintransfer,
                 avs_writedata 
                 }; 
      end
   end
   
   //--------------------------------------------------------------------------
   // =head1 ALTERA_AVALON_MM_MONITOR_ASSERTION
   // This module implements Avalon MM protocol assertion checking for 
   // simulation.
   // Component name = monitor_assertion.
   // =cut
   //--------------------------------------------------------------------------
   altera_avalon_mm_monitor_assertion
     #(
       .AV_ADDRESS_W               (AV_ADDRESS_W),
       .AV_SYMBOL_W                (AV_SYMBOL_W),
       .AV_NUMSYMBOLS              (AV_NUMSYMBOLS),
       .AV_BURSTCOUNT_W            (AV_BURSTCOUNT_W),
       .AV_CONSTANT_BURST_BEHAVIOR (AV_CONSTANT_BURST_BEHAVIOR),
       .AV_BURST_LINEWRAP          (AV_BURST_LINEWRAP),
       .AV_BURST_BNDR_ONLY         (AV_BURST_BNDR_ONLY),
       .AV_MAX_PENDING_READS       (AV_MAX_PENDING_READS),
       .AV_MAX_PENDING_WRITES      (AV_MAX_PENDING_WRITES),
       .AV_FIX_READ_LATENCY        (AV_FIX_READ_LATENCY),
       
       .REGISTER_WAITREQUEST       (REGISTER_WAITREQUEST),       

       .USE_READ                   (USE_READ),             
       .USE_WRITE                  (USE_WRITE),               
       .USE_ADDRESS                (USE_ADDRESS),              
       .USE_BYTE_ENABLE            (USE_BYTE_ENABLE),
       .USE_BURSTCOUNT             (USE_BURSTCOUNT),        
       .USE_READ_DATA              (USE_READ_DATA),         
       .USE_READ_DATA_VALID        (USE_READ_DATA_VALID),
       .USE_WRITE_DATA             (USE_WRITE_DATA),    
       .USE_BEGIN_TRANSFER         (USE_BEGIN_TRANSFER),
       .USE_BEGIN_BURST_TRANSFER   (USE_BEGIN_BURST_TRANSFER),
       .USE_WAIT_REQUEST           (USE_WAIT_REQUEST),
       
       .USE_ARBITERLOCK            (USE_ARBITERLOCK),
       .USE_LOCK                   (USE_LOCK),
       .USE_DEBUGACCESS            (USE_DEBUGACCESS),
       .USE_TRANSACTIONID          (USE_TRANSACTIONID),
       .USE_WRITERESPONSE          (USE_WRITERESPONSE),
       .USE_READRESPONSE           (USE_READRESPONSE),
       .USE_CLKEN                  (USE_CLKEN),

       .AV_READ_TIMEOUT            (AV_READ_TIMEOUT),
       .AV_WRITE_TIMEOUT           (AV_WRITE_TIMEOUT),
       .AV_WAITREQUEST_TIMEOUT     (AV_WAITREQUEST_TIMEOUT),
       .AV_READ_WAIT_TIME          (AV_READ_WAIT_TIME),
       .AV_WRITE_WAIT_TIME         (AV_WRITE_WAIT_TIME),
       .AV_REGISTERINCOMINGSIGNALS (AV_REGISTERINCOMINGSIGNALS),
       .SLAVE_ADDRESS_TYPE         (SLAVE_ADDRESS_TYPE),
       .MASTER_ADDRESS_TYPE        (MASTER_ADDRESS_TYPE)
      ) 
     master_assertion (
                      .clk         (clk),
                      .reset       (reset),
                      .tap         (tap)
                      );

   //--------------------------------------------------------------------------
   // =head1 ALTERA_AVALON_MM_MONITOR_COVERAGE
   // This module implements Avalon MM protocol coverage for simulation. 
   // Component name = monitor_coverage.
   // =cut
   //--------------------------------------------------------------------------
   altera_avalon_mm_monitor_coverage
     #(
       .AV_ADDRESS_W               (AV_ADDRESS_W),
       .AV_SYMBOL_W                (AV_SYMBOL_W),
       .AV_NUMSYMBOLS              (AV_NUMSYMBOLS),
       .AV_BURSTCOUNT_W            (AV_BURSTCOUNT_W),
       .AV_BURST_LINEWRAP          (AV_BURST_LINEWRAP),
       .AV_BURST_BNDR_ONLY         (AV_BURST_BNDR_ONLY),
       .AV_MAX_PENDING_READS       (AV_MAX_PENDING_READS),
       .AV_MAX_PENDING_WRITES      (AV_MAX_PENDING_WRITES),
       .AV_FIX_READ_LATENCY        (AV_FIX_READ_LATENCY),
       
       .REGISTER_WAITREQUEST       (REGISTER_WAITREQUEST),
       
       .USE_READ                   (USE_READ),             
       .USE_WRITE                  (USE_WRITE),               
       .USE_ADDRESS                (USE_ADDRESS),              
       .USE_BYTE_ENABLE            (USE_BYTE_ENABLE),
       .USE_BURSTCOUNT             (USE_BURSTCOUNT),        
       .USE_READ_DATA              (USE_READ_DATA),         
       .USE_READ_DATA_VALID        (USE_READ_DATA_VALID),
       .USE_WRITE_DATA             (USE_WRITE_DATA),    
       .USE_BEGIN_TRANSFER         (USE_BEGIN_TRANSFER),
       .USE_BEGIN_BURST_TRANSFER   (USE_BEGIN_BURST_TRANSFER),
       .USE_WAIT_REQUEST           (USE_WAIT_REQUEST),
       .USE_CLKEN                  (USE_CLKEN),
       
       .USE_ARBITERLOCK            (USE_ARBITERLOCK),
       .USE_LOCK                   (USE_LOCK),
       .USE_DEBUGACCESS            (USE_DEBUGACCESS),
       .USE_TRANSACTIONID          (USE_TRANSACTIONID),
       .USE_WRITERESPONSE          (USE_WRITERESPONSE),
       .USE_READRESPONSE           (USE_READRESPONSE),
       
       .AV_MAX_READ_LATENCY        (AV_MAX_READ_LATENCY),
       .AV_MAX_WAITREQUESTED_READ  (AV_MAX_WAITREQUESTED_READ),
       .AV_MAX_WAITREQUESTED_WRITE (AV_MAX_WAITREQUESTED_WRITE),
       .AV_MAX_CONTINUOUS_READ     (AV_MAX_CONTINUOUS_READ),
       .AV_MAX_CONTINUOUS_WRITE    (AV_MAX_CONTINUOUS_WRITE),
       .AV_MAX_CONTINUOUS_WAITREQUEST     (AV_MAX_CONTINUOUS_WAITREQUEST),
       .AV_MAX_CONTINUOUS_READDATAVALID   (AV_MAX_CONTINUOUS_READDATAVALID),
       .AV_READ_WAIT_TIME          (AV_READ_WAIT_TIME),
       .AV_WRITE_WAIT_TIME         (AV_WRITE_WAIT_TIME) 
      ) 
     master_coverage(
                    .clk         (clk),
                    .reset       (reset),
                    .tap         (tap)
                    );
                    
   //--------------------------------------------------------------------------
   // =head1 ALTERA_AVALON_MM_MONITOR_TRANSACTIONS
   // This module implements Avalon-MM the transaction recorder.
   // =cut
   //--------------------------------------------------------------------------
   `ifdef ENABLE_ALTERA_AVALON_TRANSACTION_RECORDING
   altera_avalon_mm_monitor_transactions
     #(
       .AV_ADDRESS_W               (AV_ADDRESS_W),
       .AV_SYMBOL_W                (AV_SYMBOL_W),
       .AV_NUMSYMBOLS              (AV_NUMSYMBOLS),
       .AV_BURSTCOUNT_W            (AV_BURSTCOUNT_W),
       .AV_BURST_LINEWRAP          (AV_BURST_LINEWRAP),
       .AV_BURST_BNDR_ONLY         (AV_BURST_BNDR_ONLY),
       .AV_MAX_PENDING_READS       (AV_MAX_PENDING_READS),
       .AV_MAX_PENDING_WRITES      (AV_MAX_PENDING_WRITES),
       .AV_FIX_READ_LATENCY        (AV_FIX_READ_LATENCY),
       
       // deprecated
       // deprecated parameter
       .AV_WRITERESPONSE_W         (AV_WRITERESPONSE_W),
       .AV_READRESPONSE_W          (AV_READRESPONSE_W),
       
       .REGISTER_WAITREQUEST       (REGISTER_WAITREQUEST),

       .USE_READ                   (USE_READ),             
       .USE_WRITE                  (USE_WRITE),               
       .USE_ADDRESS                (USE_ADDRESS),              
       .USE_BYTE_ENABLE            (USE_BYTE_ENABLE),
       .USE_BURSTCOUNT             (USE_BURSTCOUNT),        
       .USE_READ_DATA              (USE_READ_DATA),         
       .USE_READ_DATA_VALID        (USE_READ_DATA_VALID),
       .USE_WRITE_DATA             (USE_WRITE_DATA),    
       .USE_BEGIN_TRANSFER         (USE_BEGIN_TRANSFER),
       .USE_BEGIN_BURST_TRANSFER   (USE_BEGIN_BURST_TRANSFER),
       .USE_WAIT_REQUEST           (USE_WAIT_REQUEST),
       .USE_CLKEN                  (USE_CLKEN),
       
       .USE_ARBITERLOCK            (USE_ARBITERLOCK),
       .USE_LOCK                   (USE_LOCK),
       .USE_DEBUGACCESS            (USE_DEBUGACCESS),
       .USE_TRANSACTIONID          (USE_TRANSACTIONID),
       .USE_WRITERESPONSE          (USE_WRITERESPONSE),
       .USE_READRESPONSE           (USE_READRESPONSE),

       .AV_READ_WAIT_TIME          (AV_READ_WAIT_TIME),
       .AV_WRITE_WAIT_TIME         (AV_WRITE_WAIT_TIME) 
      ) 
     monitor_trans(
                    .clk         (clk),
                    .reset       (reset),
                    .tap         (tap)
                    );
   `endif
   
   // synthesis translate_off
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;

   typedef bit [AV_ADDRESS_W-1:0]                    AvalonAddress_t;
   typedef bit [AV_BURSTCOUNT_W-1:0]                 AvalonBurstCount_t;   
   typedef bit [AV_MAX_BURST-1:0][AV_DATA_W-1:0]     AvalonData_t;
   typedef bit [AV_MAX_BURST-1:0][AV_NUMSYMBOLS-1:0] AvalonByteEnable_t;
   typedef bit [AV_MAX_BURST-1:0][INT_WIDTH-1:0]     AvalonLatency_t;   

   typedef struct packed {
                          Request_t                  request;     
                          AvalonAddress_t            address;     // start address
                          AvalonBurstCount_t         burst_count; // burst length
                          AvalonData_t               data;        // write data
                          AvalonByteEnable_t         byte_enable; // hot encoded  
                          int                        burst_cycle;  
                         } SlaveCommand_t;

   typedef struct packed {
                          Request_t                  request;     
                          AvalonAddress_t            address;     // start addr
                          AvalonBurstCount_t         burst_count; // burst length
                          AvalonData_t               data;        // read data
                          AvalonLatency_t            read_latency;
                          AvalonLatency_t            wait_latency;
                         } MasterResponse_t;
                         

   //--------------------------------------------------------------------------   
   // =head1 Public Methods API
   // This section describes the public methods in the application programming
   // interface (API). In this case the application program is the test bench
   // which instantiates and controls and queries state of this component.
   // Test programs must only use these public access methods and events to 
   // communicate with this BFM component. The API and the module pins
   // are the only interfaces in this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   //--------------------------------------------------------------------------   

   function automatic string get_version();  // public
      // Return component version as a string of three integers separated by periods.
      // For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "13.1";
      return ret_version;      
   endfunction 
   
   // =cut
   //--------------------------------------------------------------------------   
   // Public API Method(s) - end
   //--------------------------------------------------------------------------   

   function automatic void hello();
      // introduction message to the console      
      string message;
      $sformat(message, "%m: - Hello from altera_avalon_mm_monitor");
      print(VERBOSITY_INFO, message);            
      `ifdef DISABLE_ALTERA_AVALON_SIM_SVA
      $sformat(message, "%m: -   Assertions disabled (DISABLE_ALTERA_AVALON_SIM_SVA defined)");
      `else
      $sformat(message, "%m: -   Assertions enabled (DISABLE_ALTERA_AVALON_SIM_SVA undefined)");      
      `endif
      print(VERBOSITY_INFO, message);      
      `ifdef ALTERA_AVALON_SIM_MTI
      $sformat(message, "%m: -   Transaction tracing enabled (ALTERA_AVALON_SIM_MTI defined)");
      `else
      $sformat(message, "%m: -   Transaction tracing disabled (ALTERA_AVALON_SIM_MTI undefined)");
      `endif
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/08/11 $");
      print(VERBOSITY_INFO, message);      
      print_divider(VERBOSITY_INFO);
   endfunction

   //-------------------------------------------------------------------------- 
   // The Mentor QuestaSim simulation transaction tracing feature is supported
   // by enabling the macro: +define+ALTERA_AVALON_SIM_MTI in CLI
   SlaveCommand_t    current_command;
   MasterResponse_t  completed_response;
   
   int               command_trans;
   int               command_trans_stream;

   int               addr_offset = 0;
   bit               burst_mode = 0;   
   int               command_counter = 0;
   int               response_counter = 0;
   int               clock_counter = 0;
   string            message = "*unitialized*";

   event             signal_fatal_error;
   event             command;
   event             response;
   
   function automatic void init_transaction_recording();   
      `ifdef ALTERA_AVALON_SIM_MTI
      command_trans_stream = 
         $create_transaction_stream("avalon_mm_monitor_bfm_cmd");
      `endif
   endfunction

   function automatic void begin_record_command_trans();
      `ifdef ALTERA_AVALON_SIM_MTI
         command_trans = $begin_transaction(command_trans_stream, "Command");
      `endif
   endfunction

   function automatic void end_record_command_trans();
      `ifdef ALTERA_AVALON_SIM_MTI
      string field;
      if (!reset) begin      
         $add_attribute(command_trans, current_command.request, "request");
         $add_attribute(command_trans, current_command.address, "address");
         $add_attribute(command_trans, current_command.burst_count, "burst_count");
         if (current_command.request == REQ_WRITE) begin
            for (int i=0; i<current_command.burst_count; i++) begin
               $sformat(field, "data_cycle_%0d", i);
               $add_attribute(command_trans, current_command.data[i], field);
               $sformat(field, "byte_enable_cycle_%0d", i);
               $add_attribute(command_trans, current_command.byte_enable[i], field);
            end
         end 
         $end_transaction(command_trans);
         $free_transaction(command_trans);
      end
      `endif
   endfunction 

   //--------------------------------------------------------------------------   

   initial begin
      // $vcdpluson;  // for debugging with DVE      
      hello();
      init_transaction_recording();
   end

   //--------------------------------------------------------------------------
   always @(posedge clk) clock_counter++;   
   always @(command) command_counter++;
   always @(response) response_counter++;   

   always @(signal_fatal_error) begin
      $sformat(message, "%m: Terminate simulation.");
      print(VERBOSITY_FAILURE, message);
      $finish;
   end
   
   always @(posedge clk) begin
      fork: monitor
      begin
         #1 monitor_command();
         begin_record_command_trans();
      end
      begin
         @(posedge clk);
         end_record_command_trans();
      end
      join_any;
   end

   task monitor_command();
      current_command.address = avm_address;
      current_command.burst_count = avm_burstcount;
      if (avm_read && avm_write) begin
         current_command.address = avm_address;
         $sformat(message, "%m: Error - both write and read active, address: %0d", 
                  current_command.address);
         print(VERBOSITY_FAILURE, message);
      end else if (avm_write) begin
         if (avm_beginbursttransfer) begin
            current_command = '0;
            addr_offset = 0;
            burst_mode = 1;
         end else if (burst_mode) begin
            if (addr_offset == avm_burstcount-1) begin
               burst_mode = 0;
               addr_offset = 0;
            end else begin
               addr_offset++;
            end
         end else begin
            current_command = '0;
            burst_mode = 0;
            addr_offset = 0;
         end  
         current_command.request = REQ_WRITE;
         current_command.data[addr_offset] = avm_writedata;
         current_command.byte_enable[addr_offset] = avm_byteenable;
         current_command.burst_cycle = addr_offset;  
         ->command;
      end else if (avm_read) begin
         current_command = '0;
         burst_mode = 0;
         addr_offset = 0;
         current_command.request = REQ_READ;
         // according to the Avalon spec, we expect that the master does 
         // not drive writedata and byteenable during read request, but
         // this behavior may be violated in custom components
         current_command.data = avm_writedata; 
         current_command.byte_enable = avm_byteenable; 
      end 
   endtask
   
   always @(posedge clk) begin
      if (USE_WAIT_REQUEST == 0) begin
         if (reset) begin
            local_avs_waitrequest = 0;
            read_wait_time = 0;
            write_wait_time = 0;
         end else begin
            local_avs_waitrequest = 0;
            if (AV_READ_WAIT_TIME > 0) begin
               #1;
               if (avs_read) begin
                  if (read_wait_time < AV_READ_WAIT_TIME) begin
                     local_avs_waitrequest = 1;
                     read_wait_time++;
                  end else begin
                     local_avs_waitrequest = 0;
                     read_wait_time = 0;
                  end
               end
            end
            
            if (AV_WRITE_WAIT_TIME > 0) begin
               #1;
               if (avs_write) begin
                  if (write_wait_time < AV_WRITE_WAIT_TIME) begin
                     local_avs_waitrequest = 1;
                     write_wait_time++;
                  end else begin
                     local_avs_waitrequest = 0;
                     write_wait_time = 0;
                  end
               end
            end
         end
      end else begin
         local_avs_waitrequest = avm_waitrequest;
      end
   end
   
   // synthesis translate_on
   
   function integer log2(
    input int value
    );
//-----------------------------------------------------------------------------
// Mathematic logarithm function with base as 2.
//-----------------------------------------------------------------------------
      value = value-1;
      for (log2=0; value>0; log2=log2+1)
      begin
         value = value>>1;
      end

   endfunction: log2

   function logic [AV_ADDRESS_W-1:0] address_shift(
    input logic [AV_ADDRESS_W-1:0] value
    );
//-----------------------------------------------------------------------------
// Shift the slave interface address back as master interface address.
//-----------------------------------------------------------------------------
      if (value >= 0)
         address_shift = value << log2(AV_NUMSYMBOLS);
      else
         address_shift = 'x;

   endfunction: address_shift
   
endmodule 

