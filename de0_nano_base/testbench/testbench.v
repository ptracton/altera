//                              -*- Mode: Verilog -*-
// Filename        : testbench.v
// Description     : Altera DE 0 Nano Board Testbench
// Author          : Philip Tracton
// Created On      : Mon May 19 16:15:19 2014
// Last Modified By: Philip Tracton
// Last Modified On: Mon May 19 16:15:19 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

`timescale 1ns/1ps

module testbench (/*AUTOARG*/) ;


   // 
   // 50 MHz Oscillator Clock
   //
   reg CLOCK_50;
   initial begin
      CLOCK_50 <= 1'b0;
      forever begin
	 #5 CLOCK_50 <= 1'b1;
	 #5 CLOCK_50 <= 1'b0;
      end
   end

   //
   // System Reset
   //
   reg reset;
   initial begin
      reset <= 1'b0;
      #12 reset <= 1'b1;
      repeat (5) @(posedge CLOCK_50);
      #3 reset <= 1'b0;      
   end

   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			ADC_CS_N;		// From dut of de0_nano.v
   wire			ADC_SADDR;		// From dut of de0_nano.v
   wire			ADC_SCLK;		// From dut of de0_nano.v
   wire			ADC_SDAT;		// From adc of adc_128s022.v
   wire [12:0]		DRAM_ADDR;		// From dut of de0_nano.v
   wire [1:0]		DRAM_BA;		// From dut of de0_nano.v
   wire			DRAM_CAS_N;		// From dut of de0_nano.v
   wire			DRAM_CKE;		// From dut of de0_nano.v
   wire			DRAM_CLK;		// From dut of de0_nano.v
   wire			DRAM_CS_N;		// From dut of de0_nano.v
   wire [15:0]		DRAM_DQ;		// To/From dut of de0_nano.v, ...
   wire [1:0]		DRAM_DQM;		// From dut of de0_nano.v
   wire			DRAM_RAS_N;		// From dut of de0_nano.v
   wire			DRAM_WE_N;		// From dut of de0_nano.v
   wire			EPCS_ASDO;		// From dut of de0_nano.v
   wire			EPCS_DCLK;		// From dut of de0_nano.v
   wire			EPCS_NCSO;		// From dut of de0_nano.v
   wire [33:0]		GPIO_0;			// To/From dut of de0_nano.v
   wire [33:0]		GPIO_1;			// To/From dut of de0_nano.v
   wire [12:0]		GPIO_2;			// To/From dut of de0_nano.v
   wire			G_SENSOR_CS_N;		// From dut of de0_nano.v
   wire			G_SENSOR_INT2;		// From accelerometer of adxl345_accelerometer.v
   wire			G_SENSOR_SDA_SDIO;	// To/From accelerometer of adxl345_accelerometer.v
   wire			G_SENSOR_SDO;		// To/From accelerometer of adxl345_accelerometer.v
   wire			I2C_SCLK;		// From dut of de0_nano.v
   wire			I2C_SDAT;		// To/From dut of de0_nano.v, ...
   wire [7:0]		LED;			// From dut of de0_nano.v
   // End of automatics
   /*AUTOREG*/

   wire [1:0] 		KEY;
   reg [1:0] 		KEY_reg;
   reg [3:0] 		SW;
   wire 		G_SENSOR_INT;
   reg [2:0] 		GPIO_2_IN;
   reg [1:0] 		GPIO_1_IN;
   reg [1:0] 		GPIO_0_IN;
   
   
   //
   // DE 0 NANO FPGA 
   //
   de0_nano dut(/*AUTOINST*/
		// Outputs
		.LED			(LED[7:0]),
		.DRAM_ADDR		(DRAM_ADDR[12:0]),
		.DRAM_BA		(DRAM_BA[1:0]),
		.DRAM_CAS_N		(DRAM_CAS_N),
		.DRAM_CKE		(DRAM_CKE),
		.DRAM_CLK		(DRAM_CLK),
		.DRAM_CS_N		(DRAM_CS_N),
		.DRAM_DQM		(DRAM_DQM[1:0]),
		.DRAM_RAS_N		(DRAM_RAS_N),
		.DRAM_WE_N		(DRAM_WE_N),
		.EPCS_ASDO		(EPCS_ASDO),
		.EPCS_DCLK		(EPCS_DCLK),
		.EPCS_NCSO		(EPCS_NCSO),
		.G_SENSOR_CS_N		(G_SENSOR_CS_N),
		.I2C_SCLK		(I2C_SCLK),
		.ADC_CS_N		(ADC_CS_N),
		.ADC_SADDR		(ADC_SADDR),
		.ADC_SCLK		(ADC_SCLK),
		// Inouts
		.DRAM_DQ		(DRAM_DQ[15:0]),
		.I2C_SDAT		(I2C_SDAT),
		.GPIO_2			(GPIO_2[12:0]),
		.GPIO_0			(GPIO_0[33:0]),
		.GPIO_1			(GPIO_1[33:0]),
		// Inputs
		.CLOCK_50		(CLOCK_50),
		.KEY			(KEY[1:0]),
		.SW			(SW[3:0]),
		.EPCS_DATA0		(EPCS_DATA0),
		.G_SENSOR_INT		(G_SENSOR_INT),
		.ADC_SDAT		(ADC_SDAT),
		.GPIO_2_IN		(GPIO_2_IN[2:0]),
		.GPIO_0_IN		(GPIO_0_IN[1:0]),
		.GPIO_1_IN		(GPIO_1_IN[1:0]));
 
   



   //
   // I2C EEPROM
   //
   M24AA02 eeprom(
		  .A0(1'b0), 
		  .A1(1'b0), 
		  .A2(1'b0), 
		  .WP(1'b0), 
		  .SDA(I2C_SDAT), 
		  .SCL(I2C_SCLK), 
		  .RESET(reset));

   //
   // ADC
   //
   reg [7:0] ADC_IN;
   
   adc_128s022 adc(/*AUTOINST*/
		   // Outputs
		   .ADC_SDAT		(ADC_SDAT),
		   // Inputs
		   .ADC_CS_N		(ADC_CS_N),
		   .ADC_SADDR		(ADC_SADDR),
		   .ADC_SCLK		(ADC_SCLK),
		   .ADC_IN		(ADC_IN[7:0]));


   //
   // Accelerometer
   //
   adxl345_accelerometer accelerometer(/*AUTOINST*/
				       // Outputs
				       .G_SENSOR_INT	(G_SENSOR_INT),
				       .G_SENSOR_INT2	(G_SENSOR_INT2),
				       // Inouts
				       .G_SENSOR_SDA_SDIO(G_SENSOR_SDA_SDIO),
				       .G_SENSOR_SDO	(G_SENSOR_SDO),
				       // Inputs
				       .G_SENSOR_SCLK	(I2C_SCLK),
				       .G_SENSOR_nCS	(G_SENSOR_CS_N));
   

   //
   // SDRAM
   //
   issi_16Mx16_SDRAM sdram(/*AUTOINST*/
			   // Inouts
			   .DRAM_DQ		(DRAM_DQ[15:0]),
			   // Inputs
			   .DRAM_ADDR		(DRAM_ADDR[12:0]),
			   .DRAM_DQM		(DRAM_DQM[1:0]),
			   .DRAM_RAS_N		(DRAM_RAS_N),
			   .DRAM_CAS_N		(DRAM_CAS_N),
			   .DRAM_CKE		(DRAM_CKE),
			   .DRAM_CLK		(DRAM_CLK),
			   .DRAM_WE_N		(DRAM_WE_N),
			   .DRAM_CS_N		(DRAM_CS_N));


   assign KEY[0] = reset;   
   assign KEY[1] = KEY_reg[1];
   
   initial begin
      KEY_reg <=2'b00;      
      SW <= 4'b0;
      ADC_IN <= 8'h0;  
      GPIO_2_IN <= 3'b000;
      GPIO_1_IN <= 2'b00;
      GPIO_0_IN <= 2'b00;
   end

   initial begin
      @(posedge reset);
      $display("RESET RELEASED @ %d", $time);
      repeat(3000) @(posedge CLOCK_50);
      $display("SIMULATION COMPLETE @ %d", $time); 
      $finish;
      
   end
   
endmodule // testbench
