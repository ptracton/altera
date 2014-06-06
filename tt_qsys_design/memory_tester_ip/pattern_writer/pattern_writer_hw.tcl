package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module pattern_writer
# | 
set_module_property DESCRIPTION "Command-based write master that accepts streaming input data"
set_module_property NAME pattern_writer
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "Pattern Writer"
set_module_property TOP_LEVEL_HDL_FILE mtm_pattern_writer.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_pattern_writer
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_pattern_writer.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------


set_module_property ELABORATION_CALLBACK    elaborate_me
set_module_property VALIDATION_CALLBACK     validate_me


# +-----------------------------------
# | parameters
# | 
add_parameter ADDRESS_WIDTH INTEGER 32
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 32
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME ADDRESS_WIDTH
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
set_parameter_property ADDRESS_WIDTH VISIBLE false
set_parameter_property ADDRESS_WIDTH SYSTEM_INFO {ADDRESS_WIDTH mm_data}

add_parameter LENGTH_WIDTH INTEGER 21 "Width of the length register, reduce the value to increase the operating frequency of the write master"
set_parameter_property LENGTH_WIDTH DEFAULT_VALUE 21
set_parameter_property LENGTH_WIDTH ALLOWED_RANGES {10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32}
set_parameter_property LENGTH_WIDTH DISPLAY_NAME "Transfer Length Register Width"
set_parameter_property LENGTH_WIDTH UNITS None
set_parameter_property LENGTH_WIDTH DISPLAY_HINT ""
set_parameter_property LENGTH_WIDTH AFFECTS_GENERATION false
set_parameter_property LENGTH_WIDTH HDL_PARAMETER true
set_parameter_property LENGTH_WIDTH AFFECTS_ELABORATION false

add_parameter DATA_WIDTH INTEGER 32 "Width of the streaming and memory mapped data ports"
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH ALLOWED_RANGES {16 32 64 128 256 512 1024}
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data Width"
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter FIFO_DEPTH INTEGER 128 "The internal FIFO is used to buffer write data between the streaming source port and write master.  Make sure the depth is at least twice the maximum burst size."
set_parameter_property FIFO_DEPTH DEFAULT_VALUE 128
set_parameter_property FIFO_DEPTH ALLOWED_RANGES {16 32 64 128 256 512 1024}
set_parameter_property FIFO_DEPTH DISPLAY_NAME "Internal FIFO Depth"
set_parameter_property FIFO_DEPTH UNITS None
set_parameter_property FIFO_DEPTH DISPLAY_HINT ""
set_parameter_property FIFO_DEPTH AFFECTS_GENERATION false
set_parameter_property FIFO_DEPTH HDL_PARAMETER true
set_parameter_property FIFO_DEPTH AFFECTS_ELABORATION false

add_parameter FIFO_DEPTH_LOG2 INTEGER 7
set_parameter_property FIFO_DEPTH_LOG2 DEFAULT_VALUE 7
set_parameter_property FIFO_DEPTH_LOG2 DISPLAY_NAME FIFO_DEPTH_LOG2
set_parameter_property FIFO_DEPTH_LOG2 UNITS None
set_parameter_property FIFO_DEPTH_LOG2 DISPLAY_HINT ""
set_parameter_property FIFO_DEPTH_LOG2 AFFECTS_GENERATION false
set_parameter_property FIFO_DEPTH_LOG2 HDL_PARAMETER true
set_parameter_property FIFO_DEPTH_LOG2 VISIBLE false
set_parameter_property FIFO_DEPTH_LOG2 DERIVED true
set_parameter_property FIFO_DEPTH_LOG2 AFFECTS_ELABORATION false

