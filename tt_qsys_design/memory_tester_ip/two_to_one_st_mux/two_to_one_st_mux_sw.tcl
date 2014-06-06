# Create a new driver - this name must be different than the 
# hardware component name
create_driver two_to_one_st_mux_driver

# Associate it with some hardware known as "two_to_one_st_mux"
set_sw_property hw_class_name two_to_one_st_mux

# The version of this driver is "1.0"
set_sw_property version 1.0
set_sw_property min_compatible_hw_version 1.0

# Initialize the driver in alt_sys_init()
set_sw_property auto_initialize false

# Location in generated BSP that sources will be copied into
set_sw_property bsp_subdirectory drivers

#
# Source file listings...
#

# C/C++ source files
add_sw_property c_source HAL/src/two_to_one_st_mux.c

# Include files
add_sw_property include_source HAL/inc/two_to_one_st_mux.h
add_sw_property include_source inc/two_to_one_st_mux_regs.h


# This driver supports HAL type
add_sw_property supported_bsp_type HAL

# End of file