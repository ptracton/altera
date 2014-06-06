###############################################################
## This file is called from run_sweep.tcl
## run_sweep.tcl runs a memory pattern test for your Hardware which has a Qsys system as defined in Qsys -Tutorials System Console's module
## 
## The file (base_address.tcl) contains variables for the base addresses of the components of your Qsys system.
## This file can be edited to match the base addresses of your Qsys system components
###############################################################


###############################################################
# You can modify the base addresses of the slave components here to match the addresses in your Qsys system
###############################################################
set mux_baseadd			0x00000440
set demux_baseadd		0x00001400
set prbsgen_baseadd		0x00000420
set prbschk_baseadd		0x00001440
set ramcntl_baseadd		0x00000800

###############################################################
# You can modify the start address of the RAM which is under test 
###############################################################
set start_address		0x00000000

###############################################################
## DO NOT MODIFY THE OFFSETS BELOW 
###############################################################

set mux_inputselect 		[format "0x%08x" [expr $mux_baseadd + 0 ] ] 
set mux_clearpipeline 		[format "0x%08x" [expr $mux_baseadd + 1 ] ] 
set mux_selectedinput 		[format "0x%08x" [expr $mux_baseadd + 4 ] ] 
set mux_pendingdata 		[format "0x%08x" [expr $mux_baseadd + 5 ] ] 

set demux_inputselect 		[format "0x%08x" [expr $demux_baseadd + 0 ] ] 
set demux_clearpipeline 	[format "0x%08x" [expr $demux_baseadd + 1 ] ] 
set demux_selectedinput 	[format "0x%08x" [expr $demux_baseadd + 4 ] ] 
set demux_pendingdata 		[format "0x%08x" [expr $demux_baseadd + 5 ] ] 

set prbsgen_payload 		[format "0x%08x" [expr $prbsgen_baseadd + 0 ] ] 
set prbsgen_infinite_lgth 	[format "0x%08x" [expr $prbsgen_baseadd + 8 ] ] 
set prbsgen_seedgen 		[format "0x%08x" [expr $prbsgen_baseadd + 9 ] ] 
set prbsgen_run 		[format "0x%08x" [expr $prbsgen_baseadd + 11 ] ] 
set prbsgen_poly1 		[format "0x%08x" [expr $prbsgen_baseadd + 16 ] ] 
set prbsgen_poly2 		[format "0x%08x" [expr $prbsgen_baseadd + 20 ] ] 
set prbsgen_poly3 		[format "0x%08x" [expr $prbsgen_baseadd + 24 ] ] 
set prbsgen_poly4 		[format "0x%08x" [expr $prbsgen_baseadd + 28 ] ] 


set prbschk_payload 		[format "0x%08x" [expr $prbschk_baseadd + 0 ] ] 
set prbschk_infinite_lgth 	[format "0x%08x" [expr $prbschk_baseadd + 8 ] ] 
set prbschk_stponfail 		[format "0x%08x" [expr $prbschk_baseadd + 9 ] ] 
set prbschk_seedchk 		[format "0x%08x" [expr $prbschk_baseadd + 10 ] ] 
set prbschk_run 		[format "0x%08x" [expr $prbschk_baseadd + 11 ] ] 
set prbschk_faildetect 		[format "0x%08x" [expr $prbschk_baseadd + 12 ] ] 

set ramcntl_baseadd1 		[format "0x%08x" [expr $ramcntl_baseadd + 0 ] ] 
set ramcntl_baseadd2 		[format "0x%08x" [expr $ramcntl_baseadd + 4 ] ] 
set ramcntl_trnsfrlgth 		[format "0x%08x" [expr $ramcntl_baseadd + 8 ] ] 
set ramcntl_blksize1 		[format "0x%08x" [expr $ramcntl_baseadd + 12 ] ] 
set ramcntl_blksize2 		[format "0x%08x" [expr $ramcntl_baseadd + 14 ] ] 
set ramcntl_blktrail 		[format "0x%08x" [expr $ramcntl_baseadd + 15 ] ] 
set ramcntl_cncrntrdwr 		[format "0x%08x" [expr $ramcntl_baseadd + 16 ] ] 
set ramcntl_start 		[format "0x%08x" [expr $ramcntl_baseadd + 19 ] ] 
