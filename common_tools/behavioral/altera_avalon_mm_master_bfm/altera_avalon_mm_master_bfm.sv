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


// $Id: //acds/rel/13.1/ip/sopc/components/verification/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv#1 $
// $Revision: #1 $
// $Date: 2013/08/11 $
// $Author: swbranch $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_master_bfm
// =head1 SYNOPSIS
// Memory Mapped Avalon Master Bus Functional Model (BFM)
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// Let's walk through a single transaction to illustrate how the Avalon
// Memory Mapped Master BFM works. First the user constructs a command 
// descriptor using the public set_command methods. These methods populate 
// the command descriptor fields with the data describing a transaction.
// Both individual word as well as burst operations can be encapsulated 
// in a single descriptor representing a single transaction. 
// Once the descriptor has been constructed, it is pushed into the 
// pending command queue. The bus driver, if it is not busy or in reset 
// state will pop a single descriptor out of the pending command queue as 
// soon as it is available. Simultaneously, a time stamp is taken 
// from the clock counter and this value is bundled together with the 
// descriptor and pushed into the issued command queue. The 
// time stamp will be used to measure the latency of read operation.
// The driver will issue the transaction request onto the physical 
// Avalon bus and hold it until the waitrequest signal is deasserted. 
// In the case of a burst write transaction, there will be a distinct 
// bus operation for each word in the burst. The bus is able to assert 
// waitrequest on each cycle.
// Meanwhile, the time stamped descriptor in the  issued command queue 
// is popped out by the bus monitor, if it is not in reset state or 
// busy with a transaction. The descriptor will tell the monitor 
// what transaction response it should expect to see on the Avalon bus. 
// In the case of a write transaction, there is currently no expected 
// response in the Avalon protocol, so the transaction is 
// assumed to have completed. (In the future we will likely add an 
// error signal on the response plane to signal incomplete or otherwise 
// broken transactions to prevent deadlock.) For read transactions, we 
// expect to capture data on the response plane. When it is received, 
// the latency is calculated by subtracting the current state of the clock 
// counter from the time stamp for that transaction. Burst read 
// transactions will need to capture multiple read data words. Once the 
// transaction is complete, a response descriptor is constructed and 
// pushed into the response queue. The client testbench can query the 
// state of the response queue, and all the other queues for that 
// matter. If the response queue is not empty, API methods are called 
// to pop a descriptor and dissect it for further processing by the 
// testbench. There are two ways the testbench can determine whether 
// all transactions pushed into the command queue have completed. The 
// test can poll the BFM status using the get_command_complete() API 
// task. It returns 1 if all commands have completed, otherwise it 
// returns 0. Alternatively, the testbench can block on the signaling 
// event named signal_command_complete. This event is fired on the 
// same conditions which cause get_command_complete() to return 1.
//
// =head1 UNSUPPORTED FEATURES
// Please note that this BFM does not support the following interface 
// parameters: doStreamReads, doStreamWrites
// Also, please note that this BFM does not support the following
// interface ports: flush, resetrequest and burstwrap.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_master_bfm(
                                    clk,
                                    reset,
                                    
                                    avm_clken,
                                   
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
                                    avm_readresponse,
                                    avm_readid,
                                    avm_writeresponserequest,
                                    avm_writeresponsevalid,
                                    avm_writeresponse,
                                    avm_writeid,
                                    avm_response
                                   );
   // =head1 PARAMETERS
   parameter AV_ADDRESS_W               = 32; // Address width in bits
   parameter AV_SYMBOL_W                = 8;  // Data symbol width in bits
   parameter AV_NUMSYMBOLS              = 4;  // Number of symbols per word
   parameter AV_BURSTCOUNT_W            = 3;  // Burst port width in bits
   parameter AV_READRESPONSE_W          = 8;
   parameter AV_WRITERESPONSE_W         = 8;   

   parameter USE_READ                   = 1;  // Use read pin on interface
   parameter USE_WRITE                  = 1;  // Use write pin on interface
   parameter USE_ADDRESS                = 1;  // Use address pins on interface
   parameter USE_BYTE_ENABLE            = 1;  // Use byte_enable pins on interface
   parameter USE_BURSTCOUNT             = 1;  // Use burstcount pin on interface 
   parameter USE_READ_DATA              = 1;  // Use readdata pin on interface 
   parameter USE_READ_DATA_VALID        = 1;  // Use readdatavalid pin on interface
   parameter USE_WRITE_DATA             = 1;  // Use writedata pin on interface   
   parameter USE_BEGIN_TRANSFER         = 1;  // Use begintransfer pin on interface
   parameter USE_BEGIN_BURST_TRANSFER   = 1;  // Use beginbursttransfer pin on interface
   parameter USE_WAIT_REQUEST           = 1;  // Use waitrequest pin on interface
   parameter USE_ARBITERLOCK            = 0;  // Use arbiterlock pin on interface
   parameter USE_LOCK                   = 0;  // Use lock pin on interface
   parameter USE_DEBUGACCESS            = 0;  // Use debugaccess pin on interface 
   parameter USE_TRANSACTIONID          = 0;  // Use transactionid interface pin
   parameter USE_WRITERESPONSE          = 0;  // Use write response interface pins
   parameter USE_READRESPONSE           = 0;  // Use read response interface pins  
   parameter USE_CLKEN                  = 0;  // Use NTCM interface pins  
   parameter AV_REGISTERINCOMINGSIGNALS = 0;  // Indicate that waitrequest is come from register 

   parameter AV_FIX_READ_LATENCY        = 0;  // Fixed read latency in cycles
   parameter AV_MAX_PENDING_READS       = 0;  // Number of pending read transactions
   parameter AV_MAX_PENDING_WRITES      = 0;  // Number of pending write transactions

   parameter AV_BURST_LINEWRAP          = 0;  
   parameter AV_BURST_BNDR_ONLY         = 0;  // Assert Addr alignment
   parameter AV_CONSTANT_BURST_BEHAVIOR = 1;  // Address, burstcount, transactionid and
                                              // avm_writeresponserequest need to be held constant
                                              // in burst transaction
   parameter AV_READ_WAIT_TIME          = 0;  // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME         = 0;  // USE_WAIT_REQUEST is 0
   
   parameter REGISTER_WAITREQUEST       = 0;  // Waitrequest is registered at the slave
   parameter VHDL_ID                    = 0;   // VHDL BFM ID number
   
   localparam MAX_BURST_SIZE            = USE_BURSTCOUNT ? 2**(AV_BURSTCOUNT_W-1) : 1;
   localparam AV_DATA_W                 = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam AV_TRANSACTIONID_W        = 8;
   
   function int lindex;
      // returns the left index for a vector having a declared width 
      // when width is 0, then the left index is set to 0 rather than -1
      input [31:0] width;
      lindex = (width > 0) ? (width-1) : 0;
   endfunction  
   
   // =cut
   // =head1 PINS
   // =head2 Clock Interface
   input                                                clk;
   input                                                reset;   // active high
   // =head2 Avalon Master Interface
   input                                                avm_waitrequest;   
   input                                                avm_readdatavalid; 
   input  [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0 ]      avm_readdata;
   output                                               avm_write;         
   output                                               avm_read;
   output [lindex(AV_ADDRESS_W):0                  ]    avm_address;
   output [lindex(AV_NUMSYMBOLS):0                 ]    avm_byteenable;    
   output [lindex(AV_BURSTCOUNT_W):0               ]    avm_burstcount;
   output                                               avm_beginbursttransfer;
   output                                               avm_begintransfer;   
   output [lindex(AV_SYMBOL_W * AV_NUMSYMBOLS):0 ]      avm_writedata;
   output                                               avm_arbiterlock;
   output                                               avm_lock;
   output                                               avm_debugaccess;   

   output [lindex(AV_TRANSACTIONID_W):0            ]    avm_transactionid;
   input  [lindex(AV_READRESPONSE_W):0             ]    avm_readresponse;
   input  [lindex(AV_TRANSACTIONID_W):0            ]    avm_readid;
   output                                               avm_writeresponserequest;
   input                                                avm_writeresponsevalid;
   input  [lindex(AV_WRITERESPONSE_W):0            ]    avm_writeresponse;
   input  [lindex(AV_TRANSACTIONID_W):0            ]    avm_writeid;
   input  [1:0]                                         avm_response;
   
   output                                               avm_clken; 
   
   //--------------------------------------------------------------------------
   // Private Data Structures
   // All internal data types are packed. SystemVerilog struct or array 
   // slices can be accessed directly and can be assigned to a logic array 
   // in Verilog or a std_logic_vector in VHDL.
   // All dommand transactions expect an associated response transaction even
   // when no data is returned. For example, a write transaction returns a
   // response indicating completion of the command with a wait latency value.
   // In the case of a write transaction, the response descriptor field values
   // for data and read_latency are "don't care".
   //--------------------------------------------------------------------------
   localparam INT_W = 32;
   
   // synthesis translate_off
   import verbosity_pkg::*;
   import avalon_mm_pkg::*;
   import avalon_utilities_pkg::*;
   
   logic                                        avm_read;
   logic                                        avm_write;
   logic                                        avm_arbiterlock;
   logic                                        avm_lock;
   logic                                        avm_debugaccess;         
   logic [lindex(AV_NUMSYMBOLS):0]              avm_byteenable;     
   logic [lindex(AV_ADDRESS_W):0]               avm_address;   
   logic [lindex(AV_BURSTCOUNT_W):0]            avm_burstcount;
   logic                                        avm_beginbursttransfer;
   logic                                        avm_begintransfer;      
   logic [lindex(AV_SYMBOL_W*AV_NUMSYMBOLS):0]  avm_writedata;
   logic [lindex(AV_TRANSACTIONID_W):0]         avm_transactionid;
   logic                                        avm_writeresponserequest;
   logic [1:0]                                  avm_response;
   
   logic                                        avm_clken;
   logic                                        temp_avm_clken = 1'b1;
   
   typedef logic [lindex(AV_ADDRESS_W):0                                ]  AvalonAddress_t;
   typedef logic [lindex(AV_BURSTCOUNT_W):0                             ]  AvalonBurstCount_t; 
   typedef logic [lindex(AV_TRANSACTIONID_W):0                          ]  AvalonTransactionId_t;   
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_DATA_W):0         ]  AvalonData_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_NUMSYMBOLS):0     ]  AvalonByteEnable_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(INT_W):0             ]  AvalonIdle_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(INT_W):0             ]  AvalonLatency_t;   
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_READRESPONSE_W):0 ]  AvalonReadResponse_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_WRITERESPONSE_W):0]  AvalonWriteResponse_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][1:0]                           AvalonReadResponseStatus_t;

   // command transaction descriptor - access with public API
   typedef struct packed {
                          Request_t               request;     
                          AvalonAddress_t         address;     // start address
                          AvalonBurstCount_t      burst_count; // burst length
                          AvalonData_t            data;        // write data
                          AvalonByteEnable_t      byte_enable; // hot encoded  
                          AvalonIdle_t            idle;        // interspersed
                          int                     init_latency;
                          int                     seq_count;
                          int                     burst_size;
                          logic                   arbiterlock; // on=1 / off=0
                          logic                   lock;        // on=1 / off=0
                          logic                   debugaccess; // on=1 / off=0
                          AvalonTransactionId_t   transaction_id;
                          logic                   write_response_request; 
                          } MasterCommand_t;

   // read and write response transaction descriptor - access with public API
   typedef struct packed {
                          Request_t                      request;     
                          AvalonAddress_t                address;     // start addr
                          AvalonBurstCount_t             burst_count; // burst length
                          AvalonData_t                   data;        // read data
                          AvalonByteEnable_t             byte_enable; // hot encoded 
                          AvalonLatency_t                wait_latency;
                          AvalonLatency_t                read_latency;
                          int                            write_latency;
                          int                            seq_count;
                          int                            burst_size;
                          AvalonTransactionId_t          read_id;
                          AvalonTransactionId_t          write_id;
                          AvalonReadResponseStatus_t     read_response;
                          AvalonResponseStatus_t         write_response;
                          logic                          write_response_request;
                          } MasterResponse_t;

   // transaction descriptor for internal issued command queue
   typedef struct packed {
                          MasterCommand_t         command;
                          AvalonLatency_t         time_stamp;
                          AvalonLatency_t         wait_time;  
                          } IssuedCommand_t;

   //--------------------------------------------------------------------------
   // Local Signals
   //--------------------------------------------------------------------------
   string            message                     = "*uninitialized*";

   event             __drive_request_done;
   event             __signal_set_clken;        // triggered when set_clken API
                                                // been called
   event             __clk;                     
   event             __command_issued;          // triggered when command been
                                                // issued
   
   int               clock_counter               = 0;
   int               clock_counter_snapshot      = 0;
   int               wait_time                   = 0;
   int               read_time                   = 0;
   int               wait_time_stamp             = 0;

   MasterCommand_t   pending_command_queue[$];
   IssuedCommand_t   issued_read_command_queue[$];
   IssuedCommand_t   issued_write_command_queue[$];
   MasterResponse_t  read_response_queue[$];
   MasterResponse_t  write_response_queue[$];

   Request_t         last_request                = REQ_IDLE;
   MasterCommand_t   new_command                 = '0; 
   MasterCommand_t   current_command;

   MasterResponse_t  return_response             = 'x;
   MasterResponse_t  completed_read_response     = 'x;
   MasterResponse_t  completed_write_response    = 'x;

   IssuedCommand_t   issued_command;
   IssuedCommand_t   completed_command;
   IssuedCommand_t   completed_read_command;
   IssuedCommand_t   completed_write_command;
   
   AvalonResponseStatus_t  null_response_status;
   IdleOutputValue_t       idle_output_config    = UNKNOWN;

   int               command_issued_counter      = 0;
   int               command_completed_counter   = 0;
   int               command_outstanding_counter = 0;
   int               command_sequence_counter    = 1;

   int               response_timeout            = 100; // disabled when 0
   int               command_timeout             = 100; // disabled when 0
   int               max_command_queue_size      = 256;
   int               min_command_queue_size      = 2;
   int               temp_write_latency          = 0;
   int               response_time_stamp         = 0;
   int               temp_read_latency           = 0;
   int               read_response_burst_counter = 0;
   int               response_time_stamp_queue[$];
   bit               start_construct_complete_write_response = 0;
   bit               start_construct_complete_read_response = 0;
   
   //--------------------------------------------------------------------------
   // =head1 Public Methods API
   // =pod
   // This section describes the public methods in the application programming
   // interface (API). The application program interface provides methods for 
   // a testbench which instantiates, controls and queries state in this BFM 
   // component. Test programs must only use these public access methods and 
   // events to communicate with this BFM component. The API and module pins
   // are the only interfaces of this component that are guaranteed to be
   // stable. The API will be maintained for the life of the product. 
   // While we cannot prevent a test program from directly accessing internal
   // tasks, functions, or data private to the BFM, there is no guarantee that
   // these will be present in the future. In fact, it is best for the user
   // to assume that the underlying implementation of this component can 
   // and will change.
   // =cut
   //--------------------------------------------------------------------------

   event signal_fatal_error; // public
   // This event notifies the test bench that a fatal error has occurred
   // in this module.
   
   event signal_read_response_complete; // public
   // This event signals that the read response has been received and
   // pushed into the response queue.
   
   event signal_write_response_complete; // public
   // This event signals that the write response has been received and
   // pushed into the response queue.

   event signal_response_complete; // public
   // This event will fire when either signal_read_response_complete
   // or signal_write_response_complete fires and indicates that either
   // a read or a write response has been received and pushed into the 
   // response queue. 
   
   event signal_command_issued; // public
   // This event signals that the currently pending command has been
   // driven onto the Avalon bus.

   event signal_all_transactions_complete; // public
   // This event signals that all queued transactions have completed.

   event signal_max_command_queue_size; // public
   // This event signals that the maximum pending transaction queue size
   // threshold has been exceeded

   event signal_min_command_queue_size; // public
   // This event signals that the pending transaction queue size
   // is below the minimum threshold
   
   function automatic string get_version();  // public
      // Return BFM version string. For example, version 9.1 sp1 is "9.1sp1" 
      string ret_version = "13.1";
      return ret_version;
   endfunction
   
   function automatic void set_response_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse waiting for a response 
      // before time out is asserted. Disable timeout by setting the value to 0.
      response_timeout = cycles;

      if (cycles == 0) begin
         $sformat(message, "%m: set to %0d cycles - disabled",
                  response_timeout);
      end else begin	 
         $sformat(message, "%m: set to %0d cycles", 
                  response_timeout);
      end
      print(VERBOSITY_INFO, message);
      
   endfunction     

   function automatic void set_command_timeout( // public
      int   cycles = 100 
   );
      // Set the number of cycles that may elapse while stalled with waitrequest
      // before time out is asserted. Disable timeout by setting the value to 0.
      command_timeout = cycles;
      if (cycles == 0) begin
         $sformat(message, "%m: set to %0d cycles - disabled", 
                  command_timeout);	 
      end else begin
         $sformat(message, "%m: set to %0d cycles", 
                  command_timeout);
      end
      print(VERBOSITY_INFO, message);      
   endfunction     

   function automatic bit all_transactions_complete(); // public
     // Query the BFM component to determine whether all issued commands 
     // have been completed. Returns 1 if true and 0 if false.
     // =cut
      $sformat(message, "%m: method called");                  
      print(VERBOSITY_DEBUG, message);
      
      return (!reset &&
              get_command_pending_queue_size() == 0 &&
              get_command_issued_queue_size() == 0 &&
              command_issued_counter > 0 &&
              command_issued_counter == command_completed_counter
              );
   endfunction 

   function automatic int get_command_issued_queue_size(); // public
      // Query the issued command queue to determine the number of 
      // commands that have been driven to the system interconnect 
      // fabric, but have not yet completed.
      $sformat(message, "%m: method called");            
      print(VERBOSITY_DEBUG, message);
      
      return (issued_read_command_queue.size() + issued_write_command_queue.size());
   endfunction 

   function automatic int get_command_pending_queue_size(); // public
      // Query the command queue to determine the number of pending commands
      // waiting to be driven out on the Avalon request plane.
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      
      return pending_command_queue.size();
   endfunction 

   function automatic logic [AV_ADDRESS_W-1:0] get_response_address(); // public
      // Returns the transaction address in the response descriptor that
      // has been popped from the response queue.
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      
      return return_response.address;      
   endfunction 

   function automatic logic [AV_NUMSYMBOLS-1:0] get_response_byte_enable(// public
      int   index
   );
      // Returns the value of the byte enables in the response descriptor
      // that has been popped from the response queue. Each cycle of a 
      // burst response is addressed individually by the specified index.
      $sformat(message, "%m: method called arg0 %0d", index); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index)) 
         return return_response.byte_enable[index];
      else
         return 'x;
   endfunction 

   function automatic logic [AV_BURSTCOUNT_W-1:0] get_response_burst_size();// public
      // Returns the size of the response transaction burst in the 
      // response descriptor that has been popped from the response queue.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      return return_response.burst_count;
   endfunction 

   function automatic logic [AV_DATA_W-1:0] get_response_data( //public
      int   index
   );
      // Returns the transaction data in the response descriptor
      // that has been popped from the response queue. Each cycle in a 
      // burst response is addressed individually by the specified index.
      // In the case of read responses, the data is the data captured on
      // the avm_readdata interface pin. In the case of write responses,
      // the data on the driven avm_writedata pin is captured and 
      // reflected here.
      $sformat(message, "%m: method called arg0 %0d", index); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index)) 
         return return_response.data[index];
      else
         return 'x;
   endfunction 

   function automatic int get_response_latency( // public 
      int index = 0
   ); 
      // Returns the transaction read latency in the response descriptor
      // that has been popped from the response queue. Each cycle in a 
      // burst read has its own latency entry. For write transaction
      // responses the returned value will always be 0.
      $sformat(message, "%m: method called arg0 %0d", index); 
      print(VERBOSITY_DEBUG, message);
      
      if (return_response.request == REQ_READ)
         if (__check_transaction_index(index)) begin
            return return_response.read_latency[index];
         end else begin
            return -1;
         end
      else if (return_response.request == REQ_WRITE) begin
         if (index > 0) begin
            $sformat(message, "%m: Write response does not require burst index. Index value will be ignored");
            print(VERBOSITY_WARNING, message);
         end
         return return_response.write_latency;
      end else begin
         return -1;
      end
   endfunction 

   function automatic Request_t get_response_request(); // public
      // Returns the transaction command type in the response descriptor
      // that has been popped from the response queue.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      return return_response.request;
   endfunction 


   function automatic int get_response_queue_size(); // public
      // Queries the write and read response queue to determine
      // number of response descriptors currently stored in the BFM.
      // This is the number of responses the test program can immediately
      // pop off the response queue for further processing.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      return read_response_queue.size() + write_response_queue.size();
   endfunction

   function automatic int get_response_wait_time( // public
      int index
   ); 
      // Returns the wait time for a transaction in the response descriptor 
      // that has been popped from the response queue. Each cycle in a burst 
      // has its own wait time entry.
      $sformat(message, "%m: method called arg0 %0d", index); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))       
         return return_response.wait_latency[index];
      else
         return -1;
   endfunction 

   task automatic init(); // public
      // Initializes the Avalon-MM Master interface.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      __drive_interface_idle();
      __init_descriptors();
      __init_queues();
   endtask

   function automatic void pop_response(); // public
      // Check internal transaction sequence count values at the head 
      // of both the read and  write response queues.
      // Pop the oldest response descriptor from one of the queues, that is
      // pop the descriptor with the lowest sequence number from either the
      // read or write response queue.
      // The response descriptor is now in context and is available for 
      // queries by the get_response_<descriptor_field> API methods.
      int read_queue_head_seq_count = read_response_queue[$].seq_count;
      int write_queue_head_seq_count = write_response_queue[$].seq_count;      

      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);

      if (reset) begin
         $sformat(message, "%m: Illegal command while reset asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      
      if (read_queue_head_seq_count == write_queue_head_seq_count) begin
         $sformat(message,
         "%m: Identical sequence count in read and write response queues");
         print(VERBOSITY_ERROR, message);
         -> signal_fatal_error;
         return;
      end else begin
         if ((read_response_queue.size() > 0) && 
                ((read_queue_head_seq_count < write_queue_head_seq_count) ||
                 (write_queue_head_seq_count == 0))) begin

            return_response = read_response_queue.pop_back();
            $sformat(message,"%m: Pop read response");
            print(VERBOSITY_DEBUG, message);
         end else if (write_response_queue.size() > 0) begin
            return_response = write_response_queue.pop_back();
            $sformat(message,"%m: Pop write response");
            print(VERBOSITY_DEBUG, message);
         end else begin
            $sformat(message,"%m: Failed to pop from response queues");
            print(VERBOSITY_ERROR, message);
            -> signal_fatal_error;
            return;
         end
      end 

      if (return_response.seq_count == 0) begin
         // sequence counter is initialized to 1
         $sformat(message,"%m:  Response transaction has sequence count of 0");
         print(VERBOSITY_WARNING, message);
      end
      
      __print_response("Master Response", return_response);///foo
      
   endfunction 

   function automatic void push_command(); // public
      // Pushes the fully populated transaction descriptor into 
      // the pending transaction command queue.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);

      if (reset) begin
         $sformat(message, "%m: Illegal command while reset asserted"); 
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
         
      new_command.seq_count = command_sequence_counter++;
                             
      pending_command_queue.push_front(new_command);

      case(new_command.request) 
         REQ_READ:  $sformat(message, "%m: push command - read addr %0x", 
                             new_command.address);
         REQ_WRITE: $sformat(message,"%m: push command - write addr %0x",
                             new_command.address);
         default:   $sformat(message, "%m: push invalid transaction request");
      endcase
      print(VERBOSITY_DEBUG, message);

      if (new_command.burst_size != new_command.burst_count) begin
         $sformat(message, "%m: burst_size and burst_count do not match"); 
         print(VERBOSITY_WARNING, message);
      end
   endfunction

   function automatic void set_command_address( // public
      bit [AV_ADDRESS_W-1:0] addr
   );
      // Sets the transaction address in the command descriptor.      
      $sformat(message, "%m: method called arg0 %0d", addr); 
      print(VERBOSITY_DEBUG, message);
      
      new_command.address = addr;
   endfunction 

   function automatic void set_command_byte_enable( // public		
      bit [AV_NUMSYMBOLS-1:0]   byte_enable,
      int                       index
   );
      // Sets the transaction byte enable field for each cycle of the burst
      // command descriptor. This field applies to both read and write 
      // operations.
      $sformat(message, "%m: method called arg0 %0d arg1 %0d", 
               byte_enable, index ); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))
         new_command.byte_enable[index] = byte_enable;
   endfunction 

   function automatic void set_command_burst_count( // public
      bit [AV_BURSTCOUNT_W-1:0] burst_count
   );
      // Sets the value driven out on the Avalon interface burstcount pin.
      // Generate a warning message if the specified burst count is less 
      // than 1 or greater than 2**(AV_BURSTCOUNT_W-1) when the 
      // parameter USE_BURSTCOUNT is enabled (equals 1).
      // If USE_BURSTCOUNT is disabled, we force the burst count to equal 1.
      
      $sformat(message, "%m: method called arg0 %0d", burst_count); 
      print(VERBOSITY_DEBUG, message);
      
      new_command.burst_count = burst_count;
      
      if (USE_BURSTCOUNT == 1) begin
         if (burst_count < 1) begin
            $sformat(message, 
                     "%m: Illegal Burst Count value: %0d - must be >= 1",
                     burst_count);
            print(VERBOSITY_WARNING, message);
         end else if (burst_count > 2**(AV_BURSTCOUNT_W-1)) begin
            $sformat(message, 
                     "%m: Illegal Burst Count value: %0d - must be <= %0d",
                     burst_count, 2**(AV_BURSTCOUNT_W-1));
            print(VERBOSITY_WARNING, message);
         end
      end else begin
         $sformat(message, 
                  "%m: USE_BURSTCOUNT set to false. Burst Count value forced to 1");
         print(VERBOSITY_WARNING, message);
         new_command.burst_count = 1;
      end
   endfunction 

   function automatic void set_command_burst_size( // public
      bit [AV_BURSTCOUNT_W-1:0] burst_size
   );
      // Sets the transaction burst count in the command descriptor
      // and determines the number of words driven out on the write burst
      // command. The value may mismatch the value specified in
      // set_command_burst_count in order to generate illegal traffic for testing.
      // We generate a warning in this situation.

      $sformat(message, "%m: method called arg0 %0d", burst_size); 
      print(VERBOSITY_DEBUG, message);
      
      new_command.burst_size = burst_size;
   endfunction 
   
   function automatic void set_command_data( // public
      bit [AV_DATA_W-1:0] data, 
      int                 index
   );
      // Sets the transaction write data in the command descriptor. For burst 
      // transactions, the command descriptor holds an array of data, 
      // with each element individually set by this method.

      $sformat(message, "%m: method called arg0 %0d arg1 %0d", 
               data, index ); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))                   
         new_command.data[index] = data;
   endfunction 

   function automatic void set_command_idle( // public
      int   idle,
      int   index
   );
      // Set idle cycles at the end of each transaction cycle. In the case
      // of read commands, idle cycles are inserted at the end of the command
      // cycle. In the case of burst write commands, idle cycles are inserted
      // at the end of each write data cycle within the burst.

      $sformat(message, "%m: method called arg0 %0d arg1 %0d", 
               idle, index ); 
      print(VERBOSITY_DEBUG, message);
      
      if (__check_transaction_index(index))                   
         new_command.idle[index] = idle;
   endfunction 

   function automatic void set_command_init_latency( // public
      int   cycles
   );
      // Set number of cycles to postpone the start of command

      $sformat(message, "%m: method called arg0 %0d", cycles);
      print(VERBOSITY_DEBUG, message);
      
      if (cycles >= 0) begin
         new_command.init_latency = cycles;
      end else begin
         $sformat(message, "%m: postpone cycles %0d must be >= 0", cycles);
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
   endfunction 

   function automatic void set_command_request( // public
      Request_t request
   );
      // Sets the transaction type to read or write in the 
      // command descriptor. The enumeration type defines
      // REQ_READ = 0 and REQ_WRITE = 1.

      new_command.request = request;

      $sformat(message, "%m: method called arg0 %0d", request);
      print(VERBOSITY_DEBUG, message);      
   endfunction 

   function automatic void set_command_arbiterlock( // public
      bit state
   );
      // Assert or deassert the arbiterlock interface signal. Arbiterlock
      // control is done on transaction boundaries. Arbiterlock cannot
      // be used when the Master BFM is operating in burst mode.

      if (USE_BURSTCOUNT) begin
         $sformat(message, "%m: Arbiterlock illegal in burst mode.");
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: method called arg0 %0d", state); 
         print(VERBOSITY_DEBUG, message);
      end
      new_command.arbiterlock = state;
   endfunction 

   function automatic void set_command_lock( // public
      bit state
   );
      // Assert or deassert the lock interface signal. Lock
      // control is done on transaction boundaries. Lock cannot
      // be used when the Master BFM is operating in burst mode.

      if (USE_BURSTCOUNT) begin
         $sformat(message, "%m: Lock illegal in burst mode.");
         print(VERBOSITY_WARNING, message);
      end else begin
         $sformat(message, "%m: method called arg0 %0d", state); 
         print(VERBOSITY_DEBUG, message);
      end
      new_command.lock = state;
   endfunction 

   function automatic void set_command_debugaccess( // public
      bit state
   );
      // Assert or deassert the debugaccess interface signal. Debugaccess
      // control is done on transaction boundaries. 
      $sformat(message, "%m: method called arg0 %0d", state); 
      print(VERBOSITY_DEBUG, message);
      new_command.debugaccess = state;
   endfunction 

   function automatic void set_max_command_queue_size( // public
      int size
   );
      // Set the pending command queue size maximum threshold. 
      // The public event signal_max_command_queue_size
      // will fire when the threshold is exceeded.
      max_command_queue_size = size;
   endfunction 

   function automatic void set_min_command_queue_size( // public
      int size
   );
      // Set the pending command queue size minimum threshold. 
      // The public event signal_min_command_queue_size
      // will fire when the queue size is below this threshold.
      min_command_queue_size = size;
   endfunction 

   function automatic void set_command_transaction_id( // public
      bit [AV_TRANSACTIONID_W-1:0] id
   );
      // Sets the transaction id number in the command descriptor.      
      $sformat(message, "%m: method called arg0 %0d", id); 
      print(VERBOSITY_DEBUG, message);
      
      new_command.transaction_id = id;
   endfunction 

   function automatic void set_command_write_response_request( // public
      bit request
   );
      // Sets the flag enabling or disabling write response requests 
      // in the command descriptor.      
      $sformat(message, "%m: method called arg0 %0d", request); 
      print(VERBOSITY_DEBUG, message);
      
      new_command.write_response_request = request;
   endfunction 

   function automatic AvalonResponseStatus_t get_read_response_status( // public
      int   index
   );
      // Returns the transaction response status in the read response 
      // descriptor that has been popped from the response queue.
      // If API is called when read response is not enabled, it will
      // return default value i.e. OKAY
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      
      if (return_response.request == REQ_READ) begin
         if (USE_READRESPONSE == 1) begin
            return AvalonResponseStatus_t'(return_response.read_response[index]);
         end else begin
            $sformat(message, "%m: Read response is disabled, returning default value");
            print(VERBOSITY_WARNING, message);
            return null_response_status;
         end
      end else begin
         $sformat(message, "%m: Read response queried on write response transaction");
         print(VERBOSITY_WARNING, message);
         return null_response_status;
      end
   endfunction
   
   function automatic logic [AV_READRESPONSE_W-1:0] get_response_read_response( // public
      int   index
   );
      // deprecated
      $sformat(message, "%m: This API is no longer supported. Please use get_read_response_status API");
      print(VERBOSITY_WARNING, message);
      
      return '0;
   endfunction

   function automatic logic [AV_TRANSACTIONID_W-1:0] get_response_read_id(); // public
      // Returns the read id of transaction in the response descriptor that
      // has been popped from the response queue.
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      if (return_response.request == REQ_WRITE) begin
         $sformat(message, "%m: Read response queried on write response transaction");
         print(VERBOSITY_WARNING, message);
      end      
      return return_response.read_id;      
   endfunction 

   function automatic AvalonResponseStatus_t get_write_response_status(); // public
      // Returns the transaction response status in the write response 
      // descriptor that has been popped from the response queue.
      // If API is called when write response is not enabled or enabled but
      // write response not requested, it will return default value i.e. OKAY
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      
      if (return_response.request == REQ_WRITE) begin
         if (USE_WRITERESPONSE == 1 && return_response.write_response_request == 1) begin
            return return_response.write_response;
         end else begin
            $sformat(message, 
               "%m: Write response is disabled or enabled but no write response requested, returning default value");
            print(VERBOSITY_WARNING, message);
            return null_response_status;
         end
      end else begin
         $sformat(message, "%m: Write response queried on read response transaction");
         print(VERBOSITY_WARNING, message);
         return null_response_status;
      end
   endfunction
   
   function automatic logic [AV_WRITERESPONSE_W-1:0] get_response_write_response( // public
      int   index
   );
      // deprecated
      $sformat(message, "%m: This API is no longer supported. Please use get_write_response_status API");
      print(VERBOSITY_WARNING, message);
      
      return '0;
   endfunction

   function automatic logic [AV_TRANSACTIONID_W-1:0] get_response_write_id(); // public
      // Returns the write id of transaction in the response descriptor that
      // has been popped from the response queue.
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      if (return_response.request == REQ_READ) begin
         $sformat(message, "%m: Write response queried on read response transaction");
         print(VERBOSITY_WARNING, message);
      end            
      return return_response.write_id;      
   endfunction 

   function automatic int get_write_response_queue_size(); // public
      // Queries the write response queue to determine
      // number of response descriptors currently stored in the BFM.
      // This is the number of responses the test program can immediately
      // pop off the response queue for further processing.
      
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      return write_response_queue.size();
   endfunction

   function automatic int get_read_response_queue_size(); // public
      // Queries the read response queue to determine
      // number of response descriptors currently stored in the BFM.
      // This is the number of responses the test program can immediately
      // pop off the response queue for further processing.
      
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);
      
      return read_response_queue.size();
   endfunction
   
   function automatic void set_clken( // public
      bit   state
   );  
      // Assert or deassert the clock enable signal. 

      temp_avm_clken = state;
      -> __signal_set_clken;

      $sformat(message, "%m: method called arg0 %0d", state);
      print(VERBOSITY_INFO, message);
    
   endfunction 
   
   function automatic void set_idle_state_output_configuration( // public
      // Set the configuration of output signal value during interface idle
      IdleOutputValue_t idle_config
   );
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
      
      idle_output_config = idle_config;
   endfunction
   
   function automatic IdleOutputValue_t get_idle_state_output_configuration(); // public
      // Get the configuration of output signal value during interface idle
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
      
      return idle_output_config;
   endfunction
   
   //=cut
   
   //--------------------------------------------------------------------------
   // Private Methods
   // Note that private methods and events are prefixed with '__'   
   //--------------------------------------------------------------------------
   
   function automatic int __check_transaction_index(int index);
      if (index > lindex(MAX_BURST_SIZE)) begin
         $sformat(message,"%m: Cycle index %0d exceeds MAX_BURST_SIZE-1 %0d",
                  index, lindex(MAX_BURST_SIZE));
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
         return 0;
      end else begin
         return 1;
      end
   endfunction
   
   task automatic __drive_interface_idle();
      avm_write                <= '0;
      avm_read                 <= '0;
      avm_beginbursttransfer   <= '0;
      avm_begintransfer        <= '0;
      avm_writeresponserequest <= '0;
      
      case (idle_output_config)
         LOW: begin
            avm_address              <= '0;
            avm_burstcount           <= '0;
            avm_writedata            <= '0;
            avm_byteenable           <= '0;
            avm_transactionid        <= '0;
         end
         HIGH: begin
            avm_address              <= '1;
            avm_burstcount           <= '1;
            avm_writedata            <= '1;
            avm_byteenable           <= '1;
            avm_transactionid        <= '1;
         end
         RANDOM: begin
            avm_address              <= $random;
            avm_burstcount           <= $random;
            avm_writedata            <= $random;
            avm_byteenable           <= $random;
            avm_transactionid        <= $random;
         end
         UNKNOWN: begin
            avm_address              <= 'x;
            avm_burstcount           <= 'x;
            avm_writedata            <= 'x;
            avm_byteenable           <= 'x;
            avm_transactionid        <= 'x;
         end
         default: begin
            avm_address              <= 'x;
            avm_burstcount           <= 'x;
            avm_writedata            <= 'x;
            avm_byteenable           <= 'x;
            avm_transactionid        <= 'x;
         end
      endcase
   endtask 

   function automatic void __init_descriptors();
      new_command = '0; 
      current_command = '0;       
      return_response = '0; 
      completed_write_response = '0; 
      completed_read_response = '0; 
      issued_command = '0; 
      completed_command = '0; 
      completed_write_command = '0; 
      completed_read_command = '0; 
      command_issued_counter = 0;
      last_request = REQ_IDLE;
      temp_write_latency = 0;
      response_time_stamp = 0;
      temp_avm_clken = 1;
      temp_read_latency = 0;
      start_construct_complete_write_response = 0;
      start_construct_complete_read_response = 0;
      read_response_burst_counter = 0;
   endfunction      

   function automatic void __init_queues();
      pending_command_queue = {};
      issued_read_command_queue = {};
      issued_write_command_queue = {};
      read_response_queue = {};
      write_response_queue = {};  
      response_time_stamp_queue  = {};
   endfunction            
   
   function automatic string __request_str(Request_t request);
      case(request)
         REQ_READ:  return "Read";
         REQ_WRITE: return "Write";
         REQ_IDLE:  return "Idle";
      endcase 
   endfunction
      
   function automatic void __print_command(string text, MasterCommand_t command);
      string message  = "";
      print_divider(VERBOSITY_DEBUG);            
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "%m: %s", text);      
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "Request:     %s", __request_str(command.request));
      print(VERBOSITY_DEBUG, message);
      $sformat(message, "transaction_id:     %0x", command.transaction_id);
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "write_response_request:     %0x", command.write_response_request);
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "Address:     %0x", command.address);
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "Burst Count: %0x", command.burst_count);
      print(VERBOSITY_DEBUG, message);
      if (command.request == REQ_WRITE) begin
         for (int i=0; i<command.burst_count; i++) begin
            $sformat(message, "  index: %0d data: %0x byteen: %0x idle: %0d",
                     i, command.data[i], 
                     command.byte_enable[i], command.idle[i]);
            print(VERBOSITY_DEBUG, message);
         end
      end
      print_divider(VERBOSITY_DEBUG);           
   endfunction

   function automatic void __print_response(string text, 
                                          MasterResponse_t response);
      string message = "";
      print_divider(VERBOSITY_DEBUG);      
      $sformat(message, "%m: %s", text);
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "Request:     %s", __request_str(response.request));
      print(VERBOSITY_DEBUG, message);
      $sformat(message, "Address:     %0x", response.address);
      print(VERBOSITY_DEBUG, message);      
      $sformat(message, "Burst Count: %0x", response.burst_count);
      print(VERBOSITY_DEBUG, message);

      for (int i=0; i<response.burst_count; i++) begin
         if (response.request == REQ_WRITE) begin            
            $sformat(message, "  index: %0d wait: %0d", 
                     i, response.wait_latency[i]);
         end else if (response.request == REQ_READ) begin	 
            $sformat(message, 
                     "  index: %0d data: %0x wait: %0d read latency: %0d", 
                     i, response.data[i], 
                     response.wait_latency[i], response.read_latency[i]);
         end else begin
            $sformat(message, "    Invalid request field");
         end
         print(VERBOSITY_DEBUG, message);
      end
   endfunction

   function automatic void __hello();
      $sformat(message, "%m: - Hello from altera_avalon_mm_master_bfm");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Revision: #1 $");
      print(VERBOSITY_INFO, message);            
      $sformat(message, "%m: -   $Date: 2013/08/11 $");
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_ADDRESS_W             = %0d", 
               AV_ADDRESS_W);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_SYMBOL_W              = %0d", 
               AV_SYMBOL_W);
      print(VERBOSITY_INFO, message);      
      $sformat(message, "%m: -   AV_NUMSYMBOLS            = %0d", 
               AV_NUMSYMBOLS);
      print(VERBOSITY_INFO, message);      
      $sformat(message, "%m: -   AV_BURSTCOUNT_W          = %0d", 
               AV_BURSTCOUNT_W);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   REGISTER_WAITREQUEST     = %0d", 
               REGISTER_WAITREQUEST);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_FIX_READ_LATENCY      = %0d", 
               AV_FIX_READ_LATENCY);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_MAX_PENDING_READS     = %0d", 
               AV_MAX_PENDING_READS);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   AV_MAX_PENDING_WRITES    = %0d", 
               AV_MAX_PENDING_WRITES);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READ                 = %0d", 
               USE_READ);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_WRITE                = %0d", 
               USE_WRITE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_ADDRESS              = %0d", 
               USE_ADDRESS);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_BYTE_ENABLE          = %0d", 
               USE_BYTE_ENABLE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_BURSTCOUNT           = %0d", 
               USE_BURSTCOUNT);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READ_DATA            = %0d", 
               USE_READ_DATA);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READ_DATA_VALID      = %0d", 
               USE_READ_DATA_VALID);
      print(VERBOSITY_INFO, message);      
      $sformat(message, "%m: -   USE_WRITE_DATA           = %0d", 
               USE_WRITE_DATA);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_BEGIN_TRANSFER       = %0d", 
               USE_BEGIN_TRANSFER);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_BEGIN_BURST_TRANSFER = %0d", 
               USE_BEGIN_BURST_TRANSFER);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_WAIT_REQUEST         = %0d", 
               USE_WAIT_REQUEST);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_ARBITERLOCK          = %0d", 
               USE_ARBITERLOCK);
      $sformat(message, "%m: -   USE_LOCK                 = %0d", 
               USE_LOCK);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_DEBUGACCESS          = %0d", 
               USE_DEBUGACCESS);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_TRANSACTIONID        = %0d", 
               USE_TRANSACTIONID);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_WRITERESPONSE        = %0d", 
               USE_WRITERESPONSE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_READRESPONSE         = %0d", 
               USE_READRESPONSE);
      print(VERBOSITY_INFO, message);
      $sformat(message, "%m: -   USE_CLKEN                = %0d", 
               USE_CLKEN);
      print(VERBOSITY_INFO, message);   
      print_divider(VERBOSITY_INFO);
   endfunction
   
   //--------------------------------------------------------------------------
   // Internal Machinery
   //--------------------------------------------------------------------------
   initial begin
      __hello();

      if (USE_READ_DATA_VALID == 0 && USE_BURSTCOUNT > 0 && USE_READ == 1) begin
         $sformat(message,
                  "%m: USE_READ_DATA_VALID must be enabled if USE_READ and USE_BURSTCOUNT enabled");
         print(VERBOSITY_ERROR, message);
         ->signal_fatal_error;
      end
      if (USE_BURSTCOUNT > 0 && 
          (AV_BURSTCOUNT_W < 1 || AV_BURSTCOUNT_W > 11)) begin
         $sformat(message,
                  "%m: Illegal AV_BURSTCOUNT_W specified");
         print(VERBOSITY_WARNING, message);
      end
   end
   
   always @(__signal_set_clken or posedge clk or posedge reset) begin
      if (reset == 0) begin
         fork
            begin: unchange_clken
               wait(__clk.triggered);
               avm_clken <= temp_avm_clken;
            end
         join_none
      end else begin
         avm_clken <= 1'b1;
      end
   end
   
   always @(posedge clk or posedge reset) begin
      -> __clk;
   end

   always @(signal_fatal_error) abort_simulation();

   always @(posedge clk) begin
      if (!USE_CLKEN || avm_clken == 1)
         clock_counter <= clock_counter + 1;
   end 

   always @(signal_read_response_complete or 
            posedge reset) begin
      if (reset) begin
         command_completed_counter = 0;
      end else begin
         ->signal_response_complete;
         command_completed_counter++;
      end
   end
   
   always @(signal_write_response_complete or 
            posedge reset) begin
      if (reset) begin
         command_completed_counter = 0;
      end else begin
         ->signal_response_complete;
         command_completed_counter++;
      end
   end

   always @(posedge clk) begin
      if (pending_command_queue.size() > max_command_queue_size) begin       
         ->signal_max_command_queue_size;
      end else if (pending_command_queue.size() < min_command_queue_size) begin  
         ->signal_min_command_queue_size;
      end      
   end
      
   always @(command_issued_counter or command_completed_counter) begin
            command_outstanding_counter = command_issued_counter - 
                                          command_completed_counter;
   end
   
   always @(negedge clk) begin
      if (!reset) begin
         if (all_transactions_complete())
            ->signal_all_transactions_complete;
      end
   end

   always @(posedge reset) begin
      command_sequence_counter    = 1;
   end

   //--------------------------------------------------------------------------
   // Physical Avalon Bus Driver
   //--------------------------------------------------------------------------
   // Stall until reset is deasserted and at least one command is in the 
   // pending command queue.
   // Pop a command transaction off the pending command queue. This becomes
   // the current command transaction.
   // Send the current command to the bus driver.
   // If the current command is a read, push the transaction into the issued 
   // command queue for the monitor to process.
   
   always @(posedge clk or posedge reset) begin
      if (reset) begin
         init();
      end else begin
         if (!USE_CLKEN || (avm_clken == 1)) begin
            avm_begintransfer      <= '0;
            avm_beginbursttransfer <= '0;
      
            if (pending_command_queue.size() > 0) begin
               $sformat(message, "%m: Pop pending command queue");
               print(VERBOSITY_DEBUG, message);
               
               current_command = pending_command_queue.pop_back();

               // programmable delay before driving the command onto the bus
               __drive_interface_idle(); 	    
               repeat(current_command.init_latency) begin 
                  @(posedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                        @(posedge clk);
                  end
               end

               fork: request_timeout
                  begin: reset_thread
                     while (1) begin
                        if (reset) begin
                           init();
                           disable fork;
                        end
                        @(posedge clk);
                     end
                  end
                  begin: driver_thread
                     drive_request(current_command);
                     ->__drive_request_done;
                     if (current_command.request == REQ_WRITE)
                        response_time_stamp_queue.push_front(clock_counter);
                  end
                  begin: timeout_thread
                     if (command_timeout == 0) begin 
                        @ __drive_request_done;
                     end else begin
                        repeat(command_timeout) begin
                           @(posedge clk);
                           if (USE_CLKEN) begin
                              while (!avm_clken)
                                 @(posedge clk);
                           end
                        end
                        $sformat(message, "%m: Command phase timeout");
                        print(VERBOSITY_FAILURE, message);
                        ->signal_fatal_error;
                     end
                  end
               join_any: request_timeout
               disable fork;

            end else begin 
               __drive_interface_idle();
            end 
         end
      end
   end      

   task automatic drive_request(MasterCommand_t current_command);
      __print_command("Drive Command", current_command);

      if (USE_BURSTCOUNT == 0) begin
         current_command.burst_count = 1;
         current_command.burst_size = 1;
      end else begin   
         if (current_command.burst_count < 1) begin
            $sformat(message, "%m: Burst Count must be set > 0");
            print(VERBOSITY_FAILURE, message);
            ->signal_fatal_error;
         end
      end
      
      avm_address              <= current_command.address;
      avm_burstcount           <= current_command.burst_count;
      avm_writedata            <= 'x;
      avm_byteenable           <= 'x;
      avm_arbiterlock          <= current_command.arbiterlock;
      avm_lock                 <= current_command.lock;
      avm_debugaccess          <= current_command.debugaccess;      
      avm_transactionid        <= current_command.transaction_id;
      
      case (current_command.request)
        REQ_READ: begin
           avm_write <= 0;
           avm_read  <= 1;
           avm_writeresponserequest <= 0;

           $sformat(message, "%m: read: addr: %0x burst: %0d ", 
                    current_command.address, current_command.burst_count);
           print(VERBOSITY_DEBUG, message);
        end
        REQ_WRITE: begin
           avm_writeresponserequest <= current_command.write_response_request;
           avm_write <= 1;
           avm_read  <= 0;
           
           $sformat(message, "%m: write: addr: %0x burst: %0d ", 
                    current_command.address, current_command.burst_count);
           print(VERBOSITY_DEBUG, message);
        end
        REQ_IDLE: begin
           avm_write <= 0;
           avm_read  <= 0;
           avm_writeresponserequest <= 0;
           
           $sformat(message, "%m: idle transaction");
           print(VERBOSITY_DEBUG, message);
        end
        default: begin
           avm_write                <= 'x;
           avm_read                 <= 'x;
           avm_address              <= 'x;        
           avm_writeresponserequest <= 'x;
           $sformat(message, "%m: INVALID request - driving X on Avalon bus!");
           print(VERBOSITY_DEBUG, message); 
        end
      endcase 

      -> signal_command_issued;

      command_issued_counter++;
      
      for (int i=0; i<current_command.burst_size; i++) begin
         wait_time_stamp = clock_counter + 1;
               
         if (current_command.request == REQ_WRITE) begin
            avm_writedata <= current_command.data[i];
            avm_write <= 1;
         end 

         avm_byteenable <= current_command.byte_enable[i];

         if (USE_BEGIN_TRANSFER && current_command.request != REQ_IDLE)
            avm_begintransfer <= 1;

         if (i == 0) begin
            if (USE_BURSTCOUNT > 0 && USE_BEGIN_BURST_TRANSFER > 0) 
               avm_beginbursttransfer <= 1;
            else
               avm_beginbursttransfer <= 0;	      
         end else begin
            avm_beginbursttransfer <= 0;
         end

         // The slave drives a response back to master on negedge clk
         // and the master samples just after that to avoid a race.
         // If a reset happens in the interim, cancel the transaction.
         
         @(negedge clk);

         if (reset) begin
            init();
            return;
         end
         
         #1;
         
         if (USE_WAIT_REQUEST) begin
            while (avm_waitrequest) begin
               @(posedge clk);
               if (USE_CLKEN) begin
                  while (!avm_clken)
                  @(posedge clk);
               end

               avm_begintransfer      <= '0;
               avm_beginbursttransfer <= '0;
               
               @(negedge clk);
               if (USE_CLKEN) begin
                  while (!avm_clken)
                  @(negedge clk);
               end

               if (reset) begin
                  init();
                  return;
               end
               #1;
            end
         end else begin
            if (current_command.request == REQ_WRITE) begin
               repeat (AV_WRITE_WAIT_TIME) begin
                  @(posedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                     @(posedge clk);
                  end

                  avm_begintransfer      <= '0;
                  avm_beginbursttransfer <= '0;
                  
                  @(negedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                     @(negedge clk);
                  end

                  if (reset) begin
                     init();
                     return;
                  end
                  
                  #1;
               end
            end else if (current_command.request == REQ_READ) begin
               repeat (AV_READ_WAIT_TIME) begin
                  @(posedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                     @(posedge clk);
                  end

                  avm_begintransfer      <= '0;
                  avm_beginbursttransfer <= '0;
                  
                  @(negedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                     @(negedge clk);
                  end

                  if (reset) begin
                     init();
                     return;
                  end
                  
                  #1;
               end
            end else begin
              $sformat(message, "%m: idle transaction");
              print(VERBOSITY_DEBUG, message);
            end
         end
         
         wait_time = clock_counter - wait_time_stamp;

         issued_command.wait_time[i] = wait_time;
         issued_command.time_stamp[i] = clock_counter;
         issued_command.command = current_command;

         if (current_command.request == REQ_WRITE) begin
            if (USE_WRITERESPONSE == 1) begin
               if (i == current_command.burst_size-1) begin
                  issued_write_command_queue.push_front(issued_command);
                  -> __command_issued;
               end
            end
            
            if (current_command.idle[i] > 0) begin
               // insert extra idle cycles after the transaction 
               @(posedge clk);
               if (USE_CLKEN) begin
                  while (!avm_clken)
                     @(posedge clk);
               end

               avm_begintransfer      <= '0;
               avm_beginbursttransfer <= '0;
               
               if (i == current_command.burst_size-1) begin
                  __drive_interface_idle();
               end else begin // address and burstcount must be held constant
                  avm_write <= 0;
                  avm_writedata <= 'x;
                  avm_byteenable <= 'x;
                  if (!AV_CONSTANT_BURST_BEHAVIOR) begin
                     avm_address              <= 'x;
                     avm_burstcount           <= 'x;
                     avm_writeresponserequest <= 'x;
                     avm_transactionid        <= 'x;
                  end
               end
               repeat(current_command.idle[i]-1) begin
                  #1 @(posedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                        @(posedge clk);
                  end
               end
            end

            if (i == current_command.burst_size-1) begin
               // Write commands do not expect a response so we bypass the
               // monitor and immediately push the completed write transaction
               // response descriptor into the queue. The only interesting
               // information in the descriptor is the wait time latency.

               if (USE_WRITERESPONSE == 0 || current_command.write_response_request == 1'b0) begin
                  completed_command = issued_command;

                  completed_write_response.seq_count = 
                                    completed_command.command.seq_count;
                  completed_write_response.request = 
                                    completed_command.command.request;
                  completed_write_response.address = 
                                    completed_command.command.address;
                  completed_write_response.byte_enable = 
                                    completed_command.command.byte_enable;	       
                  completed_write_response.burst_count = 
                                    completed_command.command.burst_count;
                  completed_write_response.burst_size = 
                                    completed_command.command.burst_size;
                  completed_write_response.read_latency = 'x;
                  completed_write_response.write_latency = 'x;
                  completed_write_response.data = 
                                    completed_command.command.data;
                  completed_write_response.wait_latency = 
                                    completed_command.wait_time;
                  
                  completed_write_response.write_response_request = 1'b0;
                  completed_write_response.write_response         = null_response_status;

                  $sformat(message, "%m: write response done - addr: %0x burst_count: %0x",
                           completed_write_response.address, 
                           completed_write_response.burst_count);
                  print(VERBOSITY_DEBUG, message);

                  write_response_queue.push_front(completed_write_response);
                  -> signal_write_response_complete;
               end

               $sformat(message, "%m: Write Burst Command Issue Complete");
               print(VERBOSITY_DEBUG, message);
               break;
            end else begin 
               @(posedge clk);
                  if (!AV_CONSTANT_BURST_BEHAVIOR) begin
                     avm_address              <= 'x;      
                     avm_burstcount           <= 'x;
                     avm_writeresponserequest <= 'x;
                     avm_transactionid        <= 'x;
                  end
               if (USE_CLKEN) begin
                  while (!avm_clken)
                     @(posedge clk);
               end
            end
         end else if (current_command.request == REQ_READ) begin
            // Burst read transactions require only a single command cycle

            if (i == 0) begin
               issued_read_command_queue.push_front(issued_command);
               -> __command_issued;
               $sformat(message, 
                       "%m: Read Burst Command Issue Complete");
               print(VERBOSITY_DEBUG, message);

               if (current_command.idle[i] > 0) begin
                  @(posedge clk);
                  if (USE_CLKEN) begin
                     while (!avm_clken)
                        @(posedge clk);
                  end
                  __drive_interface_idle();
                  repeat(current_command.idle[i]-1) begin
                     @(posedge clk);
                     if (USE_CLKEN) begin
                        while (!avm_clken)
                           @(posedge clk);
                     end
                  end
               end
                     
               break;
            end
         end
      end

      last_request = current_command.request;
   endtask 
   
   //--------------------------------------------------------------------------
   // Physical Avalon Bus Monitor
   //--------------------------------------------------------------------------
   // Stall until reset is deasserted and the issued command queue contains 
   // at least one transaction.
   // Pop issued transaction command off queue to determine what is expected.
   // If we have issued a read transaction, then check the parameters to 
   // determine whether the read is pipelined or has fixed latency.
   // In the case of a pipelined read, wait for the readdatavalid to assert
   // and then sample the data at that time.
   // Otherwise, wait a fixed number of cycles, as determined by the parameter
   // AV_FIX_READ_LATENCY and then sample data. The fixed read latency cycles
   // are relative to the command phase.
   // Push the received data along with latency information into the 
   // response queue.

   always @(posedge clk or posedge reset) begin  
      if (reset) begin
         init();
      end else begin
         if (!USE_CLKEN || avm_clken == 1) begin
            
            if (issued_write_command_queue.size() > 0) begin
               if (start_construct_complete_write_response == 0) begin
                  completed_write_command = issued_write_command_queue.pop_back();
                  start_construct_complete_write_response = 1;
               end
            end
            
            if (issued_read_command_queue.size() > 0) begin
               if (read_response_burst_counter == 0 &&
                   start_construct_complete_read_response == 0) begin
                  completed_read_command = issued_read_command_queue.pop_back();
                  start_construct_complete_read_response = 1;
               end
            end

            if (start_construct_complete_read_response)
               monitor_response(completed_read_command);
               
            if (start_construct_complete_write_response)
               monitor_response(completed_write_command);
         end
      end
   end
     
   task automatic monitor_response(IssuedCommand_t completed_command);
      case(completed_command.command.request)
         REQ_WRITE: begin
            if (USE_WRITERESPONSE && completed_command.command.write_response_request == 1'b1) begin               
               
               if (!avm_writeresponsevalid) begin
                  temp_write_latency++;
                  return;
               end
               
               completed_write_response.read_latency    = 'x;
               completed_write_response.read_id         = 'x;
               completed_write_response.read_response   = 'x;
               
               completed_write_response.seq_count = 
                        completed_command.command.seq_count;
               completed_write_response.request = 
                        completed_command.command.request;
               completed_write_response.address = 
                        completed_command.command.address;
               completed_write_response.byte_enable = 
                        completed_command.command.byte_enable;
               completed_write_response.burst_count = 
                        completed_command.command.burst_count;
               completed_write_response.burst_size = 
                        completed_command.command.burst_size;      
               completed_write_response.wait_latency = 
                        completed_command.wait_time;
               completed_write_response.data = 
                        completed_command.command.data;

               completed_write_response.write_response_request = 1'b1;
               completed_write_response.write_id = avm_writeid;
               completed_write_response.write_latency  = temp_write_latency;
               
               assert($cast(completed_write_response.write_response, avm_response))
                  else begin
                     $sformat(message, "%m: Response value is not valid when write response is valid");
                     print(VERBOSITY_FAILURE, message);
                  end
                  
               temp_write_latency = 0;
               
               $sformat(message, 
                        "%m: var latency write - addr: %0x response status: %0s",
                        completed_write_response.address, 
                        completed_write_response.write_response);
               print(VERBOSITY_DEBUG, message);

               write_response_queue.push_front(completed_write_response);
               -> signal_write_response_complete;
               start_construct_complete_write_response = 0;
            end else begin
               // does not enable write response or enable write response but 
               // does not request for write response
               start_construct_complete_write_response = 0;
            end
         end
         REQ_READ: begin
         
            if (read_response_burst_counter == 0) begin
               completed_read_response.read_latency    = 'x;
               completed_read_response.write_latency   = 'x;
               completed_read_response.wait_latency    = 'x;
               completed_read_response.data            = 'x;
               completed_read_response.read_id         = 'x;
               completed_read_response.read_response   = 'x;
            end
            
            completed_read_response.seq_count = 
                     completed_command.command.seq_count;
            completed_read_response.request = 
                     completed_command.command.request;
            completed_read_response.address = 
                     completed_command.command.address;
            completed_read_response.byte_enable = 
                     completed_command.command.byte_enable;
            completed_read_response.burst_count = 
                     completed_command.command.burst_count;
            completed_read_response.burst_size = 
                     completed_command.command.burst_size;
            completed_read_response.wait_latency[0] = 
                     completed_command.wait_time[0];
           
            if (USE_READ_DATA_VALID || USE_BURSTCOUNT) begin
            
               if (!avm_readdatavalid) begin
                  temp_read_latency++;
                  return;
               end
               completed_read_response.data[read_response_burst_counter] = avm_readdata;
               if (read_response_burst_counter == 0) begin
                  completed_read_response.read_latency[0] = clock_counter - completed_command.time_stamp;
               end else begin
                  completed_read_response.read_latency[read_response_burst_counter] = temp_read_latency;
               end
               $sformat(message, 
                        "%m: var latency read - addr: %0x data: %0x",
                        completed_read_response.address, 
                        completed_read_response.data[read_response_burst_counter]);
               print(VERBOSITY_DEBUG, message);
               
               if (USE_READRESPONSE) begin
                  completed_read_response.read_id = avm_readid;
                  
                  assert($cast(completed_read_response.read_response[read_response_burst_counter], avm_response))
                     else begin
                        $sformat(message, "%m: Response value is not valid when read response is valid");
                        print(VERBOSITY_FAILURE, message);
                     end
               end
                  
               temp_read_latency = 0;

               // bursting
            end else begin 
               if (AV_FIX_READ_LATENCY > 0) begin
                  if (clock_counter - completed_command.time_stamp < AV_FIX_READ_LATENCY) begin
                     return;
                  end
               end
              
               completed_read_response.read_latency[0] = AV_FIX_READ_LATENCY;
               completed_read_response.data[0] = avm_readdata;

               if (USE_READRESPONSE) begin
                  completed_read_response.read_id          = avm_readid;
                  
                  assert($cast(completed_read_response.read_response[0], avm_response))
                     else begin
                        $sformat(message, "%m: Response value is not valid when read response is valid");
                        print(VERBOSITY_FAILURE, message);
                     end
               end
               
               temp_read_latency = 0;
              
               $sformat(message, "%m: fixed latency read - addr: %0x data: %0x",
                        completed_read_response.address, 
                        completed_read_response.data[0]);
               print(VERBOSITY_DEBUG, message);

            end 
            
            if (read_response_burst_counter == completed_read_response.burst_count-1) begin
               read_response_queue.push_front(completed_read_response);  
               ->signal_read_response_complete;
               read_response_burst_counter = 0;
               start_construct_complete_read_response = 0;
            end else begin
               read_response_burst_counter++;
            end
         end

         default: begin
           completed_read_response.wait_latency[0] = -1;
           $sformat(message, "%m: illegal command issued");
           print(VERBOSITY_FAILURE, message);
           -> signal_fatal_error;
         end
      endcase

      $sformat(message, "%m: Push response queue");
      print(VERBOSITY_DEBUG, message);
      __print_response("Completed Response", completed_read_response);

   endtask 

   // synthesis translate_on
endmodule

// =head1 SEE ALSO
// avalon_mm_slave_bfm
// =cut




