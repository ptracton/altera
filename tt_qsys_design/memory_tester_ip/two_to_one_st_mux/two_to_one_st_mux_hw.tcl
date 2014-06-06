package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module two_to_one_st_mux
# | 
set_module_property DESCRIPTION "Streaming two-to-one multiplexer"
set_module_property NAME two_to_one_st_mux
set_module_property VERSION 1.1
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "Two-to-one Streaming Mux"
set_module_property TOP_LEVEL_HDL_FILE mtm_two_to_one_st_mux.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_two_to_one_st_mux
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_two_to_one_st_mux.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
add_parameter DATA_WIDTH INTEGER 32
set_parameter_property DATA_WIDTH DEFAULT_VALUE 32
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data Width"
set_parameter_property DATA_WIDTH UNITS None
set_parameter_property DATA_WIDTH DESCRIPTION "Data width specifies the width of the streaming ports"
set_parameter_property DATA_WIDTH ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
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
set_interface_property csr readLatency 0
set_interface_property csr readWaitStates 0
set_interface_property csr readWaitTime 0
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0

set_interface_property csr ASSOCIATED_CLOCK clock
set_interface_property csr ENABLED true

add_interface_port csr address address Input 1
add_interface_port csr readdata readdata Output 32
add_interface_port csr read read Input 1
add_interface_port csr writedata writedata Input 32
add_interface_port csr write write Input 1
add_interface_port csr byteenable byteenable Input 4
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_input_A
# | 
add_interface st_input_A avalon_streaming end
set_interface_property st_input_A associatedClock clock
set_interface_property st_input_A dataBitsPerSymbol 8
set_interface_property st_input_A errorDescriptor ""
set_interface_property st_input_A maxChannel 0
set_interface_property st_input_A readyLatency 0

set_interface_property st_input_A ASSOCIATED_CLOCK clock
set_interface_property st_input_A ENABLED true

add_interface_port st_input_A snk_data_A data Input DATA_WIDTH
add_interface_port st_input_A snk_ready_A ready Output 1
add_interface_port st_input_A snk_valid_A valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_input_B
# | 
add_interface st_input_B avalon_streaming end
set_interface_property st_input_B associatedClock clock
set_interface_property st_input_B dataBitsPerSymbol 8
set_interface_property st_input_B errorDescriptor ""
set_interface_property st_input_B maxChannel 0
set_interface_property st_input_B readyLatency 0

set_interface_property st_input_B ASSOCIATED_CLOCK clock
set_interface_property st_input_B ENABLED true

add_interface_port st_input_B snk_data_B data Input DATA_WIDTH
add_interface_port st_input_B snk_ready_B ready Output 1
add_interface_port st_input_B snk_valid_B valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_output
# | 
add_interface st_output avalon_streaming start
set_interface_property st_output associatedClock clock
set_interface_property st_output dataBitsPerSymbol 8
set_interface_property st_output errorDescriptor ""
set_interface_property st_output maxChannel 0
set_interface_property st_output readyLatency 0

set_interface_property st_output ASSOCIATED_CLOCK clock
set_interface_property st_output ENABLED true

add_interface_port st_output src_data data Output DATA_WIDTH
add_interface_port st_output src_ready ready Input 1
add_interface_port st_output src_valid valid Output 1
# | 
# +-----------------------------------
