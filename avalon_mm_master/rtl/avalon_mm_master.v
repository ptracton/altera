//                              -*- Mode: Verilog -*-
// Filename        : avalon_mm_master.v
// Description     : Avalon MM Master Example
// Author          : Philip Tracton
// Created On      : Fri May 30 17:36:03 2014
// Last Modified By: Philip Tracton
// Last Modified On: Fri May 30 17:36:03 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module avalon_mm_master (/*AUTOARG*/
   // Outputs
   ADDRESS, BEGINTRANSFER, BYTE_ENABLE, READ, WRITE, WRITEDATA, LOCK,
   BURSTCOUNT, done, data_read,
   // Inputs
   CLK, RESET, READDATA, WAITREQUEST, READDATAVALID, data_to_write,
   rnw, start, bytes, address_to_access
   ) ;

   input CLK;
   input RESET;

   //
   // FUNDAMENTAL SIGNALS
   //
   output [31:0] ADDRESS;
   output 	 BEGINTRANSFER;
   output [3:0]  BYTE_ENABLE;
   output 	 READ;
   input [31:0]  READDATA;
   output 	 WRITE;
   output [31:0] WRITEDATA;

   //
   // WAIT SIGNALS
   //
   output 	 LOCK;
   input 	 WAITREQUEST;

   //
   // PIPELINE SIGNALS
   //
   input 	 READDATAVALID;
   output 	 BURSTCOUNT;

   //
   // Control Signals -- NOT part of AVALON
   //
   input [31:0]  data_to_write;
   input 	 rnw;
   input 	 start;
   input [3:0] 	 bytes;   
   input [31:0]  address_to_access;
   output 	 done;
   output [31:0] data_read;
   
   
   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg [31:0]		ADDRESS;
   reg			BEGINTRANSFER;
   reg			BURSTCOUNT;
   reg [3:0]		BYTE_ENABLE;
   reg			LOCK;
   reg			READ;
   reg			WRITE;
   reg [31:0]		WRITEDATA;
   reg [31:0]		data_read;
   // End of automatics

   //
   // State Machine Variables
   //
   reg [1:0] 		state;
   reg [1:0] 		next_state;
   wire 		state_active;
   wire			done;
   
   parameter STATE_IDLE = 2'b00;
   parameter STATE_WAIT = 2'b01;
   parameter STATE_DONE = 2'b10;

   assign state_active = (state != STATE_IDLE);   
   assign done = (state == STATE_DONE);
   
   //
   // Synchronous state change
   //
   always @(posedge CLK)
     if (RESET) begin
	state <= STATE_IDLE;	
     end else begin
	state <= next_state;	
     end

   //
   // Asynchronous State Machine
   //
   always @(*)
     if (RESET) begin
	next_state = STATE_IDLE;
	ADDERSS = 0;
	READ = 0;
	WRITE = 0;
	WRITEDATA = 0;
	data_read = 0;
	LOCK = 0;
	BEGINTRANSFER = 0;
	BURSTCOUNT  =0;
	
     end else begin
	case (state)

	  //
	  // STATE_IDLE:  This is our default starting position.  Stay in this
	  // state until the start signal goes high.  When start is asserted, drive
	  // the transaction onto the bus and use WAITREQUEST and rnw to determine the
	  // next state
	  //
	  STATE_IDLE: begin
	     if (start) begin
		ADDRESS = address_to_access;
		BYTE_ENABLE = bytes;
		if (!rnw) begin
		   WRITE = 1'b1;
		   READ = 1'b0;
		   WRITEDATA = data_to_write;
		end else begin
		   READ = 1'b1;
		   WRITE = 1'b0;		   
		end

		if (WAITREQUEST) begin
		   next_state = STATE_WAIT;		   
		end else if (rnw) begin
		   next_state = STATE_READ;		   
		end else begin
		   next_state = STATE_WRITE;		   
		end
		
	     end else begin // if (start)
		next_state = STATE_IDLE;
		ADDERSS = 0;
		READ = 0;
		WRITE = 0;
		WRITEDATA = 0;
		data_read = 0;
		LOCK = 0;
		BEGINTRANSFER = 0;
		BURSTCOUNT  =0;
	     end
	  end // case: STATE_IDLE

	  //
	  // STATE_WAIT: Come here when WAITREQUEST is high.  Stay here until it is low!
	  //	  
	  STATE_WAIT: begin
	     if (WAITREQUEST) begin
		   next_state = STATE_WAIT;		   
	     end else begin
		next_state = STATE_DONE;		   
	     end
	  end	  

	  STATE_DONE:begin
	     if (rnw) begin
		data_read = READDATA;			
	     end
	     next_state = STATE_IDLE;	     
	  end

	  default:begin
	     next_state = STATE_IDLE;
	     ADDERSS = 0;
	     READ = 0;
	     WRITE = 0;
	     WRITEDATA = 0;
	     data_read = 0;
	     LOCK = 0;
	     BEGINTRANSFER = 0;
	     BURSTCOUNT  =0;
	  end
	  
	endcase // case (state)	
     end
   
endmodule // avalon_mm_master
