vlib work

vlog ../rtl/edge_detector.v
vlog ../behavioral/free_running_clk.v
vlog ../testbench/testbench_edge_detector.v

vsim -voptargs=+acc work.testbench_edge_detector -L altera_mf_ver

do edge_detector_wave.do

run -all