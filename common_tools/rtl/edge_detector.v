//                              -*- Mode: Verilog -*-
// Filename        : edge_detector.v
// Description     : Edge Detection
// Author          : Philip Tracton
// Created On      : Tue May 27 14:51:21 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 14:51:21 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module edged_detector (/*AUTOARG*/
   // Outputs
   RISING_EDGE, FALLING_EDGE,
   // Inputs
   CLK, RESET, ENABLE, SIGNAL
   ) ;

   //---------------------------------------------------------------------------
   //
   // PARAMETERS
   //
   //---------------------------------------------------------------------------

   //---------------------------------------------------------------------------
   //
   // PORTS
   //
   //---------------------------------------------------------------------------
   
   input CLK;              // Clock for sampling the input SIGNAL
   input RESET;            // Clock Synchronous Active High
   input ENABLE;           // When asserted (1) this block is active, else block is not active   
   input SIGNAL;           // The signal we are watching for state change
   output RISING_EDGE;     // Asserted when the input SIGNAL goes from 0 --> 1
   output FALLING_EDGE;    // Asserted when the input SIGNAL goes from 1 --> 0


   //---------------------------------------------------------------------------
   //
   // Registers 
   //
   //---------------------------------------------------------------------------
   
   reg [1:0] previous;
   
   //---------------------------------------------------------------------------
   //
   // WIRES
   //
   //---------------------------------------------------------------------------
   wire      FALLING_EDGE;
   wire      RISING_EDGE;
   
   
   //---------------------------------------------------------------------------
   //
   // COMBINATIONAL LOGIC
   //
   //---------------------------------------------------------------------------
   
   //
   // FALLING EDGE is when the new signal (previous[0]) is low (falling) and the
   // previous state of the signal is high.
   //
   assign FALLING_EDGE = ((!previous[0]) && (previous[1]) && ENABLE);

   //
   // RISING EDGE is when the new signal (previous[0]) is high (rising) and the
   // the previous state of the signal is low
   //
   assign RISING_EDGE  = ((previous[0])  && (!previous[1]) && ENABLE);


   //---------------------------------------------------------------------------
   //
   // SEQUENTIAL LOGIC
   //
   //---------------------------------------------------------------------------
   
   //
   // Sample the input and hold the last 2 clocks worth of value.
   // We want to detect between the 2 previous signals to ensure
   // that we hold the output values for a full clock cyle.
   // 
   //
   always @(posedge CLK)
     if (RESET) begin
        previous <= 2'b0;       
     end else if (ENABLE) begin
        previous[0] <= SIGNAL;
	previous[1] <= previous[0];	
     end
   
endmodule // edged_detector
