module top_level (
  input clk,
  input reset_n,

  inout  [7:0] sdram_dq,
  inout  sdram_dqs,
  inout  sdram_dqs_n,
  output sdram_ck,
  output sdram_ck_n,
  output sdram_cke,
  output sdram_ras_n,
  output sdram_cas_n,
  output [2:0] sdram_ba,
  output [12:0] sdram_a,
  output sdram_cs_n,
  output sdram_dm,
  output sdram_we_n,
  output sdram_odt,
  input  sdram_oct_rdn,
  input  sdram_oct_rup
);

  top_system the_top_system(
		.reset_n_reset_n              (reset_n),
		.clk_clk                      (clk),
      .memory_mem_dqs               (sdram_dqs),
		.memory_mem_cas_n             (sdram_cas_n),
		.memory_mem_dqs_n             (sdram_dqs_n),
		.memory_mem_ck_n              (sdram_ck_n),
		.memory_mem_reset_n           (),
		.memory_mem_cke               (sdram_cke),
		.memory_mem_ras_n             (sdram_ras_n),
		.memory_mem_ck                (sdram_ck),
		.memory_mem_ba                (sdram_ba),
		.memory_mem_odt               (sdram_odt),
		.memory_mem_a                 (sdram_a),
		.memory_mem_cs_n              (sdram_cs_n),
		.memory_mem_dm                (sdram_dm),
		.memory_mem_dq                (sdram_dq),
		.memory_mem_we_n              (sdram_we_n),
		.oct_rdn                      (sdram_oct_rdn),
		.oct_rup                      (sdram_oct_rup)
  );
  
endmodule
