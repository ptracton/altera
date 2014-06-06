/*
  Legal Notice: (C)2009 Altera Corporation. All rights reserved.  Your
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

Custom pattern write master core


Description:  This block is responsible for posting bursting or non-bursting write
              transactions to the fabric.  The data byte lanes are reversed and
              sent to the master port.
              
              A word aligned address and length that is a multiple of the word size
              is passed to the core and it immediately begins writing to memory.
              A programmable bit to signal when the transfer completion should occur
              is also available.  Burst transactions do not occur until enough data
              has been buffered in the internal FIFO.
              
              Reduce the transfer length width to increase the Fmax of the logic.
              When connecting the write master to burst wrapping slaves (SDRAM) enable
              BURST_ALIGNED_ENABLE.  This will ensure the master never crosses a
              burst boundary in the middle of a burst transaction.  The master has an
              overhead of one cycle after a transfer command is accepted and it will
              become ready for another command the cycle after the last write is posted.
              
              The command format is as follows:
              
              Bits 63:0 -->   Write base address
              Bits 95:64 -->  Write buffer length


Author: JCJB

Initial release 1.0: 04/12/2010

*/



// synthesis translate_off
`timescale 1ns / 1ps 
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_pattern_writer (
  clk,
  reset,

  master_address,
  master_write,
  master_writedata,
  master_burstcount,
  master_byteenable,
  master_waitrequest,

  snk_data,
  snk_valid,
  snk_ready,

  snk_command_data,
  snk_command_valid,
  snk_command_ready
);


  parameter ADDRESS_WIDTH = 32;          // derived parameter (using system info)
  parameter LENGTH_WIDTH = 32;           // any value from 4-32 (larger the value the slower the logic will be), LENGTH_WIDTH shouldn't be larger than ADDRESS_WIDTH and should be reduced to increase the Fmax of the master.
  parameter DATA_WIDTH = 32;             // 16, 32, 64, 128, 256, 512, 1024 are valid choices
  parameter BYTE_ENABLE_WIDTH = 4;       // derived parameter
  parameter BYTE_ENABLE_WIDTH_LOG2 = 2;  // derived parameter
  parameter BURST_ENABLE = 1;            // 1 for bursting to be enabled, otherwise it is disabled
  parameter MAX_BURST_COUNT = 2;         // must be a multiple of 2 between 2 and 1024, when bursting is disabled this value must be set to 1
  parameter BURST_WIDTH = 2;             // derived parameter
  parameter FIFO_DEPTH = 128;            // must be a multiple of 2 between 32 and 4096 (larger the value the slower the logic will be).  The FIFO_DEPTH must also be at least twice MAX_BURST_COUNT
  parameter FIFO_DEPTH_LOG2 = 7;         // derived parameter
  parameter BURST_REALIGN_ENABLE = 1;    // turn on to make sure the master realigns itself to burst boundaries at the beginning of a transfer


  input clk;
  input reset;

  output wire [ADDRESS_WIDTH-1:0] master_address;
  output wire master_write;
  output wire [DATA_WIDTH-1:0] master_writedata;
  output wire [BURST_WIDTH-1:0] master_burstcount;
  output wire [BYTE_ENABLE_WIDTH-1:0] master_byteenable;
  input master_waitrequest;

  input [DATA_WIDTH-1:0] snk_data;
  input snk_valid;
  output wire snk_ready;

  input [95:0] snk_command_data;
  input snk_command_valid;
  output wire snk_command_ready;


  // internal registers and wires
  reg [ADDRESS_WIDTH-1:0] base_address;
  reg [LENGTH_WIDTH-1:0] transfer_counter;
  reg [ADDRESS_WIDTH-1:0] transfer_address;
  reg [LENGTH_WIDTH-1:0] next_length_counter;
  reg [BURST_WIDTH-1:0] burst_count_mux;
  wire [BURST_WIDTH-1:0] burst_count;
  reg [BURST_WIDTH-1:0] burst_count_d1;
  reg [BURST_WIDTH-1:0] burst_counter;
  wire burst_idle;
  wire burst_complete;
  wire burst_begin_fast;
  wire burst_begin_from_idle;
  wire burst_begin;
  wire [BURST_WIDTH-2:0] address_burst_offset;
  wire [BURST_WIDTH-2:0] length_burst_offset;
  wire [BURST_WIDTH-2:0] adjusted_length_burst_offset;
  wire transfer_complete;
  reg first_transfer;
  wire enable_short_last_burst;
  wire enable_short_first_burst;
  wire [BURST_WIDTH-1:0] short_last_burst_count;
  reg [BURST_WIDTH-1:0] short_last_burst_count_d1;
  wire [BURST_WIDTH-1:0] short_first_burst_count;
  reg [BURST_WIDTH-1:0] short_first_burst_count_d1;
  reg master_active;
  wire set_master_active;
  wire reset_master_active;
  reg write;
  wire set_write;
  wire reset_write;

  // internal fifo signals
  wire [DATA_WIDTH-1:0] fifo_writedata;
  wire [DATA_WIDTH-1:0] fifo_readdata;
  wire fifo_full;
  wire fifo_empty;
  wire [FIFO_DEPTH_LOG2:0] fifo_used;  // going to attach fifo_full to the MSB
  wire fifo_read;
  wire fifo_write;

  // command signals
  wire load_command;
  reg load_command_d1;
  wire [63:0] command_address;
  wire [31:0] command_length;



  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      load_command_d1 <= 0;
    end
    else
    begin
      load_command_d1 <= load_command;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      master_active <= 0;
    end
    else
    begin
      if (reset_master_active == 1)
      begin
        master_active <= 0;
      end
      else if (set_master_active == 1)
      begin
        master_active <= 1;
      end 
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      write <= 0;
    end
    else
    begin
      if (reset_write == 1)
      begin
        write <= 0;
      end
      else if (set_write == 1)
      begin
        write <= 1;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      first_transfer <= 0;
    end
    else
    begin
      if (load_command == 1)
      begin
        first_transfer <= 1;
      end
      else if ((first_transfer == 1) & (transfer_complete == 1))
      begin
        first_transfer <= 0;
      end
    end
  end



  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      base_address <= 0;
    end
    else if (load_command == 1)
    begin
      base_address <= command_address[ADDRESS_WIDTH-1:0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      transfer_counter <= 0;
    end
    else
    begin
      if (load_command == 1)
      begin
        transfer_counter <= 0;
      end
      else if ((transfer_complete == 1) | (load_command_d1 == 1))
      begin
        transfer_counter <= transfer_counter + BYTE_ENABLE_WIDTH;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      transfer_address <= 0;
    end
    else if ((burst_complete == 1) | (load_command_d1 == 1))
    begin
      transfer_address <= base_address + transfer_counter;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      next_length_counter <= 0;
    end
    else
    begin
      if (load_command == 1)
      begin
        next_length_counter <= command_length[LENGTH_WIDTH-1:0];
      end
      else if ((transfer_complete == 1) | (load_command_d1 == 1))
      begin
        next_length_counter <= next_length_counter - BYTE_ENABLE_WIDTH;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      short_first_burst_count_d1 <= 0;
    end
    else if (load_command == 1)
    begin
      short_first_burst_count_d1 <= short_first_burst_count;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      short_last_burst_count_d1 <= 0;
    end
    else if (load_command == 1)
    begin
      short_last_burst_count_d1 <= short_last_burst_count;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      burst_counter <= 0;
    end
    else
    begin
      if (burst_begin == 1)
      begin
        burst_counter <= burst_count;
      end
      else if (transfer_complete == 1)
      begin
        burst_counter <= burst_counter - 1'b1;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      burst_count_d1 <= 0;
    end
    else if ((burst_begin == 1) | (load_command_d1 == 1))
    begin
      burst_count_d1 <= burst_count;
    end
  end




  scfifo master_to_st_fifo (
    .aclr   (reset),
    .clock  (clk),
    .data   (fifo_writedata),
    .full   (fifo_full),
    .empty  (fifo_empty),
    .usedw  (fifo_used[FIFO_DEPTH_LOG2-1:0]),
    .q      (fifo_readdata),
    .rdreq  (fifo_read),
    .wrreq  (fifo_write)
  );
  defparam master_to_st_fifo.lpm_width = DATA_WIDTH;
  defparam master_to_st_fifo.lpm_numwords = FIFO_DEPTH;
  defparam master_to_st_fifo.lpm_widthu = FIFO_DEPTH_LOG2;
  defparam master_to_st_fifo.lpm_showahead = "ON";
  defparam master_to_st_fifo.use_eab = "ON";
  defparam master_to_st_fifo.add_ram_output_register = "ON";  // FIFO latency of 2
  defparam master_to_st_fifo.underflow_checking = "OFF";
  defparam master_to_st_fifo.overflow_checking = "OFF";





generate if (BURST_ENABLE == 1)
begin

  assign address_burst_offset = command_address[((BURST_WIDTH-1)+BYTE_ENABLE_WIDTH_LOG2-1): BYTE_ENABLE_WIDTH_LOG2];
  assign length_burst_offset = command_length[((BURST_WIDTH-1)+BYTE_ENABLE_WIDTH_LOG2-1): BYTE_ENABLE_WIDTH_LOG2];
  assign adjusted_length_burst_offset = ((command_length - (short_first_burst_count * BYTE_ENABLE_WIDTH)) >> BYTE_ENABLE_WIDTH_LOG2) & {(BURST_WIDTH-1){1'b1}};

  assign enable_short_last_burst = (next_length_counter == (BYTE_ENABLE_WIDTH * short_last_burst_count));
  assign enable_short_first_burst = (BURST_REALIGN_ENABLE == 1) & (first_transfer == 1) & (transfer_complete == 0);
  assign short_first_burst_count = ((command_length >> BYTE_ENABLE_WIDTH_LOG2) < (MAX_BURST_COUNT - address_burst_offset))? length_burst_offset : (MAX_BURST_COUNT - address_burst_offset);

  if (BURST_REALIGN_ENABLE == 1)
  begin
    assign short_last_burst_count = (adjusted_length_burst_offset == 0)? MAX_BURST_COUNT : {1'b0, adjusted_length_burst_offset};
  end
  else
  begin 
    assign short_last_burst_count = (length_burst_offset == 0)? MAX_BURST_COUNT : {1'b0, length_burst_offset};
  end

end
else
begin
  assign enable_short_last_burst = 0;
  assign enable_short_first_burst = 0;
  assign short_last_burst_count = 0;
  assign short_first_burst_count = 0;
end
endgenerate



  always @ (enable_short_last_burst, enable_short_first_burst, short_last_burst_count_d1, short_first_burst_count_d1)
  begin
    case ({enable_short_last_burst, enable_short_first_burst})
      2'b00:  burst_count_mux = MAX_BURST_COUNT;
      2'b01:  burst_count_mux = short_first_burst_count_d1;
      2'b10:  burst_count_mux = short_last_burst_count_d1;
      2'b11:  burst_count_mux = short_first_burst_count_d1;  // in this case the master will not reach the next burst boundary so the first burst count will be used
    endcase 
  end


  assign transfer_complete = (write == 1) & (master_waitrequest == 0);
  assign burst_count = (BURST_ENABLE == 1)? burst_count_mux : 1;
  assign burst_idle = (burst_counter == 0);
  assign burst_complete = (burst_counter == 1) & (transfer_complete == 1);
  assign burst_begin_fast = (master_active == 1) & (burst_complete == 1) & (fifo_used > burst_count);
  assign burst_begin_from_idle = (master_active == 1) & (burst_idle == 1) & (fifo_used >= burst_count);
  assign burst_begin = ((burst_begin_fast == 1) | (burst_begin_from_idle == 1)) & (next_length_counter != 0);


  assign snk_command_ready = (master_active == 0);

  assign load_command = (snk_command_valid == 1) & (snk_command_ready == 1);
  assign command_address = {snk_command_data[63:BYTE_ENABLE_WIDTH_LOG2], {BYTE_ENABLE_WIDTH_LOG2{1'b0}}};      // ignoring byte address bits since this master only provides word aligned accesses
  assign command_length = {snk_command_data[95:(64+BYTE_ENABLE_WIDTH_LOG2)], {BYTE_ENABLE_WIDTH_LOG2{1'b0}}};  // ignoring length bits that are not a multiple of the data width since the master must end on a word boundary


  assign fifo_write = (snk_ready == 1) & (snk_valid == 1);
  assign fifo_read = (write == 1) & (transfer_complete == 1);
  assign fifo_used[FIFO_DEPTH_LOG2] = fifo_full;  // fifo_used will reflect the true fill level when full instead of 0 this way
  assign fifo_writedata = snk_data;

  assign set_master_active = (load_command == 1);
  assign reset_master_active = (load_command == 0) & (next_length_counter == 0) & (transfer_complete == 1);
  assign set_write = (burst_begin_from_idle == 1);
  assign reset_write = ((next_length_counter == 0) & (transfer_complete == 1)) | ((burst_begin_fast == 0) & (burst_complete == 1));


  assign master_address = transfer_address;
  assign master_write = write;
  assign master_byteenable = {BYTE_ENABLE_WIDTH{1'b1}};
  assign master_burstcount = burst_count_d1;


genvar i;
generate
  for (i = 0; i < BYTE_ENABLE_WIDTH; i = i + 1)
  begin : byte_reversal
    assign master_writedata[((8*(i+1))-1):(8*i)] = fifo_readdata[((8*((BYTE_ENABLE_WIDTH-1-i)+1))-1):(8*(BYTE_ENABLE_WIDTH-1-i))];
  end
endgenerate


  assign snk_ready = (fifo_full == 0);

endmodule
