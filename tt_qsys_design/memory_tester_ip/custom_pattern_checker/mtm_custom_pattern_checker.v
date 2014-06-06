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

Custom pattern checker core


Description:  This component is programmed via a host or master through the pattern slave port to program the internal test memory.  When the host
              writes to the start bit of the CSR slave port the component will begin to send the contents from the internal memory to the data streaming
              port.  You should use the custom pattern generator component with this component.

Register map:

|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|  Address   |   Access Type   |                                                            Bits                                                        |
|            |                 |------------------------------------------------------------------------------------------------------------------------|
|            |                 |            31..24            |            23..16            |            15..8            |            7..0            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|
|     0      |       r/w       |                                                       Payload Length                                                   |
|     4      |       r/w       |                        Pattern Position                                             Pattern Length                     |
|     8      |       r/w       |                           Run                                              Stop on Failure     Infinite Payload Length |
|     12     |      r/clr      |                                                                                                       Failure Detected |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|


Address 0  --> Bits 31:0 are used store the payload length as well as read it back while the checker core is operating.  This field should only be written to while
               the checker is stopped.
Address 4  --> Bits 15:0 is used to store pattern length, bits 31:16 used to store a new position in the pattern.  The position will update as the checker is operating.
               These fields should only be written to while the checker core is stopped.
Address 8  --> Bit 0 is used tell the checker to ignore the payload length field and generate the pattern until stopped.  Bit 8 is used to stop the checker when a failure
               is detected and bit 24 is used to start the checker core so that it begins receiving data.  The run field must be accessed at the same time as the other
               two bits or later.
Address 12 --> Bit 0 is used to read back the failure status as well as clear the failure bit


