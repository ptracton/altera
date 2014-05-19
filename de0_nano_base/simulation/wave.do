onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/CLOCK_50
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/reset
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/ADC_CS_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/ADC_SADDR
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/ADC_SCLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/ADC_SDAT
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_ADDR
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_BA
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_CAS_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_CKE
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_CLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_CS_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_DQ
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_DQM
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_RAS_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/DRAM_WE_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/EPCS_ASDO
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/EPCS_DCLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/EPCS_NCSO
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_0
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_1
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_2
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_CS_N
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_INT2
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_SDA_SDIO
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_SDO
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/I2C_SCLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/I2C_SDAT
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/LED
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/KEY
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/SW
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_INT
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_2_IN
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_1_IN
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/GPIO_0_IN
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/CLOCK_50
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/EPCS_DATA0
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/ADC_IN
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_SCLK
add wave -noupdate -group TESTBENCH -radix hexadecimal /testbench/G_SENSOR_nCS
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/CLOCK_50
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/LED
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/KEY
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/SW
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_ADDR
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_BA
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_CAS_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_CKE
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_CLK
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_CS_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_DQ
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_DQM
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_RAS_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/DRAM_WE_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/EPCS_ASDO
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/EPCS_DATA0
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/EPCS_DCLK
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/EPCS_NCSO
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/G_SENSOR_CS_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/G_SENSOR_INT
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/I2C_SCLK
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/I2C_SDAT
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/ADC_CS_N
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/ADC_SADDR
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/ADC_SCLK
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/ADC_SDAT
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_2
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_2_IN
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_0
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_0_IN
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_1
add wave -noupdate -expand -group de0_nano -radix hexadecimal /testbench/dut/GPIO_1_IN
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {4226749 ps}
