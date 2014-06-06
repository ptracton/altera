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

2:1 streaming mux core


Description:	The component is controlled by a host or master through the CSR slave port to control which streaming data input will be routed
                to the streaming data output.

Register map:

             Access Type                                      Bits
                               31..24               23..16                15..8                7..0
Address 0         w              N/A                  N/A             clear pipeline       input select
Address 4         r              N/A                  N/A              pending data       selected input

Each control and status value is a single bit aligned to the lowest bit of the byte lane (bits 0 or 8).
Input select == 0 --> input A is selected otherwise input B is selected.


Author: JCJB

Initial release 1.0: 03/25/2010

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_two_to_one_st_mux (
  clk,
  reset,

  address,
  readdata,
  read,
  writedata,
  write,
  byteenable,

  snk_data_A,
  snk_ready_A,
  snk_valid_A,

  snk_data_B,
  snk_ready_B,
  snk_valid_B,

  src_data,
  src_ready,
  src_valid
);


  parameter DATA_WIDTH = 32;


  input clk;
  input reset;

  input address;  // only two addresses (control and status)
  output wire [31:0] readdata;
  input read;
  input [31:0] writedata;
  input write;
  input [3:0] byteenable;

  input [DATA_WIDTH-1:0] snk_data_A;
  output wire snk_ready_A;
  input snk_valid_A;

  input [DATA_WIDTH-1:0] snk_data_B;
  output wire snk_ready_B;
  input snk_valid_B;

  output wire [DATA_WIDTH-1:0] src_data;
  input src_ready;
  output wire src_valid;


  // registers and signals for the slave port
  wire enable_input_select;
  reg input_select;
  wire clear_pipeline;
  wire pending_data;

  // internal pipelining registers and signals
  reg [DATA_WIDTH-1:0] data_out;
  reg valid_out;
  wire pipeline_ready;
  wire pipeline_enable;





  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      input_select <= 0;
    end
    else if (enable_input_select == 1)
    begin
      input_select <= writedata[0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      data_out <= 0;
    end
    else if (pipeline_enable == 1) 
    begin
      data_out <= (input_select == 0)? snk_data_A : snk_data_B;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      valid_out <= 0;
    end
    else
    begin
      if (clear_pipeline == 1)
      begin
        valid_out <= 0;
      end
      else if (pipeline_ready == 1)
      begin
        valid_out <= pipeline_enable;
      end
    end
  end


  assign enable_input_select = (address == 0) & (write == 1) & (byteenable[0] == 1);
  assign clear_pipeline = (address == 0) & (write == 1) & (byteenable[1] == 1) & (writedata[8] == 1);  // want this to be a single cycle strobe to clear the pipeline valid register
  assign pending_data = ((valid_out == 1) & (src_ready == 1)) | (pipeline_enable == 1);
  assign readdata = {{23{1'b0}}, pending_data, {7{1'b0}}, input_select};

  assign src_valid = valid_out;
  assign src_data = data_out;

  assign pipeline_ready = (valid_out == 0) | ((src_ready == 1) & (valid_out == 1));
  assign pipeline_enable = ((input_select == 0) & (pipeline_ready == 1) & (snk_valid_A == 1)) |
                           ((input_select == 1) & (pipeline_ready == 1) & (snk_valid_B == 1));
  assign snk_ready_A = (input_select == 0) & (pipeline_ready == 1);
  assign snk_ready_B = (input_select == 1) & (pipeline_ready == 1);

endmodule
