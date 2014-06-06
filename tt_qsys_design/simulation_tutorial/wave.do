onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider CLK_RESET
add wave -noupdate -radix hexadecimal /top/tb/clock_source/clk
add wave -noupdate -radix hexadecimal /top/tb/reset_source/reset
add wave -noupdate -divider CSR_MASTER
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_address
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_byteenable
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_write
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_writedata
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_waitrequest
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_read
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_readdata
add wave -noupdate -radix hexadecimal /top/tb/csr_master/avm_readdatavalid
add wave -noupdate -divider PATTERN_MASTER
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_address
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_waitrequest
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_byteenable
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_write
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_writedata
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_read
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_readdata
add wave -noupdate -radix hexadecimal /top/tb/pattern_master/avm_readdatavalid
add wave -noupdate -divider DUT
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_address
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_byteenable
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_write
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_writedata
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_read
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/csr_readdata
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_address
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_byteenable
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_write
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_writedata
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/src_data
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/src_valid
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/src_ready
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/infinite_payload_length
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_length
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/pattern_position_counter
add wave -noupdate -radix hexadecimal /top/tb/dut/pg/payload_length_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {6018353 ps} 0}
configure wave -namecolwidth 290
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
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {12600 ns}
