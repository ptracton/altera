package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module custom_pattern_generator
# | 
set_module_property DESCRIPTION "Custom streaming pattern generator"
set_module_property NAME custom_pattern_generator
set_module_property VERSION 1.1
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "Custom Pattern Generator"
set_module_property TOP_LEVEL_HDL_FILE mtm_custom_pattern_generator.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_custom_pattern_generator
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_custom_pattern_generator.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------


set_module_property VALIDATION_CALLBACK     validate_me


# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data Width"
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH ALLOWED_RANGES {16 32 64 128 256 512 1024}
set_parameter_property DATA_WIDTH DESCRIPTION "Data width specifies the width of the pattern slave and streaming ports"
set_parameter_property DATA_WIDTH DISPLAY_HINT ""
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
set_parameter_property DATA_WIDTH HDL_PARAMETER true

add_parameter MAX_PATTERN_LENGTH INTEGER 256
set_parameter_property MAX_PATTERN_LENGTH DEFAULT_VALUE 256
set_parameter_property MAX_PATTERN_LENGTH DISPLAY_NAME "Maximum Pattern Length"
set_parameter_property MAX_PATTERN_LENGTH UNITS None
set_parameter_property MAX_PATTERN_LENGTH ALLOWED_RANGES {32 64 128 256 512 1024}
set_parameter_property MAX_PATTERN_LENGTH DESCRIPTION "Maximum pattern length specifies the maximum number of elements in a test pattern"
set_parameter_property MAX_PATTERN_LENGTH DISPLAY_HINT ""
set_parameter_property MAX_PATTERN_LENGTH AFFECTS_GENERATION false
set_parameter_property MAX_PATTERN_LENGTH HDL_PARAMETER true

add_parameter ADDRESS_WIDTH INTEGER 6
set_parameter_property ADDRESS_WIDTH DEFAULT_VALUE 6
set_parameter_property ADDRESS_WIDTH DISPLAY_NAME ADDRESS_WIDTH
set_parameter_property ADDRESS_WIDTH UNITS None
set_parameter_property ADDRESS_WIDTH VISIBLE false
set_parameter_property ADDRESS_WIDTH DERIVED true
set_parameter_property ADDRESS_WIDTH DISPLAY_HINT ""
set_parameter_property ADDRESS_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDRESS_WIDTH HDL_PARAMETER true
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
set_interface_property csr readWaitStates 0
set_interface_property csr readWaitTime 0
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr csr_address address Input 2
add_interface_port csr csr_writedata writedata Input 32
add_interface_port csr csr_write write Input 1
add_interface_port csr csr_readdata readdata Output 32
add_interface_port csr csr_read read Input 1
add_interface_port csr csr_byteenable byteenable Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point pattern_access
# | 
add_interface pattern_access avalon end
set_interface_property pattern_access addressAlignment DYNAMIC
set_interface_property pattern_access associatedClock clock
set_interface_property pattern_access burstOnBurstBoundariesOnly false
set_interface_property pattern_access explicitAddressSpan 0
set_interface_property pattern_access holdTime 0
set_interface_property pattern_access isMemoryDevice false
set_interface_property pattern_access isNonVolatileStorage false
set_interface_property pattern_access linewrapBursts false
set_interface_property pattern_access maximumPendingReadTransactions 0
set_interface_property pattern_access printableDevice false
set_interface_property pattern_access readLatency 0
set_interface_property pattern_access readWaitTime 1
set_interface_property pattern_access setupTime 0
set_interface_property pattern_access timingUnits Cycles
set_interface_property pattern_access writeWaitTime 0

set_interface_property pattern_access ASSOCIATED_CLOCK clock
set_interface_property pattern_access ENABLED true

add_interface_port pattern_access pattern_address address Input ADDRESS_WIDTH
add_interface_port pattern_access pattern_writedata writedata Input DATA_WIDTH
add_interface_port pattern_access pattern_write write Input 1
add_interface_port pattern_access pattern_byteenable byteenable Input DATA_WIDTH/8
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_pattern_output
# | 
add_interface st_pattern_output avalon_streaming start
set_interface_property st_pattern_output associatedClock clock
set_interface_property st_pattern_output dataBitsPerSymbol 8
set_interface_property st_pattern_output errorDescriptor ""
set_interface_property st_pattern_output maxChannel 0
set_interface_property st_pattern_output readyLatency 3

set_interface_property st_pattern_output ASSOCIATED_CLOCK clock
set_interface_property st_pattern_output ENABLED true

add_interface_port st_pattern_output src_data data Output DATA_WIDTH
add_interface_port st_pattern_output src_valid valid Output 1
add_interface_port st_pattern_output src_ready ready Input 1
# | 
# +-----------------------------------


# need to set address width based on log2(MAX_PATTERN_LENGTH) which is already a power of 2
proc validate_me {}  {

set_parameter_value ADDRESS_WIDTH [expr {(log([get_parameter_value MAX_PATTERN_LENGTH])) / (log (2))}]

}
