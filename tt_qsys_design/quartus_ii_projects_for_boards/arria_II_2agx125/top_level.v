module top_level (
   input clk,
   input reset_n,

   inout [7:0] sdram_mem_dq,
   inout sdram_mem_dqs,
   inout sdram_mem_dqs_n,
   inout [1:0] sdram_mem_clk,
   inout [1:0] sdram_mem_clk_n,
   output [12:0] sdram_mem_addr,
   output sdram_mem_cke,
   output [2:0] sdram_mem_ba,
   output sdram_mem_ras_n,
   output sdram_mem_cas_n,
   output sdram_mem_we_n,
   output sdram_mem_cs_n,
   output [1:0] sdram_mem_dm,
   output sdram_mem_odt
);

   top_system the_top_system(
      .reset_n_reset_n          (reset_n),
	.clk_clk                  (clk),
	.sdram_mem_cs_n           (sdram_mem_cs_n),
	.sdram_mem_ba             (sdram_mem_ba),
	.sdram_mem_ras_n          (sdram_mem_ras_n),
	.sdram_mem_cas_n          (sdram_mem_cas_n),
	.sdram_mem_we_n           (sdram_mem_we_n),
	.sdram_mem_addr           (sdram_mem_addr),
	.sdram_mem_dq             (sdram_mem_dq),
	.sdram_mem_dqs            (sdram_mem_dqs),
	.sdram_mem_dqsn           (sdram_mem_dqs_n),
	.sdram_mem_clk            (sdram_mem_clk),
	.sdram_mem_clk_n          (sdram_mem_clk_n),
	.sdram_mem_cke            (sdram_mem_cke) , 
	.sdram_mem_dm             (sdram_mem_dm),
	.sdram_mem_odt            (sdram_mem_odt) 
);
  
endmodule

