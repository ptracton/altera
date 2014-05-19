//                              -*- Mode: Verilog -*-
// Filename        : adc_128s022.v
// Description     : ADC128S022 8 channel, 50ksps 12 bit AD Converter
// Author          : Philip Tracton
// Created On      : Mon May 19 17:11:32 2014
// Last Modified By: Philip Tracton
// Last Modified On: Mon May 19 17:11:32 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module adc_128s022 (/*AUTOARG*/
   // Outputs
   ADC_SDAT,
   // Inputs
   ADC_CS_N, ADC_SADDR, ADC_SCLK, ADC_IN
   ) ;

   input ADC_CS_N;
   input ADC_SADDR;
   output ADC_SDAT;
   input  ADC_SCLK;
   
   input [7:0]  ADC_IN;
   
endmodule // adc_128s022
