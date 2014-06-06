package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module ram_test_controller
# | 
set_module_property DESCRIPTION "Controller for the memory test pattern reader and writter cores"
set_module_property NAME ram_test_controller
set_module_property VERSION 1.1
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "RAM Test Controller"
set_module_property TOP_LEVEL_HDL_FILE mtm_ram_test_controller.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_ram_test_controller
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_ram_test_controller.v {SYNTHESIS SIMULATION}
add_file mtm_chopper_fsm.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------


set_module_property VALIDATION_CALLBACK validate_me


# +-----------------------------------
# | parameters
# | 
add_parameter DEFAULT_TIMER_RESOLUTION INTEGER 10 "Set the default timer resolution in terms of system clock ticks"
set_parameter_property DEFAULT_TIMER_RESOLUTION DEFAULT_VALUE 10
set_parameter_property DEFAULT_TIMER_RESOLUTION ALLOWED_RANGES { 2:2147483647 }
set_parameter_property DEFAULT_TIMER_RESOLUTION DISPLAY_NAME "Default Timer Resolution"
set_parameter_property DEFAULT_TIMER_RESOLUTION UNITS None
set_parameter_property DEFAULT_TIMER_RESOLUTION DISPLAY_HINT ""
set_parameter_property DEFAULT_TIMER_RESOLUTION AFFECTS_GENERATION false
set_parameter_property DEFAULT_TIMER_RESOLUTION HDL_PARAMETER true

add_parameter DEFAULT_BLOCK_SIZE INTEGER 1024 "Set the default block size in bytes.  Each block is written and verified individually."
set_parameter_property DEFAULT_BLOCK_SIZE DEFAULT_VALUE 1024
set_parameter_property DEFAULT_BLOCK_SIZE ALLOWED_RANGES { 64:16777215 }
set_parameter_property DEFAULT_BLOCK_SIZE DISPLAY_NAME "Default Block Size"
set_parameter_property DEFAULT_BLOCK_SIZE UNITS None
set_parameter_property DEFAULT_BLOCK_SIZE DISPLAY_HINT ""
set_parameter_property DEFAULT_BLOCK_SIZE AFFECTS_GENERATION false
set_parameter_property DEFAULT_BLOCK_SIZE HDL_PARAMETER true

add_parameter DEFAULT_TRAIL_DISTANCE INTEGER 1 "Set the default block trail distance in terms of the number of blocks the pattern reader should trail the pattern writer."
set_parameter_property DEFAULT_TRAIL_DISTANCE DEFAULT_VALUE 1
set_parameter_property DEFAULT_TRAIL_DISTANCE ALLOWED_RANGES { 1:255 }
set_parameter_property DEFAULT_TRAIL_DISTANCE DISPLAY_NAME "Default Block Trail Distance"
set_parameter_property DEFAULT_TRAIL_DISTANCE UNITS None
set_parameter_property DEFAULT_TRAIL_DISTANCE DISPLAY_HINT ""
set_parameter_property DEFAULT_TRAIL_DISTANCE AFFECTS_GENERATION false
set_parameter_property DEFAULT_TRAIL_DISTANCE HDL_PARAMETER true

add_parameter CLOCK_SPEED INTEGER 1
set_parameter_property CLOCK_SPEED AFFECTS_GENERATION false
set_parameter_property CLOCK_SPEED HDL_PARAMETER false
set_parameter_property CLOCK_SPEED VISIBLE false
set_parameter_property CLOCK_SPEED SYSTEM_INFO { CLOCK_RATE clock }


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
# | connection point csr
# | 
add_interface csr avalon end
set_interface_property csr addressAlignment DYNAMIC
set_interface_property csr associatedClock clock
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr isMemoryDevice false
set_interface_property csr isNonVolatileStorage false
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr printableDevice false
set_interface_property csr readLatency 1
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr csr_address address Input 3
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_byteenable byteenable Input 4
add_interface_port csr csr_waitrequest waitrequest Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point write_command
# | 
add_interface write_command avalon_streaming start
set_interface_property write_command associatedClock clock
set_interface_property write_command dataBitsPerSymbol 96
set_interface_property write_command errorDescriptor ""
set_interface_property write_command maxChannel 0
set_interface_property write_command readyLatency 0

set_interface_property write_command ASSOCIATED_CLOCK clock
set_interface_property write_command ENABLED true

add_interface_port write_command src_write_command_data data Output 96
add_interface_port write_command src_write_command_ready ready Input 1
add_interface_port write_command src_write_command_valid valid Output 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point read_command
# | 
add_interface read_command avalon_streaming start
set_interface_property read_command associatedClock clock
set_interface_property read_command dataBitsPerSymbol 97
set_interface_property read_command errorDescriptor ""
set_interface_property read_command maxChannel 0
set_interface_property read_command readyLatency 0

set_interface_property read_command ASSOCIATED_CLOCK clock
set_interface_property read_command ENABLED true

add_interface_port read_command src_read_command_data data Output 97
add_interface_port read_command src_read_command_ready ready Input 1
add_interface_port read_command src_read_command_valid valid Output 1
# | 
# +-----------------------------------



proc validate_me {}  {
  # putting the default parameters into system.h just in case software cares....
  set_module_assignment embeddedsw.CMacro.DEFAULT_TIMER_RESOLUTION [get_parameter_value DEFAULT_TIMER_RESOLUTION]
  set_module_assignment embeddedsw.CMacro.DEFAULT_BLOCK_SIZE [get_parameter_value DEFAULT_BLOCK_SIZE]
  set_module_assignment embeddedsw.CMacro.DEFAULT_TRAIL_DISTANCE [get_parameter_value DEFAULT_TRAIL_DISTANCE]
  set_module_assignment embeddedsw.CMacro.CLOCK_FREQUENCY_IN_HZ [get_parameter_value CLOCK_SPEED]
}
