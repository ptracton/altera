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


// $File: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_monitor_bfm/altera_avalon_mm_monitor_coverage.sv $
// $Revision: #1 $
// $Date: 2013/08/11 $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_monitor_coverage
// =head1 SYNOPSIS
// Memory Mapped Avalon Bus Protocol Checker
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This module implements Avalon MM protocol coverage for simulation.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_monitor_coverage(
                                         clk,
                                         reset,
                                         tap
                                        );

   // =head1 PARAMETERS
   parameter AV_ADDRESS_W               = 32;   // address width
   parameter AV_SYMBOL_W                = 8;    // default symbol is byte
   parameter AV_NUMSYMBOLS              = 4;    // number of symbols per word
   parameter AV_BURSTCOUNT_W            = 3;    // burst port width
      
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

   parameter AV_MAX_READ_LATENCY             = 100;   // maximum read latency cycle for coverage
   parameter AV_MAX_WAITREQUESTED_READ       = 100;   // maximum waitrequested read cycle for coverage
   parameter AV_MAX_WAITREQUESTED_WRITE      = 100;   // maximum waitrequested write cycle for coverage
   parameter AV_MAX_CONTINUOUS_READ          = 5;   // maximum continuous read cycle for coverage
   parameter AV_MAX_CONTINUOUS_WRITE         = 5;   // maximum continuous write cycle for coverage
   parameter AV_MAX_CONTINUOUS_WAITREQUEST   = 5;   // maximum continuous waitrequest cycle for coverage
   parameter AV_MAX_CONTINUOUS_READDATAVALID = 5;   // maximum continuous readdatavalid cycle for coverage
   
   parameter AV_READ_WAIT_TIME         = 0;  // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME        = 0;  // USE_WAIT_REQUEST is 0

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
   
   function automatic int __floor1(
      bit [31:0] arg
   );
      __floor1 = (arg <1) ? 1 : arg;
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


   string                        message       = "*unitialized*";

   bit                           covergroup_settings_changed_flag = 0;
   bit [1:0]                     reset_flag = 2'b11;
   bit                           read_transaction_flag = 0;
   bit                           read_without_waitrequest_flag = 0;
   bit                           idle_write_flag = 0;
   logic [MAX_ID:0]              idle_read_flag = 0;
   bit                           idle_in_write_burst_flag = 0;
   logic [MAX_ID:0]              read_latency_start_flag = 0;
   
   bit                           enable_c_read_byteenable = 1;
   bit                           enable_c_write_byteenable = 1;
   bit                           enable_c_read_burstcount = 1;
   bit                           enable_c_write_burstcount = 1;
   bit                           enable_c_pending_read = 1;
   bit                           enable_c_read = 1;
   bit                           enable_c_write = 1;
   bit                           enable_c_b2b_read_read = 1;
   bit                           enable_c_b2b_read_write = 1;
   bit                           enable_c_b2b_write_write = 1;
   bit                           enable_c_b2b_write_read = 1;
   bit                           enable_c_idle_in_write_burst = 1;
   bit                           enable_c_idle_in_read_response = 1;
   bit                           enable_c_read_latency = 1;
   bit                           enable_c_waitrequested_read = 1;
   bit                           enable_c_waitrequested_write = 1;
   bit                           enable_c_continuous_waitrequest_from_idle_to_write = 1;
   bit                           enable_c_continuous_waitrequest_from_idle_to_read = 1;
   bit                           enable_c_waitrequest_without_command = 1;
   bit                           enable_c_idle_before_transaction = 1;
   bit                           enable_c_continuous_read = 1;
   bit                           enable_c_continuous_write = 1;
   bit                           enable_c_continuous_readdatavalid = 1;
   bit                           enable_c_continuous_waitrequest = 1;
   bit                           enable_c_waitrequest_in_write_burst = 1;
   bit                           enable_c_readresponse = 0;
   bit                           enable_c_writeresponse = 0;
   bit                           enable_c_write_with_and_without_writeresponserequest = 1;
   bit                           enable_c_write_after_reset = 1;
   bit                           enable_c_read_after_reset = 1;   
   bit                           enable_c_write_response = 1;
   bit                           enable_c_read_response = 1;
   bit                           enable_c_write_response_transition = 1;
   bit                           enable_c_read_response_transition = 1;

   int                           read_command_while_clken = 0;
   int                           write_command_while_clken = 0;
   int                           waitrequested_command_while_clken = 0;
   int                           write_burst_counter = 0;
   logic [MAX_ID:0][31:0]        read_burst_counter = 0;
   int                           temp_read_burst_counter = 0;
   int                           pending_read_counter = 0;
   int                           fix_read_latency_counter = 0;
   int                           idle_in_read_response = 0;
   logic [MAX_ID:0][31:0]        temp_idle_in_read_response = 0;
   int                           temp_waitrequested_read_counter = 0;
   int                           waitrequested_read_counter = 0;
   int                           temp_waitrequested_write_counter = 0;
   int                           waitrequested_write_counter = 0;
   int                           byteenable_counter = 0;
   logic [MAX_ID:0][31:0]        temp_read_latency_counter = 0;
   int                           read_latency_counter = 0;
   int                           read_id = 0;
   int                           readdatavalid_id = 0;
   bit                           waitrequest_before_waitrequested_read = 0;
   bit                           waitrequest_before_waitrequested_write = 0;
   bit                           waitrequest_before_command = 0;
   bit                           waitrequest_without_command = 0;
   logic                         past_waitrequest = 0;
   logic                         idle_before_burst_transaction = 0;
   logic                         idle_before_burst_transaction_sampled = 0;
   logic                         continuous_read_sampled = 0;
   logic                         continuous_read_start_flag = 0;
   logic [31:0]                  continuous_read = 0;
   logic                         continuous_write_sampled = 0;
   logic                         continuous_write_start_flag = 0;
   logic [31:0]                  continuous_write = 0;
   logic                         continuous_readdatavalid_sampled = 0;
   logic                         continuous_readdatavalid_start_flag = 0;
   logic [31:0]                  continuous_readdatavalid = 0;
   logic                         continuous_waitrequest_sampled = 0;
   logic                         continuous_waitrequest_start_flag = 0;
   logic [31:0]                  continuous_waitrequest = 0;
   logic                         idle_in_write_burst_with_waitrequest = 0;
   logic                         idle_in_write_burst_with_waitrequest_sampled = 0;
   logic                         idle_in_write_burst_start_flag = 0;
   logic                         idle_before_burst_transaction_with_waitrequest = 0;
   logic                         idle_before_burst_transaction_with_waitrequest_sampled = 0;
   logic [31:0]                  waitrequested_before_transaction = 0;
   logic                         write_after_reset = 0;
   logic                         read_after_reset = 0;
   int                           fix_latency_queued[$];
   int                           fix_latency_queued_counter = 0;
   logic                         read_reset_transaction = 0;
   logic                         write_reset_transaction = 0;
   logic                         burst_waitrequested_command = 0;
   logic [31:0]                  readresponse_bit_num = 0;
   logic [31:0]                  writeresponse_bit_num = 0;
   AvalonResponseStatus_t        read_response;
   AvalonResponseStatus_t        write_response;
   logic [3:0]                   write_response_transition = 4'bx;
   logic [3:0]                   read_response_transition = 4'bx;

   logic [3:0]                   b2b_transfer = 4'b1111;
   logic [AV_NUMSYMBOLS-1:0]     check_byteenable = 0;
   logic [AV_NUMSYMBOLS-1:0]     legal_byteenable[(AV_NUMSYMBOLS*2)-1:0];

   logic                         byteenable_1_bit = 1'b1;
   logic [1:0]                   byteenable_2_bit = 2'b11;
   logic [3:0]                   byteenable_4_bit = 4'hf;
   logic [7:0]                   byteenable_8_bit = 8'hff;
   logic [15:0]                  byteenable_16_bit = 16'hffff;
   logic [31:0]                  byteenable_32_bit = 32'hffffffff;
   logic [63:0]                  byteenable_64_bit = 64'hffffffffffffffff;
   logic [127:0]                 byteenable_128_bit = 128'hffffffffffffffffffffffffffffffff;

   //--------------------------------------------------------------------------
   // unpack Avalon bus interface tap into individual port signals

   logic                                  waitrequest;
   logic                                  readdatavalid;
   logic [lindex(AV_DATA_W):0]            readdata;
   logic                                  write;
   logic                                  read;
   logic [lindex(AV_ADDRESS_W):0]         address;
   logic [31:0]                           byteenable;
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

   // Master Coverages API
   function automatic void set_enable_c_read_byteenable( // public
      bit     cover_enable
   );
      // enable or disable c_read_byteenable cover group
   
      enable_c_read_byteenable = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_byteenable");
   endfunction

   function automatic void set_enable_c_write_byteenable( // public
      bit     cover_enable
   );
      // enable or disable c_write_byteenable cover group
   
      enable_c_write_byteenable = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_byteenable");
   endfunction

   function automatic void set_enable_c_read_burstcount( // public
      bit     cover_enable
   );
      // enable or disable c_read_burstcount cover group
   
      enable_c_read_burstcount = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_burstcount");
   endfunction

   function automatic void set_enable_c_write_burstcount( // public
      bit     cover_enable
   );
      // enable or disable c_write_burstcount cover group
   
      enable_c_write_burstcount = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_burstcount");
   endfunction

   function automatic void set_enable_c_pending_read( // public
      bit     cover_enable
   );
      // enable or disable c_pending_read cover group
   
      enable_c_pending_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_pending_read");
   endfunction

   function automatic void set_enable_c_read( // public
      bit     cover_enable
   );
      // enable or disable c_read cover group
   
      enable_c_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read");
   endfunction

   function automatic void set_enable_c_write( // public
      bit     cover_enable
   );
      // enable or disable c_write cover group
   
      enable_c_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write");
   endfunction

   function automatic void set_enable_c_b2b_read_read( // public
      bit     cover_enable
   );
      // enable or disable c_b2b_read_read cover group
   
      enable_c_b2b_read_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_b2b_read_read");
   endfunction

   function automatic void set_enable_c_b2b_read_write( // public
      bit     cover_enable
   );
      // enable or disable c_b2b_read_write cover group
   
      enable_c_b2b_read_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_b2b_read_write");
   endfunction

   function automatic void set_enable_c_b2b_write_write( // public
      bit     cover_enable
   );
      // enable or disable c_b2b_write_write cover group
   
      enable_c_b2b_write_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_b2b_write_write");
   endfunction

   function automatic void set_enable_c_b2b_write_read( // public
      bit     cover_enable
   );
      // enable or disable c_b2b_write_read cover group
   
      enable_c_b2b_write_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_b2b_write_read");
   endfunction

   function automatic void set_enable_c_idle_in_write_burst( // public
      bit     cover_enable
   );
      // enable or disable c_idle_in_write_burst cover group
   
      enable_c_idle_in_write_burst = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_idle_in_write_burst");
   endfunction

   // Slave Coverages API
   function automatic void set_enable_c_idle_in_read_response( // public
      bit     cover_enable
   );
      // enable or disable c_idle_in_read_response cover group
   
      enable_c_idle_in_read_response = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_idle_in_read_response");
   endfunction

   function automatic void set_enable_c_read_latency( // public
      bit     cover_enable
   );
      // enable or disable c_read_latency cover group
   
      enable_c_read_latency = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_latency");
   endfunction

   function automatic void set_enable_c_waitrequested_read( // public
      bit     cover_enable
   );
      // enable or disable c_waitrequested_read cover group
   
      enable_c_waitrequested_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_waitrequested_read");
   endfunction

   function automatic void set_enable_c_waitrequested_write( // public
      bit     cover_enable
   );
      // enable or disable c_waitrequested_write cover group
   
      enable_c_waitrequested_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_waitrequested_write");
   endfunction

   function automatic void set_enable_c_continuous_waitrequest_from_idle_to_write( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_waitrequest_from_idle_to_write cover group
   
      enable_c_continuous_waitrequest_from_idle_to_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_waitrequest_from_idle_to_write");
   endfunction
   
   function automatic void set_enable_c_continuous_waitrequest_from_idle_to_read( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_waitrequest_from_idle_to_read cover group
   
      enable_c_continuous_waitrequest_from_idle_to_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_waitrequest_from_idle_to_read");
   endfunction
   
   function automatic void set_enable_c_waitrequest_without_command( // public
      bit     cover_enable
   );
      // enable or disable c_waitrequest_without_command cover group
   
      enable_c_waitrequest_without_command = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_waitrequest_without_command");
   endfunction

   function automatic void set_enable_c_idle_before_transaction( // public
      bit     cover_enable
   );
      // enable or disable c_idle_before_transaction cover group
   
      enable_c_idle_before_transaction = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_idle_before_transaction");
   endfunction
   
   function automatic void set_enable_c_continuous_read( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_read cover group
   
      enable_c_continuous_read = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_read");
   endfunction
   
   function automatic void set_enable_c_continuous_write( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_write cover group
   
      enable_c_continuous_write = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_write");
   endfunction
   
   function automatic void set_enable_c_continuous_readdatavalid( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_readdatavalid cover group
   
      enable_c_continuous_readdatavalid = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_readdatavalid");
   endfunction
   
   function automatic void set_enable_c_continuous_waitrequest( // public
      bit     cover_enable
   );
      // enable or disable c_continuous_waitrequest cover group
   
      enable_c_continuous_waitrequest = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_continuous_waitrequest");
   endfunction
   
   function automatic void set_enable_c_waitrequest_in_write_burst( // public
      bit     cover_enable
   );
      // enable or disable c_waitrequest_in_write_burst cover group
   
      enable_c_waitrequest_in_write_burst = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_waitrequest_in_write_burst");
   endfunction
   
   function automatic void set_enable_c_readresponse( // public
      bit     cover_enable
   );
      // enable or disable c_readresponse cover group
   
      // enable_c_readresponse = cover_enable;
      // coverage_settings_check(covergroup_settings_changed_flag, "c_readresponse");
      
      $sformat(message, "%m: This coverage is no longer supported. Please use c_read_response cover group");
      print(VERBOSITY_WARNING, message);
   endfunction
   
   function automatic void set_enable_c_writeresponse( // public
      bit     cover_enable
   );
      // enable or disable c_writeresponse cover group
   
      // enable_c_writeresponse = cover_enable;
      // coverage_settings_check(covergroup_settings_changed_flag, "c_writeresponse");
      
      $sformat(message, "%m: This coverage is no longer supported. Please use c_write_response cover group");
      print(VERBOSITY_WARNING, message);
   endfunction
   
   function automatic void set_enable_c_write_with_and_without_writeresponserequest( // public
      bit     cover_enable
   );
      // enable or disable c_write_with_and_without_writeresponserequest cover group
   
      enable_c_write_with_and_without_writeresponserequest = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_with_and_without_writeresponserequest");
   endfunction
   
   function automatic void set_enable_c_write_after_reset( // public
      bit     cover_enable
   );
      // enable or disable c_write_after_reset cover group
   
      enable_c_write_after_reset = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_after_reset");
   endfunction
   
   function automatic void set_enable_c_read_after_reset( // public
      bit     cover_enable
   );
      // enable or disable c_read_after_reset cover group
   
      enable_c_read_after_reset = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_after_reset");
   endfunction
   
   function automatic void coverage_settings_check(
      bit cover_flag,
      string cover_name
   );
      string message;
      if (cover_flag) begin
         $sformat(message, "%m: - Changing %s covergroup settings during run-time will not be reflected",
                  cover_name);
         print(VERBOSITY_WARNING, message);
      end
   endfunction
   
   function automatic void set_enable_c_write_response( // public
      bit     cover_enable
   );
      // enable or disable c_write_response cover group
   
      enable_c_write_response = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_response");
   endfunction
   
   function automatic void set_enable_c_read_response( // public
      bit     cover_enable
   );
      // enable or disable c_read_response cover group
   
      enable_c_read_response = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_response");
   endfunction
   
   function automatic void set_enable_c_write_response_transition( // public
      bit     cover_enable
   );
      // enable or disable c_write_response_transition cover group
   
      enable_c_write_response_transition = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_write_response_transition");
   endfunction
   
   function automatic void set_enable_c_read_response_transition( // public
      bit     cover_enable
   );
      // enable or disable c_read_response_transition cover group
   
      enable_c_read_response_transition = cover_enable;
      coverage_settings_check(covergroup_settings_changed_flag, "c_read_response_transition");
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
   
   //counter to capture previous cycle waitrequest value
   always @(posedge clk) 
   begin
      if (!reset) begin
         past_waitrequest = waitrequest;
      end
   end
      
   // Counter for general coverage counters
   always @(posedge clk) begin
      if (!USE_CLKEN || clken) begin
         if (idle_in_write_burst_start_flag) begin
            if (waitrequest) begin
               idle_in_write_burst_with_waitrequest = 1;
            end
         end
      
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
         
         // Counter for read latency and readdatavalid_id
         if (!readdatavalid) begin
            read_latency_counter = 0;
         end
         if (read && !waitrequest && !readdatavalid) begin
            if (((!$fell(waitrequest) && !waitrequested_command_while_clken) || $rose(read)) ||
                read_command_while_clken || reset_flag[1] == 0) begin
               read_latency_start_flag[read_id] = 1;
               temp_read_latency_counter[read_id] = 0;
            end else begin
               if (read_id != 0) begin
                  read_latency_start_flag[read_id-1] = 1;
                  temp_read_latency_counter[read_id-1] = 0;
               end else begin
                  read_latency_start_flag[MAX_ID] = 1;
                  temp_read_latency_counter[MAX_ID] = 0;
               end
            end
         end
         if (!read && readdatavalid) begin
               read_latency_counter =
                  temp_read_latency_counter[readdatavalid_id];
            if (read_burst_counter[readdatavalid_id] == 1 ||
                read_burst_counter[readdatavalid_id] == 0) begin
               temp_read_latency_counter[readdatavalid_id] = 0;
               read_latency_start_flag[readdatavalid_id] = 0;
               // increase the id, restart the id from zero to reduce memory usage
               if (readdatavalid_id < (MAX_ID))
                  readdatavalid_id++;
               else
                  readdatavalid_id = 0;
            end
         end
         if (read && readdatavalid) begin
            read_latency_counter =
               temp_read_latency_counter[readdatavalid_id];
            if (!waitrequest) begin
               if (((!$fell(waitrequest) && !waitrequested_command_while_clken) || $rose(read)) ||
                   read_command_while_clken || reset_flag[1] == 0) begin
                  read_latency_start_flag[read_id] = 1;
                  temp_read_latency_counter[read_id] = 0;
               end else begin
                  if (read_id != 0) begin
                     read_latency_start_flag[read_id-1] = 1;
                     temp_read_latency_counter[read_id-1] = 0;
                  end else begin
                     read_latency_start_flag[MAX_ID] = 1;
                     temp_read_latency_counter[MAX_ID] = 0;
                  end
               end
            end
            if (read_burst_counter[readdatavalid_id] == 1 ||
                read_burst_counter[readdatavalid_id] == 0) begin
               temp_read_latency_counter[readdatavalid_id] = 0;
               read_latency_start_flag[readdatavalid_id] = 0;
               if (readdatavalid_id < (MAX_ID))
                  readdatavalid_id++;
               else
                  readdatavalid_id = 0;
            end
         end
         
         // new burst write transaction started
         if (((write && (!waitrequest || $rose(waitrequest)) &&
             ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
             reset_flag[1] == 0)) || write_command_while_clken || ($rose(write))) &&
             write_burst_counter == 0) begin
            if (burstcount > 0)
               write_burst_counter = burstcount;
            idle_write_flag = 1;
            idle_in_write_burst_start_flag = 1;
            idle_before_burst_transaction_sampled = 1;
         end

         if (write && (write_burst_counter == 1)) begin
            idle_in_write_burst_start_flag = 0;
            idle_in_write_burst_with_waitrequest_sampled = 1;
         end
         
         // decrease the write_burst_counter while write asserted
         if (write && !waitrequest && write_burst_counter > 0) begin
            write_burst_counter--;
         end
         
         // new read transaction asserted
         if (((read && (!waitrequest || $rose(waitrequest)) &&
               ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
               reset_flag[1] == 0)) || read_command_while_clken || $rose(read) ||
              (read_transaction_flag && waitrequest &&
               read_without_waitrequest_flag && read))) begin
            read_transaction_flag = 1;
            idle_before_burst_transaction_sampled = 1;
            if (continuous_read >= 2)
               continuous_read++;
            if (continuous_read_start_flag) begin
               if (continuous_read == 0)
                  continuous_read = 2;
            end
            continuous_read_start_flag = 1;
            continuous_read_sampled = 0;
         end else begin
            read_transaction_flag = 0;
            if (read) begin
               continuous_read_start_flag = 1;
               continuous_read_sampled = 0;
            end else begin
               continuous_read_start_flag = 0;
               continuous_read_sampled = 1;
            end
         end
         
         // new read transaction without previous read response(readdatavalid) returned at same cycle
         if (((read && (!waitrequest || $rose(waitrequest)) &&
            ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
            reset_flag[1] == 0)) || read_command_while_clken || $rose(read) ||
            (read_transaction_flag && waitrequest &&
            read_without_waitrequest_flag && read)) &&
            !readdatavalid) begin
            if (burstcount > 0) begin
               read_burst_counter[read_id] = burstcount;
               temp_read_burst_counter = burstcount;
            end

            if (!waitrequest)
               read_without_waitrequest_flag = 1;
            else
               read_without_waitrequest_flag = 0;
            idle_write_flag = 0;
            idle_read_flag[read_id] = 1;
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
               if (read_burst_counter[readdatavalid_id] > 0) begin
                  if (read_burst_counter[readdatavalid_id] == 1) begin
                     pending_read_counter--;
                  end
                  read_burst_counter[readdatavalid_id]--;
               end
            end else if (read_id >= ((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1)) begin
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
         if (((read && (!waitrequest || $rose(waitrequest)) &&
            ((!$fell(waitrequest) && !waitrequested_command_while_clken) || 
            reset_flag[1] == 0)) || read_command_while_clken || $rose(read) ||
            (read_transaction_flag && waitrequest &&
            read_without_waitrequest_flag && read)) &&
            (readdatavalid ||
            (fix_latency_queued_counter != 0 &&
            fix_latency_queued_counter == AV_FIX_READ_LATENCY &&
            !USE_READ_DATA_VALID)) &&
            pending_read_counter > 0) begin
            if ((readdatavalid_id == 0) && (read_burst_counter[MAX_ID] == 0)) begin
               if (read_burst_counter[readdatavalid_id] > 0) begin
                  if (read_burst_counter[readdatavalid_id] == 1) begin
                     pending_read_counter--;
                  end
                  read_burst_counter[readdatavalid_id]--;
               end
            end else if (read_id >= ((readdatavalid_id == 0)?MAX_ID-1:readdatavalid_id-1)) begin
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
                  if (read_burst_counter[i] > 0) begin
                     if (read_burst_counter[i] == 1) begin
                        pending_read_counter--;
                     end
                     read_burst_counter[i]--;
                     i=MAX_ID+1;
                  end 
               end
            end
            if (burstcount > 0) begin
               read_burst_counter[read_id] = burstcount;
               temp_read_burst_counter = burstcount;
            end
            if (!waitrequest)
               read_without_waitrequest_flag = 1;
            else
               read_without_waitrequest_flag = 0;
            idle_write_flag = 0;
            idle_read_flag[read_id] = 1;
            pending_read_counter++;
            if (read_id < (MAX_ID))
               read_id++;
            else
               read_id = 0;
         end
         
         // counter for read latency
         if (pending_read_counter > 0) begin
            if (!USE_READ_DATA_VALID) begin
               fix_read_latency_counter++;
               if (fix_read_latency_counter >
                   AV_FIX_READ_LATENCY)
                  fix_read_latency_counter = 0;
            end else begin
               for (int i=0; i<=MAX_ID; i++) begin
                  if (i != read_id) begin
                     if (read_latency_start_flag[i]) begin
                        temp_read_latency_counter[i]++;
                     end
                  end
               end
            end
         end
         
         // counter for idle_in_write_burst
         if (idle_in_write_burst_flag) begin
            idle_write_flag = 0;
            idle_in_write_burst_flag = 0;
         end
         if (!write && idle_write_flag &&
             write_burst_counter < burstcount &&
             write_burst_counter != 0)
            idle_in_write_burst_flag = 1;
         
         // counter for idle_in_read_response
         if (idle_in_read_response == 1)
            idle_in_read_response = 0;
         if (!readdatavalid && !waitrequest &&
             idle_read_flag[readdatavalid_id] &&
             read_burst_counter[readdatavalid_id] <= 
             temp_read_burst_counter) begin
            temp_idle_in_read_response[readdatavalid_id]++;
            idle_in_read_response =
               temp_idle_in_read_response[readdatavalid_id];
         end
         
         // counter for waitrequested command
         if (read && waitrequest)
            temp_waitrequested_read_counter++;
         if (!read || !waitrequest) begin
            waitrequested_read_counter =
               temp_waitrequested_read_counter;
            temp_waitrequested_read_counter = 0;
         end
         if (write && waitrequest) begin
            temp_waitrequested_write_counter++;
         end
         if (!write || !waitrequest) begin
            waitrequested_write_counter =
               temp_waitrequested_write_counter;
            temp_waitrequested_write_counter = 0;
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
         waitrequested_command_while_clken = 0;
         write_command_while_clken = 0;
         read_command_while_clken = 0;
      end else begin
         if (($rose(waitrequest) && read) || ($rose(read))) begin
            read_command_while_clken = 1;
         end
         if (($rose(waitrequest) && write) || $rose(write)) begin
            write_command_while_clken = 1;
         end
         
         if ($fell(waitrequest) && (read || write)) begin
            waitrequested_command_while_clken = 1;
         end
      end
   end
   
   // counter for waitrequest before command asserted
   always @(posedge clk) begin
      if (!reset) begin
         if (!USE_CLKEN || clken) begin
            if (waitrequest && !write && !read) begin
               waitrequest_before_command = 1;
               waitrequested_before_transaction = 1;
            end else begin
               if (read || write) begin
                  waitrequested_before_transaction = 0;
               end
            end
           
            if (waitrequest && (read || write)) begin
               if (write_burst_counter == 0)
                  burst_waitrequested_command = 1;
            end
           
            if (waitrequest_before_command) begin
               if (write && waitrequest) begin
                  waitrequest_before_waitrequested_write = 1;
               end else if (read && waitrequest) begin
                  waitrequest_before_waitrequested_read = 1;
               end
               
               if(!waitrequest) begin
                  if (!waitrequest_before_waitrequested_write && !waitrequest_before_waitrequested_read) begin
                     waitrequest_without_command = 1;
                  end else begin
                     waitrequest_without_command = 0;
                  end
                  waitrequest_before_command = 0;
               end
            end else begin
               waitrequest_before_waitrequested_write = 0;
               waitrequest_before_waitrequested_read = 0;
            end
            
            if (!waitrequest) begin
               waitrequest_before_command = 0;
            end
            
            if (!read && ! write && !waitrequest) begin
               if (write_burst_counter == 0) begin
                  idle_before_burst_transaction = 1;
                  idle_before_burst_transaction_sampled = 0;
               end
            end 
            
            if (waitrequested_before_transaction) begin
               if (idle_before_burst_transaction) begin
                  idle_before_burst_transaction_with_waitrequest = 1;
                  idle_before_burst_transaction_with_waitrequest_sampled = 0;
               end
            end else begin
               if ((burst_waitrequested_command) && (idle_before_burst_transaction)) begin
                  idle_before_burst_transaction_with_waitrequest = 1;
               end
               if (write_burst_counter == 0) begin
                  idle_before_burst_transaction_with_waitrequest_sampled = 1;
               end else begin
                  idle_before_burst_transaction_with_waitrequest_sampled = 0;
               end
            end
         end
      end
   end
   
   // Counter for continuous write, readdatavalid
   always@(posedge clk) begin
      if (!reset) begin
         if (!USE_CLKEN || clken) begin
            if ((write && (!waitrequest))) begin
               if (continuous_write >= 2)
                  continuous_write++;
               if (continuous_write_start_flag) begin
                  if (continuous_write == 0)
                     continuous_write = 2;
               end else begin
                  continuous_write_start_flag = 1;
               end

               continuous_write_start_flag = 1;
               continuous_write_sampled = 0;
            end else begin
               if (write) begin
                  continuous_write_sampled = 0;
               end else begin
                  continuous_write_sampled = 1;
                  continuous_write_start_flag = 0;
               end
            end
            
            if (readdatavalid) begin
               if (continuous_readdatavalid >= 2)
                  continuous_readdatavalid++;
               if(continuous_readdatavalid_start_flag == 1) begin
                  if (continuous_readdatavalid == 0)
                     continuous_readdatavalid = 2;
               end
               continuous_readdatavalid_sampled = 0;
               continuous_readdatavalid_start_flag = 1;
            end else begin
               continuous_readdatavalid_start_flag = 0;
               continuous_readdatavalid_sampled = 1;
            end
            
            if (waitrequest) begin
               if (continuous_waitrequest >= 1)
                     continuous_waitrequest++;
               if(continuous_waitrequest_start_flag == 1) begin
                  if (continuous_waitrequest == 0) begin
                     continuous_waitrequest = 2;
                  end
               end
               continuous_waitrequest_sampled = 0;
               continuous_waitrequest_start_flag = 1;
            end else begin
               continuous_waitrequest_start_flag = 0;
               continuous_waitrequest_sampled = 1;
            end
         end
      end
   end
   
   // Counter for generating legal byteenable
   initial begin
      legal_byteenable[(AV_NUMSYMBOLS*2)-1] = 0;
      check_byteenable = byteenable_1_bit;
      for (int i=0; i<AV_NUMSYMBOLS; i++) begin
         legal_byteenable[i] = check_byteenable;
         check_byteenable = check_byteenable << 1;
         byteenable_counter = i;
      end
      if (AV_NUMSYMBOLS > 1) begin
         check_byteenable = byteenable_2_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+2) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 2;
         end
      end
      if (AV_NUMSYMBOLS > 2) begin
         check_byteenable = byteenable_4_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+4) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 4;
         end
      end
      if (AV_NUMSYMBOLS > 4) begin
         check_byteenable = byteenable_8_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+8) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 8;
         end
      end
      if (AV_NUMSYMBOLS > 8) begin
         check_byteenable = byteenable_16_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+16) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 16;
         end
      end
      if (AV_NUMSYMBOLS > 16) begin
         check_byteenable = byteenable_32_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+32) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 32;
         end
      end
      if (AV_NUMSYMBOLS > 32) begin
         check_byteenable = byteenable_64_bit;
         for (int i=0; i<AV_NUMSYMBOLS; i=i+64) begin
            byteenable_counter++;
            legal_byteenable[byteenable_counter] = check_byteenable;
            check_byteenable = check_byteenable << 64;
         end
      end
      if (AV_NUMSYMBOLS > 64) begin
         byteenable_counter++;
         legal_byteenable[byteenable_counter] = byteenable_128_bit;
      end
   end

   // Counter for back to back transfers
   always @(posedge clk) begin
      if (!USE_CLKEN || clken) begin
         if ((!read && !write) || waitrequest) begin
            b2b_transfer[3] = 1;
            b2b_transfer[2] = 0;
         end else begin
            if (read && !waitrequest) begin
               if (!b2b_transfer[3] && !b2b_transfer[2])
                  b2b_transfer[1] = b2b_transfer[0];
               if (b2b_transfer[3]) begin
                  b2b_transfer[3] = 0;
                  b2b_transfer[2] = 1;
                  b2b_transfer[1] = 0;
               end else begin
                  b2b_transfer[0] = 0;
                  if (b2b_transfer[2])
                     b2b_transfer[2] = 0;
               end
            end
            if (write && !waitrequest) begin
               if (!b2b_transfer[3] && !b2b_transfer[2])
                  b2b_transfer[1] = b2b_transfer[0];
               if (b2b_transfer[3]) begin
                  b2b_transfer[3] = 0;
                  b2b_transfer[2] = 1;
                  b2b_transfer[1] = 1;
               end else begin
                  b2b_transfer[0] = 1;
                  if (b2b_transfer[2])
                     b2b_transfer[2] = 0;
               end
            end
         end
      end
   end
   
   // Counter for write response transition
   always @(posedge clk) begin
      if (!USE_CLKEN || clken) begin
         if (writeresponsevalid) begin
            write_response_transition[3:2] = write_response_transition[1:0];
            write_response_transition[1:0] = write_response;
         end
      end
   end

   // Counter for read response transition
   always @(posedge clk) begin
      if (!USE_CLKEN || clken) begin
         if ((USE_READ_DATA_VALID && readdatavalid) || 
               (!USE_READ_DATA_VALID && fix_latency_queued_counter == AV_FIX_READ_LATENCY && fix_latency_queued_counter != 0)) begin
            read_response_transition[3:2] = read_response_transition[1:0];
            read_response_transition[1:0] = read_response;
         end
      end
   end
   // Counter for reset
   always @(posedge clk) begin
      if (reset) begin
         fix_latency_queued = {};
         idle_write_flag = 0;
         idle_read_flag = 0;
         read_latency_start_flag = 0;
         read_burst_counter = 0;
         temp_read_burst_counter = 0;
         temp_idle_in_read_response = 0;
         temp_read_latency_counter = 0;
         fix_latency_queued_counter = 0;
         read_transaction_flag = 0;
         read_without_waitrequest_flag = 0;
         idle_in_write_burst_flag = 0;
         write_burst_counter = 0;
         pending_read_counter = 0;
         fix_read_latency_counter = 0;
         idle_in_read_response = 0;
         temp_waitrequested_read_counter = 0;
         waitrequested_read_counter = 0;
         temp_waitrequested_write_counter = 0;
         waitrequested_write_counter = 0;
         byteenable_counter = 0;
         read_latency_counter = 0;
         read_id = 0;
         readdatavalid_id = 0;
         b2b_transfer = 4'b1111;
         check_byteenable = 0;
         reset_flag[1] = 0;
         reset_flag[0] = 1;
         write_after_reset = 1;
         read_after_reset = 1;
         read_reset_transaction = 1;
         write_reset_transaction = 1;
         waitrequest_before_waitrequested_read = 0;
         waitrequest_before_waitrequested_write = 0;
         waitrequest_before_command = 0;
         waitrequest_without_command = 0;
         past_waitrequest = 0;
         idle_before_burst_transaction = 0;
         idle_before_burst_transaction_sampled = 0;
         continuous_read_sampled = 0;
         continuous_read_start_flag = 0;
         continuous_read = 0;
         continuous_write_sampled = 0;
         continuous_write_start_flag = 0;
         continuous_write = 0;
         continuous_readdatavalid_sampled = 0;
         continuous_readdatavalid_start_flag = 0;
         continuous_readdatavalid = 0;
         continuous_waitrequest_sampled = 0;
         continuous_waitrequest_start_flag = 0;
         continuous_waitrequest = 0;
         idle_in_write_burst_with_waitrequest = 0;
         idle_in_write_burst_with_waitrequest_sampled = 0;
         idle_in_write_burst_start_flag = 0;
         idle_before_burst_transaction_with_waitrequest = 0;
         idle_before_burst_transaction_with_waitrequest_sampled = 0;
         waitrequested_before_transaction = 0;
         burst_waitrequested_command = 0;
         write_command_while_clken = 0;
         read_command_while_clken = 0;
         waitrequested_command_while_clken = 0;
      end 
   end

   // Flag for initial coverage settings
   initial begin
      #1 covergroup_settings_changed_flag = 1;
   end


   `ifdef DISABLE_ALTERA_AVALON_SIM_SVA
   // SVA coverage code is disabled when this macro is defined

   `else
   //--------------------------------------------------------------------------
   // COVERAGE CODE BEGIN
   //--------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   // =head2 Master Coverages
   // The following are the cover group code focus on Master component coverage
   //-------------------------------------------------------------------------------

   //-------------------------------------------------------------------------------
   // =head3 c_read_byteenable
   // This cover group covers the different byteenable during read transfers.
   // This cover group does not support byteenable value larger than
   // 1073741824.
   //-------------------------------------------------------------------------------

   covergroup cg_read_byteenable(logic [63:0] byteenable_max);
      cp_byteenable: coverpoint byteenable
      {
         bins cg_read_byteenable_cp_byteenable [] = {[0:4],
                                                     8,
                                                     12,
                                                     15,
                                                     16,
                                                     32,
                                                     48,
                                                     64,
                                                     128,
                                                     192,
                                                     255,
                                                     256,
                                                     512,
                                                     768,
                                                     1024,
                                                     2048,
                                                     3072,
                                                     3840,
                                                     4096,
                                                     8192,
                                                     12288,
                                                     16384,
                                                     32768,
                                                     49152,
                                                     65280,
                                                     65535,
                                                     65536,
                                                     131072,
                                                     196608,
                                                     262144,
                                                     524288,
                                                     786432,
                                                     1048576,
                                                     2097152,
                                                     3145728,
                                                     4194304,
                                                     8388608,
                                                     12582912,
                                                     16711680,
                                                     16777216,
                                                     33554432,
                                                     50331648,
                                                     67108864,
                                                     134217728,
                                                     201326592,
                                                     268435456,
                                                     536870912,
                                                     805306368,
                                                     1073741824};

         ignore_bins cg_read_byteenable_cp_byteenable_ignore = {[byteenable_max+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_read_byteenable c_read_byteenable;

   initial begin
      #1 if (enable_c_read_byteenable && USE_BYTE_ENABLE && USE_READ) begin
         if (AV_NUMSYMBOLS >= 32)
            c_read_byteenable = new(1073741825);
         else
            c_read_byteenable = new((2**AV_NUMSYMBOLS)-1);
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_read_byteenable && USE_BYTE_ENABLE && USE_READ) begin
         if (read && !waitrequest && clken) begin
            c_read_byteenable.sample();
         end
      end
   end

   // -------------------------------------------------------------------------------
   // =head3 c_write_byteenable
   // This cover group covers the different byteenable during write transfers.
   // This cover group does not support byteenable value larger than
   // 1073741824.
   // -------------------------------------------------------------------------------

   covergroup cg_write_byteenable(logic [31:0] byteenable_max);
      cp_byteenable: coverpoint byteenable
      {
         bins cg_write_byteenable_cp_byteenable [] = {[0:4],
                                                     8,
                                                     12,
                                                     15,
                                                     16,
                                                     32,
                                                     48,
                                                     64,
                                                     128,
                                                     192,
                                                     255,
                                                     256,
                                                     512,
                                                     768,
                                                     1024,
                                                     2048,
                                                     3072,
                                                     3840,
                                                     4096,
                                                     8192,
                                                     12288,
                                                     16384,
                                                     32768,
                                                     49152,
                                                     65280,
                                                     65535,
                                                     65536,
                                                     131072,
                                                     196608,
                                                     262144,
                                                     524288,
                                                     786432,
                                                     1048576,
                                                     2097152,
                                                     3145728,
                                                     4194304,
                                                     8388608,
                                                     12582912,
                                                     16711680,
                                                     16777216,
                                                     33554432,
                                                     50331648,
                                                     67108864,
                                                     134217728,
                                                     201326592,
                                                     268435456,
                                                     536870912,
                                                     805306368,
                                                     1073741824};
         ignore_bins cg_write_byteenable_cp_byteenable_ignore = {[byteenable_max+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_write_byteenable c_write_byteenable;

   initial begin
      #1 if (enable_c_write_byteenable && USE_BYTE_ENABLE && USE_WRITE) begin
         if (AV_NUMSYMBOLS >= 32)
            c_write_byteenable = new(1073741825);
         else
            c_write_byteenable = new((2**AV_NUMSYMBOLS)-1);
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_write_byteenable && USE_BYTE_ENABLE && USE_WRITE) begin
         if (write && !waitrequest && clken) begin
            c_write_byteenable.sample();
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_read_burstcount
   // This cover group covers the different sizes of burstcount during read
   // burst transfers
   //-------------------------------------------------------------------------------

   covergroup cg_read_burstcount;
      cp_burstcount: coverpoint burstcount
      {
         bins cg_read_burstcount_cp_burstcount_low = {1};
         bins cg_read_burstcount_cp_burstcount_mid =
            {[(AV_MAX_BURST < 3? 1:2):
              (AV_MAX_BURST < 3? 1:AV_MAX_BURST-1)]};
         bins cg_read_burstcount_cp_burstcount_high =
            {(AV_MAX_BURST < 2? 1:AV_MAX_BURST)};
      }
      option.per_instance = 1;
   endgroup

   cg_read_burstcount c_read_burstcount;

   initial begin
      #1 if (enable_c_read_burstcount && USE_BURSTCOUNT && USE_READ) begin
         c_read_burstcount = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_read_burstcount && USE_BURSTCOUNT && USE_READ) begin
         if (read && !waitrequest && clken) begin
            c_read_burstcount.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_write_burstcount
   // This cover group covers the different sizes of burstcount during write
   // burst transfers
   //-------------------------------------------------------------------------------

   covergroup cg_write_burstcount;
      cp_burstcount: coverpoint burstcount
      {
         bins cg_write_burstcount_cp_burstcount_low = {1};
         bins cg_write_burstcount_cp_burstcount_mid =
            {[(AV_MAX_BURST < 3? 1:2):
              (AV_MAX_BURST < 3? 1:AV_MAX_BURST-1)]};
         bins cg_write_burstcount_cp_burstcount_high =
            {(AV_MAX_BURST < 2? 1:AV_MAX_BURST)};
      }
      option.per_instance = 1;
   endgroup

   cg_write_burstcount c_write_burstcount;

   initial begin
      #1 if (enable_c_write_burstcount && USE_BURSTCOUNT && USE_WRITE) begin
         c_write_burstcount = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_write_burstcount && USE_BURSTCOUNT && USE_WRITE) begin
         if (write && write_burst_counter == 0 && clken) begin
            c_write_burstcount.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_pending_read
   // This cover group covers the different number of pending read transfers
   //-------------------------------------------------------------------------------

   covergroup cg_pending_read;
      cp_pending_read_count: coverpoint pending_read_counter
      {
         bins cg_pending_read_cp_pending_read_count[] =
           {[1:(AV_MAX_PENDING_READS < 2? 1:AV_MAX_PENDING_READS)]};
      }
      option.per_instance = 1;
   endgroup

   cg_pending_read c_pending_read;

   initial begin
      #1 if (enable_c_pending_read && USE_READ && USE_READ_DATA_VALID && AV_MAX_PENDING_READS > 0) begin
         c_pending_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_pending_read && USE_READ && USE_READ_DATA_VALID && AV_MAX_PENDING_READS > 0) begin
         if (read_transaction_flag && clken) begin
            c_pending_read.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_read
   // This cover group covers read transfers
   //-------------------------------------------------------------------------------

   covergroup cg_read;
      cp_read: coverpoint read
      {
         bins cg_read_cp_read = {1};
         option.comment = "This cover group covers read transfers";
      }
      option.per_instance = 1;
      option.comment = "This cover group covers how many read transfers happen";
   endgroup

   cg_read c_read;

   initial begin
      #1 if (enable_c_read && USE_READ) begin
         c_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_read && USE_READ && clken) begin
         if (read && !waitrequest) begin
            c_read.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_write
   // This cover group covers write transfers
   //-------------------------------------------------------------------------------

   covergroup cg_write;
      cp_write: coverpoint write
      {
         bins cg_write_cp_write = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_write c_write;

   initial begin
      #1 if (enable_c_write && USE_WRITE) begin
         c_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_write && USE_WRITE && clken) begin
         if (write && write_burst_counter == 0) begin
            c_write.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_b2b_read_read
   // This cover group covers back to back read to read transfers
   //-------------------------------------------------------------------------------

   covergroup cg_b2b_read_read;
      cp_b2b_read_read: coverpoint b2b_transfer
      {
         bins cp_b2b_read_read_cp_b2b_read_read = {4'b0000};
      }
      option.per_instance = 1;
   endgroup

   cg_b2b_read_read c_b2b_read_read;

   initial begin
      #1 if (enable_c_b2b_read_read && USE_READ) begin
         c_b2b_read_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_b2b_read_read && USE_READ && clken) begin
         c_b2b_read_read.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_b2b_read_write
   // This cover group covers back to back read to write transfers
   //-------------------------------------------------------------------------------

   covergroup cg_b2b_read_write;
      cp_b2b_read_write: coverpoint b2b_transfer
      {
         bins cg_b2b_read_write_cp_b2b_read_write = {4'b0001};
      }
      option.per_instance = 1;
   endgroup

   cg_b2b_read_write c_b2b_read_write;

   initial begin
      #1 if (enable_c_b2b_read_write && USE_READ && USE_WRITE) begin
         c_b2b_read_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_b2b_read_write && USE_READ && USE_WRITE && clken) begin
         c_b2b_read_write.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_b2b_write_write
   // This cover group covers back to back write to write transfers
   //-------------------------------------------------------------------------------

   covergroup cg_b2b_write_write;
      cp_b2b_write_write: coverpoint b2b_transfer
      {
         bins cg_b2b_write_write_cp_b2b_write_write = {4'b0011};
      }
      option.per_instance = 1;
   endgroup

   cg_b2b_write_write c_b2b_write_write;

   initial begin
      #1 if (enable_c_b2b_write_write && USE_WRITE) begin
         c_b2b_write_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_b2b_write_write && USE_WRITE && clken) begin
         c_b2b_write_write.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_b2b_write_read
   // This cover group covers back to back write to read transfers
   //-------------------------------------------------------------------------------

   covergroup cg_b2b_write_read;
      cp_b2b_write_read: coverpoint b2b_transfer
      {
         bins cg_b2b_write_read_cp_b2b_write_read = {4'b0010};
      }
      option.per_instance = 1;
   endgroup

   cg_b2b_write_read c_b2b_write_read;

   initial begin
      #1 if (enable_c_b2b_write_read && USE_READ && USE_WRITE) begin
         c_b2b_write_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_b2b_write_read && USE_READ && USE_WRITE && clken) begin
         c_b2b_write_read.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_idle_in_write_burst
   // This cover group covers idle cycles during write burst transfers
   //-------------------------------------------------------------------------------

   covergroup cg_idle_in_write_burst;
      cp_idle_in_write_burst: coverpoint idle_in_write_burst_flag
      {
         bins cg_idle_in_write_burst_cp_idle_in_write_burst_count = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_idle_in_write_burst c_idle_in_write_burst;

   initial begin
      #1 if (enable_c_idle_in_write_burst && USE_BURSTCOUNT && USE_WRITE &&
             AV_MAX_BURST > 1) begin
         c_idle_in_write_burst = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_idle_in_write_burst && USE_BURSTCOUNT && USE_WRITE &&
          AV_MAX_BURST > 1 && clken) begin
         c_idle_in_write_burst.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_idle_before_transaction
   // This cover group covers different cycle numbers of idle before read/write 
   // transaction.
   //-------------------------------------------------------------------------------

   covergroup cg_idle_before_transaction;
      cp_idle_before_transaction: coverpoint idle_before_burst_transaction
      {
         bins cg_idle_before_transaction_cp_idle_before_transaction = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_idle_before_transaction c_idle_before_transaction;

   initial begin
      #1 if (enable_c_idle_before_transaction) begin
         c_idle_before_transaction = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (idle_before_burst_transaction_sampled == 1 && clken) begin
         if (enable_c_idle_before_transaction) begin
            c_idle_before_transaction.sample();
            #1;
         end
         idle_before_burst_transaction = 0;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_continuous_read
   // This cover group covers the different cycle numbers of continuous read 
   // asserted from 2 until AV_MAX_CONTINUOUS_READ. For the continuous read cycles 
   // more than AV_MAX_CONTINUOUS_READ will go to another bin.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_read;
      cp_continuous_read: coverpoint continuous_read
      {
         bins cg_continuous_read_cp_continuous_read [] = 
            {[2:(AV_MAX_CONTINUOUS_READ < 2) ? 2:AV_MAX_CONTINUOUS_READ]};
         bins cg_continuous_read_cp_continuous_read_high = 
            {[AV_MAX_CONTINUOUS_READ+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_read c_continuous_read;

   initial begin
      #1 if (enable_c_continuous_read && USE_READ) begin
         c_continuous_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_continuous_read && USE_READ && clken) begin
         if (continuous_read_sampled == 1) begin
            c_continuous_read.sample();
            continuous_read = 0;
            #1;
         end
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_continuous_write
   // This cover group covers the different cycle numbers of continuous write 
   // asserted from 2 until AV_MAX_CONTINUOUS_WRITE. For the continuous write cycles 
   // more than AV_MAX_CONTINUOUS_WRITE will go to another bin.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_write;
      cp_continuous_write: coverpoint continuous_write
      {
         bins cg_continuous_write_cp_continuous_write [] = 
            {[2:(AV_MAX_CONTINUOUS_WRITE) < 2 ? 2:AV_MAX_CONTINUOUS_WRITE]};
         bins cg_continuous_write_cp_continuous_write_high = 
            {[AV_MAX_CONTINUOUS_WRITE+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_write c_continuous_write;

   initial begin
      #1 if (enable_c_continuous_write && USE_WRITE) begin
         c_continuous_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_continuous_write && USE_WRITE && clken) begin
         if (continuous_write_sampled == 1) begin
            c_continuous_write.sample();
            continuous_write = 0;
            #1;
         end
      end
   end
   
   
   //-------------------------------------------------------------------------------
   // =head3 c_write_with_and_without_writeresponserequest
   // This cover group covers write transaction with writeresponserequest asserted
   // and deasserted.
   //-------------------------------------------------------------------------------

   covergroup cg_write_with_and_without_writeresponserequest;
      cp_write_with_and_without_writeresponserequest: coverpoint writeresponserequest
      {
         bins cg_write_with_and_without_writeresponserequest_cp_write_with_writeresponserequest = {1};
         bins cg_write_with_and_without_writeresponserequest_cp_write_without_writeresponserequest = {0};
      }
      option.per_instance = 1;
   endgroup

   cg_write_with_and_without_writeresponserequest c_write_with_and_without_writeresponserequest;

   initial begin
      #1 if (enable_c_write_with_and_without_writeresponserequest && USE_WRITERESPONSE && USE_WRITE) begin
         c_write_with_and_without_writeresponserequest = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_write_with_and_without_writeresponserequest && USE_WRITERESPONSE && USE_WRITE) begin
         if (write && !waitrequest && clken) begin
            c_write_with_and_without_writeresponserequest.sample();
            #1;
         end
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_write_after_reset
   // This cover group covers write transaction right after reset
   //-------------------------------------------------------------------------------

   covergroup cg_write_after_reset;
      cp_write_after_reset: coverpoint write_after_reset
      {
         bins cg_write_after_reset_cp_write_after_reset = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_write_after_reset c_write_after_reset;

   initial begin
      #1 if (enable_c_write_after_reset && USE_WRITE) begin
         c_write_after_reset = new();
      end
   end

   always @(posedge clk) begin
      if (enable_c_write_after_reset && USE_WRITE && !reset && clken) begin
         if (write) begin
            c_write_after_reset.sample();
            #1;
         end
         if (write_reset_transaction == 0) begin
            write_after_reset = 0;
         end
         write_reset_transaction = 0;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_read_after_reset
   // This cover group covers read transaction right after reset
   // =cut
   //-------------------------------------------------------------------------------

   covergroup cg_read_after_reset;
      cp_read_after_reset: coverpoint read_after_reset
      {
         bins cg_read_after_reset_cp_read_after_reset = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_read_after_reset c_read_after_reset;

   initial begin
      #1 if (enable_c_read_after_reset && USE_READ) begin
         c_read_after_reset = new();
      end
   end

   always @(posedge clk) begin
      if (enable_c_read_after_reset && USE_READ && !reset && clken) begin
         if (read) begin
            c_read_after_reset.sample();
            #1;
         end
         if (read_reset_transaction == 0) begin
            read_after_reset = 0;
         end
         read_reset_transaction = 0;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head2 Slave Coverages
   // The following are the cover group code focus on Slave component coverage
   //-------------------------------------------------------------------------------

   //-------------------------------------------------------------------------------
   // =head3 c_idle_in_read_response
   // This cover group covers idle cycles during read response
   //-------------------------------------------------------------------------------

   covergroup cg_idle_in_read_response;
      cp_idle_in_read_response: coverpoint idle_in_read_response
      {
         bins cg_idle_in_read_response_cp_idle_in_read_response_count = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_idle_in_read_response c_idle_in_read_response;

   initial begin
      #1 if (enable_c_idle_in_read_response && USE_BURSTCOUNT && USE_READ &&
             USE_READ_DATA_VALID) begin
         c_idle_in_read_response = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_idle_in_read_response && USE_BURSTCOUNT && USE_READ &&
          USE_READ_DATA_VALID && clken) begin
         c_idle_in_read_response.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_read_latency
   // This cover group covers different read latency cycles
   //-------------------------------------------------------------------------------

   covergroup cg_read_latency;
      cp_read_latency: coverpoint read_latency_counter
      {
         bins cg_read_latency_cp_read_latency_count_low = {1};
         bins cg_read_latency_cp_read_latency_count_high =
            {[(AV_MAX_READ_LATENCY < 2? 1:2):
              (AV_MAX_READ_LATENCY < 2? 1:AV_MAX_READ_LATENCY)]};
      }
      option.per_instance = 1;
   endgroup

   cg_read_latency c_read_latency;

   initial begin
      #1 if (enable_c_read_latency && USE_READ && USE_READ_DATA_VALID &&
             AV_MAX_READ_LATENCY > 0) begin
         c_read_latency = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_read_latency && USE_READ && USE_READ_DATA_VALID &&
          AV_MAX_READ_LATENCY > 0 && clken) begin
         c_read_latency.sample();
         #1;
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_waitrequested_read
   // This cover group covers different waitrequested read cycles
   //-------------------------------------------------------------------------------

   covergroup cg_waitrequested_read;
      cp_waitrequested_read_cycle: coverpoint waitrequested_read_counter
      {
         bins cg_waitrequested_read_cp_waitrequested_read_cycle_low = {1};
         bins cg_waitrequested_read_cp_waitrequested_read_cycle_high =
            {[(AV_MAX_WAITREQUESTED_READ < 2? 1:2):
              (AV_MAX_WAITREQUESTED_READ < 2? 1:AV_MAX_WAITREQUESTED_READ)]};
      }
      option.per_instance = 1;
   endgroup

   cg_waitrequested_read c_waitrequested_read;

   initial begin
      #1 if (enable_c_waitrequested_read && USE_WAIT_REQUEST && USE_READ &&
             AV_MAX_WAITREQUESTED_READ > 0) begin
         c_waitrequested_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_waitrequested_read && USE_WAIT_REQUEST && USE_READ &&
          AV_MAX_WAITREQUESTED_READ > 0 && clken) begin
         if (temp_waitrequested_read_counter == 0) begin
            c_waitrequested_read.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_waitrequested_write
   // This cover group covers different waitrequested write cycles
   //-------------------------------------------------------------------------------

   covergroup cg_waitrequested_write;
      cp_waitrequested_write_cycle: coverpoint waitrequested_write_counter
      {
         bins cg_waitrequested_write_cp_waitrequested_write_cycle_low = {1};
         bins cg_waitrequested_write_cp_waitrequested_write_cycle_high =
            {[(AV_MAX_WAITREQUESTED_WRITE < 2? 1:2):
              (AV_MAX_WAITREQUESTED_WRITE < 2? 1:AV_MAX_WAITREQUESTED_WRITE)]};
      }
      option.per_instance = 1;
   endgroup

   cg_waitrequested_write c_waitrequested_write;

   initial begin
      #1 if (enable_c_waitrequested_write && USE_WAIT_REQUEST && USE_WRITE &&
             AV_MAX_WAITREQUESTED_WRITE > 0) begin
         c_waitrequested_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_waitrequested_write && USE_WAIT_REQUEST && USE_WRITE &&
          AV_MAX_WAITREQUESTED_WRITE > 0 && clken) begin
         if (temp_waitrequested_write_counter == 0) begin
            c_waitrequested_write.sample();
            #1;
         end
      end
   end

   //-------------------------------------------------------------------------------
   // =head3 c_continuous_waitrequest_from_idle_to_write
   // This cover group covers waitrequest is asserted before waitrequested write.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_waitrequest_from_idle_to_write;
      cp_continuous_waitrequest_from_idle_to_write: coverpoint waitrequest_before_waitrequested_write
      {
         bins cg_continuous_waitrequest_from_idle_to_write_cp_continuous_waitrequest_from_idle_to_write = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_waitrequest_from_idle_to_write c_continuous_waitrequest_from_idle_to_write;

   initial begin
      #1 if (enable_c_continuous_waitrequest_from_idle_to_write && USE_WAIT_REQUEST && USE_WRITE &&
             AV_MAX_WAITREQUESTED_WRITE > 0) begin
         c_continuous_waitrequest_from_idle_to_write = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (!waitrequest && clken) begin
         if (enable_c_continuous_waitrequest_from_idle_to_write && USE_WAIT_REQUEST && USE_WRITE &&
             AV_MAX_WAITREQUESTED_WRITE > 0) begin
            c_continuous_waitrequest_from_idle_to_write.sample();
            #1;
         end
         waitrequest_before_waitrequested_write = 0;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_continuous_waitrequest_from_idle_to_read
   // This cover group covers waitrequest is asserted before waitrequested read.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_waitrequest_from_idle_to_read;
      cp_continuous_waitrequest_from_idle_to_read: coverpoint waitrequest_before_waitrequested_read
      {
         bins cg_continuous_waitrequest_from_idle_to_read_cp_continuous_waitrequest_from_idle_to_read = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_waitrequest_from_idle_to_read c_continuous_waitrequest_from_idle_to_read;

   initial begin
      #1 if (enable_c_continuous_waitrequest_from_idle_to_read && USE_WAIT_REQUEST && USE_READ &&
             AV_MAX_WAITREQUESTED_READ > 0) begin
         c_continuous_waitrequest_from_idle_to_read = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (!waitrequest && clken) begin
         if (enable_c_continuous_waitrequest_from_idle_to_read && USE_WAIT_REQUEST && USE_READ &&
             AV_MAX_WAITREQUESTED_READ > 0) begin
            c_continuous_waitrequest_from_idle_to_read.sample();
            #1;
         end
         waitrequest_before_waitrequested_read = 0;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_waitrequest_without_command
   // This cover group covers no command has been asserted for the period 
   // waitrequest is asserted and then deasserted.
   //-------------------------------------------------------------------------------

   covergroup cg_waitrequest_without_command;
      cp_waitrequest_without_command: coverpoint waitrequest_without_command
      {
         bins cg_waitrequest_without_command_cp_waitrequest_without_command = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_waitrequest_without_command c_waitrequest_without_command;

   initial begin
      #1 if (enable_c_waitrequest_without_command && USE_WAIT_REQUEST) begin
         c_waitrequest_without_command = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_waitrequest_without_command && USE_WAIT_REQUEST && clken) begin
         c_waitrequest_without_command.sample();
         waitrequest_without_command = 0;
         #1;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_continuous_readdatavalid
   // This cover group covers the different cycle numbers of continuous 
   // readdatavalid asserted from 2 until AV_MAX_CONTINUOUS_READDATAVALID. For the 
   // continuous readdatavalid cycles more than AV_MAX_CONTINUOUS_READDATAVALID will
   // go to another bin.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_readdatavalid;
      cp_continuous_readdatavalid: coverpoint continuous_readdatavalid
      {
         bins cg_continuous_readdatavalid_cp_continuous_readdatavalid [] = 
            {[2:(AV_MAX_CONTINUOUS_READDATAVALID < 2) ? 2:AV_MAX_CONTINUOUS_READDATAVALID]};
         bins cg_continuous_readdatavalid_cp_continuous_readdatavalid_high = 
            {[AV_MAX_CONTINUOUS_READDATAVALID+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_readdatavalid c_continuous_readdatavalid;

   initial begin
      #1 if (enable_c_continuous_readdatavalid && USE_READ_DATA_VALID) begin
         c_continuous_readdatavalid = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_continuous_readdatavalid && USE_READ_DATA_VALID && clken) begin
         if (continuous_readdatavalid_sampled == 1) begin
            c_continuous_readdatavalid.sample();
            continuous_readdatavalid = 0;
            #1;
         end
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_continuous_waitrequest
   // This cover group covers the different cycle numbers of continuous waitrequest
   // asserted from 2 until AV_MAX_CONTINUOUS_WAITREQUEST. For the continuous 
   // waitrequest cycles more than AV_MAX_CONTINUOUS_WAITREQUEST will go to another 
   // bin.
   //-------------------------------------------------------------------------------

   covergroup cg_continuous_waitrequest;
      cp_continuous_waitrequest: coverpoint continuous_waitrequest
      {
         bins cg_continuous_waitrequest_cp_continuous_waitrequest [] = 
            {[2:(AV_MAX_CONTINUOUS_WAITREQUEST < 2) ? 2:AV_MAX_CONTINUOUS_WAITREQUEST]};
         bins cg_continuous_waitrequest_cp_continuous_waitrequest_high = 
            {[AV_MAX_CONTINUOUS_WAITREQUEST+1:$]};
      }
      option.per_instance = 1;
   endgroup

   cg_continuous_waitrequest c_continuous_waitrequest;

   initial begin
      #1 if (enable_c_continuous_waitrequest && USE_WAIT_REQUEST) begin
         c_continuous_waitrequest = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_continuous_waitrequest && USE_WAIT_REQUEST && clken) begin
         if (continuous_waitrequest_sampled == 1) begin
            c_continuous_waitrequest.sample();
            continuous_waitrequest = 0;
            #1;
         end
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_waitrequest_in_write_burst
   // This cover group covers the different number of cycles for idle cycle during 
   // write burst transaction with different number of cycles for waitrequest.
   //-------------------------------------------------------------------------------

   covergroup cg_waitrequest_in_write_burst;
      cp_waitrequest_in_write_burst: coverpoint idle_in_write_burst_with_waitrequest
      {
         bins cg_waitrequest_in_write_burst_cp_waitrequest_in_write_burst = {1};
      }
      option.per_instance = 1;
   endgroup

   cg_waitrequest_in_write_burst c_waitrequest_in_write_burst;

   initial begin
      #1 if (enable_c_waitrequest_in_write_burst && USE_WAIT_REQUEST && USE_WRITE && USE_BURSTCOUNT && (AV_BURSTCOUNT_W > 1)) begin
         c_waitrequest_in_write_burst = new();
      end
   end

   always @(posedge clk && !reset) begin
      if (enable_c_waitrequest_in_write_burst && USE_WAIT_REQUEST && USE_BURSTCOUNT && USE_WRITE && (AV_BURSTCOUNT_W > 1)) begin
         if (idle_in_write_burst_with_waitrequest_sampled == 1 && clken) begin
            c_waitrequest_in_write_burst.sample();
            idle_in_write_burst_with_waitrequest = 0;
            idle_in_write_burst_with_waitrequest_sampled = 0;
            #1;
         end
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_readresponse 
   // This cover group covers each bits of the valid readresponse which represent 
   // different status.
   //-------------------------------------------------------------------------------

   // covergroup cg_readresponse;
      // cp_readresponse: coverpoint readresponse_bit_num
      // {
         // bins cg_readresponse_cp_readresponse [] = {[0:(AV_READRESPONSE_W-1)]};
      // }
      // option.per_instance = 1;
   // endgroup

   // cg_readresponse c_readresponse;
   
   // initial begin
      // #1 if (enable_c_readresponse && USE_READRESPONSE && USE_READ) begin
           // c_readresponse = new();
      // end
   // end
   
   // always @(posedge clk && !reset) begin
      // if (enable_c_readresponse && USE_READRESPONSE && USE_READ && clken) begin
         // if ((USE_READ_DATA_VALID && readdatavalid) || (!USE_READ_DATA_VALID)) begin
            // for (int i=0; i<AV_READRESPONSE_W; i++) begin
               // if (readresponse[i] == 1)
                  // readresponse_bit_num = i;
               // else
                  // readresponse_bit_num = AV_READRESPONSE_W;
               // c_readresponse.sample();
            // end
         // end
         // #1;
      // end
   // end
   
   //-------------------------------------------------------------------------------
   // =head3 c_writeresponse 
   // This cover group covers each bits of the valid writeresponse which represent 
   // different status.
   //-------------------------------------------------------------------------------

   // covergroup cg_writeresponse;
      // cp_writeresponse : coverpoint writeresponse_bit_num
      // {
         // bins cg_writeresponse_cp_writeresponse [] = {[0:(AV_WRITERESPONSE_W-1)]};
      // }
      // option.per_instance = 1;
   // endgroup

   // cg_writeresponse c_writeresponse;

   // initial begin
      // #1 if (enable_c_writeresponse && USE_WRITERESPONSE && USE_WRITE) begin
         // c_writeresponse = new();
      // end
   // end
   
   // always @(posedge clk && !reset) begin
      // if (enable_c_writeresponse && USE_WRITERESPONSE && USE_WRITE  && clken) begin
         // if (writeresponsevalid) begin
            // for (int i=0; i<AV_WRITERESPONSE_W; i++) begin
               // if (writeresponse[i] == 1)
                  // writeresponse_bit_num = i;
               // else
                  // writeresponse_bit_num = AV_WRITERESPONSE_W;
               // c_writeresponse.sample();
            // end
         // end
         // #1;
      // end
   // end
   
   //-------------------------------------------------------------------------------
   // =head3 c_write_response 
   // This cover group covers the value of write response
   //-------------------------------------------------------------------------------

   covergroup cg_write_response;
      cp_write_response : coverpoint write_response
      {
         bins cg_write_response_cp_write_response [] = {AV_OKAY, AV_DECODE_ERROR, AV_SLAVE_ERROR};
      }
   endgroup

   cg_write_response c_write_response;

   initial begin
      #1 if (enable_c_write_response && USE_WRITERESPONSE && USE_WRITE) begin
         c_write_response = new();
      end
   end
   
   always @(posedge clk && !reset) begin
      if (enable_c_write_response && USE_WRITERESPONSE && USE_WRITE  && clken) begin
         if (writeresponsevalid) begin
            assert($cast(write_response, response))
               else begin
                  $sformat(message, "%m: Response value is not valid when write response is valid");
                  print(VERBOSITY_FAILURE, message);
               end
            c_write_response.sample();
         end
         #1;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_read_response 
   // This cover group covers the value of read response
   //-------------------------------------------------------------------------------
   
   covergroup cg_read_response;
      cp_read_response : coverpoint read_response
      {
         bins cg_read_response_cp_read_response [] = {AV_OKAY, AV_DECODE_ERROR, AV_SLAVE_ERROR};
      }
   endgroup

   cg_read_response c_read_response;

   initial begin
      #1 if (enable_c_read_response && USE_READRESPONSE && USE_READ) begin
         c_read_response = new();
      end
   end
   
   always @(posedge clk && !reset) begin
      if (enable_c_read_response && USE_READRESPONSE && USE_READ && clken) begin
         if ((USE_READ_DATA_VALID && readdatavalid) || 
               (!USE_READ_DATA_VALID && fix_latency_queued_counter == AV_FIX_READ_LATENCY && fix_latency_queued_counter != 0)) begin
            
            assert($cast(read_response, response))
               else begin
                  $sformat(message, "%m: Response value is not valid when read response is valid");
                  print(VERBOSITY_FAILURE, message);
               end
            c_read_response.sample();
         end
         #1;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_write_response_transition
   // This cover group covers the value of write response
   //-------------------------------------------------------------------------------

   covergroup cg_write_response_transition;
      cp_write_response_transition : coverpoint write_response_transition
      {
         bins cg_write_response_transition_cp_write_response_transition_OKAY_TO_OKAY                  = {4'b0000};
         bins cg_write_response_transition_cp_write_response_transition_OKAY_TO_SLAVE_ERROR           = {4'b0010};
         bins cg_write_response_transition_cp_write_response_transition_OKAY_TO_DECODE_ERROR          = {4'b0011};
         bins cg_write_response_transition_cp_write_response_transition_SLAVE_ERROR_TO_OKAY           = {4'b1000};
         bins cg_write_response_transition_cp_write_response_transition_SLAVE_ERROR_TO_SLAVE_ERROR    = {4'b1010};
         bins cg_write_response_transition_cp_write_response_transition_SLAVE_ERROR_TO_DECODE_ERROR   = {4'b1011};
         bins cg_write_response_transition_cp_write_response_transition_DECODE_ERROR_TO_OKAY          = {4'b1100};
         bins cg_write_response_transition_cp_write_response_transition_DECODE_ERROR_TO_SLAVE_ERROR   = {4'b1110};
         bins cg_write_response_transition_cp_write_response_transition_DECODE_ERROR_TO_DECODE_ERROR  = {4'b1111};
      }
   endgroup

   cg_write_response_transition c_write_response_transition;

   initial begin
      #1 if (enable_c_write_response_transition && USE_WRITERESPONSE && USE_WRITE) begin
         c_write_response_transition = new();
      end
   end
   
   always @(posedge clk && !reset) begin
      if (enable_c_write_response_transition && USE_WRITERESPONSE && USE_WRITE  && clken) begin
         if (writeresponsevalid) begin            
            c_write_response_transition.sample();
         end
         #1;
      end
   end
   
   //-------------------------------------------------------------------------------
   // =head3 c_read_response_transition
   // This cover group covers the value of read response
   //-------------------------------------------------------------------------------

   covergroup cg_read_response_transition;
      cp_read_response_transition : coverpoint read_response_transition
      {
         bins cg_read_response_transition_cp_read_response_transition_OKAY_TO_OKAY                  = {4'b0000};
         bins cg_read_response_transition_cp_read_response_transition_OKAY_TO_SLAVE_ERROR           = {4'b0010};
         bins cg_read_response_transition_cp_read_response_transition_OKAY_TO_DECODE_ERROR          = {4'b0011};
         bins cg_read_response_transition_cp_read_response_transition_SLAVE_ERROR_TO_OKAY           = {4'b1000};
         bins cg_read_response_transition_cp_read_response_transition_SLAVE_ERROR_TO_SLAVE_ERROR    = {4'b1010};
         bins cg_read_response_transition_cp_read_response_transition_SLAVE_ERROR_TO_DECODE_ERROR   = {4'b1011};
         bins cg_read_response_transition_cp_read_response_transition_DECODE_ERROR_TO_OKAY          = {4'b1100};
         bins cg_read_response_transition_cp_read_response_transition_DECODE_ERROR_TO_SLAVE_ERROR   = {4'b1110};
         bins cg_read_response_transition_cp_read_response_transition_DECODE_ERROR_TO_DECODE_ERROR  = {4'b1111};
      }
   endgroup

   cg_read_response_transition c_read_response_transition;

   initial begin
      #1 if (enable_c_read_response_transition && USE_READRESPONSE && USE_READ) begin
         c_read_response_transition = new();
      end
   end
   
   always @(posedge clk && !reset) begin
      if (enable_c_read_response_transition && USE_READRESPONSE && USE_READ  && clken) begin
         if ((USE_READ_DATA_VALID && readdatavalid) || 
               (!USE_READ_DATA_VALID && fix_latency_queued_counter == AV_FIX_READ_LATENCY && fix_latency_queued_counter != 0)) begin
            c_read_response_transition.sample();
         end
         #1;
      end
   end
      
   //--------------------------------------------------------------------------
   // COVERAGE CODE END
   //--------------------------------------------------------------------------   
   `endif

   // synthesis translate_on

endmodule 
