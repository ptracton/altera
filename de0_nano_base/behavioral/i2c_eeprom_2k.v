//                              -*- Mode: Verilog -*-
// Filename        : i2c_eeprom_2k.v
// Description     : Microchip 24AA02 EEPROM Model
// Author          : Philip Tracton
// Created On      : Mon May 19 17:02:03 2014
// Last Modified By: Philip Tracton
// Last Modified On: Mon May 19 17:02:03 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module i2c_eeprom_2k (/*AUTOARG*/
   // Inouts
   I2C_SDAT,
   // Inputs
   I2C_SCLK
   ) ;
   input I2C_SCLK;
   inout I2C_SDAT;
 

   //
   // EEPROM Memory, 8x2k
   // 
   reg [7:0] memory[0:2048];
   
   

   
endmodule // i2c_eeprom_2k
