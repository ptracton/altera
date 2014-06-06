/*  When porting to other boards and memories you should be able to re-use the same design and just swap out the memory controller under test.
    The following settings should be changed to match the memory you are testing:
    
    NUM_OF_TESTS --> Each test loop can take over a minute so set this value for the number of times to repeat the test, use -1 to test indefinitely
    DATA_WIDTH   --> Set this to be the width of the memory test controllers (and the memory) in terms of bytes
    RAM_BASE     --> Set this to be the base address of the memory under test
    RAM_SPAN     --> Set this to be the span of your memory in bytes
    
    All the other settings can most likely be left alone, they are only provided for completeness.  
*/
    
/***********************************************************************************************************************************************************************************/
/***************************************************  Testing parameter, modify these and not the code below them  *****************************************************************/
/***********************************************************************************************************************************************************************************/
#define NUM_OF_TESTS                  1                  // set to -1 for test the memory indefinitely
#define DATA_WIDTH                    4                  // the data width of the memory under test in bytes
#define RAM_BASE                      0x0                // base address of the memory under test
#define RAM_SPAN                      0x2000000          // span in bytes of the memory under test
#define RAM_LENGTH_MINIMUM            0x400              // minimum test length, must be a multiple of the master word size, this value is a byte length
#define RAM_LENGTH_MAXIMUM            RAM_SPAN           // maximum test length, must be a multiple of the master word size and cannot exceed RAM_SPAN
#define CONCURRENT_ACCESS_ENABLE      0                  // read and write masters take turns accessing the memory when this is disabled
#define BLOCK_SIZE_MINIMUM            0x400              // minimum block size, must be a multiple of the master word size in terms of bytes and must be less than or equal to "BLOCK_SIZE_MAXIMUM"
#define BLOCK_SIZE_MAXIMUM            (1024*1024)        // maximum block size, must be a multiple of the master word size in terms of bytes  and must not exceed 1MB since the masters are setup for a maximum transfer length of 21 bits in width (one byte shy of 2MB)
#define BLOCK_TRAIL_DISTANCE_MINIMUM  1                  // the write master will always be this many blocks ahead of the read master, this value must be 1-255
#define BLOCK_TRAIL_DISTANCE_MAXIMUM  255                // the write master will always be this many blocks ahead of the read master, this value must be 1-255 and larger or equal than "BLOCK_TRAIL_DISTANCE_MINIMUM"
#define ENABLE_SMALL_PRINTF           1                  // reduces code footprint at the expense of text formatting

// Each sub test that you enable will be run sequentially for an entire test run.  The tests will be run in the order they are listed below and will be referred to minor tests 0 through 7.
#define WALKING_ONES_TEST_ENABLE                  1      // write a shifting walking ones bit pattern that moves the one from LSB to the MSB before repeating (D0=00000001, D1=00000010, D2=00000100, etc...) 
#define WALKING_ZEROS_TEST_ENABLE                 1      // same pattern as walking ones only inverted (D0=11111110, D1=11111101, D2=11111011, etc...)
#define LOW_FREQUENCY_TEST_ENABLE                 1      // write a word of ones followed by a word of zeros and then repeat to cause the I/O to switch at the same time (D0=11111111, D1=00000000, D2=11111111, etc...)
#define ALTERNATING_LOW_FREQUENCY_TEST_ENABLE     1      // write a word with the upper half set to ones and the lower half zeros followed by the a word with the upper half of zeros and lower half of ones and repeat (D0=11110000, D1=00001111, D2=11110000, etc...)
#define HIGH_FREQUENCY_TEST_ENABLE                1      // write a word of 0xAA replicated across the entire word followed by a word of 0x55 replicated across the entire word and repeat (D0=10101010, D1=01010101, D2=10101010, etc...)
#define ALTERNATING_HIGH_FREQUENCY_TEST_ENABLE    1      // write a word of 0x5A replicate across the entire word followed by a word of 0xA5 replicated across the entire word and repeat (D0=01011010, D1=10100101, D2=01011010, etc...)
#define SYNC_PRBS_TEST_ENABLE                     1      // write an 8-bit PRBS value replicated across the entire word followed by the next element in the pattern
#define PRBS_TEST_ENABLE                          1      // a parallel PRBS pattern will be written with the pattern dictated by the data width of generator
/***********************************************************************************************************************************************************************************/
/******************************************************  DO NOT MODIFY ANY CODE BELOW THIS LINE  ***********************************************************************************/
/***********************************************************************************************************************************************************************************/


// Some handy defined values for decoding what test to run
#define NUMBER_OF_MINOR_TESTS                     8
#define WALKING_ONES_TEST_NUMBER                  0
#define WALKING_ZEROS_TEST_NUMBER                 1
#define LOW_FREQUENCY_TEST_NUMBER                 2
#define ALTERNATING_LOW_FREQUENCY_TEST_NUMBER     3
#define HIGH_FREQUENCY_TEST_NUMBER                4
#define ALTERNATING_HIGH_FREQUENCY_TEST_NUMBER    5
#define SYNC_PRBS_TEST_NUMBER                     6
#define PRBS_TEST_NUMBER                          7



// the timeout will be used to determine if the testing hardware is stuck, the value is in term of a 32-bit software counter increments and it is recommended that you leave this value alone
#define TIMEOUT               0x7FFFFFFF


// OUTPUT_RATE will be the maximum that a blinking counter will reach before flipping the testing bit, the testing time will varry on the values above so this will help keep the blinking somewhat constant
#define OUTPUT_RATE           1     // 0 sends status updates fastest, keep this number under 10 and only increase it as the clock frequency increases

#define TIMER_RESOLUTION      2     // clock divider between 2 and 65535, for this software there are some short buffer tests so leave this at 2 to maintain a highly accurate measure of time
