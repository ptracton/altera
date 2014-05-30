vlib work

vlog ../rtl/fifo.v
vlog ../behavioral/free_running_clk.v
vlog ../testbench/testbench_fifo.v

vsim -voptargs=+acc work.testbench_fifo

do fifo_wave.do

run -all