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

Transaction chopper statemachine


Description:  

This module is responsible for taking the entire test descriptor and chopping it into smaller test blocks.  This module
accepts the transfer base address, transfer length, and block size and continues to chop up the transfer into smaller
blocks every four clock cycles until no blocks remain.  The outputs from this module are a new base address, transfer length
and a last block status bit which is only asserted when the last block is written out.  It is essential that the inputs to
this module remain held until the state machine completes.


Author: JCJB

Initial release 1.0: 05/11/2010

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_chopper_fsm (
  clk,
  reset,

  enable,
  transfer_length,
  block_size,
  base_address,
  fifo_full,
  
  fifo_command_address,
  fifo_command_length,
  fifo_last_command,
  fifo_write
);

  input clk;
  input reset;
  
  input enable;
  input [31:0] transfer_length;  // assumed to be constant throughout transfer
  input [23:0] block_size;       // assumed to be constant throughout transfer
  input [63:0] base_address;     // assumed to be constant throughout transfer
  input fifo_full;
  
  output wire [63:0] fifo_command_address;
  output wire [23:0] fifo_command_length;
  output wire fifo_last_command;
  output wire fifo_write;


  reg enable_d1;
  wire initialize;
  reg [31:0] length_counter;
  wire increment_length_counter;
  reg [63:0] command_address;
  wire enable_command_address;

  reg [31:0] length_downcounter;
  wire decrement_length_downcounter;
  reg [3:0] state;
  wire [3:0] state_decode;
  wire compare;
  reg compare_d1;
  wire enable_compare_d1;
  wire [23:0] command_length;
  reg [23:0] command_length_d1;
  wire enable_command_length_d1;
  wire command_last_block;
  reg command_last_block_d1;
  wire enable_command_last_block_d1;
  wire flush_state_pipeline;



  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      enable_d1 <= 0;
    end
    else
    begin
      enable_d1 <= enable;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      length_counter <= 0;
    end
    else
    begin
      if (initialize == 1)
      begin
        length_counter <= 0;
      end
      else if (increment_length_counter == 1)
      begin
        length_counter <= length_counter + block_size;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      command_address <= 0;
    end
    else if (enable_command_address == 1)
    begin
      command_address <= base_address + length_counter;
    end
  end



  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      length_downcounter <= 0;
    end
    else
    begin
      if (initialize == 1)
      begin
        length_downcounter <= transfer_length;
      end
      else if (decrement_length_downcounter == 1)
      begin
        length_downcounter <= length_downcounter - block_size;  // don't care if this counter underflows
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
      command_length_d1 <= 0;
    end
    else if (enable_command_length_d1 == 1)
    begin
      command_length_d1 <= command_length;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      command_last_block_d1 <= 0;
    end
    else if (enable_command_last_block_d1 == 1)
    begin
      command_last_block_d1 <= command_last_block;
    end
  end



  // state 0 --> enable length_counter and length_downcounter
  // state 1 --> enable command_address and compare_d1
  // state 2 --> enable command_length_d1 and command_last_block_d1
  // state 3 --> enable fifo_write
  // when transitioning from state 3 back to 0 the command has been written to the FIFO
  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      state <= 0;
    end
    else
    begin
      if (initialize == 1)
      begin
        state <= 4'b0010;                   // state[0] is used to increment/decrement length_counter and length_downcounter so we can skip this state the first time through 
      end
      else if (flush_state_pipeline == 1)   // last command has been sent to FIFO, stop issuing commands
      begin
        state <= 0;
      end
      else if (fifo_full == 0)
      begin
        state <= {state[2:0], state[3]};    // simple ring based state machine
      end
    end
  end


  assign initialize = (enable == 1) & (enable_d1 == 0);

  assign increment_length_counter = (enable == 1) & (state[0] == 1) & (fifo_full == 0);
  assign decrement_length_downcounter = (enable == 1) & (state[0] == 1) & (fifo_full == 0);

  assign enable_command_address = (enable == 1) & (state[1] == 1) & (fifo_full == 0);
  assign enable_compare_d1 = (enable == 1) & (state[1] == 1) & (fifo_full == 0);

  assign enable_command_length_d1 = (enable == 1) & (state[2] == 1) & (fifo_full == 0);
  assign enable_command_last_block_d1 = (enable == 1) & (state[2] == 1) & (fifo_full == 0);

  assign compare = (length_downcounter <= block_size);
  assign command_length = (compare_d1 == 1)? length_downcounter[23:0] : block_size;
  assign command_last_block = (compare_d1 == 1);

  assign flush_state_pipeline = (fifo_write == 1) & (command_last_block_d1 == 1);

  assign fifo_command_address = command_address;
  assign fifo_command_length = command_length_d1;
  assign fifo_last_command = command_last_block_d1;
  assign fifo_write = (enable == 1) & (state[3] == 1) & (fifo_full == 0);

endmodule
