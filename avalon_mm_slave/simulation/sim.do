vlib work 

vlog ../../common_tools/behavioral/packages/avalon_utilities_pkg.sv
vlog ../../common_tools/behavioral/packages/verbosity_pkg.sv
vlog ../../common_tools/behavioral/packages/avalon_mm_pkg.sv                          

vlog ../rtl/avalon_slave.v

vlog ../testbench/testbench.v
vlog ../../common_tools/behavioral/free_running_clk.v 

vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv  


vsim work.testbench -L altera_mf_ver

do wave.do

run -all