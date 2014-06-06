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

1:2 streaming demux core


Description:	The component is controlled by a host or master through the CSR slave port to control which streaming data output the input
                streaming data will be routed to.


Register map:

             Access Type                                      Bits
                               31..24               23..16                15..8                7..0
Address 0         w              N/A                  N/A             clear pipeline       output select
Address 4         r              N/A                  N/A              pending data       selected output

Each control and status value is a single bit aligned to the lowest bit of the byte lane (bits 0 or 8).
Output select == 0 --> output A is selected otherwise output B is selected.
Pending data has two bits since there are two outputs.  Bit 8 represents the A output containing pending data.
Bit 9 represents the B output containing pending data.


Author:         JCJB

Initial release 1.0:    03/25/2010

*/


// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// turn off superfluous verilog processor warnings 
// altera message_level Level1 
// altera message_off 10230


module mtm_one_to_two_st_demux (
  clk,
  reset,

  address,
  readdata,
  read,
  writedata,
  write,
  byteenable,

  snk_data,
  snk_ready,
  snk_valid,
  
  src_data_A,
  src_ready_A,
  src_valid_A,

  src_data_B,
  src_ready_B,
  src_valid_B
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

  input [DATA_WIDTH-1:0] snk_data;
  output wire snk_ready;
  input snk_valid;
  
  output wire [DATA_WIDTH-1:0] src_data_A;
  input src_ready_A;
  output wire src_valid_A;

  output wire [DATA_WIDTH-1:0] src_data_B;
  input src_ready_B;
  output wire src_valid_B;


  // registers and signals for the slave port
  wire enable_output_select;
  reg output_select;
  wire clear_pipeline;
  wire pending_data_A;
  wire pending_data_B;

  // internal pipelining registers and signals
  reg [DATA_WIDTH-1:0] data_out_A;
  reg valid_out_A;
  reg [DATA_WIDTH-1:0] data_out_B;
  reg valid_out_B;
  wire pipeline_ready_A;
  wire pipeline_ready_B;
  wire pipeline_enable_A;
  wire pipeline_enable_B;





  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      output_select <= 0;
    end
    else if (enable_output_select == 1)
    begin
      output_select <= writedata[0];
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      data_out_A <= 0;
    end
    else if (pipeline_enable_A == 1)
    begin
      data_out_A <= snk_data;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      data_out_B <= 0;
    end
    else if (pipeline_enable_B == 1)
    begin
      data_out_B <= snk_data;
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      valid_out_A <= 0;
    end
    else
    begin
      if (clear_pipeline == 1)
      begin
        valid_out_A <= 0;
      end
      else if (pipeline_ready_A == 1)
      begin
        valid_out_A <= pipeline_enable_A;
      end
    end
  end


  always @ (posedge clk or posedge reset)
  begin
    if (reset == 1)
    begin
      valid_out_B <= 0;
    end
    else
    begin
      if (clear_pipeline == 1)
      begin
        valid_out_B <= 0;
      end
      else if (pipeline_ready_B == 1)
      begin
        valid_out_B <= pipeline_enable_B;
      end
    end
  end


  assign enable_output_select = (address == 0) & (write == 1) & (byteenable[0] == 1);
  assign clear_pipeline = (address == 0) & (write == 1) & (byteenable[1] == 1) & (writedata[8] == 1);  // want this to be a single cycle strobe to clear the pipeline valid register
  assign pending_data_A = ((valid_out_A == 1) & (src_ready_A == 1)) | (pipeline_enable_A == 1);
  assign pending_data_B = ((valid_out_B == 1) & (src_ready_B == 1)) | (pipeline_enable_B == 1);
  assign readdata = {{22{1'b0}}, pending_data_B, pending_data_A, {7{1'b0}}, output_select};

  assign src_valid_A = valid_out_A;
  assign src_data_A = data_out_A;
  assign src_valid_B = valid_out_B;
  assign src_data_B = data_out_B;

  assign pipeline_ready_A = (valid_out_A == 0) | ((src_ready_A == 1) & (valid_out_A == 1));
  assign pipeline_enable_A = (output_select == 0) & (pipeline_ready_A == 1) & (snk_valid == 1);

  assign pipeline_ready_B = (valid_out_B == 0) | ((src_ready_B == 1) & (valid_out_B == 1));
  assign pipeline_enable_B = (output_select == 1) & (pipeline_ready_B == 1) & (snk_valid == 1);

  assign snk_ready = ((output_select == 0) & (pipeline_ready_A == 1)) | 
                     ((output_select == 1) & (pipeline_ready_B == 1));

endmodule
