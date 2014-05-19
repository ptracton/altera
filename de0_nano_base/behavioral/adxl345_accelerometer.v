//                              -*- Mode: Verilog -*-
// Filename        : adxl345_accelerometer.v
// Description     : ADXL345 Digital Accelerometer
// Author          : Philip Tracton
// Created On      : Mon May 19 17:17:07 2014
// Last Modified By: Philip Tracton
// Last Modified On: Mon May 19 17:17:07 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module adxl345_accelerometer (/*AUTOARG*/
   // Outputs
   G_SENSOR_INT, G_SENSOR_INT2,
   // Inouts
   G_SENSOR_SDA_SDIO, G_SENSOR_SDO,
   // Inputs
   G_SENSOR_SCLK, G_SENSOR_nCS
   ) ;

   input G_SENSOR_SCLK;
   input G_SENSOR_nCS;
   inout G_SENSOR_SDA_SDIO;
   inout G_SENSOR_SDO;
   
   
   output G_SENSOR_INT;
   output G_SENSOR_INT2;
   
endmodule // adxl345_accelerometer
