package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module prbs_pattern_checker
# | 
set_module_property DESCRIPTION "PRBS streaming pattern checker"
set_module_property NAME prbs_pattern_checker
set_module_property VERSION 1.1
set_module_property INTERNAL false
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "PRBS Pattern Checker"
set_module_property TOP_LEVEL_HDL_FILE mtm_prbs_pattern_checker.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_prbs_pattern_checker
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_prbs_pattern_checker.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data Width"
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DESCRIPTION "Data width specifies the width of the streaming port"
set_parameter_property DATA_WIDTH ALLOWED_RANGES {16 32 64 128}
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true
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
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_byteenable byteenable Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_pattern_input
# | 
add_interface st_pattern_input avalon_streaming end
set_interface_property st_pattern_input associatedClock clock
set_interface_property st_pattern_input dataBitsPerSymbol 8
set_interface_property st_pattern_input errorDescriptor ""
set_interface_property st_pattern_input maxChannel 0
set_interface_property st_pattern_input readyLatency 0

set_interface_property st_pattern_input ASSOCIATED_CLOCK clock
set_interface_property st_pattern_input ENABLED true

add_interface_port st_pattern_input snk_data data Input DATA_WIDTH
add_interface_port st_pattern_input snk_valid valid Input 1
add_interface_port st_pattern_input snk_ready ready Output 1
# | 
# +-----------------------------------
