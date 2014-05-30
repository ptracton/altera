onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TESTBENCH -radix hexadecimal /testbench_edge_detector/CLK
add wave -noupdate -expand -group TESTBENCH -radix hexadecimal /testbench_edge_detector/RESET
add wave -noupdate -expand -group TESTBENCH /testbench_edge_detector/ENABLE
add wave -noupdate -expand -group TESTBENCH -radix hexadecimal /testbench_edge_detector/RISING_EDGE
add wave -noupdate -expand -group TESTBENCH -radix hexadecimal /testbench_edge_detector/FALLING_EDGE
add wave -noupdate -expand -group TESTBENCH -radix hexadecimal /testbench_edge_detector/SIGNAL
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/CLK
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/RESET
add wave -noupdate -expand -group DUT /testbench_edge_detector/dut/ENABLE
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/SIGNAL
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/RISING_EDGE
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/FALLING_EDGE
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_edge_detector/dut/previous
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {1281 ns}
