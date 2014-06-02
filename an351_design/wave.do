onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/clk
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/rst_n
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_irq
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_address
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_chipselect
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_waitrequest
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_write_n
add wave -noupdate -radix ascii -subitemconfig {{/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[31]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[30]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[29]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[28]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[27]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[26]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[25]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[24]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[23]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[22]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[21]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[20]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[19]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[18]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[17]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[16]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[15]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[14]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[13]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[12]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[11]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[10]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[9]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[8]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[7]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[6]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[5]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[4]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[3]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[2]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[1]} {-radix ascii} {/niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata[0]} {-radix ascii}} /niosii_system_tb/niosii_system_inst/jtag_uart/av_writedata
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_read_n
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/av_readdata
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/dataavailable
add wave -noupdate -radix ascii /niosii_system_tb/niosii_system_inst/jtag_uart/readyfordata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1646605401 ps} 0}
configure wave -namecolwidth 153
configure wave -valuecolwidth 131
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
WaveRestoreZoom {1645893096 ps} {1647338968 ps}