add_parameter BYTE_ENABLE_WIDTH INTEGER 4
set_parameter_property BYTE_ENABLE_WIDTH DEFAULT_VALUE 4
set_parameter_property BYTE_ENABLE_WIDTH DISPLAY_NAME BYTE_ENABLE_WIDTH
set_parameter_property BYTE_ENABLE_WIDTH UNITS None
set_parameter_property BYTE_ENABLE_WIDTH DISPLAY_HINT ""
set_parameter_property BYTE_ENABLE_WIDTH AFFECTS_GENERATION false
set_parameter_property BYTE_ENABLE_WIDTH HDL_PARAMETER true
set_parameter_property BYTE_ENABLE_WIDTH VISIBLE false
set_parameter_property BYTE_ENABLE_WIDTH DERIVED true

add_parameter BYTE_ENABLE_WIDTH_LOG2 INTEGER 2
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 DEFAULT_VALUE 2
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 DISPLAY_NAME BYTE_ENABLE_WIDTH_LOG2
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 UNITS None
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 DISPLAY_HINT ""
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 AFFECTS_GENERATION false
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 HDL_PARAMETER true
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 VISIBLE false
set_parameter_property BYTE_ENABLE_WIDTH_LOG2 DERIVED true

add_parameter BURST_ENABLE INTEGER 0 "Enable bursting when connecting the write master to burst capable slave ports like SDRAM for example"
set_parameter_property BURST_ENABLE DEFAULT_VALUE 0
set_parameter_property BURST_ENABLE DISPLAY_NAME "Burst Enable"
set_parameter_property BURST_ENABLE UNITS None
set_parameter_property BURST_ENABLE DISPLAY_HINT boolean
set_parameter_property BURST_ENABLE AFFECTS_GENERATION false
set_parameter_property BURST_ENABLE HDL_PARAMETER true

add_parameter MAX_BURST_COUNT INTEGER 2 "When burst is enabled the maximum burst count will be used to determine the burst count presented to the fabric"
set_parameter_property MAX_BURST_COUNT DEFAULT_VALUE 2
set_parameter_property MAX_BURST_COUNT ALLOWED_RANGES {2 4 8 16 32 64 128}
set_parameter_property MAX_BURST_COUNT DISPLAY_NAME "Maximum Burst Count"
set_parameter_property MAX_BURST_COUNT UNITS None
set_parameter_property MAX_BURST_COUNT DISPLAY_HINT ""
set_parameter_property MAX_BURST_COUNT AFFECTS_GENERATION false
set_parameter_property MAX_BURST_COUNT HDL_PARAMETER true
set_parameter_property MAX_BURST_COUNT AFFECTS_ELABORATION true

add_parameter BURST_WIDTH INTEGER 2
set_parameter_property BURST_WIDTH DEFAULT_VALUE 2
set_parameter_property BURST_WIDTH DISPLAY_NAME BURST_WIDTH
set_parameter_property BURST_WIDTH UNITS None
set_parameter_property BURST_WIDTH DISPLAY_HINT ""
set_parameter_property BURST_WIDTH AFFECTS_GENERATION false
set_parameter_property BURST_WIDTH HDL_PARAMETER true
set_parameter_property BURST_WIDTH VISIBLE false
set_parameter_property BURST_WIDTH DERIVED true

add_parameter BURST_REALIGN_ENABLE INTEGER 1 "Enable burst re-alignment support if you want the write master to progress to the next burst boundary before performing full bursts.  This will improve throughput if you connect the master to a burst wrapping slave such as SDRAM"
set_parameter_property BURST_REALIGN_ENABLE DEFAULT_VALUE 1
set_parameter_property BURST_REALIGN_ENABLE DISPLAY_NAME "Enable Burst Re-alignment"
set_parameter_property BURST_REALIGN_ENABLE UNITS None
set_parameter_property BURST_REALIGN_ENABLE DISPLAY_HINT boolean
set_parameter_property BURST_REALIGN_ENABLE AFFECTS_GENERATION false
set_parameter_property BURST_REALIGN_ENABLE HDL_PARAMETER true
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection points clock and reset
# | 
add_interface clock clock end
add_interface_port clock clk clk input 1

add_interface reset reset end clock
add_interface_port reset reset reset input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point command
# | 
add_interface command avalon_streaming end
set_interface_property command associatedClock clock
set_interface_property command dataBitsPerSymbol 96
set_interface_property command errorDescriptor ""
set_interface_property command maxChannel 0
set_interface_property command readyLatency 0

