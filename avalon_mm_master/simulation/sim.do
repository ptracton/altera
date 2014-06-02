vlib work

vlog ../../common_tools/behavioral/altera_avalon_mm_slave_bfm/verbosity_pkg.sv
vlog ../../common_tools/behavioral/altera_avalon_mm_slave_bfm/avalon_utilities_pkg.sv  
vlog ../../common_tools/behavioral/altera_avalon_mm_slave_bfm/avalon_mm_pkg.sv  
vlog ../../common_tools/behavioral/altera_avalon_mm_slave_bfm/altera_avalon_mm_slave_bfm.sv  

vlog ../../common_tools/behavioral/free_running_clk.v
vlog ../testbench/testbench.v
vlog ../rtl/avalon_mm_master.v

vsim work.testbench -L altera_mf_ver

do wave.do

run 1ms