Author:             JCJB
Initial release:    04/14/2010

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_custom_pattern_checker (
  clk,
  reset,

  csr_address,
  csr_writedata,
  csr_write,
  csr_readdata,
  csr_read,
  csr_byteenable,

  pattern_address,
  pattern_writedata,
  pattern_write,
  pattern_byteenable,

  snk_data,
  snk_valid,
  snk_ready
);


  parameter DATA_WIDTH = 32;          // must be an even multiple of 8 and is used to determine the width of the 2nd port of the on-chip RAM
  parameter MAX_PATTERN_LENGTH = 64;  // used to determine the depth of the on-chip RAM and modulo counter width, set to a multiple of 2
  parameter ADDRESS_WIDTH = 6;

  localparam NUM_OF_SYMBOLS = DATA_WIDTH / 8;


  input clk;
  input reset;

  input [1:0] csr_address;
  input [31:0] csr_writedata;
  input csr_write;
  output wire [31:0] csr_readdata;
  input csr_read;
  input [3:0] csr_byteenable;

  input [ADDRESS_WIDTH-1:0] pattern_address;
  input [DATA_WIDTH-1:0] pattern_writedata;
  input pattern_write;
  input [(DATA_WIDTH/8)-1:0] pattern_byteenable;

  input [DATA_WIDTH-1:0] snk_data;
  input snk_valid;
  output wire snk_ready;

  // internal registers and wires
  reg [31:0] payload_length_counter;
  wire load_payload_length_counter;
  wire [3:0] load_payload_length_counter_lanes;
  reg [15:0] pattern_length;
  wire load_pattern_length;
  wire [1:0] load_pattern_length_lanes;
  reg [15:0] pattern_position_counter;
  wire load_pattern_position_counter;
  wire [1:0] load_pattern_position_counter_lanes;
  reg infinite_payload_length;
  wire load_infinite_payload_length;
  reg stop_on_failure;
  wire load_stop_on_failure;
  reg start;
  wire load_start;
  wire clear_start;
  reg failure_detected;
  wire set_failure_detected;
  wire clear_failure_detected;

  reg [ADDRESS_WIDTH-1:0] pattern_length_minus_one;
  wire increment_pattern_position_counter;
  wire decrement_payload_length_counter;
  wire [ADDRESS_WIDTH-1:0] internal_memory_address;
  wire data_compare;
  reg data_compare_d1;
  wire [DATA_WIDTH-1:0] data_in;
  reg [DATA_WIDTH-1:0] data_in_d1;
  reg [DATA_WIDTH-1:0] data_in_d2;
  reg [DATA_WIDTH-1:0] data_in_d3;
  wire valid_data;
  reg valid_data_d1;
  reg valid_data_d2;
  reg valid_data_d3;
  reg valid_data_d4;
  wire [DATA_WIDTH-1:0] memory_data;
  reg [DATA_WIDTH-1:0] memory_data_d1;
  reg [31:0] readback_mux;
  reg [31:0] readback_mux_d1;



  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      start <= 0;
      pattern_length_minus_one <= 0;
    end
    else
    begin
      if (clear_start == 1)
      begin
        start <= 0;
      end
      else if (load_start == 1)
      begin
        start <= csr_writedata[24];
        pattern_length_minus_one <= (pattern_length - 1'b1);
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      stop_on_failure <= 0;
    end
    else if (load_stop_on_failure == 1)
    begin
      stop_on_failure <= csr_writedata[8];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      payload_length_counter <= 0;
    end
    else 
    begin
      if (load_payload_length_counter == 1)
      begin
        if (load_payload_length_counter_lanes[0] == 1)
        begin
          payload_length_counter[7:0] <= csr_writedata[7:0];
        end
        if (load_payload_length_counter_lanes[1] == 1)
        begin
          payload_length_counter[15:8] <= csr_writedata[15:8];
        end
        if (load_payload_length_counter_lanes[2] == 1)
        begin
          payload_length_counter[23:16] <= csr_writedata[23:16];
        end
        if (load_payload_length_counter_lanes[3] == 1)
        begin
          payload_length_counter[31:24] <= csr_writedata[31:24];
        end
      end
      else if (decrement_payload_length_counter == 1)
      begin
        payload_length_counter <= payload_length_counter - NUM_OF_SYMBOLS;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pattern_length <= 0;
    end
    else
    begin
      if (load_pattern_length == 1)
      begin
        if (load_pattern_length_lanes[0] == 1)
        begin
          pattern_length[7:0] <= csr_writedata[7:0];
        end
        if (load_pattern_length_lanes[1] == 1)
        begin
          pattern_length[15:8] <= csr_writedata[15:8];
        end
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      pattern_position_counter <= 0;
    end
    else
    begin
      if (load_pattern_position_counter == 1)
      begin
        if (load_pattern_position_counter_lanes[0] == 1)
        begin
          pattern_position_counter[7:0] <= csr_writedata[23:16];
        end
        if (load_pattern_position_counter_lanes[1] == 1)
        begin
          pattern_position_counter[15:8] <= csr_writedata[31:24];
        end
      end
      else if (increment_pattern_position_counter == 1)
      begin
        pattern_position_counter[ADDRESS_WIDTH-1:0] <= (pattern_position_counter[ADDRESS_WIDTH-1:0] == pattern_length_minus_one)? 0 : (pattern_position_counter[ADDRESS_WIDTH-1:0] + 1'b1);
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      infinite_payload_length <= 0;
    end
    else if (load_infinite_payload_length == 1)
    begin
      infinite_payload_length <= csr_writedata[0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      failure_detected <= 0;
    end
    else
    begin
      if (set_failure_detected == 1)
      begin
        failure_detected <= 1;
      end
      else if (clear_failure_detected == 1)
      begin
        failure_detected <= 0;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      readback_mux_d1 <= 0;
    end
    else if (csr_read == 1)
    begin
      readback_mux_d1 <= readback_mux;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      data_in_d1 <= 0;
      data_in_d2 <= 0;
      data_in_d3 <= 0;
      valid_data_d1 <= 0;
      valid_data_d2 <= 0;
      valid_data_d3 <= 0;
      valid_data_d4 <= 0;
      data_compare_d1 <= 0;
    end
    else
    begin
      data_in_d1 <= data_in;
      data_in_d2 <= data_in_d1;
      data_in_d3 <= data_in_d2;
      valid_data_d1 <= valid_data;
      valid_data_d2 <= valid_data_d1;
      valid_data_d3 <= valid_data_d2;
      valid_data_d4 <= valid_data_d3;
      data_compare_d1 <= data_compare;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      memory_data_d1 <= 0;
    end
    else if (valid_data_d2 == 1)
    begin
      memory_data_d1 <= memory_data;
    end
  end


  // Port A used to access pattern from slave port, Port B used to send data out the source port
  altsyncram pattern_memory (
    .clock0 (clk),
    .data_a (pattern_writedata),
    .wren_a (pattern_write),
    .byteena_a (pattern_byteenable),
    .address_a (pattern_address),
    .address_b (internal_memory_address),
    .q_b (memory_data)
  );
  defparam pattern_memory.operation_mode = "DUAL_PORT";
  defparam pattern_memory.lpm_type = "altsyncram";
  defparam pattern_memory.read_during_write_mode_mixed_ports = "DONT_CARE";
  defparam pattern_memory.power_up_uninitialized = "TRUE";
  defparam pattern_memory.byte_size = 8;
  defparam pattern_memory.width_a = DATA_WIDTH;
  defparam pattern_memory.width_b = DATA_WIDTH;
  defparam pattern_memory.widthad_a = ADDRESS_WIDTH;
  defparam pattern_memory.widthad_b = ADDRESS_WIDTH;
  defparam pattern_memory.width_byteena_a = (DATA_WIDTH/8);
  defparam pattern_memory.numwords_a = MAX_PATTERN_LENGTH;
  defparam pattern_memory.numwords_b = MAX_PATTERN_LENGTH;
  defparam pattern_memory.address_reg_b = "CLOCK0";
  defparam pattern_memory.outdata_reg_b = "CLOCK0";



  always @ (csr_address or payload_length_counter or pattern_length or pattern_position_counter or infinite_payload_length or stop_on_failure or start or failure_detected)
  begin
    case (csr_address)
      2'b00: readback_mux = payload_length_counter;
      2'b01: readback_mux = {pattern_position_counter, pattern_length};
      2'b10: readback_mux = {{7{1'b0}}, start, {15{1'b0}}, stop_on_failure, {7{1'b0}}, infinite_payload_length};
      2'b11: readback_mux = {{31{1'b0}}, failure_detected};
    endcase
  end


