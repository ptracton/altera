derive_pll_clocks -create_base_clocks


# JTAG Signal Constraints constrain the TCK port
#create_clock -name tck -period 100 [get_ports altera_reserved_tck]
# Cut all paths to and from tck
set_clock_groups -asynchronous -group [get_clocks altera_reserved_tck]
# Constrain the TDI port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdi]
# Constrain the TMS port
set_input_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tms]
# Constrain the TDO port
set_output_delay -clock altera_reserved_tck -clock_fall 1 [get_ports altera_reserved_tdo]


## Cutting the input reset path Because Qsys synchronizes the reset input
set_false_path -from [get_ports reset_n]

