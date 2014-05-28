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
   wire [31:0] DATA_OUT;
   wire        FULL;
   wire        EMPTY;

   reg 	       FLUSH;
   reg 	       ENABLE;
   reg [31:0]  DATA_IN;
   reg 	       PUSH;
   reg 	       POP;
   
   fifo dut(
	    // Outputs
	    .DATA_OUT(), 
	    .FULL(), 
	    .EMPTY(),
	    // Inputs
	    .CLK(CLK), 
	    .RESET(RESET), 
	    .ENABLE(ENABLE), 
	    .FLUSH(FLUSH), 
	    .DATA_IN(DATA_IN), 
	    .PUSH(PUSH), 
	    .POP(POP)
	    ) ;

   //---------------------------------------------------------------------------
   //
   // TASKS
   // 
   //---------------------------------------------------------------------------
   task push_data;
      input [31:0] data;
      begin
	 PUSH <= 1'b0;
	 @(posedge CLK);
	 DATA_IN <= data;
	 PUSH <= 1'b1;
	 @(posedge CLK);
	 PUSH <= 1'b0;
	 DATA_IN <= $random;
	 if (EMPTY) begin
	    $display("PUSH_DATA: EMPTY ERROR %d @ %d", EMPTY, $time);
	    $finish;	 
	 end	 
      end
   endtask //

   task pop_data;
      input [31:0] expected;
      begin
	 POP <= 1'b0;
	 @(posedge CLK);
	 if (DATA_OUT != expected) begin
	    $display("POP_DATA: 0x%h != 0x%h @ %d",expected, DATA_OUT, $time);
	    $finish;	    
	 end
	 POP <= 1'b1;
	 @(posedge CLK);
	 POP <= 1'b0;	 
      end
   endtask //

   task flush;
      begin
	 FLUSH <= 1'b0;
	 @(posedge CLK);
	 FLUSH <= 1'b1;
	 @(posedge CLK);
	 FLUSH <= 1'b0;
      end
   endtask //
   
   
   //---------------------------------------------------------------------------
   //
   // TEST CASES
   // 
   //---------------------------------------------------------------------------
   initial begin
      FLUSH <= 1'b0;
      ENABLE <= 1'b0;
      DATA_IN <= 32'b0;
      PUSH <= 1'b0;
      POP <= 1'b0;
      
      #5 @(negedge RESET);
      $display("RESET RELEASED @ %d", $time);
      repeat (10) @(posedge  CLK);


      ENABLE <= 1'b1;      
      push_data(32'hAAAA_5555);
      push_data(32'hBBBB_6666);
      push_data(32'hCCCC_7777);
      push_data(32'hDDDD_8888);
      push_data(32'hAAAA_5555);
      push_data(32'hBBBB_6666);
      push_data(32'hCCCC_7777);
      push_data(32'hDDDD_8888);
      push_data(32'h0123_4567);
      

      pop_data(32'hAAAA_5555);
      pop_data(32'hBBBB_6666);
      pop_data(32'hCCCC_7777);
      pop_data(32'hDDDD_8888);
      pop_data(32'hAAAA_5555);
      pop_data(32'hBBBB_6666);
      pop_data(32'hCCCC_7777);
      pop_data(32'hDDDD_8888);

      flush();
      pop_data(32'h0);
      
      if (DATA_OUT != DATA_IN) begin
	 $display("DATA ERROR 0x%h != 0x%h @ %d", DATA_OUT, DATA_IN, $time);
	 $finish;	 
      end

      
      repeat (10) @(posedge  CLK);
      $display("SIM COMPLETE @ %d", $time);      
      $finish;
   end
   
endmodule // testbench_fifo
