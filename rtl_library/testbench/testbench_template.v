//                              -*- Mode: Verilog -*-
// Filename        : testbench_fifo.v
// Description     : Testbench for FIFO
// Author          : Philip Tracton
// Created On      : Tue May 27 17:04:38 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 17:04:38 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!
module testbench_fifo (/*AUTOARG*/ ) ;

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


   //---------------------------------------------------------------------------
   //
   // TEST CASES
   // 
   //---------------------------------------------------------------------------
   initial begin

      #5 @(negedge RESET);
      $display("RESET RELEASED @ %d", $time);
         
      repeat (10) @(posedge  CLK);
      $display("SIM COMPLETE @ %d", $time);      
      $finish;
   end
   
endmodule // testbench_fifo
