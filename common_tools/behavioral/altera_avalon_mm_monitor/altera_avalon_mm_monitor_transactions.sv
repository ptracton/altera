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


// $File: //acds/main/ip/sopc/components/verification/altera_avalon_st_monitor_bfm/altera_avalon_st_monitor_transactions.sv $
// $Revision: #1 $
// $Date: 2010/05/10 $
// $Author: pscheidt $
//-----------------------------------------------------------------------------
// =head1 NAME
// altera_avalon_mm_monitor_transactions
// =head1 SYNOPSIS
// Memory Mapped Avalon Bus Protocol Checker
//-----------------------------------------------------------------------------
// =head1 DESCRIPTION
// This module implements Avalon MM protocol transaction recording.
//-----------------------------------------------------------------------------

`timescale 1ns / 1ns

module altera_avalon_mm_monitor_transactions(
                                             clk,
                                             reset,
                                             tap
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
   parameter USE_CLKEN                  = 0;    // Use clken interface pins
   
   parameter AV_READ_WAIT_TIME         = 0;  // Fixed wait time cycles when
   parameter AV_WRITE_WAIT_TIME        = 0;  // USE_WAIT_REQUEST is 0

   localparam AV_DATA_W = AV_SYMBOL_W * AV_NUMSYMBOLS;
   localparam MAX_BURST_SIZE           = USE_BURSTCOUNT ? 2**(AV_BURSTCOUNT_W-1) : 1;
   localparam AV_TRANSACTIONID_W       = 8;
   localparam INT_W = 32;
   localparam FIFO_MAX_LEVEL   = 100;
   localparam FIFO_THRESHOLD   = 50;

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
   
   //-------------------------------------------------------------------------- 
   // synthesis translate_off

   import verbosity_pkg::*;
   import avalon_mm_pkg::*;
   
   localparam VERSION = "13.1";

   typedef logic [lindex(AV_ADDRESS_W):0                                ] AvalonAddress_t;
   typedef logic [lindex(AV_BURSTCOUNT_W):0                             ] AvalonBurstCount_t;
   typedef logic [lindex(AV_TRANSACTIONID_W):0                          ] AvalonTransactionId_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_NUMSYMBOLS):0     ] AvalonByteEnable_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_DATA_W):0         ] AvalonData_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(INT_W):0             ] AvalonIdle_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(INT_W):0             ] AvalonLatency_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_READRESPONSE_W):0 ] AvalonReadResponse_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][lindex(AV_WRITERESPONSE_W):0] AvalonWriteResponse_t;
   typedef logic [lindex(MAX_BURST_SIZE):0][1:0]                          AvalonReadResponseStatus_t;
 
   typedef struct packed {
                          Request_t               request;     
                          AvalonAddress_t         address;     
                          AvalonBurstCount_t      burst_count; 
                          AvalonData_t            data;        
                          AvalonByteEnable_t      byte_enable;  
                          AvalonIdle_t            idle;        
                          int                     burst_cycle;
                          logic                   arbiterlock;
                          logic                   lock;
                          logic                   debugaccess;
                          AvalonTransactionId_t   transaction_id;
                          logic                   write_response_request;
                          } Command_t;

   typedef struct packed {
                          Request_t                   request;     
                          AvalonAddress_t             address;     
                          AvalonBurstCount_t          burst_count; 
                          AvalonData_t                data;        
                          AvalonByteEnable_t          byte_enable;  
                          AvalonLatency_t             wait_latency;
                          AvalonLatency_t             read_latency;
                          int                         write_latency; 
                          int                         seq_count;
                          int                         burst_size;
                          AvalonTransactionId_t       read_id;
                          AvalonTransactionId_t       write_id;
                          AvalonReadResponseStatus_t  read_response;
                          AvalonResponseStatus_t      write_response;
                          logic                       write_response_request;
                          } Response_t;
   
   // unpack Avalon bus interface tap into individual port signals
   logic                                  avs_waitrequest;
   logic                                  avs_readdatavalid;
   logic [lindex(AV_DATA_W):0]            avs_readdata;
   logic                                  avs_write;
   logic                                  avs_read;
   logic [lindex(AV_ADDRESS_W):0]         avs_address;
   logic [lindex(AV_NUMSYMBOLS):0]        avs_byteenable;
   logic [lindex(AV_BURSTCOUNT_W):0]      avs_burstcount;
   logic                                  avs_beginbursttransfer;
   logic                                  avs_begintransfer;
   logic [lindex(AV_DATA_W):0]            avs_writedata;
   
   logic                                  avs_arbiterlock;
   logic                                  avs_lock;
   logic                                  avs_debugaccess;
   
   logic [lindex(AV_TRANSACTIONID_W):0]   avs_transactionid;
   logic [lindex(AV_TRANSACTIONID_W):0]   avs_readid;
   logic [lindex(AV_TRANSACTIONID_W):0]   avs_writeid;
   logic [1:0]                            avs_response;
   logic                                  avs_writeresponserequest;
   logic                                  avs_writeresponsevalid;
   logic                                  avs_clken;
   logic                                  clken_register = 1'b1;

   string               message                       = "*uninitialized*";     
   int                  transaction_fifo_max          = FIFO_MAX_LEVEL;
   int                  transaction_fifo_threshold    = FIFO_THRESHOLD;
   
   int                  response_addr_offset          = 0;
   int                  command_addr_offset           = 0;
   int                  command_sequence_counter      = 1;
   
   Command_t            command_queue[$];
   Command_t            current_command               = '0;
   Command_t            client_command                = '0;
   
   Response_t           write_response_queue[$];
   Response_t           read_response_queue[$];   
   Response_t           new_response                  = '0; 

   Response_t           return_response               = 'x;
   Response_t           completed_command             = 'x;
   Response_t           completed_read_command        = 'x;
   Response_t           completed_write_command        = 'x;
   Response_t           issued_read_command_queue[$];
   Response_t           issued_write_command_queue[$];
   
   AvalonResponseStatus_t     null_response_status;
   
   int                  consolidate_write_burst_transactions = 1;
   int                  wait_time = 0;
   int                  write_burst_response_counter = 0;
   int                  write_latency = 0;
   int                  write_burst_command_counter = 0;
   int                  read_latency = 0;
   int                  command_waitrequested_start = 0;
   int                  read_response_burst_counter = 0;
   bit                  start_construct_complete_read_response = 0;
   bit                  start_construct_complete_write_response = 0;
   int                  clock_counter = 0;
   int                  current_time = 0;
   int                  clock_snapshot[$];

   //--------------------------------------------------------------------------
   // Private Functions
   //--------------------------------------------------------------------------

   function automatic void __abort_simulation();
      string message;
      $sformat(message, "%m: Abort the simulation due to fatal error."); 
      print(VERBOSITY_FAILURE, message);
      $stop;
   endfunction
   
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
   event signal_fatal_error; // public
      // Signal that a fatal error has occurred. Terminates simulation.
   
   event signal_transaction_fifo_threshold; // public
      // Signal that the transaction FIFO threshold level has been exceeded

   event signal_transaction_fifo_overflow; // public
      // Signal that the FIFO is full and further transactions are being dropped
   
   function automatic string get_version();  // public
      // Return component version as a string of three integers separated by 
      // periods. For example, version 9.1 sp1 is encoded as "9.1.1".      
      string ret_version = "10.1";
      return ret_version;
   endfunction 

   function automatic void set_transaction_fifo_max( // public
      int  level
   );
      // Set the maximum fullness level of the FIFO. The event
      // signal_transaction_fifo_max is triggered when this 
      // level is exceeded.      
      transaction_fifo_max = level;
   endfunction

   function automatic int get_transaction_fifo_max();
      // Get the maximum transaction FIFO depth.
      return transaction_fifo_max;
   endfunction
   
   function automatic void set_transaction_fifo_threshold( // public
      int  level
   );
      // Set the threshold alert level of the FIFO. The event
      // signal_transaction_fifo_threshold is triggered when this 
      // level is exceeded.
      transaction_fifo_threshold = level;
   endfunction

   function automatic int get_transaction_fifo_threshold();
      // Get the transaction FIFO threshold level.
      return transaction_fifo_threshold;
   endfunction
   
   //--------------------------------------------------------------------------
   // Command Transaction API
   //--------------------------------------------------------------------------
   event signal_command_received; // public
   // This event notifies the test bench that a command has been detected
   // on the Avalon port. 
   // The testbench can respond with a set_interface_wait_time
   // call on receiving this event to dynamically back pressure the driving
   // Avalon master. Alternatively, wait_time which was previously set may
   // be used continuously for a set of transactions.

   function automatic void set_command_transaction_mode( // public
       int mode
   );
      // By default, write burst commands are consolidated into a single
      // command transaction containing the write data for all burst cycles
      // in that command. This mode is set when the mode argument equals 0.
      // When the mode argument is set to 1, the default is overridden and
      // write burst commands yield one command transaction per burst cycle.

      $sformat(message, "%m: method called arg0 %0d ", mode);
      print(VERBOSITY_DEBUG, message);
      consolidate_write_burst_transactions = (mode == 0) ? 1:0;
   endfunction 
   
   function automatic void pop_command(); // public
      // Pop the command descriptor from the queue so that it can be
      // queried with the get_command methods by the test bench.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
          
      client_command = command_queue.pop_back();

      case(client_command.request) 
         REQ_READ:   $sformat(message, "%m: read addr %0x", 
                              client_command.address);
         REQ_WRITE:  $sformat(message,"%m: write addr %0x", 
                              client_command.address);
         REQ_IDLE:   $sformat(message, "%m: idle transaction");
         default:    $sformat(message, "%m: illegal transaction");
      endcase
      print(VERBOSITY_DEBUG, message);
   endfunction
   
   function automatic int get_command_queue_size(); // public
      // Query the command queue to determine number of pending commands
      $sformat(message, "%m: method called");                  
      print(VERBOSITY_DEBUG, message);
      
      return command_queue.size();
   endfunction 

   function automatic Request_t get_command_request(); // public
      // Get the received command descriptor to determine command request type.
      // A command type may be REQ_READ or REQ_WRITE. These type values
      // are defined in the enumerated type called Request_t which is
      // imported with the package named avalon_mm_pkg.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
          
      return client_command.request;
   endfunction 

   function automatic logic [AV_ADDRESS_W-1:0] get_command_address(); // public
      // Query the received command descriptor for the transaction address.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
          
      return client_command.address;      
   endfunction 

   function automatic [AV_BURSTCOUNT_W-1:0] get_command_burst_count();// public
      // Query the received command descriptor for the transaction burst count.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
          
      return client_command.burst_count;      
   endfunction 

   function automatic logic [AV_DATA_W-1:0] get_command_data( // public
      int index
   );
      // Query the received command descriptor for the transaction write data.
      // The burst commands with burst count greater than 1, the index
      // selects the write data cycle.
      $sformat(message, "%m: method called arg0 %0d", index);
      print(VERBOSITY_DEBUG, message);
          
      if (__check_transaction_index(index))
         return client_command.data[index];
      else
         return('x);
   endfunction 

   function automatic logic [AV_NUMSYMBOLS-1:0] get_command_byte_enable(// public
      int index
   );
      // Query the received command descriptor for the transaction byte enable.
      // The burst commands with burst count greater than 1, the index
      // selects the data cycle.
      $sformat(message, "%m: method called arg0 %0d", index);
      print(VERBOSITY_DEBUG, message);
          
      if (__check_transaction_index(index))
         return client_command.byte_enable[index];
      else
         return('x);
   endfunction 

   function automatic int get_command_burst_cycle();  // public
      // Write burst commands are received and processed by the slave BFM as
      // a sequence of discrete commands. The number of commands corresponds
      // to the burst count. A separate command descriptor is constructed for
      // each write burst cycle, corresponding to a partially completed burst.
      // Write data is incrementally added to each new descriptor in each burst
      // cycle until the command descriptor in final burst cycle contains 
      // the full burst command data array. 
      // The burst cycle field returned by this method tells the test bench
      // which burst cycle was active when this descriptor was constructed.
      // This facility enables the testbench to query partially completed 
      // write burst operations. In other words, the testbench can query 
      // the write data word on each burst cycle as it arrives and begin to 
      // process it immediately rather than waiting until the entire burst
      // has been received. This makes it possible to perform pipelined write 
      // burst processing in the test bench.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
          
      return client_command.burst_cycle;
   endfunction

   function automatic logic get_command_arbiterlock(); // public
      // Query the received command descriptor for the transaction arbiterlock.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
      return client_command.arbiterlock;      
   endfunction 

   function automatic logic get_command_lock(); // public
      // Query the received command descriptor for the transaction lock.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
      return client_command.lock;      
   endfunction 

   function automatic logic get_command_debugaccess(); // public
      // Query the received command descriptor for the transaction debugaccess.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);
      return client_command.debugaccess;      
   endfunction 

   function automatic logic [AV_TRANSACTIONID_W-1:0] get_command_transaction_id(); // public
      // Query the received command descriptor for the transaction ID.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);

      return client_command.transaction_id;
   endfunction 

   function automatic logic [AV_TRANSACTIONID_W-1:0] get_command_write_response_request(); // public
      // Query the received command descriptor for value of the 
      // write_response_request field. If it is one, then the master has 
      // requested a write response.
      $sformat(message, "%m: method called");
      print(VERBOSITY_DEBUG, message);

      return client_command.write_response_request;
   endfunction 

   //--------------------------------------------------------------------------
   // Response Transaction API
   //--------------------------------------------------------------------------
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

   function automatic int get_command_issued_queue_size(); // public
      // Query the issued command queue to determine the number of 
      // commands that have been driven to the system interconnect 
      // fabric, but have not yet completed.
      $sformat(message, "%m: method called");            
      print(VERBOSITY_DEBUG, message);
      
      return (issued_read_command_queue.size() + issued_write_command_queue.size());
   endfunction 

   function automatic logic [AV_ADDRESS_W-1:0] get_response_address(); // public
      // Returns the transaction address in the response descriptor that
      // has been popped from the response queue.
      $sformat(message, "%m: called");
      print(VERBOSITY_DEBUG, message);
      
      return return_response.address;      
   endfunction 

   function automatic logic [AV_NUMSYMBOLS-1:0] get_response_byte_enable(// public
      int index
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
      int index
   );
      // Returns the transaction data in the response descriptor
      // that has been popped from the response queue. Each cycle in a 
      // burst response is addressed individually by the specified index.
      // In the case of read responses, the data is the data captured on
      // the avs_readdata interface pin. In the case of write responses,
      // the data on the driven avs_writedata pin is captured and 
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

   function automatic void pop_response(); // public
      // Pop the transaction descriptor from the queue so that it can be
      // queried with the get_response methods by the test bench.
      
      int read_queue_head_seq_count = read_response_queue[$].seq_count;
      int write_queue_head_seq_count = write_response_queue[$].seq_count;      

      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);

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
   
   function automatic AvalonResponseStatus_t get_read_response_status( // public
      int index
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
   
   function automatic AvalonReadResponse_t get_response_read_response( // public
      int index
   );
      // API is no longer supported
      $sformat(message, "%m: API is not longer supported. Please use get_read_response_status API");
      print(VERBOSITY_WARNING, message);

      return '0;
   endfunction 
   
   function automatic AvalonWriteResponse_t get_response_write_response( // public
      int index
   );
      // API is no longer supported
      $sformat(message, "%m: API is not longer supported.  Please use get_write_response_status API");
      print(VERBOSITY_WARNING, message);

      return '0;
   endfunction 

   function automatic AvalonTransactionId_t get_response_read_id(); // public
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

   function automatic AvalonTransactionId_t get_response_write_id(); // public
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
   
   function automatic logic get_clken();  // public
      // Return the clken status
      $sformat(message, "%m: method called");      
      print(VERBOSITY_DEBUG, message);
      return clken_register;
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
   
   task automatic init(); // public
      // Initializes the counters and clear the queue.
      $sformat(message, "%m: method called"); 
      print(VERBOSITY_DEBUG, message);

      __init_descriptors();
      __init_queues();
   endtask
   
   // =cut
   //--------------------------------------------------------------------------
   // Private Methods
   // Note that private methods and events are prefixed with '__'   
   //--------------------------------------------------------------------------
   
   event __command_issued;
   
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
   
   function automatic void __print_response(string text, 
                                            Response_t response);
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

   function automatic void __init_descriptors();
      new_response = '0; 
      current_command = '0;       
      return_response = '0; 
      completed_command = '0;
      command_addr_offset = 0;
      response_addr_offset = 0;
      client_command = '0;
      return_response = '0;
      command_sequence_counter = 1;
      wait_time = 0;
      write_burst_response_counter = 0;
      write_latency = 0;
      write_burst_command_counter = 0;
      read_latency = 0;
      command_waitrequested_start = 0;
      start_construct_complete_read_response = 0;
      start_construct_complete_write_response = 0;
      read_response_burst_counter = 0;
   endfunction      

   function automatic void __init_queues();
      issued_read_command_queue = {};
      issued_write_command_queue = {};
      read_response_queue = {};
      write_response_queue = {};
      command_queue = {};
   endfunction  
   
   function automatic string __request_str(Request_t request);
      case(request)
        REQ_READ:  return "Read";
        REQ_WRITE: return "Write";
        REQ_IDLE:  return "Idle";
      endcase 
   endfunction
   
   //--------------------------------------------------------------------------
   // Local Machinery
   //--------------------------------------------------------------------------
   always @(signal_fatal_error) __abort_simulation();
   
   always @(*) begin
      {
        avs_clken,
        avs_arbiterlock,
        avs_lock,
        avs_debugaccess,
        avs_transactionid,
        avs_readid,
        avs_writeid,
        avs_response,
        avs_writeresponserequest,
        avs_writeresponsevalid,
        
        avs_waitrequest,
        avs_readdatavalid,
        avs_readdata,

        avs_write,
        avs_read,
        avs_address,
        avs_byteenable,
        avs_burstcount,
        avs_beginbursttransfer,
        avs_begintransfer,
        avs_writedata 
       } <= tap; 

   end

//-----------------------------------------------------------------------------
// This two block monitoring the response transaction
//-----------------------------------------------------------------------------
   always @(posedge clk or posedge reset) begin
      clock_counter = clock_counter +1;
      if (reset) begin
         init();
      end else begin
         if (!USE_CLKEN || avs_clken == 1) begin
            sampled_response();
         end
      end 
   end
   
   always @(posedge clk or posedge reset) begin  
      if (reset) begin
         init();
      end else begin
         if (!USE_CLKEN || avs_clken == 1) begin
            if ((get_command_issued_queue_size() == 0) && 
               (start_construct_complete_write_response == 0) &&
               start_construct_complete_read_response == 0) begin 
               @__command_issued;
            end

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
   
//-----------------------------------------------------------------------------
// This task monitoring the command port info and pass it to response
// transaction.
//-----------------------------------------------------------------------------
   task automatic sampled_response();

      if (avs_read) begin
         response_addr_offset = 0;
         new_response.request                  = REQ_READ;
         new_response.data                     = 'x;
         new_response.wait_latency             = 'x;
         new_response.byte_enable              = 'x;
         new_response.write_latency            = 'x;
         new_response.burst_count              = avs_burstcount;
         new_response.burst_size               = avs_burstcount;
         new_response.seq_count                = command_sequence_counter++;;
         new_response.address                  = avs_address;
         new_response.read_id                  = 'x;
         new_response.read_response            = 'x;
         new_response.write_response_request   = avs_writeresponserequest;

         if (USE_READ_DATA_VALID || USE_BURSTCOUNT)
            new_response.read_latency = 'x;
         else
            new_response.read_latency = AV_FIX_READ_LATENCY;
         
         if (avs_waitrequest) begin
            wait_time++;
            return;
         end

         new_response.wait_latency[response_addr_offset] = wait_time;
         new_response.byte_enable[response_addr_offset] = avs_byteenable;
         issued_read_command_queue.push_front(new_response);
         -> __command_issued;
         write_burst_response_counter = 0;
         wait_time = 0;
         clock_snapshot.push_front(clock_counter);
      end else if (avs_write) begin
         if (write_burst_response_counter == 0) begin
            write_burst_response_counter = avs_burstcount;
            new_response.seq_count = command_sequence_counter++;;
            response_addr_offset = 0;
         end
         
         new_response.read_latency                        = 'x;
         new_response.request                             = REQ_WRITE;
         new_response.data[response_addr_offset]          = avs_writedata;
         new_response.byte_enable[response_addr_offset]   = avs_byteenable;
         new_response.write_response_request              = avs_writeresponserequest;
         new_response.write_latency                       = 'x;
         if (response_addr_offset == 0) begin
            new_response.burst_count                      = avs_burstcount;
            new_response.burst_size                       = avs_burstcount;
            new_response.address                          = avs_address;
         end
         new_response.read_id                             = 'x;
         new_response.read_response                       = 'x;
         
         if (avs_waitrequest) begin
            wait_time++;
            return;
         end
         
         new_response.wait_latency[response_addr_offset] = wait_time;

         if (USE_WRITERESPONSE == 0 || new_response.write_response_request == 1'b0) begin
            if (response_addr_offset == (new_response.burst_count-1)) begin
               if (get_response_queue_size() < transaction_fifo_max) begin
                  write_response_queue.push_front(new_response);
                  if (get_response_queue_size() > transaction_fifo_threshold) 
                     ->signal_transaction_fifo_threshold;
               end else begin
                  $sformat(message, 
                     "%m: FIFO overflow! Transaction dropped.");
                  print(VERBOSITY_WARNING, message);
                  ->signal_transaction_fifo_overflow;
               end
               -> signal_write_response_complete;
            end
         end else begin
            if (response_addr_offset == (new_response.burst_count-1)) begin
               issued_write_command_queue.push_front(new_response);
               -> __command_issued;
            end
         end

         response_addr_offset++;
         write_burst_response_counter--;
         wait_time = 0;
      end

   endtask 
 
//-----------------------------------------------------------------------------
// This task monitoring the response port and construct a full response
// transaction.
//-----------------------------------------------------------------------------
   task automatic monitor_response(ref Response_t completed_response);
      case(completed_response.request)
         REQ_WRITE: begin
            // no response transaction while USE_WRITERESPONSE = 0
            if (USE_WRITERESPONSE == 1) begin
               if (!avs_writeresponsevalid) begin
                  write_latency++;
                  return;
               end

               completed_response.write_id               = avs_writeid;
               completed_response.write_latency          = write_latency;
               
               assert($cast(completed_response.write_response, avs_response))
                  else begin
                     $sformat(message, "%m: Response value is not valid when write response is valid");
                     print(VERBOSITY_FAILURE, message);
                  end

               write_latency = 0;
               
               if (get_response_queue_size() < transaction_fifo_max) begin
                  write_response_queue.push_front(completed_response);
                  if (get_response_queue_size() > transaction_fifo_threshold) begin
                     ->signal_transaction_fifo_threshold;
                  end
               end else begin
                  $sformat(message,"%m: FIFO overflow! Transaction dropped.");
                  print(VERBOSITY_WARNING, message);
                  ->signal_transaction_fifo_overflow;
               end               
               -> signal_write_response_complete;
               start_construct_complete_write_response = 0;
            end
         end
         REQ_READ: begin
            if (USE_READ_DATA_VALID || USE_BURSTCOUNT) begin
               if (!avs_readdatavalid) begin
                  read_latency++;
                  return;
               end
               completed_response.data[read_response_burst_counter] = avs_readdata;
               completed_response.read_latency[read_response_burst_counter] = read_latency;

               if (USE_READRESPONSE) begin
                  completed_response.read_id = avs_readid;
                  
                  assert($cast(completed_response.read_response[read_response_burst_counter], avs_response))
                     else begin
                        $sformat(message, "%m: Response value is not valid when read response is valid");
                        print(VERBOSITY_FAILURE, message);
                     end
               end
                  
               read_latency = 0;

            end else begin
               if (AV_FIX_READ_LATENCY > 0) begin
                  if (clock_counter - clock_snapshot[$] < AV_FIX_READ_LATENCY) begin
                     return;
                  end
                  current_time = clock_snapshot.pop_back();
               end
              
               completed_response.read_latency[0]     = AV_FIX_READ_LATENCY;
               completed_response.data[0]             = avs_readdata;

               if (USE_READRESPONSE) begin
                  completed_response.read_id          = avs_readid;
                  
                  assert($cast(completed_response.read_response[0], avs_response))
                     else begin
                        $sformat(message, "%m: Response value is not valid when read response is valid");
                        print(VERBOSITY_FAILURE, message);
                     end
               end
               read_latency = 0;
            end 
            
            if (read_response_burst_counter == completed_response.burst_count-1) begin
               if (get_response_queue_size() < transaction_fifo_max) begin
                  read_response_queue.push_front(completed_response);
                  if (get_response_queue_size() > transaction_fifo_threshold) 
                     ->signal_transaction_fifo_threshold;
               end else begin
                  $sformat(message, 
                     "%m: FIFO overflow! Transaction dropped.");
                  print(VERBOSITY_WARNING, message);
                  ->signal_transaction_fifo_overflow;
               end
               ->signal_read_response_complete;
               read_response_burst_counter = 0;
               start_construct_complete_read_response = 0;
            end else begin
               read_response_burst_counter++;
            end
         end
      endcase
   endtask 
   
   always @(signal_read_response_complete or 
            signal_write_response_complete or 
            posedge reset) begin
      if (!reset) begin
         ->signal_response_complete;
      end
   end
   
   
//-----------------------------------------------------------------------------
// This block monitoring the command transaction
//-----------------------------------------------------------------------------
   always @(posedge clk or posedge reset) begin
      clken_register <= avs_clken;
      if (reset) begin
         init();
      end else begin
         if (!USE_CLKEN || avs_clken == 1) begin
            monitor_command();  
         end
      end
   end
   
//-----------------------------------------------------------------------------
// This task monitoring the command port and construct a full command
// transaction.
//-----------------------------------------------------------------------------
   task automatic monitor_command();
      if (avs_write) begin
         if (write_burst_command_counter == 0) begin
            write_burst_command_counter = avs_burstcount;
            command_addr_offset = 0;
         end

         current_command.request                   = REQ_WRITE;
         current_command.data[command_addr_offset] = avs_writedata;
         current_command.byte_enable[command_addr_offset]  = avs_byteenable;
         if ( command_addr_offset == 0) begin
            current_command.address                   = avs_address;
            current_command.burst_count               = avs_burstcount;
            current_command.transaction_id            = avs_transactionid;
            current_command.write_response_request    = avs_writeresponserequest;
         end
         
         current_command.burst_cycle               = command_addr_offset; 
         current_command.arbiterlock               = avs_arbiterlock;
         current_command.lock                      = avs_lock;
         current_command.debugaccess               = avs_debugaccess;
         
         if (command_waitrequested_start == 0) begin
            if ((consolidate_write_burst_transactions &&
               (command_addr_offset == current_command.burst_count-1)) ||
               !consolidate_write_burst_transactions) begin
               if (get_command_queue_size() < transaction_fifo_max) begin
                  command_queue.push_front(current_command);
                  if (get_command_queue_size() > transaction_fifo_threshold) 
                      ->signal_transaction_fifo_threshold;
               end else begin
                  $sformat(message, "%m: FIFO overflow! Transaction dropped.");
                  print(VERBOSITY_WARNING, message);
                  ->signal_transaction_fifo_overflow;
               end
               ->signal_command_received;
            end
            if (avs_waitrequest) begin
               command_waitrequested_start = 1;
               return;
            end
         end else begin
            if (avs_waitrequest)
               return;
            else
               command_waitrequested_start = 0;
         end
         command_addr_offset++;
         write_burst_command_counter--;
      end else if (avs_read) begin 

         current_command = 'x;
         write_burst_command_counter = 0;
         command_addr_offset = 0;
          
         current_command.request                   = REQ_READ;      
         current_command.address                   = avs_address;
         current_command.data                      = 'x; 
         current_command.byte_enable               = avs_byteenable; 
         current_command.burst_count               = avs_burstcount;
         current_command.arbiterlock               = avs_arbiterlock;
         current_command.lock                      = avs_lock;
         current_command.debugaccess               = avs_debugaccess; 
         current_command.transaction_id            = avs_transactionid;
         current_command.write_response_request    = avs_writeresponserequest;
         
         if (command_waitrequested_start == 0) begin
            if (get_command_queue_size() < transaction_fifo_max) begin
               command_queue.push_front(current_command);
               if (get_command_queue_size() > transaction_fifo_threshold) 
                   ->signal_transaction_fifo_threshold;
            end else begin
               $sformat(message, "%m: FIFO overflow! Transaction dropped.");
               print(VERBOSITY_WARNING, message);
               ->signal_transaction_fifo_overflow;
            end
            ->signal_command_received;
            if (avs_waitrequest) begin
               command_waitrequested_start = 1;
               return;
            end
         end else begin
            if (avs_waitrequest)
               return;
            else
               command_waitrequested_start = 0;
         end
      end
   endtask

   // synthesis translate_on  
endmodule



