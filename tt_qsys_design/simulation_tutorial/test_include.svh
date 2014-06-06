//--------------------------------------------------------------------------
// This header file contains the macros that are used by test_program.sv
//--------------------------------------------------------------------------

//Console messaging level
`define VERBOSITY VERBOSITY_INFO

//BFM hierachy
`define CLOCK_BFM $root.top.tb.clock_source
`define RESET_BFM $root.top.tb.reset_source
`define CSR_MASTER $root.top.tb.csr_master
`define PATTERN_MASTER $root.top.tb.pattern_master
`define PATTERN_SINK $root.top.tb.pattern_sink

//User-defined test program parameters: Change these definitions to change the test pattern
`define PATTERN_POSITION 		8		//the start position of pattern to be generated
`define NUM_OF_PATTERN 			32		//number of test patterns in HEX file
`define NUM_OF_PAYLOAD_BYTES 	1024	//number of pattern payload to be generated (in bytes)
`define FILENAME				"walking_ones.hex"
`define FILENAME_REV			"walking_ones_rev.hex"

//CSR_MASTER BFM related parameters
`define CSR_MASTER_ADDRESS_W 	2
`define CSR_MASTER_SYMBOL_W 	8
`define CSR_MASTER_NUMSYMBOLS 	4
`define CSR_MASTER_DATA_W 		(`CSR_MASTER_SYMBOL_W * `CSR_MASTER_NUMSYMBOLS)

//PATTERN_MASTER BFM related parameters
`define PATTERN_MASTER_ADDRESS_W 	8
`define PATTERN_MASTER_SYMBOL_W 	8
`define PATTERN_MASTER_NUMSYMBOLS 	4
`define PATTERN_MASTER_DATA_W 		(`PATTERN_MASTER_SYMBOL_W * `PATTERN_MASTER_NUMSYMBOLS)

//Custom pattern generator register offset
`define PAYLOAD_LENGTH_REG 		4'h0
`define PATTERN_SETTINGS_REG 	4'h1
`define CONTROL_REG 			4'h2

//Do not modify the definitions below this line
`define INDEX_ZERO 				0  		//burst cycle with index zero for non-bursting transactions
`define FULL_BYTE 				4'b1111
`define LOWER_HALFBYTE 			4'b0011
`define UPPER_HALFBYTE 			4'b1100
`define PATTERN_POSITION_SHIFT 	(`PATTERN_POSITION << 16)
`define NUM_OF_PAYLOAD_WORDS 	(`NUM_OF_PAYLOAD_BYTES / `PATTERN_MASTER_NUMSYMBOLS)
