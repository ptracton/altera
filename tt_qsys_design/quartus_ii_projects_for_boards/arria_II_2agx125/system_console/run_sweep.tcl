#puts stdout "Resetting the system in the beginning"
#set jd_path [lindex [get_service_paths jtag_debug] 0]
#open_service jtag_debug $jd_path
#jtag_debug_reset_system $jd_path
#close_service jtag_debug $jd_path
#puts stdout "Done with Resetting"

###############################################################
# All the slave base addresses of the system are defined in base_address.tcl
###############################################################
source base_address.tcl


###############################################################
# This test loops for different block sizes, block trail and span of the memory
# You can change these settings in test_cases.tcl 
###############################################################
source test_cases.tcl

###############################################################
# Opening the master service
###############################################################
set mm [lindex [get_service_paths master] 0]
open_service master $mm

###############################################################
## Setting the slave registers of PRBS checker and generator, MUX, DEMUX and RAM controller
###############################################################
puts stdout "................................."
puts stdout ".... Setting the components .... "
puts stdout ""

#########################################################
# MUX Settings
#########################################################
puts stdout ".... MUX Settings ... (0 selects custom pattern generator, 1 selects PRBS generator)"
master_write_8 $mm $mux_inputselect 0x01
puts stdout "Selected input for MUX is [format  %d [master_read_32 $mm $mux_selectedinput 1] ]"
puts ""

#########################################################
# DEMUX Settings
#########################################################
puts stdout ".... DEMUX Settings ... (0 selects custom pattern checker, 1 selects PRBS checker)"
master_write_8 $mm $demux_inputselect 0x01
puts stdout "Selected Input for DEMUX is [format %d [master_read_32 $mm $demux_selectedinput 1] ]"
puts ""

#########################################################
# PRBS Generator Settings
#########################################################
puts stdout ".... PRBS Generator Settings ... "
master_write_32 $mm $prbsgen_payload $memoryspan
puts stdout "Payload size OR Memory Span under test is [format %d [master_read_32 $mm $prbsgen_payload 1] ] "
master_write_8 $mm $prbsgen_infinite_lgth 0x00
puts stdout "Inifinite Payload length bit is set to [format %d [master_read_8 $mm $prbsgen_infinite_lgth 1] ]"
puts ""


#########################################################
# PRBS Checker Settings
#########################################################
puts stdout ".... PRBS Checker Settings ... "
master_write_32 $mm $prbschk_payload $memoryspan
puts stdout "Payload size OR Memory Span under test is [format %d [master_read_32 $mm $prbschk_payload 1] ]"
master_write_8 $mm prbschk_infinite_lgth 0x00
puts stdout "Infinite payload length bit is set to [format %d [master_read_8 $mm $prbschk_infinite_lgth 1] ]"
master_write_8 $mm $prbschk_stponfail 0x01
puts stdout "Stop on Fail bit is set to [format %d [master_read_8 $mm $prbschk_stponfail 1] ]"
puts ""

#########################################################
# Ram Contoller Settings
#########################################################
puts stdout ".... RAM Controller Settings ..."
master_write_32 $mm $ramcntl_baseadd1 $start_address
puts stdout "Base address of the memory at which the test starts is [format %d [master_read_32 $mm $ramcntl_baseadd1 1] ]"
master_write_32 $mm $ramcntl_trnsfrlgth $memoryspan
puts stdout "Memory span under test is from [format %d [master_read_32 $mm $ramcntl_baseadd1 1] ] to [format %d [master_read_32 $mm $ramcntl_trnsfrlgth 1] ]"
master_write_8 $mm $ramcntl_cncrntrdwr 0x01
puts stdout "Concurrent Read/Write Enable bit is set to [format %d [master_read_8 $mm $ramcntl_cncrntrdwr 1] ]"

#######################################################
# Making loops with different block sizes and block trails, the $blocksizes and  $blocktrails variables are defined in test_cases.tcl
#######################################################
puts ""
puts stdout "................................."
puts stdout "... Starting the Tests for different block sizes and block trails..."
puts ""
foreach blocksize $blocksizes {
puts "" 
master_write_16 $mm $ramcntl_blksize1 [format "0x%04x" $blocksize]
puts stdout ".....Memory Block Size is set to [format %d [master_read_16 $mm $ramcntl_blksize1 1] ]"

foreach blocktrail $blocktrails {
master_write_32 $mm $prbschk_payload $memoryspan
master_write_32 $mm $prbsgen_payload $memoryspan

master_write_8 $mm $ramcntl_blktrail [format "0x%02x" $blocktrail]
puts ""
puts stdout "..... Starting the test with Block Size $blocksize and Block Trail $blocktrail"
puts ""

########################################################
# Starting the PRBS Checker and Generator
########################################################
puts stdout ".... Setting the Run bit of PRBS checker and Generator ..."
master_write_8 $mm $prbschk_run 0x01
puts stdout "Run bit of PRBS checker is set to [format %d [master_read_8 $mm $prbschk_run 1] ]"
master_write_8 $mm $prbsgen_run 0x01
puts stdout "Run bit of PRBS generator is set to [format %d [master_read_8 $mm $prbsgen_run 1] ]"
puts ""

########################################################
# Starting the RAM Controller 
########################################################
puts stdout ".... Starting the RAM controller ..."
master_write_8 $mm $ramcntl_start 0x01
puts stdout "RAM controller Start bit is [format %d [master_read_8 $mm $ramcntl_start 1] ]"

#######################################################
# Creating a loop to continuously poll the Stop and Fail bit in PRBS Checker
######################################################
set stop 1 
set fail 0 

puts stdout ".... Polling stop bit and fail bit in PRBS checker continuously ....."
while { $stop == 1 } {
  set stop [format "%d" [master_read_8 $mm $prbschk_run 1] ]
  set fail [format "%d" [master_read_8 $mm $prbschk_faildetect 1] ]
   puts " ..........."
  }
#### end if polling loop
puts stdout "... Test case with Block Size $blocksize and Block Trail $blocktrail finished successfully "

 }
#### end of blocktrail loop
}
#### end of blocksize loop

#######################################################
# Test has finished, so closing the master service
#######################################################
puts ""
puts stdout ".... All tests have finished without any Failures ..."
close_service master $mm   
