
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
# Auto-generated simulation script

# ----------------------------------------
# Initialize variables
if ![info exists SYSTEM_INSTANCE_NAME] { 
  set SYSTEM_INSTANCE_NAME ""
} elseif { ![ string match "" $SYSTEM_INSTANCE_NAME ] } { 
  set SYSTEM_INSTANCE_NAME "/$SYSTEM_INSTANCE_NAME"
}

if ![info exists TOP_LEVEL_NAME] { 
  set TOP_LEVEL_NAME "testing_tb"
}

if ![info exists QSYS_SIMDIR] { 
  set QSYS_SIMDIR "./../"
}

if ![info exists QUARTUS_INSTALL_DIR] { 
  set QUARTUS_INSTALL_DIR "/data/pace/scratch03/tractp1/altera/13.1/quartus/"
}

# ----------------------------------------
# Initialize simulation properties - DO NOT MODIFY!
set ELAB_OPTIONS ""
set SIM_OPTIONS ""
if ![ string match "*-64 vsim*" [ vsim -version ] ] {
} else {
}

set Aldec "Riviera"
if { [ string match "*Active-HDL*" [ vsim -version ] ] } {
  set Aldec "Active"
}

if { [ string match "Active" $Aldec ] } {
  scripterconf -tcl
  createdesign "$TOP_LEVEL_NAME"  "."
  opendesign "$TOP_LEVEL_NAME"
}

# ----------------------------------------
# Copy ROM/RAM files to simulation directory
alias file_copy {
  echo "\[exec\] file_copy"
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_MEMORY.hex ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.mif ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.hex ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.dat ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.dat ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_a.dat ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.hex ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.dat ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.mif ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ociram_default_contents.mif ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.mif ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_ic_tag_ram.hex ./
  file copy -force $QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_rf_ram_b.hex ./
}

# ----------------------------------------
# Create compilation libraries
proc ensure_lib { lib } { if ![file isdirectory $lib] { vlib $lib } }
ensure_lib      ./libraries     
ensure_lib      ./libraries/work
vmap       work ./libraries/work
ensure_lib                  ./libraries/altera_ver      
vmap       altera_ver       ./libraries/altera_ver      
ensure_lib                  ./libraries/lpm_ver         
vmap       lpm_ver          ./libraries/lpm_ver         
ensure_lib                  ./libraries/sgate_ver       
vmap       sgate_ver        ./libraries/sgate_ver       
ensure_lib                  ./libraries/altera_mf_ver   
vmap       altera_mf_ver    ./libraries/altera_mf_ver   
ensure_lib                  ./libraries/altera_lnsim_ver
vmap       altera_lnsim_ver ./libraries/altera_lnsim_ver
ensure_lib                  ./libraries/cycloneive_ver  
vmap       cycloneive_ver   ./libraries/cycloneive_ver  
ensure_lib                                                                          ./libraries/altera_common_sv_packages                                               
vmap       altera_common_sv_packages                                                ./libraries/altera_common_sv_packages                                               
ensure_lib                                                                          ./libraries/rsp_xbar_mux                                                            
vmap       rsp_xbar_mux                                                             ./libraries/rsp_xbar_mux                                                            
ensure_lib                                                                          ./libraries/rsp_xbar_demux                                                          
vmap       rsp_xbar_demux                                                           ./libraries/rsp_xbar_demux                                                          
ensure_lib                                                                          ./libraries/cmd_xbar_mux                                                            
vmap       cmd_xbar_mux                                                             ./libraries/cmd_xbar_mux                                                            
ensure_lib                                                                          ./libraries/cmd_xbar_demux_001                                                      
vmap       cmd_xbar_demux_001                                                       ./libraries/cmd_xbar_demux_001                                                      
ensure_lib                                                                          ./libraries/cmd_xbar_demux                                                          
vmap       cmd_xbar_demux                                                           ./libraries/cmd_xbar_demux                                                          
ensure_lib                                                                          ./libraries/limiter                                                                 
vmap       limiter                                                                  ./libraries/limiter                                                                 
ensure_lib                                                                          ./libraries/id_router                                                               
vmap       id_router                                                                ./libraries/id_router                                                               
ensure_lib                                                                          ./libraries/addr_router                                                             
vmap       addr_router                                                              ./libraries/addr_router                                                             
ensure_lib                                                                          ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo
vmap       CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo
ensure_lib                                                                          ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
vmap       CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent          ./libraries/CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
ensure_lib                                                                          ./libraries/CPU_instruction_master_translator_avalon_universal_master_0_agent       
vmap       CPU_instruction_master_translator_avalon_universal_master_0_agent        ./libraries/CPU_instruction_master_translator_avalon_universal_master_0_agent       
ensure_lib                                                                          ./libraries/CPU_jtag_debug_module_translator                                        
vmap       CPU_jtag_debug_module_translator                                         ./libraries/CPU_jtag_debug_module_translator                                        
ensure_lib                                                                          ./libraries/CPU_instruction_master_translator                                       
vmap       CPU_instruction_master_translator                                        ./libraries/CPU_instruction_master_translator                                       
ensure_lib                                                                          ./libraries/rst_controller                                                          
vmap       rst_controller                                                           ./libraries/rst_controller                                                          
ensure_lib                                                                          ./libraries/irq_mapper                                                              
vmap       irq_mapper                                                               ./libraries/irq_mapper                                                              
ensure_lib                                                                          ./libraries/mm_interconnect_0                                                       
vmap       mm_interconnect_0                                                        ./libraries/mm_interconnect_0                                                       
ensure_lib                                                                          ./libraries/jtag_uart_0                                                             
vmap       jtag_uart_0                                                              ./libraries/jtag_uart_0                                                             
ensure_lib                                                                          ./libraries/SWITCHES                                                                
vmap       SWITCHES                                                                 ./libraries/SWITCHES                                                                
ensure_lib                                                                          ./libraries/LEDS                                                                    
vmap       LEDS                                                                     ./libraries/LEDS                                                                    
ensure_lib                                                                          ./libraries/MEMORY                                                                  
vmap       MEMORY                                                                   ./libraries/MEMORY                                                                  
ensure_lib                                                                          ./libraries/CPU                                                                     
vmap       CPU                                                                      ./libraries/CPU                                                                     
ensure_lib                                                                          ./libraries/testing_inst_switches_input_bfm                                         
vmap       testing_inst_switches_input_bfm                                          ./libraries/testing_inst_switches_input_bfm                                         
ensure_lib                                                                          ./libraries/testing_inst_leds_output_bfm                                            
vmap       testing_inst_leds_output_bfm                                             ./libraries/testing_inst_leds_output_bfm                                            
ensure_lib                                                                          ./libraries/testing_inst_reset_bfm                                                  
vmap       testing_inst_reset_bfm                                                   ./libraries/testing_inst_reset_bfm                                                  
ensure_lib                                                                          ./libraries/testing_inst_clk_bfm                                                    
vmap       testing_inst_clk_bfm                                                     ./libraries/testing_inst_clk_bfm                                                    
ensure_lib                                                                          ./libraries/testing_inst                                                            
vmap       testing_inst                                                             ./libraries/testing_inst                                                            