genvar i;
generate
  for (i = 0; i < NUM_OF_SYMBOLS; i = i + 1)
  begin : byte_reversal
    assign data_in[((8*(i+1))-1):(8*i)] = snk_data[((8*((NUM_OF_SYMBOLS-1-i)+1))-1):(8*(NUM_OF_SYMBOLS-1-i))];
  end
endgenerate




  assign load_payload_length_counter = (csr_address == 0) & (csr_write == 1);
  assign load_payload_length_counter_lanes = csr_byteenable;
  assign load_pattern_length = (csr_address == 1) & (csr_write == 1) & (csr_byteenable[1:0] != 0);
  assign load_pattern_length_lanes = csr_byteenable[1:0];
  assign load_pattern_position_counter = (csr_address == 1) & (csr_write == 1) & (csr_byteenable[3:2] != 0);
  assign load_pattern_position_counter_lanes = csr_byteenable[3:2];
  assign load_infinite_payload_length = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[0] == 1);
  assign load_stop_on_failure = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[1] == 1);
  assign load_start = (csr_address == 2) & (csr_write == 1) & (csr_byteenable[3] == 1);


  assign increment_pattern_position_counter = (start == 1) & (snk_valid == 1);
  assign decrement_payload_length_counter = (start == 1) & (snk_valid == 1) & (infinite_payload_length == 0);
  assign clear_start = (start == 1) & (((failure_detected == 1) & (stop_on_failure == 1)) | ((infinite_payload_length == 0) & (payload_length_counter == 0)));
  assign snk_ready = (start == 1);
  assign internal_memory_address = pattern_position_counter[ADDRESS_WIDTH-1:0];

  assign valid_data = (snk_valid == 1) & (snk_ready == 1);
  assign data_compare = (memory_data_d1 == data_in_d3);
  assign set_failure_detected = (data_compare_d1 == 0) & (valid_data_d4 == 1);
  assign clear_failure_detected = (csr_address == 3) & (csr_write == 1) & (csr_byteenable[0] == 1) & (csr_writedata[0] == 1);

  assign csr_readdata = readback_mux_d1;

endmodule
