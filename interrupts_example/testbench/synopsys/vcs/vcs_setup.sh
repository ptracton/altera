
# (C) 2001-2014 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and 
# other software and tools, and its AMPP partner logic functions, and 
# any output files any of the foregoing (including device programming 
# or simulation files), and any associated documentation or information 
# are expressly subject to the terms and conditions of the Altera 
# Program License Subscription Agreement, Altera MegaCore Function 
# License Agreement, or other applicable license agreement, including, 
# without limitation, that your use is for the sole purpose of 
# programming logic devices manufactured by Altera and sold by Altera 
# or its authorized distributors. Please refer to the applicable 
# agreement for further details.

# ACDS 13.1 162 linux 2014.06.06.12:54:59

# ----------------------------------------
# vcs - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="interrupt_example_tb"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="/data/pace/scratch03/tractp1/altera/13.1/quartus/"
SKIP_FILE_COPY=0
SKIP_ELAB=0
SKIP_SIM=0
USER_DEFINED_ELAB_OPTIONS=""
USER_DEFINED_SIM_OPTIONS="+vcs+finish+100"
# ----------------------------------------
# overwrite variables - DO NOT MODIFY!
# This block evaluates each command line argument, typically used for 
# overwriting variables. An example usage:
#   sh <simulator>_setup.sh SKIP_ELAB=1 SKIP_SIM=1
for expression in "$@"; do
  eval $expression
  if [ $? -ne 0 ]; then
    echo "Error: This command line argument, \"$expression\", is/has an invalid expression." >&2
    exit $?
  fi
done

# ----------------------------------------
# initialize simulation properties - DO NOT MODIFY!
ELAB_OPTIONS=""
SIM_OPTIONS=""
if [[ `vcs -platform` != *"amd64"* ]]; then
  :
else
  :
fi

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_MEMORY.hex ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_b.mif ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_a.mif ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_b.dat ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_ociram_default_contents.hex ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_a.dat ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_ociram_default_contents.mif ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_ociram_default_contents.dat ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_a.hex ./
  cp -f $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_rf_ram_b.hex ./
fi

vcs -lca -timescale=1ps/1ps -sverilog +verilog2001ext+.v -ntb_opts dtm $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v \
  $QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_hssi_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_pcie_hip_atoms.v \
  -v $QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneiv_atoms.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/verbosity_pkg.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_arbitrator.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_rsp_xbar_mux_001.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_rsp_xbar_mux.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_rsp_xbar_demux_003.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_rsp_xbar_demux.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_cmd_xbar_mux_003.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_cmd_xbar_mux.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_cmd_xbar_demux_001.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_cmd_xbar_demux.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_id_router_003.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_id_router.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_addr_router_001.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0_addr_router.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_avalon_sc_fifo.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_slave_agent.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_master_agent.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_slave_translator.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_merlin_master_translator.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_reset_controller.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_reset_synchronizer.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_irq_mapper.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_mm_interconnect_0.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_SWITCHES.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_LEDS.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_JTAG_UART.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_MEMORY.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_jtag_debug_module_sysclk.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_oci_test_bench.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_jtag_debug_module_tck.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_jtag_debug_module_wrapper.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example_CPU_test_bench.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_conduit_bfm_0002.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_conduit_bfm.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_avalon_reset_source.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/altera_avalon_clock_source.sv \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/submodules/interrupt_example.v \
  $QSYS_SIMDIR/interrupt_example_tb/simulation/interrupt_example_tb.v \
  -top $TOP_LEVEL_NAME
# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
