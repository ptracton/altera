//                              -*- Mode: Verilog -*-
// Filename        : issi_16Mx16_SDRAM.v
// Description     : ISSI 16Mx16 SDRAM
// Author          : Philip Tracton
// Created On      : Mon May 19 17:22:17 2014
// Last Modified By: Philip Tracton
// Last Modified On: Mon May 19 17:22:17 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module issi_16Mx16_SDRAM (/*AUTOARG*/
   // Inouts
   DRAM_DQ,
   // Inputs
   DRAM_ADDR, DRAM_DQM, DRAM_RAS_N, DRAM_CAS_N, DRAM_CKE, DRAM_CLK,
   DRAM_WE_N, DRAM_CS_N
   ) ;

   input [12:0]	DRAM_ADDR;  //Pins 0-->P2, N5, N6, M8, P8, T7, N8, T6, R1, P1, N2, N1, L4
   inout [15:0] DRAM_DQ;
   input [1:0] 	DRAM_DQM;
   input 	DRAM_RAS_N;
   input 	DRAM_CAS_N;
   input 	DRAM_CKE;
   input 	DRAM_CLK;
   input 	DRAM_WE_N;
   input 	DRAM_CS_N;
   
   
endmodule // issi_16Mx16_SDRAM
