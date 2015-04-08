//                              -*- Mode: Verilog -*-
// Filename        : rtl/system_control.v
// Description     : Altera Cyclone IV FPGA System Controller
// Author          : Philip Tracton
// Created On      : Tue May 20 14:47:16 2014
// Last Modified By: Philip Tracton
// Last Modified On: Tue May 20 14:47:16 2014
// Update Count    : 0
// Status          : Unknown, Use with caution!

module system_control (/*AUTOARG*/
   // Outputs
   ready_sys, clk_sys50, clk_sys200, clk_sys33, reset_sys,
   // Inputs
   CLK, RESET
   ) ;
   input CLK;
   input RESET;
   output ready_sys;   
   output clk_sys50;
   output clk_sys200;
   output clk_sys33;
   output reset_sys;

   /*AUTOWIRE*/
   /*AUTOREG*/
   // Beginning of automatic regs (for this module's undeclared outputs)
   reg			reset_sys;
   // End of automatics

   wire 		ready_sys;
   wire [4:0] clk_wire;

   //
   // If we are not ready, pass the input clock to the system
   // so we can do SYNCHRONOUS resets.  If we are ready, assign
   // appropriate output clocks from the PLL
   //
   assign clk_sys50  = (ready_sys) ? clk_wire[0] : CLK;
   assign clk_sys200 = (ready_sys) ? clk_wire[1] : CLK;
   assign clk_sys33  = (ready_sys) ? clk_wire[2] : CLK;

   //
   // Reset logic, we hold the reset to the system until we have
   // ready_sys high and we have counter 16 periods of the input clock
   //
   reg [3:0]  reset_count;
   
   always @(posedge CLK or posedge RESET)
     if (RESET) begin
	reset_sys <= 1'b1;
	reset_count <= 4'h01;	
     end else begin
	if (!ready_sys) begin
	   reset_sys <= 1'b1;
	end
	else if (reset_count < 4'hF) begin
	   reset_sys <= 1'b1;
	   reset_count <= reset_count + 1;
	end else begin
	   reset_sys <= 1'b0;	   
	end
     end
   
   altpll  altpll_component (
                             .areset (RESET),
                             .inclk ({1'b0, CLK}),
                             .clk (clk_wire),
                             .locked (ready_sys),
                             .activeclock (),
                             .clkbad (),
                             .clkena ({6{1'b1}}),
                             .clkloss (),
                             .clkswitch (1'b0),
                             .configupdate (1'b0),
                             .enable0 (),
                             .enable1 (),
                             .extclk (),
                             .extclkena ({4{1'b1}}),
                             .fbin (1'b1),
                             .fbmimicbidir (),
                             .fbout (),
                             .fref (),
                             .icdrclk (),
                             .pfdena (1'b1),
                             .phasecounterselect ({4{1'b1}}),
                             .phasedone (),
                             .phasestep (1'b1),
                             .phaseupdown (1'b1),
                             .pllena (1'b1),
                             .scanaclr (1'b0),
                             .scanclk (1'b0),
                             .scanclkena (1'b1),
                             .scandata (1'b0),
                             .scandataout (),
                             .scandone (),
                             .scanread (1'b0),
                             .scanwrite (1'b0),
                             .sclkout0 (),
                             .sclkout1 (),
                             .vcooverrange (),
                             .vcounderrange ());
   defparam
     altpll_component.bandwidth_type = "AUTO",
     altpll_component.clk0_divide_by = 1,
     altpll_component.clk0_duty_cycle = 50,
     altpll_component.clk0_multiply_by = 1,
     altpll_component.clk0_phase_shift = "0",
     altpll_component.clk1_divide_by = 1,
     altpll_component.clk1_duty_cycle = 50,
     altpll_component.clk1_multiply_by = 4,
     altpll_component.clk1_phase_shift = "0",
     altpll_component.clk2_divide_by = 3,
     altpll_component.clk2_duty_cycle = 50,
     altpll_component.clk2_multiply_by = 2,
     altpll_component.clk2_phase_shift = "0",
     altpll_component.compensate_clock = "CLK0",
     altpll_component.inclk0_input_frequency = 20000,
     altpll_component.intended_device_family = "Cyclone IV E",
     altpll_component.lpm_hint = "CBX_MODULE_PREFIX=de0_nano_pll",
     altpll_component.lpm_type = "altpll",
     altpll_component.operation_mode = "NORMAL",
     altpll_component.pll_type = "AUTO",
     altpll_component.port_activeclock = "PORT_UNUSED",
     altpll_component.port_areset = "PORT_USED",
     altpll_component.port_clkbad0 = "PORT_UNUSED",
     altpll_component.port_clkbad1 = "PORT_UNUSED",
     altpll_component.port_clkloss = "PORT_UNUSED",
     altpll_component.port_clkswitch = "PORT_UNUSED",
     altpll_component.port_configupdate = "PORT_UNUSED",
     altpll_component.port_fbin = "PORT_UNUSED",
     altpll_component.port_inclk0 = "PORT_USED",
     altpll_component.port_inclk1 = "PORT_UNUSED",
     altpll_component.port_locked = "PORT_USED",
     altpll_component.port_pfdena = "PORT_UNUSED",
     altpll_component.port_phasecounterselect = "PORT_UNUSED",
     altpll_component.port_phasedone = "PORT_UNUSED",
     altpll_component.port_phasestep = "PORT_UNUSED",
     altpll_component.port_phaseupdown = "PORT_UNUSED",
     altpll_component.port_pllena = "PORT_UNUSED",
     altpll_component.port_scanaclr = "PORT_UNUSED",
     altpll_component.port_scanclk = "PORT_UNUSED",
     altpll_component.port_scanclkena = "PORT_UNUSED",
     altpll_component.port_scandata = "PORT_UNUSED",
     altpll_component.port_scandataout = "PORT_UNUSED",
     altpll_component.port_scandone = "PORT_UNUSED",
     altpll_component.port_scanread = "PORT_UNUSED",
     altpll_component.port_scanwrite = "PORT_UNUSED",
     altpll_component.port_clk0 = "PORT_USED",
     altpll_component.port_clk1 = "PORT_USED",
     altpll_component.port_clk2 = "PORT_USED",
     altpll_component.port_clk3 = "PORT_UNUSED",
     altpll_component.port_clk4 = "PORT_UNUSED",
     altpll_component.port_clk5 = "PORT_UNUSED",
     altpll_component.port_clkena0 = "PORT_UNUSED",
     altpll_component.port_clkena1 = "PORT_UNUSED",
     altpll_component.port_clkena2 = "PORT_UNUSED",
     altpll_component.port_clkena3 = "PORT_UNUSED",
     altpll_component.port_clkena4 = "PORT_UNUSED",
     altpll_component.port_clkena5 = "PORT_UNUSED",
     altpll_component.port_extclk0 = "PORT_UNUSED",
     altpll_component.port_extclk1 = "PORT_UNUSED",
     altpll_component.port_extclk2 = "PORT_UNUSED",
     altpll_component.port_extclk3 = "PORT_UNUSED",
     altpll_component.self_reset_on_loss_lock = "OFF",
     altpll_component.width_clock = 5;

   
endmodule // system_control
