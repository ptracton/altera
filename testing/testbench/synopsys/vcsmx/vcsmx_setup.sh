
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

# ACDS 13.1 162 linux 2014.06.02.17:45:21

# ----------------------------------------
# vcsmx - auto-generated simulation script

# ----------------------------------------
# initialize variables
TOP_LEVEL_NAME="testing_tb"
QSYS_SIMDIR="./../../"
QUARTUS_INSTALL_DIR="/data/pace/scratch03/tractp1/altera/13.1/quartus/"
SKIP_FILE_COPY=0
SKIP_DEV_COM=0
SKIP_COM=0
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
# create compilation libraries
mkdir -p ./libraries/work/
mkdir -p ./libraries/altera_common_sv_packages/
mkdir -p ./libraries/rsp_xbar_mux/
mkdir -p ./libraries/rsp_xbar_demux/
mkdir -p ./libraries/cmd_xbar_mux/
mkdir -p ./libraries/cmd_xbar_demux_001/
mkdir -p ./libraries/cmd_xbar_demux/
mkdir -p ./libraries/limiter/
mkdir -p ./libraries/id_router/
mkdir -p ./libraries/addr_router/
mkdir -p ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo/
mkdir -p ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent/
mkdir -p ./libraries/CPU_instruction_master_translator_avalon_universal_master_0_agent/
mkdir -p ./libraries/CPU_jtag_debug_module_translator/
mkdir -p ./libraries/CPU_instruction_master_translator/
mkdir -p ./libraries/rst_controller/
mkdir -p ./libraries/irq_mapper/
mkdir -p ./libraries/mm_interconnect_0/
mkdir -p ./libraries/jtag_uart_0/
mkdir -p ./libraries/SWITCHES/
mkdir -p ./libraries/LEDS/
mkdir -p ./libraries/MEMORY/
mkdir -p ./libraries/CPU/
mkdir -p ./libraries/testing_inst_switches_input_bfm/
mkdir -p ./libraries/testing_inst_leds_output_bfm/
mkdir -p ./libraries/testing_inst_reset_bfm/
mkdir -p ./libraries/testing_inst_clk_bfm/
mkdir -p ./libraries/testing_inst/
mkdir -p ./libraries/altera_ver/
mkdir -p ./libraries/lpm_ver/
mkdir -p ./libraries/sgate_ver/
mkdir -p ./libraries/altera_mf_ver/
mkdir -p ./libraries/altera_lnsim_ver/
mkdir -p ./libraries/cycloneive_ver/

# ----------------------------------------
# copy RAM/ROM files to simulation directory
if [ $SKIP_FILE_COPY -eq 0 ]; then
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_MEMORY.hex ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.mif ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.hex ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.dat ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.dat ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.dat ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.hex ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.dat ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.mif ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.mif ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.mif ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.hex ./
  cp -f $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.hex ./
fi

# ----------------------------------------
# compile device library files
if [ $SKIP_DEV_COM -eq 0 ]; then
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" -work altera_ver      
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"          -work lpm_ver         
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"             -work sgate_ver       
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
  vlogan +v2k -sverilog "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlogan +v2k           "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneive_atoms.v"  -work cycloneive_ver  
fi

# ----------------------------------------
# compile design files in correct order
if [ $SKIP_COM -eq 0 ]; then
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/verbosity_pkg.sv"                                -work altera_common_sv_packages                                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_arbitrator.sv"                     -work rsp_xbar_mux                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_rsp_xbar_mux.sv"       -work rsp_xbar_mux                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_rsp_xbar_demux.sv"     -work rsp_xbar_demux                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_arbitrator.sv"                     -work cmd_xbar_mux                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_mux.sv"       -work cmd_xbar_mux                                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_demux_001.sv" -work cmd_xbar_demux_001                                                      
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_demux.sv"     -work cmd_xbar_demux                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_traffic_limiter.sv"                -work limiter                                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_reorder_memory.sv"                 -work limiter                                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_sc_fifo.v"                         -work limiter                                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_st_pipeline_base.v"                -work limiter                                                                 
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_id_router.sv"          -work id_router                                                               
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_addr_router.sv"        -work addr_router                                                             
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_sc_fifo.v"                         -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_slave_agent.sv"                    -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"             -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_master_agent.sv"                   -work CPU_instruction_master_translator_avalon_universal_master_0_agent       
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_slave_translator.sv"               -work CPU_jtag_debug_module_translator                                        
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_master_translator.sv"              -work CPU_instruction_master_translator                                       
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_reset_controller.v"                       -work rst_controller                                                          
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_reset_synchronizer.v"                     -work rst_controller                                                          
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_irq_mapper.sv"                           -work irq_mapper                                                              
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0.v"                     -work mm_interconnect_0                                                       
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_jtag_uart_0.v"                           -work jtag_uart_0                                                             
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_SWITCHES.v"                              -work SWITCHES                                                                
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_LEDS.v"                                  -work LEDS                                                                    
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_MEMORY.v"                                -work MEMORY                                                                  
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_sysclk.v"          -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_test_bench.v"                        -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_oci_test_bench.v"                    -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_mult_cell.v"                         -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_wrapper.v"         -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU.vo"                                  -work CPU                                                                     
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_tck.v"             -work CPU                                                                     
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_conduit_bfm_0002.sv"                      -work testing_inst_switches_input_bfm                                         
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_conduit_bfm.sv"                           -work testing_inst_leds_output_bfm                                            
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_reset_source.sv"                   -work testing_inst_reset_bfm                                                  
  vlogan +v2k -sverilog "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_clock_source.sv"                   -work testing_inst_clk_bfm                                                    
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing.v"                                       -work testing_inst                                                            
  vlogan +v2k           "$QSYS_SIMDIR/testing_tb/simulation/testing_tb.v"                                                                                                                             
fi

# ----------------------------------------
# elaborate top level design
if [ $SKIP_ELAB -eq 0 ]; then
  vcs -lca -t ps $ELAB_OPTIONS $USER_DEFINED_ELAB_OPTIONS $TOP_LEVEL_NAME
fi

# ----------------------------------------
# simulate
if [ $SKIP_SIM -eq 0 ]; then
  ./simv $SIM_OPTIONS $USER_DEFINED_SIM_OPTIONS
fi
