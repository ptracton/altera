#######################################################
# This file contains variables for block size, block trail and span of the memory
# You can change these settings if desired
########################################################

########################################################
# Span of the memory
########################################################
# 32MB
# set memoryspan 0x02000000
# 64MB
set memoryspan 0x04000000
# 256MB
# set memoryspan 0x10000000
# 1GB
# set memoryspan 0x40000000
# 4GB
# set memoryspan 0xffffffff
 
########################################################
# Block Size of the memory
########################################################
set blocksizes {32 1024} 
#set blocksizes {32 64 128 256 512 1024} 

########################################################
# Block Trail of the memory
########################################################
set blocktrails {1 16 32} 
#set blocktrails {1 2 4 16 32} 
