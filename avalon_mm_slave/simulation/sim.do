vlib work 

vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/avalon_utilities_pkg.sv
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/verbosity_pkg.sv
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/avalon_mm_pkg.sv                          

vlog ../rtl/avalon_slave.v

vlog ../testbench/testbench.v
vlog ../../common_tools/behavioral/free_running_clk.v 

vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_master_bfm.sv  
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_monitor_assertion.sv  
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_monitor_transactions.sv  
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_monitor.sv     
vlog ../../common_tools/behavioral/altera_avalon_mm_master_bfm/altera_avalon_mm_monitor_coverage.sv   

vsim work.testbench -L altera_mf_ver

do wave.do

run -all