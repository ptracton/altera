// interrupt_example.v

// Generated using ACDS version 13.1 162 at 2014.06.06.12:54:34

`timescale 1 ps / 1 ps
module interrupt_example (
		input  wire       clk_clk,               //            clk.clk
		input  wire       reset_reset_n,         //          reset.reset_n
		input  wire [7:0] switches_input_export, // switches_input.export
		output wire [7:0] leds_output_export     //    leds_output.export
	);

	wire  [31:0] mm_interconnect_0_leds_s1_writedata;                       // mm_interconnect_0:LEDS_s1_writedata -> LEDS:writedata
	wire   [1:0] mm_interconnect_0_leds_s1_address;                         // mm_interconnect_0:LEDS_s1_address -> LEDS:address
	wire         mm_interconnect_0_leds_s1_chipselect;                      // mm_interconnect_0:LEDS_s1_chipselect -> LEDS:chipselect
	wire         mm_interconnect_0_leds_s1_write;                           // mm_interconnect_0:LEDS_s1_write -> LEDS:write_n
	wire  [31:0] mm_interconnect_0_leds_s1_readdata;                        // LEDS:readdata -> mm_interconnect_0:LEDS_s1_readdata
	wire         cpu_data_master_waitrequest;                               // mm_interconnect_0:CPU_data_master_waitrequest -> CPU:d_waitrequest
	wire  [31:0] cpu_data_master_writedata;                                 // CPU:d_writedata -> mm_interconnect_0:CPU_data_master_writedata
	wire  [16:0] cpu_data_master_address;                                   // CPU:d_address -> mm_interconnect_0:CPU_data_master_address
	wire         cpu_data_master_write;                                     // CPU:d_write -> mm_interconnect_0:CPU_data_master_write
	wire         cpu_data_master_read;                                      // CPU:d_read -> mm_interconnect_0:CPU_data_master_read
	wire  [31:0] cpu_data_master_readdata;                                  // mm_interconnect_0:CPU_data_master_readdata -> CPU:d_readdata
	wire         cpu_data_master_debugaccess;                               // CPU:jtag_debug_module_debugaccess_to_roms -> mm_interconnect_0:CPU_data_master_debugaccess
	wire   [3:0] cpu_data_master_byteenable;                                // CPU:d_byteenable -> mm_interconnect_0:CPU_data_master_byteenable
	wire         mm_interconnect_0_cpu_jtag_debug_module_waitrequest;       // CPU:jtag_debug_module_waitrequest -> mm_interconnect_0:CPU_jtag_debug_module_waitrequest
	wire  [31:0] mm_interconnect_0_cpu_jtag_debug_module_writedata;         // mm_interconnect_0:CPU_jtag_debug_module_writedata -> CPU:jtag_debug_module_writedata
	wire   [8:0] mm_interconnect_0_cpu_jtag_debug_module_address;           // mm_interconnect_0:CPU_jtag_debug_module_address -> CPU:jtag_debug_module_address
	wire         mm_interconnect_0_cpu_jtag_debug_module_write;             // mm_interconnect_0:CPU_jtag_debug_module_write -> CPU:jtag_debug_module_write
	wire         mm_interconnect_0_cpu_jtag_debug_module_read;              // mm_interconnect_0:CPU_jtag_debug_module_read -> CPU:jtag_debug_module_read
	wire  [31:0] mm_interconnect_0_cpu_jtag_debug_module_readdata;          // CPU:jtag_debug_module_readdata -> mm_interconnect_0:CPU_jtag_debug_module_readdata
	wire         mm_interconnect_0_cpu_jtag_debug_module_debugaccess;       // mm_interconnect_0:CPU_jtag_debug_module_debugaccess -> CPU:jtag_debug_module_debugaccess
	wire   [3:0] mm_interconnect_0_cpu_jtag_debug_module_byteenable;        // mm_interconnect_0:CPU_jtag_debug_module_byteenable -> CPU:jtag_debug_module_byteenable
	wire         cpu_instruction_master_waitrequest;                        // mm_interconnect_0:CPU_instruction_master_waitrequest -> CPU:i_waitrequest
	wire  [16:0] cpu_instruction_master_address;                            // CPU:i_address -> mm_interconnect_0:CPU_instruction_master_address
	wire         cpu_instruction_master_read;                               // CPU:i_read -> mm_interconnect_0:CPU_instruction_master_read
	wire  [31:0] cpu_instruction_master_readdata;                           // mm_interconnect_0:CPU_instruction_master_readdata -> CPU:i_readdata
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest; // JTAG_UART:av_waitrequest -> mm_interconnect_0:JTAG_UART_avalon_jtag_slave_waitrequest
	wire  [31:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata;   // mm_interconnect_0:JTAG_UART_avalon_jtag_slave_writedata -> JTAG_UART:av_writedata
	wire   [0:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_address;     // mm_interconnect_0:JTAG_UART_avalon_jtag_slave_address -> JTAG_UART:av_address
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect;  // mm_interconnect_0:JTAG_UART_avalon_jtag_slave_chipselect -> JTAG_UART:av_chipselect
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_write;       // mm_interconnect_0:JTAG_UART_avalon_jtag_slave_write -> JTAG_UART:av_write_n
	wire         mm_interconnect_0_jtag_uart_avalon_jtag_slave_read;        // mm_interconnect_0:JTAG_UART_avalon_jtag_slave_read -> JTAG_UART:av_read_n
	wire  [31:0] mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata;    // JTAG_UART:av_readdata -> mm_interconnect_0:JTAG_UART_avalon_jtag_slave_readdata
	wire  [31:0] mm_interconnect_0_switches_s1_writedata;                   // mm_interconnect_0:SWITCHES_s1_writedata -> SWITCHES:writedata
	wire   [1:0] mm_interconnect_0_switches_s1_address;                     // mm_interconnect_0:SWITCHES_s1_address -> SWITCHES:address
	wire         mm_interconnect_0_switches_s1_chipselect;                  // mm_interconnect_0:SWITCHES_s1_chipselect -> SWITCHES:chipselect
	wire         mm_interconnect_0_switches_s1_write;                       // mm_interconnect_0:SWITCHES_s1_write -> SWITCHES:write_n
	wire  [31:0] mm_interconnect_0_switches_s1_readdata;                    // SWITCHES:readdata -> mm_interconnect_0:SWITCHES_s1_readdata
	wire  [31:0] mm_interconnect_0_memory_s1_writedata;                     // mm_interconnect_0:MEMORY_s1_writedata -> MEMORY:writedata
	wire  [12:0] mm_interconnect_0_memory_s1_address;                       // mm_interconnect_0:MEMORY_s1_address -> MEMORY:address
	wire         mm_interconnect_0_memory_s1_chipselect;                    // mm_interconnect_0:MEMORY_s1_chipselect -> MEMORY:chipselect
	wire         mm_interconnect_0_memory_s1_clken;                         // mm_interconnect_0:MEMORY_s1_clken -> MEMORY:clken
	wire         mm_interconnect_0_memory_s1_write;                         // mm_interconnect_0:MEMORY_s1_write -> MEMORY:write
	wire  [31:0] mm_interconnect_0_memory_s1_readdata;                      // MEMORY:readdata -> mm_interconnect_0:MEMORY_s1_readdata
	wire   [3:0] mm_interconnect_0_memory_s1_byteenable;                    // mm_interconnect_0:MEMORY_s1_byteenable -> MEMORY:byteenable
	wire         irq_mapper_receiver0_irq;                                  // SWITCHES:irq -> irq_mapper:receiver0_irq
	wire         irq_mapper_receiver1_irq;                                  // JTAG_UART:av_irq -> irq_mapper:receiver1_irq
	wire  [31:0] cpu_d_irq_irq;                                             // irq_mapper:sender_irq -> CPU:d_irq
	wire         rst_controller_reset_out_reset;                            // rst_controller:reset_out -> [CPU:reset_n, JTAG_UART:rst_n, LEDS:reset_n, MEMORY:reset, SWITCHES:reset_n, irq_mapper:reset, mm_interconnect_0:CPU_reset_n_reset_bridge_in_reset_reset, rst_translator:in_reset]
	wire         rst_controller_reset_out_reset_req;                        // rst_controller:reset_req -> [CPU:reset_req, MEMORY:reset_req, rst_translator:reset_req_in]
	wire         cpu_jtag_debug_module_reset_reset;                         // CPU:jtag_debug_module_resetrequest -> rst_controller:reset_in1

	interrupt_example_CPU cpu (
		.clk                                   (clk_clk),                                             //                       clk.clk
		.reset_n                               (~rst_controller_reset_out_reset),                     //                   reset_n.reset_n
		.reset_req                             (rst_controller_reset_out_reset_req),                  //                          .reset_req
		.d_address                             (cpu_data_master_address),                             //               data_master.address
		.d_byteenable                          (cpu_data_master_byteenable),                          //                          .byteenable
		.d_read                                (cpu_data_master_read),                                //                          .read
		.d_readdata                            (cpu_data_master_readdata),                            //                          .readdata
		.d_waitrequest                         (cpu_data_master_waitrequest),                         //                          .waitrequest
		.d_write                               (cpu_data_master_write),                               //                          .write
		.d_writedata                           (cpu_data_master_writedata),                           //                          .writedata
		.jtag_debug_module_debugaccess_to_roms (cpu_data_master_debugaccess),                         //                          .debugaccess
		.i_address                             (cpu_instruction_master_address),                      //        instruction_master.address
		.i_read                                (cpu_instruction_master_read),                         //                          .read
		.i_readdata                            (cpu_instruction_master_readdata),                     //                          .readdata
		.i_waitrequest                         (cpu_instruction_master_waitrequest),                  //                          .waitrequest
		.d_irq                                 (cpu_d_irq_irq),                                       //                     d_irq.irq
		.jtag_debug_module_resetrequest        (cpu_jtag_debug_module_reset_reset),                   //   jtag_debug_module_reset.reset
		.jtag_debug_module_address             (mm_interconnect_0_cpu_jtag_debug_module_address),     //         jtag_debug_module.address
		.jtag_debug_module_byteenable          (mm_interconnect_0_cpu_jtag_debug_module_byteenable),  //                          .byteenable
		.jtag_debug_module_debugaccess         (mm_interconnect_0_cpu_jtag_debug_module_debugaccess), //                          .debugaccess
		.jtag_debug_module_read                (mm_interconnect_0_cpu_jtag_debug_module_read),        //                          .read
		.jtag_debug_module_readdata            (mm_interconnect_0_cpu_jtag_debug_module_readdata),    //                          .readdata
		.jtag_debug_module_waitrequest         (mm_interconnect_0_cpu_jtag_debug_module_waitrequest), //                          .waitrequest
		.jtag_debug_module_write               (mm_interconnect_0_cpu_jtag_debug_module_write),       //                          .write
		.jtag_debug_module_writedata           (mm_interconnect_0_cpu_jtag_debug_module_writedata),   //                          .writedata
		.no_ci_readra                          ()                                                     // custom_instruction_master.readra
	);

	interrupt_example_MEMORY memory (
		.clk        (clk_clk),                                //   clk1.clk
		.address    (mm_interconnect_0_memory_s1_address),    //     s1.address
		.clken      (mm_interconnect_0_memory_s1_clken),      //       .clken
		.chipselect (mm_interconnect_0_memory_s1_chipselect), //       .chipselect
		.write      (mm_interconnect_0_memory_s1_write),      //       .write
		.readdata   (mm_interconnect_0_memory_s1_readdata),   //       .readdata
		.writedata  (mm_interconnect_0_memory_s1_writedata),  //       .writedata
		.byteenable (mm_interconnect_0_memory_s1_byteenable), //       .byteenable
		.reset      (rst_controller_reset_out_reset),         // reset1.reset
		.reset_req  (rst_controller_reset_out_reset_req)      //       .reset_req
	);

	interrupt_example_JTAG_UART jtag_uart (
		.clk            (clk_clk),                                                   //               clk.clk
		.rst_n          (~rst_controller_reset_out_reset),                           //             reset.reset_n
		.av_chipselect  (mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect),  // avalon_jtag_slave.chipselect
		.av_address     (mm_interconnect_0_jtag_uart_avalon_jtag_slave_address),     //                  .address
		.av_read_n      (~mm_interconnect_0_jtag_uart_avalon_jtag_slave_read),       //                  .read_n
		.av_readdata    (mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata),    //                  .readdata
		.av_write_n     (~mm_interconnect_0_jtag_uart_avalon_jtag_slave_write),      //                  .write_n
		.av_writedata   (mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata),   //                  .writedata
		.av_waitrequest (mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest), //                  .waitrequest
		.av_irq         (irq_mapper_receiver1_irq)                                   //               irq.irq
	);

	interrupt_example_LEDS leds (
		.clk        (clk_clk),                              //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),      //               reset.reset_n
		.address    (mm_interconnect_0_leds_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_leds_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_leds_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_leds_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_leds_s1_readdata),   //                    .readdata
		.out_port   (leds_output_export)                    // external_connection.export
	);

	interrupt_example_SWITCHES switches (
		.clk        (clk_clk),                                  //                 clk.clk
		.reset_n    (~rst_controller_reset_out_reset),          //               reset.reset_n
		.address    (mm_interconnect_0_switches_s1_address),    //                  s1.address
		.write_n    (~mm_interconnect_0_switches_s1_write),     //                    .write_n
		.writedata  (mm_interconnect_0_switches_s1_writedata),  //                    .writedata
		.chipselect (mm_interconnect_0_switches_s1_chipselect), //                    .chipselect
		.readdata   (mm_interconnect_0_switches_s1_readdata),   //                    .readdata
		.in_port    (switches_input_export),                    // external_connection.export
		.irq        (irq_mapper_receiver0_irq)                  //                 irq.irq
	);

	interrupt_example_mm_interconnect_0 mm_interconnect_0 (
		.clk_0_clk_clk                           (clk_clk),                                                   //                         clk_0_clk.clk
		.CPU_reset_n_reset_bridge_in_reset_reset (rst_controller_reset_out_reset),                            // CPU_reset_n_reset_bridge_in_reset.reset
		.CPU_data_master_address                 (cpu_data_master_address),                                   //                   CPU_data_master.address
		.CPU_data_master_waitrequest             (cpu_data_master_waitrequest),                               //                                  .waitrequest
		.CPU_data_master_byteenable              (cpu_data_master_byteenable),                                //                                  .byteenable
		.CPU_data_master_read                    (cpu_data_master_read),                                      //                                  .read
		.CPU_data_master_readdata                (cpu_data_master_readdata),                                  //                                  .readdata
		.CPU_data_master_write                   (cpu_data_master_write),                                     //                                  .write
		.CPU_data_master_writedata               (cpu_data_master_writedata),                                 //                                  .writedata
		.CPU_data_master_debugaccess             (cpu_data_master_debugaccess),                               //                                  .debugaccess
		.CPU_instruction_master_address          (cpu_instruction_master_address),                            //            CPU_instruction_master.address
		.CPU_instruction_master_waitrequest      (cpu_instruction_master_waitrequest),                        //                                  .waitrequest
		.CPU_instruction_master_read             (cpu_instruction_master_read),                               //                                  .read
		.CPU_instruction_master_readdata         (cpu_instruction_master_readdata),                           //                                  .readdata
		.CPU_jtag_debug_module_address           (mm_interconnect_0_cpu_jtag_debug_module_address),           //             CPU_jtag_debug_module.address
		.CPU_jtag_debug_module_write             (mm_interconnect_0_cpu_jtag_debug_module_write),             //                                  .write
		.CPU_jtag_debug_module_read              (mm_interconnect_0_cpu_jtag_debug_module_read),              //                                  .read
		.CPU_jtag_debug_module_readdata          (mm_interconnect_0_cpu_jtag_debug_module_readdata),          //                                  .readdata
		.CPU_jtag_debug_module_writedata         (mm_interconnect_0_cpu_jtag_debug_module_writedata),         //                                  .writedata
		.CPU_jtag_debug_module_byteenable        (mm_interconnect_0_cpu_jtag_debug_module_byteenable),        //                                  .byteenable
		.CPU_jtag_debug_module_waitrequest       (mm_interconnect_0_cpu_jtag_debug_module_waitrequest),       //                                  .waitrequest
		.CPU_jtag_debug_module_debugaccess       (mm_interconnect_0_cpu_jtag_debug_module_debugaccess),       //                                  .debugaccess
		.JTAG_UART_avalon_jtag_slave_address     (mm_interconnect_0_jtag_uart_avalon_jtag_slave_address),     //       JTAG_UART_avalon_jtag_slave.address
		.JTAG_UART_avalon_jtag_slave_write       (mm_interconnect_0_jtag_uart_avalon_jtag_slave_write),       //                                  .write
		.JTAG_UART_avalon_jtag_slave_read        (mm_interconnect_0_jtag_uart_avalon_jtag_slave_read),        //                                  .read
		.JTAG_UART_avalon_jtag_slave_readdata    (mm_interconnect_0_jtag_uart_avalon_jtag_slave_readdata),    //                                  .readdata
		.JTAG_UART_avalon_jtag_slave_writedata   (mm_interconnect_0_jtag_uart_avalon_jtag_slave_writedata),   //                                  .writedata
		.JTAG_UART_avalon_jtag_slave_waitrequest (mm_interconnect_0_jtag_uart_avalon_jtag_slave_waitrequest), //                                  .waitrequest
		.JTAG_UART_avalon_jtag_slave_chipselect  (mm_interconnect_0_jtag_uart_avalon_jtag_slave_chipselect),  //                                  .chipselect
		.LEDS_s1_address                         (mm_interconnect_0_leds_s1_address),                         //                           LEDS_s1.address
		.LEDS_s1_write                           (mm_interconnect_0_leds_s1_write),                           //                                  .write
		.LEDS_s1_readdata                        (mm_interconnect_0_leds_s1_readdata),                        //                                  .readdata
		.LEDS_s1_writedata                       (mm_interconnect_0_leds_s1_writedata),                       //                                  .writedata
		.LEDS_s1_chipselect                      (mm_interconnect_0_leds_s1_chipselect),                      //                                  .chipselect
		.MEMORY_s1_address                       (mm_interconnect_0_memory_s1_address),                       //                         MEMORY_s1.address
		.MEMORY_s1_write                         (mm_interconnect_0_memory_s1_write),                         //                                  .write
		.MEMORY_s1_readdata                      (mm_interconnect_0_memory_s1_readdata),                      //                                  .readdata
		.MEMORY_s1_writedata                     (mm_interconnect_0_memory_s1_writedata),                     //                                  .writedata
		.MEMORY_s1_byteenable                    (mm_interconnect_0_memory_s1_byteenable),                    //                                  .byteenable
		.MEMORY_s1_chipselect                    (mm_interconnect_0_memory_s1_chipselect),                    //                                  .chipselect
		.MEMORY_s1_clken                         (mm_interconnect_0_memory_s1_clken),                         //                                  .clken
		.SWITCHES_s1_address                     (mm_interconnect_0_switches_s1_address),                     //                       SWITCHES_s1.address
		.SWITCHES_s1_write                       (mm_interconnect_0_switches_s1_write),                       //                                  .write
		.SWITCHES_s1_readdata                    (mm_interconnect_0_switches_s1_readdata),                    //                                  .readdata
		.SWITCHES_s1_writedata                   (mm_interconnect_0_switches_s1_writedata),                   //                                  .writedata
		.SWITCHES_s1_chipselect                  (mm_interconnect_0_switches_s1_chipselect)                   //                                  .chipselect
	);

	interrupt_example_irq_mapper irq_mapper (
		.clk           (clk_clk),                        //       clk.clk
		.reset         (rst_controller_reset_out_reset), // clk_reset.reset
		.receiver0_irq (irq_mapper_receiver0_irq),       // receiver0.irq
		.receiver1_irq (irq_mapper_receiver1_irq),       // receiver1.irq
		.sender_irq    (cpu_d_irq_irq)                   //    sender.irq
	);

	altera_reset_controller #(
		.NUM_RESET_INPUTS          (2),
		.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
		.SYNC_DEPTH                (2),
		.RESET_REQUEST_PRESENT     (1),
		.RESET_REQ_WAIT_TIME       (1),
		.MIN_RST_ASSERTION_TIME    (3),
		.RESET_REQ_EARLY_DSRT_TIME (1),
		.USE_RESET_REQUEST_IN0     (0),
		.USE_RESET_REQUEST_IN1     (0),
		.USE_RESET_REQUEST_IN2     (0),
		.USE_RESET_REQUEST_IN3     (0),
		.USE_RESET_REQUEST_IN4     (0),
		.USE_RESET_REQUEST_IN5     (0),
		.USE_RESET_REQUEST_IN6     (0),
		.USE_RESET_REQUEST_IN7     (0),
		.USE_RESET_REQUEST_IN8     (0),
		.USE_RESET_REQUEST_IN9     (0),
		.USE_RESET_REQUEST_IN10    (0),
		.USE_RESET_REQUEST_IN11    (0),
		.USE_RESET_REQUEST_IN12    (0),
		.USE_RESET_REQUEST_IN13    (0),
		.USE_RESET_REQUEST_IN14    (0),
		.USE_RESET_REQUEST_IN15    (0),
		.ADAPT_RESET_REQUEST       (0)
	) rst_controller (
		.reset_in0      (~reset_reset_n),                     // reset_in0.reset
		.reset_in1      (cpu_jtag_debug_module_reset_reset),  // reset_in1.reset
		.clk            (clk_clk),                            //       clk.clk
		.reset_out      (rst_controller_reset_out_reset),     // reset_out.reset
		.reset_req      (rst_controller_reset_out_reset_req), //          .reset_req
		.reset_req_in0  (1'b0),                               // (terminated)
		.reset_req_in1  (1'b0),                               // (terminated)
		.reset_in2      (1'b0),                               // (terminated)
		.reset_req_in2  (1'b0),                               // (terminated)
		.reset_in3      (1'b0),                               // (terminated)
		.reset_req_in3  (1'b0),                               // (terminated)
		.reset_in4      (1'b0),                               // (terminated)
		.reset_req_in4  (1'b0),                               // (terminated)
		.reset_in5      (1'b0),                               // (terminated)
		.reset_req_in5  (1'b0),                               // (terminated)
		.reset_in6      (1'b0),                               // (terminated)
		.reset_req_in6  (1'b0),                               // (terminated)
		.reset_in7      (1'b0),                               // (terminated)
		.reset_req_in7  (1'b0),                               // (terminated)
		.reset_in8      (1'b0),                               // (terminated)
		.reset_req_in8  (1'b0),                               // (terminated)
		.reset_in9      (1'b0),                               // (terminated)
		.reset_req_in9  (1'b0),                               // (terminated)
		.reset_in10     (1'b0),                               // (terminated)
		.reset_req_in10 (1'b0),                               // (terminated)
		.reset_in11     (1'b0),                               // (terminated)
		.reset_req_in11 (1'b0),                               // (terminated)
		.reset_in12     (1'b0),                               // (terminated)
		.reset_req_in12 (1'b0),                               // (terminated)
		.reset_in13     (1'b0),                               // (terminated)
		.reset_req_in13 (1'b0),                               // (terminated)
		.reset_in14     (1'b0),                               // (terminated)
		.reset_req_in14 (1'b0),                               // (terminated)
		.reset_in15     (1'b0),                               // (terminated)
		.reset_req_in15 (1'b0)                                // (terminated)
	);

endmodule
