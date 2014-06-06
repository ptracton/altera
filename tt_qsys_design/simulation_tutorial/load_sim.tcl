# Set hierarchy variables used in the Qsys-generated files
set TOP_LEVEL_NAME "top"
set QSYS_SIMDIR "./pattern_generator/testbench/pattern_generator_tb/simulation"  

# Source Qsys-generated script and set up alias commands used below
source $QSYS_SIMDIR/mentor/msim_setup.tcl 

# Compile device library files
dev_com
# Compile design files in correct order
com  
             
# Compile the additional test files
# Use -L to specify a BFM library that contains the required System Verilog packages
vlog -sv ./test_program.sv -L pattern_generator_tb_csr_master
vlog -sv ./top.sv   
         
# Elaborate the top-level design
elab

# Load the waveform "do file" macro script
do ./wave.do