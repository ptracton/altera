# Create a new driver - this name must be different than the 
# hardware component name
create_driver custom_pattern_checker_driver

# Associate it with some hardware known as "custom_pattern_checker"
set_sw_property hw_class_name custom_pattern_checker

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
add_sw_property c_source HAL/src/custom_pattern_checker.c

# Include files
add_sw_property include_source HAL/inc/custom_pattern_checker.h
add_sw_property include_source inc/custom_pattern_checker_regs.h


# This driver supports HAL type
add_sw_property supported_bsp_type HAL

# End of file