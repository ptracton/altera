# -------------------------------------------------------------------------- #
#
# Copyright (C) 1991-2013 Altera Corporation
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, Altera MegaCore Function License 
# Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by 
# Altera or its authorized distributors.  Please refer to the 
# applicable agreement for further details.
#
# -------------------------------------------------------------------------- #
#
# Quartus II 32-bit
# Version 13.1.0 Build 162 10/23/2013 SJ Web Edition
# Date created = 16:17:53  June 05, 2014
#
# -------------------------------------------------------------------------- #
#
# Notes:
#
# 1) The default values for assignments are stored in the file:
#		leds_assignment_defaults.qdf
#    If this file doesn't exist, see file:
#		assignment_defaults.qdf
#
# 2) Altera recommends that you do not modify this file. This
#    file is updated automatically by the Quartus II software
#    and any changes you make may be lost or overwritten.
#
# -------------------------------------------------------------------------- #


set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE115F29C7
set_global_assignment -name TOP_LEVEL_ENTITY leds
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:17:53  JUNE 05, 2014"
set_global_assignment -name LAST_QUARTUS_VERSION 13.1
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V

#============================================================
# CLOCK
#============================================================
set_location_assignment PIN_Y2 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50

#============================================================
# LED
#============================================================
set_location_assignment PIN_E21 -to LEDG[0]
set_location_assignment PIN_E22 -to LEDG[1]
set_location_assignment PIN_E25 -to LEDG[2]
set_location_assignment PIN_E24 -to LEDG[3]
set_location_assignment PIN_H21 -to LEDG[4]
set_location_assignment PIN_G20 -to LEDG[5]
set_location_assignment PIN_G22 -to LEDG[6]
set_location_assignment PIN_G21 -to LEDG[7]
set_location_assignment PIN_F17 -to LEDG[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[2]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDG[8]

set_location_assignment PIN_G19 -to LEDR[0]
set_location_assignment PIN_E19 -to LEDR[2]
set_location_assignment PIN_F19 -to LEDR[1]
set_location_assignment PIN_F21 -to LEDR[3]
set_location_assignment PIN_F18 -to LEDR[4]
set_location_assignment PIN_E18 -to LEDR[5]
set_location_assignment PIN_J19 -to LEDR[6]
set_location_assignment PIN_H19 -to LEDR[7]
set_location_assignment PIN_J17 -to LEDR[8]
set_location_assignment PIN_G17 -to LEDR[9]
set_location_assignment PIN_J15 -to LEDR[10]
set_location_assignment PIN_H16 -to LEDR[11]
set_location_assignment PIN_J16 -to LEDR[12]
set_location_assignment PIN_H17 -to LEDR[13]
set_location_assignment PIN_F15 -to LEDR[14]
set_location_assignment PIN_G15 -to LEDR[15]
set_location_assignment PIN_G16 -to LEDR[16]
set_location_assignment PIN_H15 -to LEDR[17]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[0]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[1]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[3]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[4]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[5]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[7]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[8]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[9]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[10]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[11]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[12]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[13]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[14]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[15]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[16]
set_instance_assignment -name IO_STANDARD "2.5 V" -to LEDR[17]

set_location_assignment PIN_M23 -to RESET
set_instance_assignment -name IO_STANDARD "2.5 V" -to RESET
set_global_assignment -name SOURCE_FILE leds.qsf
set_global_assignment -name VERILOG_FILE ../rtl/leds.v
set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top