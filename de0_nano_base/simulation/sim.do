vlib work

do ../rtl/rtl.do
do ../behavioral/behavioral.do
do ../testbench/testbench.do

vsim -voptargs=+acc work.testbench 

do wave.do

run -all