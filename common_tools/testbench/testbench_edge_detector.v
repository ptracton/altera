//                              -*- Mode: Verilog -*-
// Filename        : testbench_edge_detector.v
// Description     : Testbench for Edge Detector
// Author          : Philip Tracton
// Created On      : Tue May 27 14:54:55 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 14:54:55 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module testbench_edge_detector (/*AUTOARG*/ ) ;
   
   //---------------------------------------------------------------------------
   //
   // Free Running Clock
   //
   //---------------------------------------------------------------------------
   wire CLK;
   free_running_clk CLK_50MHZ (.CLK(CLK));

    //---------------------------------------------------------------------------
   //
   // System Reset
   //
   //---------------------------------------------------------------------------
   reg  RESET;
   initial begin
      RESET <= 1'b0;
      repeat (2) @(posedge CLK);
      #3 RESET <= 1'b1;
      repeat (20) @(posedge CLK);
      #2 RESET <= 1'b0;      
   end


   //---------------------------------------------------------------------------
   //   
   // DUT
   //
   //---------------------------------------------------------------------------
   wire RISING_EDGE;
   wire FALLING_EDGE;
   reg  SIGNAL;
   reg 	ENABLE;
   
   
   edged_detector dut(
                      // Outputs
                      .RISING_EDGE(RISING_EDGE), 
                      .FALLING_EDGE(FALLING_EDGE),
                      // Inputs
                      .CLK(CLK),
		      .ENABLE(ENABLE),
                      .RESET(RESET), 
                      .SIGNAL(SIGNAL)
                     ) ;

   //---------------------------------------------------------------------------
   //
   // TEST CASES
   // 
   //---------------------------------------------------------------------------
   initial begin
      SIGNAL <= 1'b0;
      ENABLE <= 1'b0;      
      #5 @(negedge RESET);
      $display("RESET RELEASED @ %d", $time);

      //
      // TEST 1: Rising Edge detection
      //
      ENABLE <= 1'b1;      
      @(posedge CLK);
      #2 SIGNAL <= 1'b1;
      @(posedge RISING_EDGE);
      if (! RISING_EDGE) begin
         $display("RISING EDGE = 0x%h FAIL @ %d", RISING_EDGE, $time);
         $finish;        
      end
      repeat (10) @(posedge  CLK);
      
      //
      // TEST 2: Falling Edge detection
      //
      @(posedge CLK);
      #2 SIGNAL <= 1'b0;
      @(posedge FALLING_EDGE);
      if (! FALLING_EDGE) begin
         $display("FALLING EDGE = 0x%h FAIL @ %d", FALLING_EDGE, $time);
         $finish;        
      end

      //
      // TEST 3: Enable signal operation
      //
      ENABLE <= 1'b0;      
      @(posedge CLK);      
      #2 SIGNAL <= 1'b1;
      @(posedge CLK);
      @(posedge CLK);
      if (RISING_EDGE) begin
         $display("ENABLE RISING EDGE = 0x%h FAIL @ %d", RISING_EDGE, $time);
         $finish;        
      end
      repeat (10) @(posedge  CLK);

      @(posedge CLK);
      #2 SIGNAL <= 1'b0;
      @(posedge CLK);
      @(posedge CLK);
      if (FALLING_EDGE) begin
         $display("ENABLE FALLING EDGE = 0x%h FAIL @ %d", FALLING_EDGE, $time);
         $finish;        
      end
      

      
      repeat (10) @(posedge  CLK);
      $display("SIM COMPLETE @ %d", $time);      
      $finish;
      
   end
   
   
endmodule // testbench_edge_detector
