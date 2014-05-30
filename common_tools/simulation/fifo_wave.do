onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/CLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/RESET
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/DATA_OUT
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/FULL
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/EMPTY
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/FLUSH
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/ENABLE
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/DATA_IN
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/PUSH
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench_fifo/POP
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/DATA_WIDTH
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/ADDR_EXP
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/ADDR_DEPTH
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/CLK
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/RESET
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/ENABLE
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/FLUSH
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/DATA_IN
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/PUSH
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/POP
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/DATA_OUT
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/FULL
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/EMPTY
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/memory
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/write_ptr
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/read_ptr
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/depth
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/next_write_ptr
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/next_read_ptr
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/accept_write
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/accept_read
add wave -noupdate -expand -group DUT -radix hexadecimal /testbench_fifo/dut/i
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
WaveRestoreZoom {0 ns} {1 us}
