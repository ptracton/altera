package require -exact sopc 10.0
# | 
# +-----------------------------------

# +-----------------------------------
# | module one_to_two_st_demux
# | 
set_module_property DESCRIPTION "Streaming one-to-two demultiplexer"
set_module_property NAME one_to_two_st_demux
set_module_property VERSION 1.1
set_module_property GROUP "Memory Test Microcores"
set_module_property AUTHOR JCJB
set_module_property DISPLAY_NAME "One-to-two Streaming Demux"
set_module_property TOP_LEVEL_HDL_FILE mtm_one_to_two_st_demux.v
set_module_property TOP_LEVEL_HDL_MODULE mtm_one_to_two_st_demux
set_module_property EDITABLE false
set_module_property ANALYZE_HDL false
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file mtm_one_to_two_st_demux.v {SYNTHESIS SIMULATION}
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

add_interface_port csr readdata readdata Output 32
add_interface_port csr read read Input 1
add_interface_port csr writedata writedata Input 32
add_interface_port csr write write Input 1
add_interface_port csr byteenable byteenable Input 4
add_interface_port csr address address Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_input
# | 
add_interface st_input avalon_streaming end
set_interface_property st_input associatedClock clock
set_interface_property st_input dataBitsPerSymbol 8
set_interface_property st_input errorDescriptor ""
set_interface_property st_input maxChannel 0
set_interface_property st_input readyLatency 0

set_interface_property st_input ASSOCIATED_CLOCK clock
set_interface_property st_input ENABLED true

add_interface_port st_input snk_data data Input DATA_WIDTH
add_interface_port st_input snk_ready ready Output 1
add_interface_port st_input snk_valid valid Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_output_A
# | 
add_interface st_output_A avalon_streaming start
set_interface_property st_output_A associatedClock clock
set_interface_property st_output_A dataBitsPerSymbol 8
set_interface_property st_output_A errorDescriptor ""
set_interface_property st_output_A maxChannel 0
set_interface_property st_output_A readyLatency 0

set_interface_property st_output_A ASSOCIATED_CLOCK clock
set_interface_property st_output_A ENABLED true

add_interface_port st_output_A src_ready_A ready Input 1
add_interface_port st_output_A src_valid_A valid Output 1
add_interface_port st_output_A src_data_A data Output DATA_WIDTH
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point st_output_B
# | 
add_interface st_output_B avalon_streaming start
set_interface_property st_output_B associatedClock clock
set_interface_property st_output_B dataBitsPerSymbol 8
set_interface_property st_output_B errorDescriptor ""
set_interface_property st_output_B maxChannel 0
set_interface_property st_output_B readyLatency 0

set_interface_property st_output_B ASSOCIATED_CLOCK clock
set_interface_property st_output_B ENABLED true

add_interface_port st_output_B src_data_B data Output DATA_WIDTH
add_interface_port st_output_B src_ready_B ready Input 1
add_interface_port st_output_B src_valid_B valid Output 1
# | 
# +-----------------------------------
