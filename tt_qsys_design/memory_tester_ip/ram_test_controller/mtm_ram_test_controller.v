/*
  Legal Notice: (C)2010 Altera Corporation. All rights reserved.  Your
  use of Altera Corporation's design tools, logic functions and other
  software and tools, and its AMPP partner logic functions, and any
  output files any of the foregoing (including device programming or
  simulation files), and any associated documentation or information are
  expressly subject to the terms and conditions of the Altera Program
  License Subscription Agreement or other applicable license agreement,
  including, without limitation, that your use is for the sole purpose
  of programming logic devices manufactured by Altera and sold by Altera
  or its authorized distributors.  Please refer to the applicable
  agreement for further details.
*/


/*

RAM test controller

Author:  JCJB
Date:    04/30/2010

Description:  

Register map:

|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|  Address   |   Access Type   |                                                            Bits                                                        |
|            |                 |------------------------------------------------------------------------------------------------------------------------|
|            |                 |            31..24            |            23..16            |            15..8            |            7..0            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|     0      |       r/w       |                                                     Base Address[31..0]                                                |
|     4      |       r/w       |                                                     Base Address[63..32]                                               |
|     8      |       r/w       |                                                    Transfer Length[31..0]                                              |
|     12     |       r/w       |        Block Trail[7..0]                                             Block Size[23..0]                                 |
|     16     |       r/w       |                         Start                                                                    Concurrent R/W Enable |
|     20     |       N/A       |                                                            N/A                                                         |
|     24     |       r/w       |                                                                               Timer Resolution[15..0]                  |
|     28     |       r/w       |                                                         Timer[31..0]                                                   |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|


Address 0  --> Lower 32 bits of the base address
Address 4  --> Upper 32 bits of the base address (Note this will not be addressable in SOPC Builder)
Address 8  --> Transfer length register
Address 12 --> Bits 23-0 are used to specify the transfer block size.  The block size (in bytes) is used to determine how large of block of memory should
               be tested at any given time.  If 'concurrent r/w enable' is set to 0 then the block size represents how much data will be written before a
               read verification cycle starts.  Bits 31-24 are used to specify the block trail.  The block trail represents how many blocks the read master
               should trail the write master by.  A block trail of 0 means that the block is written out and read back immediately.  A block train of 1 means
               that two blocks will be written followed by reading the first block.
Address 16 --> Bit 0 is used to enable concurrent read and write block operations.  When disabled the read master remains idle while the write master
               operates.  When enabled the read and write masters can operate concurrently presenting a mix of read and write accesses to the memory.
               Bit 24 is used to start the memory test masters and will remain enabled until the last read data returns to the read master.
Address 20 --> N/A
Address 24 --> Timer resolution in terms of system clock cycles.  If the system clock speed is 100MHz (T=10ns) then setting the resolution to 100 ticks
               will result in the timer having a 1us timer resolution.  By default the timer resolution is 10 ticks.  The timer resolution is used to generate
               a free running slower clock which operates at all times.  As a result this clock divider value must be between 2 and 65535.
Address 28 --> Timer with write capabilities.  The timer counts the number of times the free running timer reaches the terminal value while the start bit is
               set.  To take multiple measurments you can either write a 0 to the timer register before enabling the test to get a measurement for each test
               or run multiple tests and reading the timer value at the end of the test.  While the test is not operating (start == 0) the timer will stop and
               hold it's previous value.

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_ram_test_controller (
  clk,
  reset,
  
  csr_address,
  csr_read,
  csr_write,
  csr_readdata,
  csr_writedata,
  csr_byteenable,
  csr_waitrequest,
  
  src_write_command_data,
  src_write_command_ready,
  src_write_command_valid,

  src_read_command_data,
  src_read_command_ready,
  src_read_command_valid
);

  parameter DEFAULT_TIMER_RESOLUTION = 10;
  parameter DEFAULT_BLOCK_SIZE = 1024;
  parameter DEFAULT_TRAIL_DISTANCE = 1;
  localparam USE_EAB = 1;    // slight Fmax increase if the FIFO is converted to LEs, probably never need to use this though so it is set locally (and is not tested!!!)
  localparam EAB_FIFO_DEPTH = 256;
  localparam EAB_FIFO_DEPTH_LOG2 = 8;  // log2(EAB_FIFO_DEPTH)
  localparam LE_FIFO_DEPTH = 4;
  localparam LE_FIFO_DEPTH_LOG2 = 2;   // log2(LE_FIFO_DEPTH)

  input clk;
  input reset;

  input [2:0] csr_address;
  input csr_read;
  input csr_write;
  output wire [31:0] csr_readdata;
  input [31:0] csr_writedata;
  input [3:0] csr_byteenable;
  output wire csr_waitrequest;

  output wire [95:0] src_write_command_data;
  input src_write_command_ready;
  output wire src_write_command_valid;
  
  output wire [96:0] src_read_command_data;
  input src_read_command_ready;
  output wire src_read_command_valid;


  // registers and control for the CSR
  reg [63:0] base_address;
  wire load_base_address;
  wire [7:0] load_base_address_lanes;
  reg [31:0] length;
  wire load_length;
  wire [3:0] load_length_lanes;
  reg [23:0] block_size;
  wire load_block_size;
  wire [2:0] load_block_size_lanes;
  reg [7:0] block_trail;
  wire load_block_trail;
  reg concurrent_access_enable;
  wire load_concurrent_access_enable;
  reg start;
  wire load_start;
  wire clear_start;
  reg [15:0] timer_resolution;
  wire load_timer_resolution;
  wire [1:0] load_timer_resolution_lanes;
  reg [31:0] timer_counter;
  wire load_timer_counter;
  wire [3:0] load_timer_counter_lanes;
  wire increment_timer_counter;
  reg [31:0] read_data;
  reg [31:0] read_data_d1;



  wire [63:0] read_fsm_command_address;
  wire [23:0] read_fsm_command_length;
  wire read_fsm_last_command;

  wire [63:0] write_fsm_command_address;
  wire [23:0] write_fsm_command_length;
  wire write_fsm_last_command;


  wire [88:0] read_fifo_datain;
  wire read_fifo_full;
  wire read_fifo_empty;
  wire [88:0] read_fifo_dataout;
  wire read_fifo_pop;     // 'read'
  wire read_fifo_push;    // 'write'


  wire [88:0] write_fifo_datain;
  wire write_fifo_full;
  wire write_fifo_empty;
  wire [88:0] write_fifo_dataout;
  wire write_fifo_pop;    // 'read'
  wire write_fifo_push;   // 'write'


  reg last_write_complete;
  wire set_last_write_complete;
  wire clear_last_write_complete;
  reg last_read_complete;
  wire set_last_read_complete;
  wire clear_last_read_complete;
  reg [7:0] block_trail_distance;
  wire issue_read_command;
  reg issue_read_command_d1;
  reg issue_read_command_d2;
  wire set_issue_read_command_d2;
  wire reset_issue_read_command_d2;
  wire issue_write_command;
  reg issue_write_command_d1;
  reg issue_write_command_d2;
  wire set_issue_write_command_d2;
  wire reset_issue_write_command_d2;

  reg [2:0] state;
  wire initialize;
  wire flush_state_pipeline;
  wire compare;
  reg compare_d1;
  wire enable_compare_d1;

  reg [15:0] timer_resolution_minus_one;
  reg [15:0] high_res_timer_counter;
  wire clear_high_res_timer_counter;
  reg clear_high_res_timer_counter_d1;





  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      base_address <= 0;
    end
    else if (load_base_address == 1)
    begin
      if (load_base_address_lanes[0] == 1)
      begin
        base_address[7:0] <= csr_writedata[7:0];
      end
      if (load_base_address_lanes[1] == 1)
      begin
        base_address[15:8] <= csr_writedata[15:8];
      end
      if (load_base_address_lanes[2] == 1)
      begin
        base_address[23:16] <= csr_writedata[23:16];
      end
      if (load_base_address_lanes[3] == 1)
      begin
        base_address[31:24] <= csr_writedata[31:24];
      end
      if (load_base_address_lanes[4] == 1)
      begin
        base_address[39:32] <= csr_writedata[7:0];
      end
      if (load_base_address_lanes[5] == 1)
      begin
        base_address[47:40] <= csr_writedata[15:8];
      end
      if (load_base_address_lanes[6] == 1)
      begin
        base_address[55:48] <= csr_writedata[23:16];
      end
      if (load_base_address_lanes[7] == 1)
      begin
        base_address[63:56] <= csr_writedata[31:24];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      length <= 0;
    end
    else if (load_length == 1)
    begin
      if (load_length_lanes[0] == 1)
      begin
        length[7:0] <= csr_writedata[7:0];
      end
      if (load_length_lanes[1] == 1)
      begin
        length[15:8] <= csr_writedata[15:8];
      end
      if (load_length_lanes[2] == 1)
      begin
        length[23:16] <= csr_writedata[23:16];
      end
      if (load_length_lanes[3] == 1)
      begin
        length[31:24] <= csr_writedata[31:24];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      block_size <= DEFAULT_BLOCK_SIZE;
    end
    else if (load_block_size == 1)
    begin
      if (load_block_size_lanes[0] == 1)
      begin
        block_size[7:0] <= csr_writedata[7:0];
      end
      if (load_block_size_lanes[1] == 1)
      begin
        block_size[15:8] <= csr_writedata[15:8];
      end
      if (load_block_size_lanes[2] == 1)
      begin
        block_size[23:16] <= csr_writedata[23:16];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      block_trail <= DEFAULT_TRAIL_DISTANCE;
    end
    else if (load_block_trail == 1)
    begin
      block_trail <= csr_writedata[31:24];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      concurrent_access_enable <= 0;
    end
    else if (load_concurrent_access_enable == 1)
    begin
      concurrent_access_enable <= csr_writedata[0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      start <= 0;
    end
    else
    begin
      if (clear_start == 1)
      begin
        start <= 0;
      end
      else if (load_start)
      begin
        start <= csr_writedata[24];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      timer_resolution <= DEFAULT_TIMER_RESOLUTION;
    end
    else if (load_timer_resolution == 1)
    begin
      if (load_timer_resolution_lanes[0] == 1)
      begin
        timer_resolution[7:0] <= csr_writedata[7:0];
      end
      if (load_timer_resolution_lanes[1] == 1)
      begin
        timer_resolution[15:8] <= csr_writedata[15:8];
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      timer_counter <= 0;
    end
    else
    begin
      if (load_timer_counter == 1)
      begin
        if (load_timer_counter_lanes[0] == 1)
        begin
          timer_counter[7:0] <= csr_writedata[7:0];
        end
        if (load_timer_counter_lanes[1] == 1)
        begin
          timer_counter[15:8] <= csr_writedata[15:8];
        end
        if (load_timer_counter_lanes[2] == 1)
        begin
          timer_counter[23:16] <= csr_writedata[23:16];
        end
        if (load_timer_counter_lanes[3] == 1)
        begin
          timer_counter[31:24] <= csr_writedata[31:24];
        end
      end
      else if (increment_timer_counter == 1)
      begin
        timer_counter <= timer_counter + 1'b1;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
	  timer_resolution_minus_one <= 0;
      clear_high_res_timer_counter_d1 <= 0;
      high_res_timer_counter <= 0;
      issue_write_command_d1 <= 0;
      issue_read_command_d1 <= 0;
    end
    else
    begin
	  timer_resolution_minus_one <= timer_resolution - 1'b1;
      clear_high_res_timer_counter_d1 <= clear_high_res_timer_counter;
      high_res_timer_counter <= (clear_high_res_timer_counter_d1 == 1)? 1 : (high_res_timer_counter + 1'b1);  // starting from 1 since the clearing signal is a cycle late
      issue_write_command_d1 <= issue_write_command;
      issue_read_command_d1 <= issue_read_command;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      read_data_d1 <= 0;
    end
    else if (csr_read == 1)
    begin
      read_data_d1 <= read_data;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      block_trail_distance <= 0;
    end
    else
    begin
      case ({read_fifo_pop, write_fifo_pop})
        2'b00:  block_trail_distance <= block_trail_distance;
        2'b01:  block_trail_distance <= block_trail_distance + 1'b1;
        2'b10:  block_trail_distance <= block_trail_distance - 1'b1;
        2'b11:  block_trail_distance <= block_trail_distance;
      endcase
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      last_write_complete <= 0;
    end
    else
    begin
      if (clear_last_write_complete == 1)
      begin
        last_write_complete <= 0;
      end
      else if (set_last_write_complete == 1)
      begin
        last_write_complete <= 1;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      last_read_complete <= 0;
    end
    else
    begin
      if (clear_last_read_complete == 1)
      begin
        last_read_complete <= 0;
      end
      else if (set_last_read_complete == 1)
      begin
        last_read_complete <= 1;
      end
    end
  end  
  

  // simple one-hot ring statemachine
  // state 0 --> register compare
  // state 1 --> register issue_read_command_d1 and issue_write_command_d1 (these will always be enabled)
  // state 2 --> set issue_read_command_d2 and issue_write_command_d2 if the previous pipeline stage is high
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      state <= 0;
    end
    else
    begin
      if (flush_state_pipeline == 1)
      begin
        state <= 0;
      end
      else if (initialize == 1)
      begin
        state <= 3'b001;
      end
      else
      begin
        state <= {state[1], state[0], state[2]};
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      compare_d1 <= 0;
    end
    else if (enable_compare_d1 == 1)
    begin
      compare_d1 <= compare;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      issue_write_command_d2 <= 0;
    end
    else 
    begin
      if (reset_issue_write_command_d2 == 1)
      begin
        issue_write_command_d2 <= 0;
      end
      else if (set_issue_write_command_d2 == 1)
      begin
        issue_write_command_d2 <= issue_write_command_d1;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      issue_read_command_d2 <= 0;
    end
    else
    begin
      if (reset_issue_read_command_d2 == 1)
      begin
        issue_read_command_d2 <= 0;
      end
      else if (set_issue_read_command_d2 == 1)
      begin
        issue_read_command_d2 <= issue_read_command_d1;
      end
    end
  end



  // this state machine is responsible for taking the total read transaction and chopping it up into blocks and feeding them into the read command FIFO
  mtm_chopper_fsm read_fsm (
    .clk                    (clk),
    .reset                  (reset),
    .enable                 (start),
    .transfer_length        (length),
    .block_size             (block_size),
    .base_address           (base_address),
    .fifo_full              (read_fifo_full),
    .fifo_command_address   (read_fsm_command_address),
    .fifo_command_length    (read_fsm_command_length),
    .fifo_last_command      (read_fsm_last_command),
    .fifo_write             (read_fifo_push)
  );


  // this state machine is responsible for taking the total write transaction and chopping it up into blocks and feeding them into the write command FIFO
  mtm_chopper_fsm write_fsm (
    .clk                    (clk),
    .reset                  (reset),
    .enable                 (start),
    .transfer_length        (length),
    .block_size             (block_size),
    .base_address           (base_address),
    .fifo_full              (write_fifo_full),
    .fifo_command_address   (write_fsm_command_address),
    .fifo_command_length    (write_fsm_command_length),
    .fifo_last_command      (write_fsm_last_command),
    .fifo_write             (write_fifo_push)
  );


  // this fifo will buffer the read_command_address, read_command_length, and read_command_last_block signals
  scfifo read_fifo (
    .aclr   (reset),
    .clock  (clk),
    .data   (read_fifo_datain),
    .full   (read_fifo_full),
    .empty  (read_fifo_empty),
    .q      (read_fifo_dataout),
    .rdreq  (read_fifo_pop),
    .wrreq  (read_fifo_push)
  );
  defparam read_fifo.lpm_width = 89;  // 64 bit command address, 24 bit command length, 1 bit last block
  defparam read_fifo.lpm_numwords = (USE_EAB == 1)? EAB_FIFO_DEPTH : LE_FIFO_DEPTH;
  defparam read_fifo.lpm_widthu = (USE_EAB == 1)? EAB_FIFO_DEPTH_LOG2 : LE_FIFO_DEPTH_LOG2;
  defparam read_fifo.lpm_showahead = "ON";
  defparam read_fifo.use_eab = (USE_EAB == 1)? "ON" : "OFF";
  defparam read_fifo.add_ram_output_register = "ON";  // FIFO latency of 2
  defparam read_fifo.underflow_checking = "OFF";
  defparam read_fifo.overflow_checking = "OFF";


  // this fifo will buffer the write_command_address, write_command_length, and write_command_last_block signals
  scfifo write_fifo (
    .aclr   (reset),
    .clock  (clk),
    .data   (write_fifo_datain),
    .full   (write_fifo_full),
    .empty  (write_fifo_empty),
    .q      (write_fifo_dataout),
    .rdreq  (write_fifo_pop),
    .wrreq  (write_fifo_push)
  );
  defparam write_fifo.lpm_width = 89;  // 64 bit command address, 24 bit command length, 1 bit last block
  defparam write_fifo.lpm_numwords = (USE_EAB == 1)? EAB_FIFO_DEPTH : LE_FIFO_DEPTH;
  defparam write_fifo.lpm_widthu = (USE_EAB == 1)? EAB_FIFO_DEPTH_LOG2 : LE_FIFO_DEPTH_LOG2;
  defparam write_fifo.lpm_showahead = "ON";
  defparam write_fifo.use_eab = (USE_EAB == 1)? "ON" : "OFF";
  defparam write_fifo.add_ram_output_register = "ON";  // FIFO latency of 2
  defparam write_fifo.underflow_checking = "OFF";
  defparam write_fifo.overflow_checking = "OFF";




  always @ (base_address or length or block_size or block_trail or concurrent_access_enable or start or timer_resolution or timer_counter or csr_address)
  begin
    case (csr_address)
      3'b000: read_data = base_address[31:0];
      3'b001: read_data = base_address[63:32];
      3'b010: read_data = length;
      3'b011: read_data = {block_trail, block_size};
      3'b100: read_data = {{7{1'b0}}, start, {23{1'b0}}, concurrent_access_enable};
      3'b101: read_data = {32{1'b0}};
      3'b110: read_data = {{16{1'b0}}, timer_resolution};
      3'b111: read_data = timer_counter;
    endcase
  end


  assign load_base_address = (csr_write == 1) & ((csr_address == 3'b000) | (csr_address == 3'b001)) & (csr_waitrequest == 0);
  assign load_base_address_lanes[3:0] = (csr_address[0] == 0)? csr_byteenable : 4'b0000;
  assign load_base_address_lanes[7:4] = (csr_address[0] == 1)? csr_byteenable : 4'b0000;
  assign load_length = (csr_write == 1) & (csr_address == 3'b010) & (csr_waitrequest == 0);
  assign load_length_lanes = csr_byteenable;
  assign load_block_size = (csr_write == 1) & (csr_address == 3'b011) & (csr_waitrequest == 0);
  assign load_block_size_lanes = csr_byteenable[2:0];
  assign load_block_trail = (csr_write == 1) & (csr_address == 3'b011) & (csr_byteenable[3] == 1) & (csr_waitrequest == 0);
  assign load_concurrent_access_enable = (csr_write == 1) & (csr_address == 3'b100) & (csr_byteenable[0] == 1) & (csr_waitrequest == 0);
  assign load_start = (csr_write == 1) & (csr_address == 3'b100) & (csr_byteenable[3] == 1) & (csr_waitrequest == 0);
  assign load_timer_resolution = (csr_write == 1) & (csr_address == 3'b110) & (csr_waitrequest == 0);
  assign load_timer_resolution_lanes = csr_byteenable[1:0];
  assign load_timer_counter = (csr_write == 1) & (csr_address == 3'b111) & (csr_waitrequest == 0);
  assign load_timer_counter_lanes = csr_byteenable;

  assign write_fifo_datain = {write_fsm_last_command, write_fsm_command_length, write_fsm_command_address};
  assign src_write_command_data = {{8{1'b0}}, write_fifo_dataout[87:0]};  // padding 24-bit command length to be 32-bits
  assign src_write_command_valid = (issue_write_command_d2 == 1);
  assign read_fifo_datain = {read_fsm_last_command, read_fsm_command_length, read_fsm_command_address};
  assign src_read_command_data = {!read_fifo_dataout[88], {8{1'b0}}, read_fifo_dataout[87:0]};  // padding 24-bit command length to be 32-bits and inverting the last block bit and using it as the early_done bit (don't want early done high on last command)
  assign src_read_command_valid = (issue_read_command_d2 == 1);



  assign clear_start = (last_read_complete == 1) & (src_read_command_ready == 1);  // last read command has been completed by the read master

  assign clear_last_write_complete = (clear_start == 1) & (last_write_complete == 1);
  assign set_last_write_complete = (write_fifo_dataout[88] == 1) & (write_fifo_pop == 1) & (last_write_complete == 0);
  
  assign clear_last_read_complete = (clear_start == 1) & (last_read_complete == 1);
  assign set_last_read_complete = (read_fifo_dataout[88] == 1) & (read_fifo_pop == 1) & (last_read_complete == 0);
  
  assign initialize = (load_start == 1) | (write_fifo_pop == 1) | (read_fifo_pop == 1);
  assign flush_state_pipeline = (clear_start == 1);
  assign compare = (block_trail_distance < block_trail);
  assign enable_compare_d1 = (state[0] == 1);


  assign issue_write_command = (write_fifo_empty == 0) & (state[1] == 1) &
                               (  ((compare_d1 == 1) & (concurrent_access_enable == 0) & (src_read_command_ready == 1)) |
                                  ((compare_d1 == 1) & (concurrent_access_enable == 1))  );

  assign set_issue_write_command_d2 = (state[2] == 1) & (issue_write_command_d1 == 1) & (start == 1) & (initialize == 0);
  assign reset_issue_write_command_d2 = (issue_write_command_d2 == 1) & (src_write_command_ready == 1);
  assign write_fifo_pop = (issue_write_command_d2 == 1) & (src_write_command_ready == 1);


  assign issue_read_command = (read_fifo_empty == 0) & (state[1] == 1) &
                              (  ((compare_d1 == 0) & (concurrent_access_enable == 0) & (src_write_command_ready == 1)) |
                                 ((compare_d1 == 0) & (concurrent_access_enable == 1)) |
                                 ((last_write_complete == 1) & (concurrent_access_enable == 0) & (src_write_command_ready == 1)) |
                                 ((last_write_complete == 1) & (concurrent_access_enable == 1))  );


  assign set_issue_read_command_d2 = (state[2] == 1) & (issue_read_command_d1 == 1) & (start == 1) & (initialize == 0);
  assign reset_issue_read_command_d2 = (issue_read_command_d2 == 1) & (src_read_command_ready == 1);
  assign read_fifo_pop = (issue_read_command_d2 == 1) & (src_read_command_ready == 1);

  assign clear_high_res_timer_counter = (high_res_timer_counter == timer_resolution_minus_one) | (load_timer_resolution == 1);
  assign increment_timer_counter = (start == 1) & (clear_high_res_timer_counter_d1 == 1);

  assign csr_waitrequest = (csr_write == 1) & (start == 1);
  assign csr_readdata = read_data_d1;

endmodule