set_interface_property command ASSOCIATED_CLOCK clock
set_interface_property command ENABLED true

add_interface_port command snk_command_data data Input 96
add_interface_port command snk_command_valid valid Input 1
add_interface_port command snk_command_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_data
# | 
add_interface st_data avalon_streaming end
set_interface_property st_data associatedClock clock
set_interface_property st_data dataBitsPerSymbol 8
set_interface_property st_data errorDescriptor ""
set_interface_property st_data maxChannel 0
set_interface_property st_data readyLatency 0

set_interface_property st_data ASSOCIATED_CLOCK clock
set_interface_property st_data ENABLED true

add_interface_port st_data snk_data data Input DATA_WIDTH
add_interface_port st_data snk_valid valid Input 1
add_interface_port st_data snk_ready ready Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point mm_data
# | 
add_interface mm_data avalon start
set_interface_property mm_data associatedClock clock
set_interface_property mm_data burstOnBurstBoundariesOnly false
set_interface_property mm_data doStreamReads false
set_interface_property mm_data doStreamWrites false
set_interface_property mm_data linewrapBursts false

set_interface_property mm_data ASSOCIATED_CLOCK clock
set_interface_property mm_data ENABLED true

add_interface_port mm_data master_address address Output ADDRESS_WIDTH
add_interface_port mm_data master_write write Output 1
add_interface_port mm_data master_writedata writedata Output DATA_WIDTH
add_interface_port mm_data master_burstcount burstcount Output BURST_WIDTH
add_interface_port mm_data master_byteenable byteenable Output BYTE_ENABLE_WIDTH
add_interface_port mm_data master_waitrequest waitrequest Input 1
# | 
# +-----------------------------------


proc elaborate_me {}  {

  if { [get_parameter_value BURST_ENABLE] == 1 }  {
    set_port_property master_burstcount TERMINATION false
  } else {
    set_port_property master_burstcount TERMINATION true
  }

  # when the forced burst alignment is enabled the master will post bursts of 1 until the next burst boundary is reached so this is safe to enable.
  if { [get_parameter_value BURST_REALIGN_ENABLE] == 1 }  {
    set_interface_property mm_data burstOnBurstBoundariesOnly true
  } else {
    set_interface_property mm_data burstOnBurstBoundariesOnly false
  }

}



proc validate_me {}  {

  set_parameter_value BYTE_ENABLE_WIDTH [expr {[get_parameter_value DATA_WIDTH] / 8}]
  set_parameter_value BYTE_ENABLE_WIDTH_LOG2 [expr {log([get_parameter_value DATA_WIDTH] / 8) / log(2)}]
  set_parameter_value BURST_WIDTH [expr {(log([get_parameter_value MAX_BURST_COUNT]) / log(2)) + 1}]
  set_parameter_value FIFO_DEPTH_LOG2 [expr {log([get_parameter_value FIFO_DEPTH]) / log(2)}]
  
  if { [get_parameter_value BURST_ENABLE] == 1 }  {
    set_parameter_property MAX_BURST_COUNT ENABLED true
	set_parameter_property BURST_REALIGN_ENABLE ENABLED true
  } else {  
    set_parameter_property MAX_BURST_COUNT ENABLED false
	set_parameter_property BURST_REALIGN_ENABLE ENABLED false
  }

  if { ([get_parameter_value BURST_ENABLE] == 1) && ([get_parameter_value FIFO_DEPTH] < (2 * [get_parameter_value MAX_BURST_COUNT])) }  {
    send_message Error "You must set the FIFO depth to be at least twice the maximum burst count."
  }

  if { [get_parameter_value ADDRESS_WIDTH] < ([get_parameter_value LENGTH_WIDTH] - 1) }  {
    send_message Info "The transfer length register is wider than the master can address, it is recommended that you reduce the length register width to increase the master Fmax."
  }
  
}
