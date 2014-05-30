//                              -*- Mode: Verilog -*-
// Filename        : testbench_cross_clock_domains.v
// Description     : Testbench for Cross Clock Domains
// Author          : Philip Tracton
// Created On      : Tue May 27 15:54:47 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 27 15:54:47 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!
module testbench_cross_clock_domains (/*AUTOARG*/ ) ;

   //---------------------------------------------------------------------------
   //
   // Free Running Clocks
   //
   //---------------------------------------------------------------------------
   wire CLK_SRC;
   wire CLK_DST;
   free_running_clk CLK_SRC (.CLK(CLK_SRC));
   free_running_clk CLK_DST (.CLK(CLK_SRC));

   
endmodule // testbench_cross_clock_domains
