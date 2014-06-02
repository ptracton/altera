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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_monitor_bfm/altera_avalon_mm_monitor_assertion.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_monitor_assertion
// =head1 SYNOPSIS
// Memory Mapped Avalon Bus Protocol Checker
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This module implements Avalon MM protocol assertion checking for simulation.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_monitor_assertion(
                                          clk,
                                          reset,
                                          tap
                                         );

   // =head1 PARAMETERS
   parameter AV_ADDRESS_W               = 32;   // address width
   parameter AV_SYMBOL_W                = 8;    // default symbol is byte
   parameter AV_NUMSYMBOLS              = 4;    // number of symbols per word
   parameter AV_BURSTCOUNT_W            = 3;    // burst port width
      
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
   parameter USE_CLKEN                  = 0;    // Use clken interface pins

   parameter AV_READ_TIMEOUT            = 100;  // timeout period for read transfer
   parameter AV_WRITE_TIMEOUT           = 100;  // timeout period for write burst transfer
   parameter AV_WAITREQUEST_TIMEOUT     = 1024; // timeout period for continuous waitrequest
   parameter AV_MAX_READ_LATENCY        = 100;  // maximum read latency cycle for coverage
   parameter AV_MAX_WAITREQUESTED_READ  = 100;  // maximum waitrequested read cycle for coverage
   parameter AV_MAX_WAITREQUESTED_WRITE = 100;  // maximum waitrequested write cycle for coverage
   parameter SLAVE_ADDRESS_TYPE = "SYMBOLS";   // Set slave interface address type, {SYMBOLS, WORDS}
   parameter MASTER_ADDRESS_TYPE = "SYMBOLS";  // Set master interface address type, {SYMBOLS, WORDS}
   
   parameter AV_READ_WAIT_TIME         = 0;     // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME        = 0;     // USE_WAIT_REQUEST is 0
   
   parameter AV_REGISTERINCOMINGSIGNALS = 0;    // Indicate that waitrequest is come from register 

   localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam AV_MAX_BURST = USE_BURSTCOUNT ? 2**(AV_BURSTCOUNT_W-1) : 1;
   localparam INT_WIDTH = 32;
   localparam MAX_ID = (AV_MAX_PENDING_READS*AV_MAX_BURST > 100? AV_MAX_PENDING_READS*AV_MAX_BURST:100);
   localparam AV_TRANSACTIONID_W = 8;
   
   localparam TAP_W = 1 +                                                  // clken
                      1 +                                                  // arbiterlock
                      1 +                                                  // lock
                      1 +                                                  // debugaccess
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // transactionid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // readid
                      ((AV_TRANSACTIONID_W == 0)? 1:AV_TRANSACTIONID_W) +  // avm_writeid
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

   // =head1 PINS
   // =head2 Clock Interface   
   input                                             clk;
   input                                             reset; 

   // =head2 Avalon Monitor Interface 
   // Interface consists of Avalon Memory-Mapped Interface.
   // =cut
   
   // =pod
   input  [TAP_W-1:0]                                tap;
   // =cut
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction  
   
   //-------------------------------------------------------------------------- 
   // synthesis translate_off

   import verbosity_pkg::*;
   import avalon_mm_pkg::*;

   typedef bit [AV_ADDRESS_W-1:0]                    AvalonAddress_t;
   typedef bit [AV_BURSTCOUNT_W-1:0]                 AvalonBurstCount_t;   
   typedef bit [AV_MAX_BURST-1:0][AV_DATA_W-1:0]     AvalonData_t;
   typedef bit [AV_MAX_BURST-1:0][AV_NUMSYMBOLS-1:0] AvalonByteEnable_t;
   typedef bit [AV_MAX_BURST-1:0][INT_WIDTH-1:0]     AvalonLatency_t; 
   typedef bit [AV_MAX_BURST-1:0][1:0]               AvalonReadResponseStatus_t;

   typedef struct packed {
                          Request_t                  request;     
                          AvalonAddress_t            address;     // start address
                          AvalonBurstCount_t         burst_count; // burst length
                          AvalonData_t               data;        // write data
                          AvalonByteEnable_t         byte_enable; // hot encoded  
                          int                        burst_cycle;
                          logic                      write_response_request;
                         } SlaveCommand_t;

   typedef struct packed {
                          Request_t                  request;     
                          AvalonAddress_t            address;     // start addr
                          AvalonBurstCount_t         burst_count; // burst length
                          AvalonData_t               data;        // read data
                          AvalonLatency_t            read_latency;
                          AvalonLatency_t            wait_latency;
                          AvalonReadResponseStatus_t read_response;
                          AvalonResponseStatus_t     write_response;
                         } MasterResponse_t;

   event                                  event_a_half_cycle_reset_legal;
   event                                  event_a_no_read_during_reset;
   event                                  event_a_no_write_during_reset;
   event                                  event_a_exclusive_read_write;
   event                                  event_a_begintransfer_single_cycle;
   event                                  event_a_begintransfer_legal;
   event                                  event_a_begintransfer_exist;
   event                                  event_a_beginbursttransfer_single_cycle;
   event                                  event_a_beginbursttransfer_legal;
   event                                  event_a_beginbursttransfer_exist;
   event                                  event_a_less_than_burstcount_max_size;
   event                                  event_a_byteenable_legal;
   event                                  event_a_constant_during_waitrequest;
   event                                  event_a_constant_during_burst;
   event                                  event_a_burst_legal;
   event                                  event_a_waitrequest_during_reset;
   event                                  event_a_no_readdatavalid_during_reset;
   event                                  event_a_less_than_maximumpendingreadtransactions;
   event                                  event_a_waitrequest_timeout;
   event                                  event_a_write_burst_timeout;
   event                                  event_a_read_response_timeout;
   event                                  event_a_read_response_sequence;
   event                                  event_a_readid_sequence;
   event                                  event_a_writeid_sequence;
   event                                  event_a_constant_during_clk_disabled;
   event                                  event_a_register_incoming_signals;
   event                                  event_a_address_align_with_data_width;
   event                                  event_a_write_response_timeout;
   event                                  event_a_unrequested_write_response;
   

   bit [1:0]                              reset_flag = 2'b11;
   bit                                    read_transaction_flag = 0;
   bit                                    read_without_waitrequest_flag = 0;
   bit                                    byteenable_legal_flag = 0;
   bit                                    byteenable_single_bit_flag = 0;
   bit                                    byteenable_continual_bit_flag = 0;
   bit                                    reset_half_cycle_flag = 0;
   logic [MAX_ID:0]                       read_response_timeout_start_flag = 0;

   bit                                    enable_a_half_cycle_reset_legal = 1;
   bit                                    enable_a_no_read_during_reset = 1;
   bit                                    enable_a_no_write_during_reset = 1;
   bit                                    enable_a_exclusive_read_write = 1;
   bit                                    enable_a_begintransfer_single_cycle = 1;
   bit                                    enable_a_begintransfer_legal = 1;
   bit                                    enable_a_begintransfer_exist = 1;
   bit                                    enable_a_beginbursttransfer_single_cycle = 1;
   bit                                    enable_a_beginbursttransfer_legal = 1;
   bit                                    enable_a_beginbursttransfer_exist = 1;
   bit                                    enable_a_less_than_burstcount_max_size = 1;
   bit                                    enable_a_byteenable_legal = 1;
   bit                                    enable_a_constant_during_waitrequest = 1;
   bit                                    enable_a_constant_during_burst = 1;
   bit                                    enable_a_burst_legal = 1;
   bit                                    enable_a_waitrequest_during_reset = 1;
   bit                                    enable_a_no_readdatavalid_during_reset = 1;
   bit                                    enable_a_less_than_maximumpendingreadtransactions = 1;
   bit                                    enable_a_waitrequest_timeout = 1;
   bit                                    enable_a_write_burst_timeout = 1;
   bit                                    enable_a_read_response_timeout = 1;
   bit                                    enable_a_read_response_sequence = 1;
   bit                                    enable_a_readid_sequence = 1;
   bit                                    enable_a_writeid_sequence = 1;
   bit                                    enable_a_constant_during_clk_disabled = 1;
   bit                                    enable_a_register_incoming_signals = 1;
   bit                                    enable_a_address_align_with_data_width = 1;
   bit                                    enable_a_write_response_timeout = 1;
   bit                                    enable_a_unrequested_write_response = 1;

   int                                    write_burst_counter = 0;
   int                                    pending_read_counter = 0;
   int                                    write_burst_timeout_counter = 0;
   int                                    waitrequest_timeout_counter = 0;
   logic [MAX_ID:0][31:0]                 temp_read_response_timeout_counter = 0;
   int                                    read_response_timeout_counter = 0;
   int                                    read_id = 0;
   int                                    readdatavalid_id = 0;
   int                                    byteenable_bit_counter = 0;
   int                                    reset_counter = 1;
   bit                                    write_burst_completed = 0;
   logic [MAX_ID:0][AV_BURSTCOUNT_W-1:0] read_burst_counter = 0;
   logic [AV_TRANSACTIONID_W-1:0]         write_transactionid_queued[$];
   logic [AV_TRANSACTIONID_W-1:0]         read_transactionid_queued[$];
   int                                    write_response_burstcount = 0;
   int                                    write_burstcount_queued[$];
   int                                    read_response_burstcount = 0;
   int                                    read_burstcount_queued[$];
   int                                    temp_write_transactionid_queued = 0;
   int                                    temp_read_transactionid_queued = 0;
   int                                    fix_latency_queued[$];
   int                                    fix_latency_queued_counter = 0;
   int                                    pending_write_response = 0;
   int                                    write_response_timeout = 100;
   logic [AV_MAX_PENDING_WRITES-1:0][31:0] write_response_timeout_counter;
   logic                                  request_for_write_response = 0;
   logic                                  past_readdatavalid = 0;
   logic                                  past_writeresponsevalid = 0;
   logic [lindex(AV_TRANSACTIONID_W):0]   past_writeid;
   logic [lindex(AV_TRANSACTIONID_W):0]   past_readid;
   logic                                  round_over = 0;
   logic                                  command_while_clken = 0;
   logic                                  waitrequested_command_while_clken = 0;

   //--------------------------------------------------------------------------
   // unpack Avalon bus interface tap into individual port signals

   logic                                  waitrequest;
   logic                                  readdatavalid;
   logic [lindex(AV_DATA_W):0]            readdata;
   logic                                  write;
   logic                                  read;
   logic [lindex(AV_ADDRESS_W):0]         address;
   logic [lindex(AV_NUMSYMBOLS):0]        byteenable;
   logic [lindex(AV_BURSTCOUNT_W):0]      burstcount;
   logic                                  beginbursttransfer;
   logic                                  begintransfer;
   logic [lindex(AV_DATA_W):0]            writedata;
   logic                                  arbiterlock;
   logic                                  lock;
   logic                                  debugaccess;
   
   logic [lindex(AV_TRANSACTIONID_W):0]   transactionid;
   logic [lindex(AV_TRANSACTIONID_W):0]   readid;
   logic [lindex(AV_TRANSACTIONID_W):0]   writeid;
   logic [1:0]                            response;
   logic                                  writeresponserequest;
   logic                                  writeresponsevalid;      
   logic                                  clken;

   always_comb begin

      clken <= (USE_CLKEN == 1)? 
                      tap[3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+21:
                          3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+21] : 1;
   
      arbiterlock <= (USE_ARBITERLOCK == 1)? 
                      tap[3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+20:
                          3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+20] : 0;
      
      lock <= (USE_LOCK == 1)? 
                      tap[3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+19:
                          3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+19] : 0;
      
      debugaccess <= (USE_DEBUGACCESS == 1)? 
                      tap[3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+18:
                          3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+18] : 0;
      
      transactionid <= (USE_TRANSACTIONID == 1)? 
                      tap[3*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+17:
                          2*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+17] : 0;
      
      readid <= (USE_READRESPONSE == 1)? 
                      tap[2*(lindex(AV_TRANSACTIONID_W))+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+16:
                          lindex(AV_TRANSACTIONID_W)+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+16] : 0;
      
      writeid <= (USE_WRITERESPONSE == 1)? 
                      tap[lindex(AV_TRANSACTIONID_W)+2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+15:
                          2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+15] : 0;
      
      response <= (USE_WRITERESPONSE == 1 || USE_READRESPONSE == 1)? 
                 tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+14:
                     2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+13] : 0;
                          
      writeresponserequest <= (USE_WRITERESPONSE == 1)? 
                      tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+12:
                          2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+12] : 0;
                          
      writeresponsevalid <= (USE_WRITERESPONSE == 1)? 
                      tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+11:
                          2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+11] : 0;
                          
      waitrequest <= tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+10:
                          2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+10];
      
      readdatavalid <= (USE_READ_DATA_VALID == 1)? 
                        tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+9:
                            2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+9] : 0;
      
      readdata <= (USE_READ_DATA == 1)? 
                   tap[2*(lindex(AV_DATA_W))+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+8:
                       lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+8] : 0;
      
      write <= (USE_WRITE == 1)? 
                tap[lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+7:
                    lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+7] : 0;
      
      read <= (USE_READ == 1)? 
               tap[lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+6:
                   lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+6] : 0;
      
      address <= (USE_ADDRESS == 1)? 
                  tap[lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+lindex(AV_ADDRESS_W)+5:
                      lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+5] : 0;
      
      byteenable <= (USE_BYTE_ENABLE == 1)? 
                     tap[lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+lindex(AV_NUMSYMBOLS)+4:
                         lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+4] : 0;
      
      burstcount <= (USE_BURSTCOUNT == 1)? 
                     tap[lindex(AV_DATA_W)+lindex(AV_BURSTCOUNT_W)+3: lindex(AV_DATA_W)+3] : 1;
      
      beginbursttransfer <= (USE_BEGIN_BURST_TRANSFER == 1)? 
                             tap[lindex(AV_DATA_W)+2:lindex(AV_DATA_W)+2] : 0;
      
      begintransfer <= (USE_BEGIN_TRANSFER == 1)? tap[lindex(AV_DATA_W)+1:lindex(AV_DATA_W)+1] : 0;
      
      writedata <= (USE_WRITE_DATA == 1)? tap[lindex(AV_DATA_W):0] : 0;
   end

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
   // =cut
   //--------------------------------------------------------------------------   

   // Master Assertions API
   function automatic void set_enable_a_half_cycle_reset_legal( // public
      bit     assert_enable
   );
   // enable or disable a_half_cycle_reset_legal assertion
   
      enable_a_half_cycle_reset_legal = assert_enable;
   endfunction

   function automatic void set_enable_a_no_read_during_reset( // public
      bit     assert_enable
   );
   // enable or disable a_no_read_during_reset assertion
   
      enable_a_no_read_during_reset = assert_enable;
   endfunction

   function automatic void set_enable_a_no_write_during_reset( // public
      bit     assert_enable
   );
   // enable or disable a_no_write_during_reset assertion
   
      enable_a_no_write_during_reset = assert_enable;
   endfunction

   function automatic void set_enable_a_exclusive_read_write( // public
      bit     assert_enable
   );
   // enable or disable a_exclusive_read_write assertion
   
      enable_a_exclusive_read_write = assert_enable;
   endfunction

   function automatic void set_enable_a_begintransfer_single_cycle( // public
      bit     assert_enable
   );
   // enable or disable a_begintransfer_single_cycle assertion
   
      enable_a_begintransfer_single_cycle = assert_enable;
   endfunction

   function automatic void set_enable_a_begintransfer_legal( // public
      bit     assert_enable
   );
   // enable or disable a_begintransfer_legal assertion
   
      enable_a_begintransfer_legal = assert_enable;
   endfunction

   function automatic void set_enable_a_begintransfer_exist( // public
      bit     assert_enable
   );
   // enable or disable a_begintransfer_exist assertion
   
      enable_a_begintransfer_exist = assert_enable;
   endfunction

   function automatic void set_enable_a_beginbursttransfer_single_cycle( // public
      bit     assert_enable
   );
   // enable or disable a_beginbursttransfer_single_cycle assertion
   
      enable_a_beginbursttransfer_single_cycle = assert_enable;
   endfunction

   function automatic void set_enable_a_beginbursttransfer_legal( // public
      bit     assert_enable
   );
   // enable or disable a_beginbursttransfer_legal assertion
   
      enable_a_beginbursttransfer_legal = assert_enable;
   endfunction

   function automatic void set_enable_a_beginbursttransfer_exist( // public
      bit     assert_enable
   );
   // enable or disable a_beginbursttransfer_exist assertion
   
      enable_a_beginbursttransfer_exist = assert_enable;
   endfunction

   function automatic void set_enable_a_less_than_burstcount_max_size( // public
      bit     assert_enable
   );
   // enable or disable a_less_than_burstcount_max_size assertion
   
      enable_a_less_than_burstcount_max_size = assert_enable;
   endfunction

   function automatic void set_enable_a_byteenable_legal( // public
      bit     assert_enable
   );
   // enable or disable a_byteenable_legal assertion
   
      enable_a_byteenable_legal = assert_enable;
   endfunction

   function automatic void set_enable_a_constant_during_waitrequest( // public
      bit     assert_enable
   );
   // enable or disable a_constant_during_waitrequest assertion
   
      enable_a_constant_during_waitrequest = assert_enable;
   endfunction

   function automatic void set_enable_a_constant_during_burst( // public
      bit     assert_enable
   );
   // enable or disable a_constant_during_burst assertion
   
      enable_a_constant_during_burst = assert_enable;
   endfunction

   function automatic void set_enable_a_burst_legal( // public
      bit     assert_enable
   );
   // enable or disable a_burst_legal assertion
   
      enable_a_burst_legal = assert_enable;
   endfunction

   // Slave Assertions API
   function automatic void set_enable_a_waitrequest_during_reset( // public
      bit     assert_enable
   );
   // enable or disable a_waitrequest_during_reset assertion
   
      enable_a_waitrequest_during_reset = assert_enable;
   endfunction

   function automatic void set_enable_a_no_readdatavalid_during_reset( // public
      bit     assert_enable
   );
   // enable or disable a_no_readdatavalid_during_reset assertion
   
      enable_a_no_readdatavalid_during_reset = assert_enable;
   endfunction

   function automatic void set_enable_a_less_than_maximumpendingreadtransactions( // public
      bit     assert_enable
   );
   // enable or disable a_less_than_maximumpendingreadtransactions assertion
   
      enable_a_less_than_maximumpendingreadtransactions = assert_enable;
   endfunction
   
   function automatic void set_enable_a_read_response_sequence( // public
      bit     assert_enable
   );
   // enable or disable a_read_response_sequence assertion
   
      enable_a_read_response_sequence = assert_enable;
   endfunction
   
   function automatic void set_enable_a_readid_sequence( // public
      bit     assert_enable
   );
   // enable or disable a_readid_sequence assertion
   
      enable_a_readid_sequence = assert_enable;
   endfunction
   
   function automatic void set_enable_a_writeid_sequence( // public
      bit     assert_enable
   );
   // enable or disable a_writeid_sequence assertion
   
      enable_a_writeid_sequence = assert_enable;
   endfunction
   // Timeout Assertions API
   function automatic void set_enable_a_waitrequest_timeout( // public
      bit     assert_enable
   );
   // enable or disable a_waitrequest_timeout assertion
   
      enable_a_waitrequest_timeout = assert_enable;
   endfunction

   function automatic void set_enable_a_write_burst_timeout( // public
      bit     assert_enable
   );
   // enable or disable a_write_burst_timeout assertion
   
      enable_a_write_burst_timeout = assert_enable;
   endfunction

   function automatic void set_enable_a_read_response_timeout( // public
      bit     assert_enable
   );
   // enable or disable a_read_response_timeout assertion
   
      enable_a_read_response_timeout = assert_enable;
   endfunction
   
   function automatic void set_enable_a_constant_during_clk_disabled( // public
      bit     assert_enable
   );
   // enable or disable a_constant_during_clk_disabled assertion
   
      enable_a_constant_during_clk_disabled = assert_enable;
   endfunction
   
   function automatic void set_enable_a_register_incoming_signals( // public
      bit     assert_enable
   );
   // enable or disable a_register_incoming_signals assertion
   
      enable_a_register_incoming_signals = assert_enable;
   endfunction
   
   function automatic void set_enable_a_address_align_with_data_width( // public
      bit     assert_enable
   );
   // enable or disable a_address_align_with_data_width assertion
   
      enable_a_address_align_with_data_width = assert_enable;
   endfunction
   
   function automatic void set_enable_a_write_response_timeout( // public
      bit     assert_enable
   );
   // enable or disable a_write_response_timeout assertion
   
      enable_a_write_response_timeout = assert_enable;
   endfunction
   
   function automatic void set_enable_a_unrequested_write_response( // public
      bit     assert_enable
   );
   // enable or disable a_unrequested_write_response assertion
   
      enable_a_unrequested_write_response = assert_enable;
   endfunction
   
   function automatic void set_write_response_timeout( // public
      bit     cycles = 100
   );
   // set timeout for write response
   
      write_response_timeout = cycles;
   endfunction
   
   //-------------------------------------------------------------------------- 
   // =head1 Assertion Checkers and Coverage Monitors
   // The assertion checkers in this module are only executable on simulators 
   // supporting the SystemVerilog Assertion (SVA) language. 
   // Mentor Modelsim AE and SE do not support this.
   // Simulators that are supported include: Synopsys VCS and Mentor questasim.
   // The assertion checking logic in this module must be explicitly enabled
   // so that designs using this module can still be compiled on Modelsim without
   // changes. To disable assertions define the following macro in the testbench
   // or on the command line with: +define+DISABLE_ALTERA_AVALON_SIM_SVA.
   // =cut
   //-------------------------------------------------------------------------- 
   
   string   str_assertion;

   function automatic void print_assertion(
      string message_in
   );
      string message_out;
      $sformat(message_out, "ASSERTION: %m: %s", message_in);
      print(VERBOSITY_FAILURE, message_out);      
   endfunction
   
   // previous cycle value of signals
   always @(posedge clk) begin
      past_readdatavalid = readdatavalid;
      past_writeresponsevalid = writeresponsevalid;
      past_readid = readid;
      past_writeid = writeid;
   end
   
   // Counter for general assertion counters
   always @(posedge clk) begin
      
      if (!USE_CLKEN || clken) begin
         // ignore the waitrequest effect while reset
         if ((read || write) &&
         reset_flag[1] == 0)
            reset_flag[0] = 0;
         if (($fell(read) || $fell(write) || readdatavalid ||
         $fell(begintransfer) || $fell(beginbursttransfer) || 
         ((read || write) && $fell(waitrequest))) &&
         reset_flag[0] == 0) begin
            reset_flag[1] = 1;
            reset_flag[0] = 1;
         end
         
         // counter for readdatavalid_id and read response timeout check
         if ((!read || (read && waitrequest)) && !readdatavalid) begin
            read_response_timeout_counter = 0;
         end
         if (read && !waitrequest && !readdatavalid) begin
            if (((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
            $rose(read)) || command_while_clken || reset_flag[1] == 0) begin
               read_response_timeout_start_flag[read_id] = 1;
               temp_read_response_timeout_counter[read_id] = 0;
            end else begin
               if (read_id != 0) begin
                  read_response_timeout_start_flag[read_id-1] = 1;
                  temp_read_response_timeout_counter[read_id-1] = 0;
                end else begin
                  read_response_timeout_start_flag[MAX_ID] = 1;
                  temp_read_response_timeout_counter[MAX_ID] = 0;
                end
            end
         end
         
         if (!read && readdatavalid) begin
            read_response_timeout_counter =
               temp_read_response_timeout_counter[readdatavalid_id]-1;
            if (read_burst_counter[readdatavalid_id] == 1 ||
            read_burst_counter[readdatavalid_id] == 0) begin
               temp_read_response_timeout_counter[readdatavalid_id] = 0;
               read_response_timeout_start_flag[readdatavalid_id] = 0;
               if (readdatavalid_id < (MAX_ID))
                  readdatavalid_id++;
               else
                  readdatavalid_id = 0;
            end
         end
         if (read && readdatavalid) begin
            read_response_timeout_counter =
               temp_read_response_timeout_counter[readdatavalid_id]-1;
            if (!waitrequest) begin
               if (((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
               $rose(read)) || command_while_clken || reset_flag[1] == 0) begin
                  read_response_timeout_start_flag[read_id] = 1;
                  temp_read_response_timeout_counter[read_id] = 0;
               end else begin
                  if (read_id != 0) begin
                     read_response_timeout_start_flag[read_id-1] = 1;
                     temp_read_response_timeout_counter[read_id-1] = 0;
                  end else begin
                     read_response_timeout_start_flag[MAX_ID] = 1;
                     temp_read_response_timeout_counter[MAX_ID] = 0;
                  end
               end
            end
            if (read_burst_counter[readdatavalid_id] == 1 ||
            read_burst_counter[readdatavalid_id] == 0) begin
               temp_read_response_timeout_counter[readdatavalid_id] = 0;
               read_response_timeout_start_flag[readdatavalid_id] = 0;
               if (readdatavalid_id < (MAX_ID))
                  readdatavalid_id++;
               else
                  readdatavalid_id = 0;
            end
         end
         
         // new burst write transaction started
         if (($rose(write) || (write && ((!waitrequest && ((!$fell(waitrequest) &&
         !waitrequested_command_while_clken) || reset_flag[1] == 0)) || 
         command_while_clken || ($rose(waitrequest))))) &&
         write_burst_counter == 0 && burstcount > 0) begin
            write_burst_counter = burstcount;
            write_transactionid_queued.push_front(transactionid);
            temp_write_transactionid_queued = write_transactionid_queued[$];
            write_burstcount_queued.push_front(burstcount);
         end
         
         if (write && !waitrequest && write_burst_counter > 0)
            write_burst_counter--;
         
         // new read transaction asserted
         if (($rose(read) || (read && ((!waitrequest && 
         ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
         reset_flag[1] == 0)) || command_while_clken || 
         ($rose(waitrequest))))) || (read_transaction_flag && waitrequest &&
         read_without_waitrequest_flag && read)) begin
            read_transaction_flag = 1;
            read_transactionid_queued.push_front(transactionid);
            temp_read_transactionid_queued = read_transactionid_queued[$];
            read_burstcount_queued.push_front(burstcount);
         end else
            read_transaction_flag = 0;
            
         // new read transaction without previous read response(readdatavalid) returned at same cycle
         if ((($rose(read) || (read && ((!waitrequest && 
         ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
         reset_flag[1] == 0)) || command_while_clken || 
         ($rose(waitrequest))))) || (read_transaction_flag && waitrequest &&
         read_without_waitrequest_flag && read)) &&
         !readdatavalid) begin
            if (burstcount > 0)
               read_burst_counter[read_id] = burstcount;
            if (!waitrequest)
               read_without_waitrequest_flag = 1;
            else
               read_without_waitrequest_flag = 0;
            pending_read_counter++;
            if (read_id < (MAX_ID))
               read_id++;
            else
               read_id = 0;
         end
         
         // previous read response(readdatavalid) returned while no new read transaction asserted
         if ((readdatavalid ||
            (fix_latency_queued_counter != 0 &&
            fix_latency_queued_counter == AV_FIX_READ_LATENCY &&
            !USE_READ_DATA_VALID)) &&
            (!read_transaction_flag || !read) && pending_read_counter > 0) begin
            if ((readdatavalid_id == 0) && (read_burst_counter[MAX_ID] == 0)) begin
               round_over = 0;
               if (read_burst_counter[readdatavalid_id] > 0) begin
                  if (read_burst_counter[readdatavalid_id] == 1) begin
                     pending_read_counter--;
                  end
                  read_burst_counter[readdatavalid_id]--;
               end
            end else if (read_id >= ((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1)) begin
               round_over = 0;
               for (int i=0; i<=MAX_ID; i++) begin
                  if (read_burst_counter[i] > 0) begin
                     if (read_burst_counter[i] == 1) begin
                        pending_read_counter--;
                     end
                     read_burst_counter[i]--;
                     i=MAX_ID+1;
                  end
               end
            end else begin
               for (int i=((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1); i<=MAX_ID; i++) begin
                  round_over = 1;
                  if (read_burst_counter[i] > 0) begin
                     if (read_burst_counter[i] == 1) begin
                        pending_read_counter--;
                     end
                     read_burst_counter[i]--;
                     i=MAX_ID+1;
                  end
               end
            end
         end
         
         // new read transaction with previous read response(readdatavalid) returned at same cycle
         if ((($rose(read) || (read && ((!waitrequest && 
         ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
         reset_flag[1] == 0)) || command_while_clken || 
         ($rose(waitrequest))))) || (read_transaction_flag && waitrequest &&
         read_without_waitrequest_flag && read)) &&
         (readdatavalid || (fix_latency_queued_counter != 0 &&
         fix_latency_queued_counter == AV_FIX_READ_LATENCY &&
         !USE_READ_DATA_VALID))) begin
            if ((readdatavalid_id == 0) && (read_burst_counter[MAX_ID] == 0)) begin
               round_over = 0;
               if (read_burst_counter[readdatavalid_id] > 0) begin
                  if (read_burst_counter[readdatavalid_id] == 1) begin
                     pending_read_counter--;
                  end
                  read_burst_counter[readdatavalid_id]--;
               end
            end else if (read_id >= ((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1)) begin
               round_over = 0;
               for (int i=0; i<=MAX_ID; i++) begin
                  if (read_burst_counter[i] > 0) begin
                     if (read_burst_counter[i] == 1) begin
                        pending_read_counter--;
                     end
                     read_burst_counter[i]--;
                     i=MAX_ID+1;
                  end 
               end
            end else begin
               for (int i=((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1); i<=MAX_ID; i++) begin
                  round_over = 1;
                  if (read_burst_counter[i] > 0) begin
                     if (read_burst_counter[i] == 1) begin
                        pending_read_counter--;
                     end
                     read_burst_counter[i]--;
                     i=MAX_ID+1;
                  end
               end
            end

            if (burstcount > 0)
               read_burst_counter[read_id] = burstcount;
            if (!waitrequest)
               read_without_waitrequest_flag = 1;
            else
               read_without_waitrequest_flag = 0;
            pending_read_counter++;
            if (read_id < (MAX_ID))
               read_id++;
            else
               read_id = 0;
         end
         
         // Counter for timeout
         if (pending_read_counter > 0) begin
            if (!USE_READ_DATA_VALID) begin
            end else begin
               for (int i=0; i<=MAX_ID; i++) begin
                  if (i != read_id) begin
                     if (read_response_timeout_start_flag[i])
                        temp_read_response_timeout_counter[i]++;
                  end
               end
            end
         end
         
         if (read || write_burst_counter == 0)
            write_burst_timeout_counter = 0;
         if (write_burst_counter != 0 || (write && beginbursttransfer))
            write_burst_timeout_counter++;
         if (waitrequest && (read || write))
            waitrequest_timeout_counter++;
         else
            waitrequest_timeout_counter = 0;
         
         // Counter for write response timeout checking
         if (pending_write_response > 0) begin
            for (int i = 0; i < pending_write_response; i++) begin
               write_response_timeout_counter[i]++;            
            end            
         end
         
         // sample writeresponserequest on the 1st cycle of write command
         if (write == 1 && (burstcount - 1) == write_burst_counter && writeresponserequest == 1) begin
            request_for_write_response = writeresponserequest;
         end
         
         if (write == 1 && write_burst_counter == 0 && request_for_write_response == 1) begin
            write_response_timeout_counter[pending_write_response] = 0;
            pending_write_response++;
         end
         
         if (writeresponsevalid) begin
            pending_write_response--;
            for (int i = 0; i < pending_write_response; i++) begin
               write_response_timeout_counter[i] = write_response_timeout_counter[i+1];
            end
         end
         
         // Counter for writeresponse sequence checking
         if (writeresponsevalid) begin            
            void'(write_transactionid_queued.pop_back());
            temp_write_transactionid_queued = write_transactionid_queued[$];
         end
         
         // Counter for readresponse sequence checking
         if (readdatavalid || ((fix_latency_queued_counter == AV_FIX_READ_LATENCY) &&
            (!USE_READ_DATA_VALID))) begin
            if (read_response_burstcount == 0) begin
               if (read_burstcount_queued.size() > 0)
                  read_response_burstcount = read_burstcount_queued.pop_back();
            end
            if (read_response_burstcount > 0)
               read_response_burstcount--;
            if (read_response_burstcount == 0) begin
               if (read_transactionid_queued.size() > 0)
                  void'(read_transactionid_queued.pop_back());
               temp_read_transactionid_queued = read_transactionid_queued[$];
            end
         end
        
         // fix latency counter
         if (read && !waitrequest) begin
            fix_latency_queued.push_front(0);
         end
         
         if (fix_latency_queued.size() > 0) begin
            foreach(fix_latency_queued[size]) begin
               fix_latency_queued[size]++;
               if (fix_latency_queued[size] > AV_FIX_READ_LATENCY) begin
                  void'(fix_latency_queued.pop_back());
               end
            end
            fix_latency_queued_counter = fix_latency_queued[$];
         end
         command_while_clken = 0;
         waitrequested_command_while_clken = 0;
      end else begin
         if (($rose(waitrequest) && (read || write)) || 
         ($rose(read) || $rose(write))) begin
            command_while_clken = 1;
         end
         
         if ($fell(waitrequest) && (read || write)) begin
               waitrequested_command_while_clken = 1;
            end
         end
   end
   
   // Counter for byteenable legality checking
   always @(posedge clk && byteenable >= 0) begin
      byteenable_bit_counter = 0;
      byteenable_legal_flag = 0;
      byteenable_single_bit_flag = 0;
      byteenable_continual_bit_flag = 0;
      for (int i=0; i<AV_NUMSYMBOLS; i++) begin
         if (byteenable[i]) begin
            if (!byteenable_single_bit_flag &&
                byteenable_bit_counter == 0) begin
               byteenable_single_bit_flag = 1;
               byteenable_continual_bit_flag = 0;
               byteenable_legal_flag = 0;
            end else if (byteenable_single_bit_flag &&
                         byteenable_bit_counter > 0) begin
               byteenable_single_bit_flag = 0;
               byteenable_continual_bit_flag = 1;
               byteenable_legal_flag = 0;
            end else if (!byteenable_single_bit_flag &&
                         !byteenable_continual_bit_flag &&
                         byteenable_bit_counter > 0) begin
               byteenable_legal_flag = 1;
               break;
            end
         byteenable_bit_counter++;
         end else begin
            if (byteenable_bit_counter > 0) begin
               if (byteenable_single_bit_flag && 
                   byteenable_bit_counter == 1) begin
                  byteenable_single_bit_flag = 0;
                  byteenable_continual_bit_flag = 0;
                  byteenable_legal_flag = 0;
               end else if (byteenable_continual_bit_flag &&
                            byteenable_bit_counter > 1) begin
                   if ((i != byteenable_bit_counter &&
                       i%byteenable_bit_counter == 0) ||
                       (i == byteenable_bit_counter &&
                       AV_NUMSYMBOLS%i == 0)) begin
                      byteenable_single_bit_flag = 0;
                      byteenable_continual_bit_flag = 0;
                      byteenable_legal_flag = 0;
                   end else begin
                      byteenable_legal_flag = 1;
                      break;
                   end
                end
             end else
                byteenable_legal_flag = 0;
          end
      end
      if (byteenable_bit_counter != 1 &&
          byteenable_bit_counter != 2 &&
          byteenable_bit_counter%4 != 0 &&
          byteenable_legal_flag == 0) begin
         byteenable_legal_flag = 1;
      end
   end

   // Counter for reset
   always @(clk) begin
      if (reset) begin
         write_transactionid_queued = {};
         read_transactionid_queued = {};
         write_burstcount_queued = {};
         read_burstcount_queued = {};
         fix_latency_queued = {};
         write_response_burstcount = 0;
         read_response_burstcount = 0;
         temp_write_transactionid_queued = 0;
         temp_read_transactionid_queued = 0;
         fix_latency_queued_counter = 0;
         read_response_timeout_start_flag = 0;
         temp_read_response_timeout_counter = 0;
         read_burst_counter = 0;
      
         read_transaction_flag = 0;
         read_without_waitrequest_flag = 0;
         byteenable_legal_flag = 0;
         byteenable_single_bit_flag = 0;
         byteenable_continual_bit_flag = 0;
         write_burst_counter = 0;
         pending_read_counter = 0;
         write_burst_timeout_counter = 0;
         waitrequest_timeout_counter = 0;
         read_response_timeout_counter = 0;
         read_id = 0;
         readdatavalid_id = 0;
         byteenable_bit_counter = 0;
         reset_counter++;
         reset_flag[1] = 0;
         reset_flag[0] = 1;
         write_burst_completed = 0;
         round_over = 0;
         command_while_clken = 0;
         waitrequested_command_while_clken = 0;
         if ((reset_counter%2) == 1)
            reset_half_cycle_flag = 1;
         else
            reset_half_cycle_flag = 0;
      end
      if (reset == 0) begin
         reset_half_cycle_flag = 0;
         reset_counter = 0;
      end
   end

   // SVA assertion code lives within the following section block 
   // which is disabled when the macro DISABLE_ALTERA_AVALON_SIM_SVA
   // is defined

   `ifdef DISABLE_ALTERA_AVALON_SIM_SVA
   // SVA assertion code has been disabled

   `else
   //--------------------------------------------------------------------------
   // ASSERTION CODE BEGIN
   //-------------------------------------------------------------------------- 
   //-------------------------------------------------------------------------------
   // =head2 Master Assertions
   // The following are the assertions code focus on Master component checking
   //-------------------------------------------------------------------------------

   //-------------------------------------------------------------------------------
   // =head3 a_half_cycle_reset_legal
   // This property checks if reset is asserted correctly
   //-------------------------------------------------------------------------------

   sequence s_reset_half_cycle;
      reset_half_cycle_flag ##0
         $rose(clk);
   endsequence

   sequence s_reset_non_half_cycle;
      reset_half_cycle_flag && reset ##1
         reset_counter > 1;
   endsequence

   property p_half_cycle_reset_legal;
      @(clk && enable_a_half_cycle_reset_legal)
          reset_half_cycle_flag |-> s_reset_half_cycle or
                           s_reset_non_half_cycle;
   endproperty
   
   if (USE_BURSTCOUNT >= 0) begin: master_assertion_01
      a_half_cycle_reset_legal: assert property(p_half_cycle_reset_legal)
         else begin
            -> event_a_half_cycle_reset_legal;
            print_assertion("reset must be held accross postive clock edge");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_no_read_during_reset
   // This property checks if read is deasserted while reset is asserted
   //-------------------------------------------------------------------------------

   property p_no_read_during_reset;
      @(clk && enable_a_no_read_during_reset)
         (reset_counter > 0 || reset_half_cycle_flag) &&
         $rose(clk) |-> !read;
   endproperty

   if (USE_READ) begin: master_assertion_02
      a_no_read_during_reset: assert property(p_no_read_during_reset)
         else begin
            -> event_a_no_read_during_reset;
            print_assertion("read must be deasserted while reset is asserted");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_no_write_during_reset
   // This property checks if write is deasserted while reset is asserted
   //-------------------------------------------------------------------------------

   property p_no_write_during_reset;
      @(clk && enable_a_no_write_during_reset)
         (reset_counter > 0 || reset_half_cycle_flag) &&
         $rose(clk) |-> !write;
      endproperty

   if (USE_WRITE) begin: master_assertion_03
      a_no_write_during_reset: assert property(p_no_write_during_reset)
         else begin
            -> event_a_no_write_during_reset;
            print_assertion("write must be deasserted while reset is asserted");
         end
   end 
   
   //-------------------------------------------------------------------------------
   // =head3 a_exclusive_read_write
   // This property checks that read and write are not asserted simultaneously
   //-------------------------------------------------------------------------------

   property p_exclusive_read_write;
      @(posedge clk && enable_a_exclusive_read_write)
         disable iff (reset || (!clken && (USE_CLKEN)))
         read || write |-> $onehot({read, write});
   endproperty

   if (USE_READ && USE_WRITE) begin: master_assertion_04
      a_exclusive_read_write: assert property(p_exclusive_read_write)
         else begin
             -> event_a_exclusive_read_write;
            print_assertion("write and read were asserted simultaneously");
         end
   end
   //-------------------------------------------------------------------------------
   // =head3 a_begintransfer_single_cycle
   // This property checks if begintransfer is asserted for only 1 cycle    
   //-------------------------------------------------------------------------------

   sequence s_begintransfer_without_waitrequest;
      begintransfer && !waitrequest ##1
         !begintransfer || (begintransfer && (read || write));
   endsequence

   sequence s_begintransfer_with_waitrequest;
      begintransfer && waitrequest ##1
         !begintransfer;
   endsequence

   property p_begintransfer_single_cycle;
      @(posedge clk && enable_a_begintransfer_single_cycle)
         disable iff (reset || (!clken && (USE_CLKEN)))
         begintransfer |-> s_begintransfer_without_waitrequest or
                           s_begintransfer_with_waitrequest;
   endproperty

   if (USE_BEGIN_TRANSFER) begin: master_assertion_05
      a_begintransfer_single_cycle: assert property(p_begintransfer_single_cycle)
         else begin
            -> event_a_begintransfer_single_cycle;
            print_assertion("begintransfer must be asserted for only 1 cycle");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_begintransfer_legal
   // This property checks if either read or write is asserted while 
   // begintransfer is asserted   
   //-------------------------------------------------------------------------------

   property p_begintransfer_legal;
      @(posedge clk && enable_a_begintransfer_legal)
         disable iff (reset || (!clken && (USE_CLKEN)))
         begintransfer |-> read || write;
   endproperty

   if (USE_BEGIN_TRANSFER) begin: master_assertion_06
      a_begintransfer_legal: assert property(p_begintransfer_legal)
         else begin
            -> event_a_begintransfer_legal;
            print_assertion("neither read nor write was asserted with begintransfer");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_begintransfer_exist
   // This property checks if begintransfer is asserted during a transfer 
   //-------------------------------------------------------------------------------

   property p_begintransfer_exist;
      @(posedge clk && enable_a_begintransfer_exist)
         disable iff (reset || (!clken && (USE_CLKEN)))
         ($rose(read) || $rose(write)) ||
         ((write || read) &&
         (!$fell(waitrequest) && !waitrequested_command_while_clken) &&
         ($rose(waitrequest) || !waitrequest))  |-> begintransfer;
   endproperty

   if (USE_BEGIN_TRANSFER) begin: master_assertion_07
      a_begintransfer_exist: assert property(p_begintransfer_exist)
         else begin
            -> event_a_begintransfer_exist;
            print_assertion("begintransfer was deasserted during a transfer");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_beginbursttransfer_single_cycle
   // This property checks if beginbursttransfer is asserted for only 1 cycle    
   //-------------------------------------------------------------------------------

   sequence s_beginbursttransfer_without_waitrequest;
      beginbursttransfer && !waitrequest && write_burst_counter == 0 ##1
         !beginbursttransfer || (beginbursttransfer && (read || write));
   endsequence

   sequence s_beginbursttransfer_with_waitrequest;
      beginbursttransfer && waitrequest && write_burst_counter == 0 ##1
         !beginbursttransfer;
   endsequence

   property p_beginbursttransfer_single_cycle;
      @(posedge clk && enable_a_beginbursttransfer_single_cycle)
      disable iff (reset || (!clken && (USE_CLKEN)))
         beginbursttransfer |-> s_beginbursttransfer_without_waitrequest or 
                                s_beginbursttransfer_with_waitrequest;
   endproperty

   if (USE_BEGIN_BURST_TRANSFER) begin: master_assertion_08
      a_beginbursttransfer_single_cycle: assert property(p_beginbursttransfer_single_cycle)
         else begin
            -> event_a_beginbursttransfer_single_cycle;
            print_assertion("beginbursttransfer must be asserted for only 1 cycle");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_beginbursttransfer_legal
   // This property checks if either read or write is asserted while 
   // beginbursttransfer is asserted   
   //-------------------------------------------------------------------------------

   property p_beginbursttransfer_legal;
      @(posedge clk && enable_a_beginbursttransfer_legal)
         disable iff (reset || (!clken && (USE_CLKEN)))
         beginbursttransfer |-> read || write;
   endproperty

   if (USE_BEGIN_BURST_TRANSFER) begin: master_assertion_09
      a_beginbursttransfer_legal: assert property(p_beginbursttransfer_legal)
         else begin
            -> event_a_beginbursttransfer_legal;
            print_assertion("neither read nor write was asserted with beginbursttransfer");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_beginbursttransfer_exist
   // This property checks if beginbursttransfer is asserted during a transfer 
   //-------------------------------------------------------------------------------

   property p_beginbursttransfer_exist;
      @(posedge clk && enable_a_beginbursttransfer_exist)
         disable iff (reset || (!clken && (USE_CLKEN)))
         (($rose(read) || $rose(write)) ||
         ((write || read) &&
         (!$fell(waitrequest) && !waitrequested_command_while_clken) &&
         ($rose(waitrequest) || !waitrequest))) &&
         write_burst_counter == 0 |-> beginbursttransfer;
   endproperty

   if (USE_BEGIN_BURST_TRANSFER) begin: master_assertion_10
      a_beginbursttransfer_exist: assert property(p_beginbursttransfer_exist)
         else begin
            -> event_a_beginbursttransfer_exist;
            print_assertion("beginbursttransfer was deasserted during a transfer");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_less_than_burstcount_max_size
   // This property checks if burstcount is less than or euqals to maxBurstSize
   //------------------------------------------------------------------------------

   property p_less_than_burstcount_max_size;
      @(posedge clk && enable_a_less_than_burstcount_max_size)
         disable iff (reset || (!clken && (USE_CLKEN)))
         burstcount > 0 |-> burstcount <= AV_MAX_BURST;
   endproperty

   if (USE_BURSTCOUNT) begin: master_assertion_11
      a_less_than_burstcount_max_size: assert property(p_less_than_burstcount_max_size)
         else begin
            -> event_a_less_than_burstcount_max_size;
            print_assertion("burstcount must be less than or equals to maxBurstSize");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_byteenable_legal
   // This property checks if byteenalbe is a legal value
   //------------------------------------------------------------------------------

   property p_byteenable_legal;
      @(posedge clk && enable_a_byteenable_legal)
         disable iff (reset || (!clken && (USE_CLKEN)))
         byteenable >= 0 |-> byteenable_legal_flag == 0;
      endproperty

   if (USE_BYTE_ENABLE) begin: master_assertion_12
      a_byteenable_legal: assert property(p_byteenable_legal)
         else begin
            -> event_a_byteenable_legal;
            print_assertion("byteenable has an illegal value");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_constant_during_waitrequest
   // This property checks if read, write, writedata, address, burstcount and 
   // byteenable are constant while waitrequest is asserted
   //------------------------------------------------------------------------------

   sequence s_waitrequest_with_read_constant_in_burst;
      (AV_CONSTANT_BURST_BEHAVIOR) && waitrequest && 
      !$fell(waitrequest) &&
      read ##1 read == $past(read) &&
               address == $past(address) &&
               burstcount == $past(burstcount) &&
               byteenable == $past(byteenable) &&
               transactionid == $past(transactionid);
   endsequence

   sequence s_waitrequest_with_read_inconstant_in_burst;
      !(AV_CONSTANT_BURST_BEHAVIOR) && waitrequest && 
      !$fell(waitrequest) &&
      read ##1 read == $past(read) &&
               $isunknown(address)? $isunknown($past(address)): address == $past(address) &&
               $isunknown(burstcount)? $isunknown($past(burstcount)): burstcount == $past(burstcount) &&
               $isunknown(transactionid)? $isunknown($past(transactionid)): transactionid == $past(transactionid) &&
               byteenable == $past(byteenable);
   endsequence
   
   sequence s_waitrequest_with_write_constant_in_burst;
      (AV_CONSTANT_BURST_BEHAVIOR) && waitrequest &&
      !$fell(waitrequest) && 
      write ##1 write == $past(write) &&
                writedata == $past(writedata) &&
                address == $past(address) &&
                burstcount == $past(burstcount) &&
                byteenable == $past(byteenable) &&
                transactionid == $past(transactionid) &&
                writeresponserequest == $past(writeresponserequest);
   endsequence
   
   sequence s_waitrequest_with_write_inconstant_in_burst;
      !(AV_CONSTANT_BURST_BEHAVIOR) && waitrequest && 
      !$fell(waitrequest) && 
      write ##1 write == $past(write) &&
                writedata == $past(writedata) &&
                $isunknown(address)? $isunknown($past(address)): address == $past(address) &&
                $isunknown(burstcount)? $isunknown($past(burstcount)): burstcount == $past(burstcount) &&
                $isunknown(transactionid)? $isunknown($past(transactionid)): transactionid == $past(transactionid) &&
                $isunknown(writeresponserequest)? $isunknown($past(writeresponserequest)): writeresponserequest == $past(writeresponserequest) &&
                byteenable == $past(byteenable);
   endsequence

   property p_constant_during_waitrequest;
      @(posedge clk && enable_a_constant_during_waitrequest)
         disable iff (reset || (!clken && (USE_CLKEN)))
         waitrequest &&
         !$fell(waitrequest) &&
         !reset &&
         !$fell(reset) &&
         (read || write) |-> s_waitrequest_with_read_constant_in_burst or s_waitrequest_with_write_constant_in_burst or
                             s_waitrequest_with_read_inconstant_in_burst or s_waitrequest_with_write_inconstant_in_burst;
   endproperty

   if (USE_WAIT_REQUEST) begin: master_assertion_13
      a_constant_during_waitrequest:
         assert property(p_constant_during_waitrequest)
         else begin
            -> event_a_constant_during_waitrequest;
            print_assertion("control signal(s) has changed while waitrequest is asserted");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_constant_during_burst
   // This property checks if address, burstcount and transactionid are constant 
   // during write burst transfer
   //------------------------------------------------------------------------------

   property p_constant_during_burst;
      @(posedge clk && enable_a_constant_during_burst)
         disable iff (reset || (!clken && (USE_CLKEN)))
         write_burst_counter > 0 |-> burstcount == $past(burstcount) && 
                                     address == $past(address) &&
                                     transactionid == $past(transactionid) &&
                                     writeresponserequest == $past(writeresponserequest);
   endproperty

   if (USE_BURSTCOUNT && USE_WRITE && AV_CONSTANT_BURST_BEHAVIOR) begin: master_assertion_14
      a_constant_during_burst: assert property(p_constant_during_burst)
         else begin
            -> event_a_constant_during_burst;
            print_assertion("control signal(s) has changed during write burst transfer");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_burst_legal
   // This property checks if the total number of successive write is asserted and
   // equals to burstcount to complete a write burst transfer
   //------------------------------------------------------------------------------

   property p_burst_legal;
      @(posedge clk && enable_a_burst_legal)
         disable iff (reset || (!clken && (USE_CLKEN)))
         (beginbursttransfer || $rose(read)) |-> write_burst_counter == 0;
   endproperty

   if (USE_BURSTCOUNT && USE_WRITE &&
      (USE_READ || USE_BEGIN_BURST_TRANSFER)) begin: master_assertion_15
      a_burst_legal: assert property(p_burst_legal)
         else begin
            -> event_a_burst_legal;
            print_assertion("insufficient write were asserted during burst transfer");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_constant_during_clk_disabled
   // This property checks if all the signals are constant while clken is 
   // deasserted.
   //------------------------------------------------------------------------------

   sequence s_constant_during_clk_disabled_command;
         clken == 0 ##1 waitrequest === $past(waitrequest) &&
                        burstcount === $past(burstcount) && 
                        address === $past(address) &&
                        transactionid === $past(transactionid) &&
                        waitrequest === $past(waitrequest) &&
                        write === $past(write) &&
                        read === $past(read) &&
                        byteenable === $past(byteenable) &&
                        beginbursttransfer === $past(beginbursttransfer) &&
                        begintransfer === $past(begintransfer) &&
                        writedata === $past(writedata) &&
                        arbiterlock === $past(arbiterlock) &&
                        lock === $past(lock) &&
                        debugaccess === $past(debugaccess) &&
                        writeresponserequest === $past(writeresponserequest)
                        ;
   endsequence
   
   sequence s_constant_during_clk_disabled_response;
         clken == 0 ##0 readdatavalid === $past(readdatavalid) &&
                        readdata === $past(readdata) &&
                        readid === $past(readid) &&
                        writeid === $past(writeid) &&
                        response === $past(response) &&
                        writeresponsevalid === $past(writeresponsevalid)
                        ;
   endsequence
   
   property p_constant_during_clk_disabled;
      @(posedge clk && enable_a_constant_during_clk_disabled)
         disable iff (reset)
         clken == 0 |-> s_constant_during_clk_disabled_response and
                        s_constant_during_clk_disabled_command
                        ;
   endproperty
   
   if (USE_CLKEN) begin: master_assertion_16
      a_constant_during_clk_disabled: assert property(p_constant_during_clk_disabled)
         else begin
            -> event_a_constant_during_clk_disabled;
            print_assertion("signal(s) change while clken is deasserted.");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_address_align_with_data_width
   // This property checks if master is using byte address, the address must be
   // aligned with the data width.
   //------------------------------------------------------------------------------

   property p_address_align_with_data_width;
      @(posedge clk && enable_a_address_align_with_data_width)
         disable iff (reset || (!clken && (USE_CLKEN)))
         ((read || write) && !waitrequest) |-> (address%AV_NUMSYMBOLS) == 0;
   endproperty

   if (USE_ADDRESS && (SLAVE_ADDRESS_TYPE == "SYMBOLS")) begin: master_assertion_17
      a_address_align_with_data_width: assert property(p_address_align_with_data_width)
         else begin
            -> event_a_burst_legal;
            print_assertion("address is not align with data width");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head2 Slave Assertions
   // The following are the assertions code focus on Slave component checking
   //-------------------------------------------------------------------------------

   //-------------------------------------------------------------------------------
   // =head3 a_waitrequest_during_reset
   // This property checks if waitrequest is asserted while reset is asserted
   //-------------------------------------------------------------------------------

   property p_waitrequest_during_reset;
      @(clk && enable_a_waitrequest_during_reset)
         (reset_counter > 0 || reset_half_cycle_flag) &&
         ($rose(clk) || $fell(clk)) && !$fell(reset) |-> waitrequest;
   endproperty

   if (USE_WAIT_REQUEST) begin: slave_assertion_01
      a_waitrequest_during_reset: assert property(p_waitrequest_during_reset)
         else begin
            -> event_a_waitrequest_during_reset;
            print_assertion("waitrequest must be asserted while reset is asserted");
         end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 a_no_readdatavalid_during_reset
   // This property checks if readdatavalid is deasserted while reset is asserted
   //-------------------------------------------------------------------------------

   property p_no_readdatavalid_during_reset;
      @(clk && enable_a_no_readdatavalid_during_reset)
         (reset_counter > 0 || reset_half_cycle_flag) &&
         $rose(clk) |-> !readdatavalid;
   endproperty

   if (USE_READ_DATA_VALID) begin: slave_assertion_02
      a_no_readdatavalid_during_reset: assert property(p_no_readdatavalid_during_reset)
         else begin
            -> event_a_no_readdatavalid_during_reset;
            print_assertion("readdatavalid must be deasserted while reset is asserted");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_less_than_maximumpendingreadtransactions
   // This property checks if pipelined pending read count is less than 
   // maximumPendingReadTransaction
   //------------------------------------------------------------------------------

   property p_less_than_maximumpendingreadtransactions;
      @(posedge clk && enable_a_less_than_maximumpendingreadtransactions)
         disable iff (reset || (!clken && (USE_CLKEN)))
         pending_read_counter > 0 |->
            pending_read_counter <= (((read && (waitrequest == 1)) || (read && readdatavalid))?
                                    AV_MAX_PENDING_READS+1:AV_MAX_PENDING_READS);
   endproperty 

   if (USE_READ && USE_READ_DATA_VALID && AV_MAX_PENDING_READS > 0) begin: slave_assertion_03
      a_less_than_maximumpendingreadtransactions:
         assert property(p_less_than_maximumpendingreadtransactions)
         else begin
            -> event_a_less_than_maximumpendingreadtransactions;
            print_assertion("pending read must be within maximumPendingReadTransactions");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_read_response_sequence
   // This property checks if readdatavalid is asserted while read is asserted for
   // the same read transfer
   //------------------------------------------------------------------------------

   sequence s_read_response_sequence_0;
      !read && (readdatavalid_id < read_id) ##1 (round_over == 0);
   endsequence
   
   sequence s_read_response_sequence_1;
      read && ($past(waitrequest) == 1) && ($past(read) == 1) && 
         (readdatavalid_id < read_id-1) ##1 (round_over == 0);
   endsequence
   
   sequence s_read_response_sequence_2;
      ((read && ($past(waitrequest) == 0)) || ($rose(read))) &&
         (readdatavalid_id < read_id) ##1 (round_over == 0);
   endsequence
   
   sequence s_read_response_sequence_3;
      !read && (readdatavalid_id > read_id) ##1 (round_over == 1);
   endsequence
   
   sequence s_read_response_sequence_4;
      read && ($past(waitrequest) == 1) && ($past(read) == 1) && 
         (read_id == 0)?(readdatavalid_id < MAX_ID):(readdatavalid_id > read_id-1) ##1 (round_over == 1);
   endsequence

   sequence s_read_response_sequence_5;
      ((read && ($past(waitrequest) == 0)) || ($rose(read))) &&
         (readdatavalid_id > read_id) ##1 (round_over == 1);
   endsequence
   
   property p_read_response_sequence;
      @(posedge clk && enable_a_read_response_sequence)
         disable iff (reset || (!clken && (USE_CLKEN)))
         readdatavalid |-> s_read_response_sequence_0 or 
                           s_read_response_sequence_1 or
                           s_read_response_sequence_2 or 
                           s_read_response_sequence_3 or 
                           s_read_response_sequence_4 or
                           s_read_response_sequence_5;
   endproperty

   if (USE_READ_DATA_VALID && USE_READ) begin: slave_assertion_04
      a_read_response_sequence: assert property(p_read_response_sequence)
         else begin
            -> event_a_read_response_sequence;
            print_assertion("readdatavalid must be asserted after read command");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_readid_sequence
   // This property checks if readid return follow the sequence of transactionid
   // asserted.
   //------------------------------------------------------------------------------

   property p_readid_sequence;
      @(posedge clk && enable_a_readid_sequence)
         disable iff (reset || (!clken && (USE_CLKEN)))
         (readdatavalid || ((!USE_READ_DATA_VALID) && 
            (fix_latency_queued_counter == (AV_FIX_READ_LATENCY)))) |-> 
               readid == temp_read_transactionid_queued;
   endproperty

   if (USE_TRANSACTIONID) begin: slave_assertion_05
      a_readid_sequence: assert property(p_readid_sequence)
         else begin
            -> event_a_readid_sequence;
            print_assertion("readid did not match transactionid.");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_writeid_sequence
   // This property checks if writeid return follow the sequence of transactionid
   // asserted.
   //------------------------------------------------------------------------------
   
   property p_writeid_sequence;
      @(posedge clk && enable_a_writeid_sequence)
         disable iff (reset || (!clken && (USE_CLKEN)))
         writeresponsevalid |-> writeid == temp_write_transactionid_queued;
   endproperty

   if (USE_TRANSACTIONID) begin: slave_assertion_06
      a_writeid_sequence: assert property(p_writeid_sequence)
         else begin
            -> event_a_writeid_sequence;
            print_assertion("writeid did not match the transactionid.");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_register_incoming_signals
   // This property checks if waitrequest is asserted all the times except 
   // deasserted at the single clock cycle after read/write transaction happen.
   //------------------------------------------------------------------------------
   
   sequence s_register_incoming_signals_with_waitrequested_command;
      ((read && waitrequest) || (write && waitrequest)) ##[1:$] !waitrequest ##1 waitrequest;
   endsequence
   
   sequence s_register_incoming_signals_without_command;
      (!write && !read) ##0 waitrequest;
   endsequence
   
   sequence s_register_incoming_signals_read;
      (read && !waitrequest) ##0 (read === $past(read) && $past(waitrequest) == 1) ##1 
            waitrequest;
   endsequence
   
   sequence s_register_incoming_signals_write;
      (write && !waitrequest) ##0 (write === $past(write) && $past(waitrequest) == 1) ##1 
            waitrequest;
   endsequence
   
   property p_register_incoming_signals;
      @(posedge clk && enable_a_register_incoming_signals)
         disable iff (!clken && (USE_CLKEN))
         enable_a_register_incoming_signals |-> s_register_incoming_signals_read or 
         s_register_incoming_signals_write or
         s_register_incoming_signals_without_command or
         s_register_incoming_signals_with_waitrequested_command;
   endproperty

   if (AV_REGISTERINCOMINGSIGNALS) begin: slave_assertion_07
      a_register_incoming_signals: 
         assert property(p_register_incoming_signals)
         else begin
            -> event_a_register_incoming_signals;
            print_assertion("waitrequest not asserted in first cycle of transaction.");
         end
   end
      
   //------------------------------------------------------------------------------
   // =head3 a_unrequested_write_response
   // This property checks for write response to occur only when there is  
   // request for write response
   //------------------------------------------------------------------------------
   
   property p_unrequested_write_response;
      @(posedge clk && enable_a_unrequested_write_response)
         disable iff (reset || (!clken && (USE_CLKEN)))
         pending_write_response == 0 |-> !writeresponsevalid;
   endproperty
   
   if (USE_WRITE && USE_WRITERESPONSE) begin: slave_assertion_08
      a_unrequested_write_response: assert property(p_unrequested_write_response)
         else begin
            -> event_a_unrequested_write_response;
            print_assertion("write response must only happen when write response is requested");
         end
   end
   //-------------------------------------------------------------------------------
   // =head2 Timeout Assertions
   // The following are the assertions code focus on timeout checking
   //-------------------------------------------------------------------------------

   //------------------------------------------------------------------------------
   // =head3 a_write_burst_timeout
   // This property checks if write burst transfer is completed within timeout
   // period
   //------------------------------------------------------------------------------

   property p_write_burst_timeout;
      @(posedge clk && enable_a_write_burst_timeout)
         disable iff (reset || (!clken && (USE_CLKEN)))
         write_burst_counter > 0 |->
            write_burst_timeout_counter <= AV_WRITE_TIMEOUT;
   endproperty

   if (USE_BURSTCOUNT && USE_WRITE && AV_WRITE_TIMEOUT > 0) begin: timeout_assertion_01
      a_write_burst_timeout: assert property(p_write_burst_timeout)
         else begin
            -> event_a_write_burst_timeout;
            print_assertion("write burst transfer must be completed within timeout period");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_waitrequest_timeout
   // This property checks if waitrequest is asserted continously for more than
   // maximum allowed timeout period
   //------------------------------------------------------------------------------

   property p_waitrequest_timeout;
      @(posedge clk && enable_a_waitrequest_timeout)
         waitrequest_timeout_counter > 0 |->
            waitrequest_timeout_counter <= AV_WAITREQUEST_TIMEOUT;
   endproperty

   if (USE_WAIT_REQUEST && AV_WAITREQUEST_TIMEOUT > 0) begin: timeout_assertion_02
      a_waitrequest_timeout: assert property(p_waitrequest_timeout)
         else begin
            -> event_a_waitrequest_timeout;
            print_assertion("continuous waitrequest must be within timeout period");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_read_response_timeout
   // This property checks if readdatavalid is asserted within timeout period
   // =cut
   //------------------------------------------------------------------------------

   property p_read_response_timeout;
      @(posedge clk && enable_a_read_response_timeout)
         disable iff (reset || (!clken && (USE_CLKEN)))
         temp_read_response_timeout_counter[readdatavalid_id] > 0 |->
            temp_read_response_timeout_counter[readdatavalid_id] <= AV_READ_TIMEOUT;
   endproperty

   if (USE_READ && USE_READ_DATA_VALID && AV_READ_TIMEOUT > 0) begin: timeout_assertion_03
      a_read_response_timeout: assert property(p_read_response_timeout)
         else begin
            -> event_a_read_response_timeout;
            print_assertion("readdatavalid must be asserted within timeout period");
         end
   end
   
   //------------------------------------------------------------------------------
   // =head3 a_write_response_timeout
   // This property checks if write response happens within timeout
   // period after completed write command
   //------------------------------------------------------------------------------

   property p_write_response_timeout;
      @(posedge clk && enable_a_write_response_timeout)
         disable iff (reset || (!clken && (USE_CLKEN)))
         write_response_timeout_counter[0] > 0 |->
            write_response_timeout_counter[0] <= write_response_timeout;
   endproperty

   if (USE_WRITE && USE_WRITERESPONSE > 0) begin: timeout_assertion_04
      a_write_response_timeout: assert property(p_write_response_timeout)
         else begin
            -> event_a_write_response_timeout;
            print_assertion("write response must happens within timeout period after completed write command");
         end
   end

   //--------------------------------------------------------------------------
   // ASSERTION CODE END
   //--------------------------------------------------------------------------   
   `endif   

   // synthesis translate_on

endmodule 
