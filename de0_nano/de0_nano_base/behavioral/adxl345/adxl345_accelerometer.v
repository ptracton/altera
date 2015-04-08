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

   //
   // I2C Interface
   //
   wire   i2c_sdata;
   wire [7:0] i2c_read_data;
   wire [7:0] i2c_write_data;
   wire       i2c_read;
   wire       i2c_write;
   
   adxl345_i2c i2c(
		   // Outputs
		   .sdata_oe		(sdata_oe),
		   .write		(i2c_write),
		   .read		(i2c_read),
		   .write_data		(i2c_write_data[7:0]),
		   // Inouts
		   .sdata		(i2c_sdata),
		   // Inputs
		   .sclk		(G_SENSOR_SCLK),
		   .read_data		(i2c_read_data[7:0]));
   
   
endmodule // adxl345_accelerometer