# ----------------------------------------
# Compile device library files
alias dev_com {
  echo "\[exec\] dev_com"
  vlog +define+SKIP_KEYWORDS_PRAGMA "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_primitives.v" -work altera_ver      
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/220model.v"          -work lpm_ver         
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/sgate.v"             -work sgate_ver       
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_mf.v"         -work altera_mf_ver   
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/altera_lnsim.sv"     -work altera_lnsim_ver
  vlog                              "$QUARTUS_INSTALL_DIR/eda/sim_lib/cycloneive_atoms.v"  -work cycloneive_ver  
}

# ----------------------------------------
# Compile the design files in correct order
alias com {
  echo "\[exec\] com"
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/verbosity_pkg.sv"                                                             -work altera_common_sv_packages                                               
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_arbitrator.sv"                     -l altera_common_sv_packages -work rsp_xbar_mux                                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_rsp_xbar_mux.sv"       -l altera_common_sv_packages -work rsp_xbar_mux                                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_rsp_xbar_demux.sv"     -l altera_common_sv_packages -work rsp_xbar_demux                                                          
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_arbitrator.sv"                     -l altera_common_sv_packages -work cmd_xbar_mux                                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_mux.sv"       -l altera_common_sv_packages -work cmd_xbar_mux                                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_demux_001.sv" -l altera_common_sv_packages -work cmd_xbar_demux_001                                                      
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_cmd_xbar_demux.sv"     -l altera_common_sv_packages -work cmd_xbar_demux                                                          
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_traffic_limiter.sv"                -l altera_common_sv_packages -work limiter                                                                 
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_reorder_memory.sv"                 -l altera_common_sv_packages -work limiter                                                                 
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_sc_fifo.v"                         -l altera_common_sv_packages -work limiter                                                                 
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_st_pipeline_base.v"                -l altera_common_sv_packages -work limiter                                                                 
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_id_router.sv"          -l altera_common_sv_packages -work id_router                                                               
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0_addr_router.sv"        -l altera_common_sv_packages -work addr_router                                                             
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_sc_fifo.v"                                                      -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_slave_agent.sv"                    -l altera_common_sv_packages -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_burst_uncompressor.sv"             -l altera_common_sv_packages -work CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent         
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_master_agent.sv"                   -l altera_common_sv_packages -work CPU_instruction_master_translator_avalon_universal_master_0_agent       
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_slave_translator.sv"               -l altera_common_sv_packages -work CPU_jtag_debug_module_translator                                        
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_merlin_master_translator.sv"              -l altera_common_sv_packages -work CPU_instruction_master_translator                                       
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_reset_controller.v"                                                    -work rst_controller                                                          
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_reset_synchronizer.v"                                                  -work rst_controller                                                          
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_irq_mapper.sv"                           -l altera_common_sv_packages -work irq_mapper                                                              
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_mm_interconnect_0.v"                                                  -work mm_interconnect_0                                                       
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_jtag_uart_0.v"                                                        -work jtag_uart_0                                                             
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_SWITCHES.v"                                                           -work SWITCHES                                                                
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_LEDS.v"                                                               -work LEDS                                                                    
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_MEMORY.v"                                                             -work MEMORY                                                                  
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_sysclk.v"                                       -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_test_bench.v"                                                     -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_oci_test_bench.v"                                                 -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_mult_cell.v"                                                      -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_wrapper.v"                                      -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU.vo"                                                               -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing_CPU_jtag_debug_module_tck.v"                                          -work CPU                                                                     
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_conduit_bfm_0002.sv"                      -l altera_common_sv_packages -work testing_inst_switches_input_bfm                                         
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_conduit_bfm.sv"                           -l altera_common_sv_packages -work testing_inst_leds_output_bfm                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_reset_source.sv"                   -l altera_common_sv_packages -work testing_inst_reset_bfm                                                  
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/altera_avalon_clock_source.sv"                   -l altera_common_sv_packages -work testing_inst_clk_bfm                                                    
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/submodules/testing.v"                                                                    -work testing_inst                                                            
  vlog  "$QSYS_SIMDIR/testing_tb/simulation/testing_tb.v"                                                                                                                                                          
}

# ----------------------------------------
# Elaborate top level design
alias elab {
  echo "\[exec\] elab"
  eval vsim +access +r -t ps $ELAB_OPTIONS -L work -L altera_common_sv_packages -L rsp_xbar_mux -L rsp_xbar_demux -L cmd_xbar_mux -L cmd_xbar_demux_001 -L cmd_xbar_demux -L limiter -L id_router -L addr_router -L CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo -L CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent -L CPU_instruction_master_translator_avalon_universal_master_0_agent -L CPU_jtag_debug_module_translator -L CPU_instruction_master_translator -L rst_controller -L irq_mapper -L mm_interconnect_0 -L jtag_uart_0 -L SWITCHES -L LEDS -L MEMORY -L CPU -L testing_inst_switches_input_bfm -L testing_inst_leds_output_bfm -L testing_inst_reset_bfm -L testing_inst_clk_bfm -L testing_inst -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Elaborate the top level design with -dbg -O2 option
alias elab_debug {
  echo "\[exec\] elab_debug"
  eval vsim -dbg -O2 +access +r -t ps $ELAB_OPTIONS -L work -L altera_common_sv_packages -L rsp_xbar_mux -L rsp_xbar_demux -L cmd_xbar_mux -L cmd_xbar_demux_001 -L cmd_xbar_demux -L limiter -L id_router -L addr_router -L CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent_rsp_fifo -L CPU_jtag_debug_module_translator_avalon_universal_slave_0_agent -L CPU_instruction_master_translator_avalon_universal_master_0_agent -L CPU_jtag_debug_module_translator -L CPU_instruction_master_translator -L rst_controller -L irq_mapper -L mm_interconnect_0 -L jtag_uart_0 -L SWITCHES -L LEDS -L MEMORY -L CPU -L testing_inst_switches_input_bfm -L testing_inst_leds_output_bfm -L testing_inst_reset_bfm -L testing_inst_clk_bfm -L testing_inst -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver $TOP_LEVEL_NAME
}

# ----------------------------------------
# Compile all the design files and elaborate the top level design
alias ld "
  dev_com
  com
  elab
"

# ----------------------------------------
# Compile all the design files and elaborate the top level design with -dbg -O2
alias ld_debug "
  dev_com
  com
  elab_debug
"

# ----------------------------------------
# Print out user commmand line aliases
alias h {
  echo "List Of Command Line Aliases"
  echo
  echo "file_copy                     -- Copy ROM/RAM files to simulation directory"
  echo
  echo "dev_com                       -- Compile device library files"
  echo
  echo "com                           -- Compile the design files in correct order"
  echo
  echo "elab                          -- Elaborate top level design"
  echo
  echo "elab_debug                    -- Elaborate the top level design with -dbg -O2 option"
  echo
  echo "ld                            -- Compile all the design files and elaborate the top level design"
  echo
  echo "ld_debug                      -- Compile all the design files and elaborate the top level design with -dbg -O2"
  echo
  echo 
  echo
  echo "List Of Variables"
  echo
  echo "TOP_LEVEL_NAME                -- Top level module name."
  echo
  echo "SYSTEM_INSTANCE_NAME          -- Instantiated system module name inside top level module."
  echo
  echo "QSYS_SIMDIR                   -- Qsys base simulation directory."
  echo
  echo "QUARTUS_INSTALL_DIR           -- Quartus installation directory."
}
file_copy
h
