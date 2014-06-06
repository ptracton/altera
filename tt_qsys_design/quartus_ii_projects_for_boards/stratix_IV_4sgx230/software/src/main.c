/*

RAM Tester Software

Author:  JCJB
Date:    06/27/2010
Version 1.1: 02/16/2011

This software will control the test controller, mux and demux, checker and generator
cores of the RAM test system.  The test software sweeps through the following memory
tests (in this order):

  - Walking ones
  - Walking zeros
  - Low frequency (all high, all low, repeat...)
  - Alternating low frequency (MSBs high with LSBs low, MSB low with LSBs high, repeat)
  - High frequency (0xAA across the entire word, 0x55 across the entire word, repeat)
  - Alternating high frequency (0x5A across the entire word, 0xA5 across the entire word, repeat)
  - Syncronous PRBS (8-bit PRBS replicated across all byte lanes)
  - PRBS (16/32/64/128-bit wide PRBS pattern)
  
The software by default prints messages to the console and flashes LEDs to represent
the test status.  By default the software tests the memory forever until an error is
detected.  With the default settings below this code will fit in an 8kB on-chip memory.

*/


// Minor test is for a particular pattern (custom or PRBS) and performs test sweeps of test length, block size, and block trail distances (this takes a while)
// Major test is for a sweep of all minor tests


#include "custom_pattern_generator.h"
#include "prbs_pattern_generator.h"
#include "one_to_two_st_demux.h"
#include "two_to_one_st_mux.h"
#include "custom_pattern_checker.h"
#include "prbs_pattern_checker.h"
#include "ram_test_controller.h"
#include "io.h"
#include "system.h"
#include "settings.h"  // don't change the code, edit the values in settings.h instead

#if(ENABLE_SMALL_PRINTF == 1)
  #include "sys/alt_stdio.h"
#else
  #include "stdio.h"
#endif


/*  By default this software assumes the memory tester slave ports live in the top level.  This detection checks if the PRBS pattern
    generator does not live at the top level and switch all the names to use to use the following naming convention:
    
    memory_tester_subsystem_pattern_generator_subsystem_<slave port name>
    memory_tester_subsystem_pattern_checker_subsystem_<slave port name>
*/
#ifndef PRBS_PATTERN_GENERATOR_BASE
  #define PRBS_PATTERN_GENERATOR_BASE                     MEMORY_TESTER_SUBSYSTEM_PATTERN_GENERATOR_SUBSYSTEM_PRBS_PATTERN_GENERATOR_BASE
  #define CUSTOM_PATTERN_GENERATOR_CSR_BASE               MEMORY_TESTER_SUBSYSTEM_PATTERN_GENERATOR_SUBSYSTEM_CUSTOM_PATTERN_GENERATOR_CSR_BASE
  #define CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE    MEMORY_TESTER_SUBSYSTEM_PATTERN_GENERATOR_SUBSYSTEM_CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE
  #define TWO_TO_ONE_ST_MUX_BASE                          MEMORY_TESTER_SUBSYSTEM_PATTERN_GENERATOR_SUBSYSTEM_TWO_TO_ONE_ST_MUX_BASE
  #define RAM_TEST_CONTROLLER_BASE                        MEMORY_TESTER_SUBSYSTEM_RAM_TEST_CONTROLLER_BASE
  #define ONE_TO_TWO_ST_DEMUX_BASE                        MEMORY_TESTER_SUBSYSTEM_PATTERN_CHECKER_SUBSYSTEM_ONE_TO_TWO_ST_DEMUX_BASE
  #define PRBS_PATTERN_CHECKER_BASE                       MEMORY_TESTER_SUBSYSTEM_PATTERN_CHECKER_SUBSYSTEM_PRBS_PATTERN_CHECKER_BASE
  #define CUSTOM_PATTERN_CHECKER_CSR_BASE                 MEMORY_TESTER_SUBSYSTEM_PATTERN_CHECKER_SUBSYSTEM_CUSTOM_PATTERN_CHECKER_CSR_BASE
  #define CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE      MEMORY_TESTER_SUBSYSTEM_PATTERN_CHECKER_SUBSYSTEM_CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE
#endif



void populate_walking_ones_pattern (unsigned char invert_output_enable)
{
  int symbol_counter, byte_counter, xor_mask;
  const unsigned char lut[8] = { 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80 };  // walking ones for a single byte, invert to get walking zeros
  unsigned char temp_data;
  
  xor_mask = (invert_output_enable == 0)? 0x00 : 0xFF;  // using ^ 0xFF to create walking zeros test
  
  for (symbol_counter = 0; symbol_counter < (DATA_WIDTH * 8); symbol_counter++)
  {
    for (byte_counter = 0; byte_counter < DATA_WIDTH; byte_counter++)
    {
       temp_data = ((symbol_counter / 8) == byte_counter)? lut[symbol_counter % 8] : 0x00;
       IOWR_8DIRECT (CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, ((symbol_counter * DATA_WIDTH) + byte_counter), (temp_data ^ xor_mask));
       IOWR_8DIRECT (CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, ((symbol_counter * DATA_WIDTH) + byte_counter), (temp_data ^ xor_mask));
    }
  }
  
  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, (DATA_WIDTH * 8));  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, (DATA_WIDTH * 8));
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}


void populate_low_frequency_pattern ()
{
  int byte_counter;
  
  for (byte_counter = 0; byte_counter < DATA_WIDTH; byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
  }
  for (byte_counter = DATA_WIDTH; byte_counter < (2*DATA_WIDTH); byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0x00);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0x00);
  }
  
  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 2);  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, 2);
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}


void populate_alternating_low_frequency_pattern ()
{
  int byte_counter;

  for (byte_counter = 0; byte_counter < (DATA_WIDTH/2); byte_counter++)  // lower half of first pattern symbol
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0x00);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0x00);
  }
  for (byte_counter = (DATA_WIDTH/2); byte_counter < DATA_WIDTH; byte_counter++)  // upper half of the first pattern symbol
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
  }
  for (byte_counter = DATA_WIDTH; byte_counter < ((3*DATA_WIDTH)/2); byte_counter++)  // lower half of the second pattern symbol
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0xFF);
  }
  for (byte_counter = ((3*DATA_WIDTH)/2); byte_counter < (2*DATA_WIDTH); byte_counter++)  // upper half of the second pattern symbol
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0x00);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0x00);
  }
  
  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 2);  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, 2);
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}


void populate_high_frequency_pattern ()
{
  int byte_counter;

  for (byte_counter = 0; byte_counter < DATA_WIDTH; byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0xAA);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0xAA);
  }
  for (byte_counter = DATA_WIDTH; byte_counter < (2*DATA_WIDTH); byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0x55);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0x55);
  }
  
  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 2);  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, 2);
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}


void populate_alternating_high_frequency_pattern ()
{
  int byte_counter;

  for (byte_counter = 0; byte_counter < DATA_WIDTH; byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0x5A);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0x5A);
  }
  for (byte_counter = DATA_WIDTH; byte_counter < (2*DATA_WIDTH); byte_counter++)
  {
    IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, byte_counter, 0xA5);
    IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, byte_counter, 0xA5);
  }

  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 2);  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, 2);
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}


void populate_sync_prbs_pattern ()
{
  int symbol_counter, byte_counter;
  const unsigned short polynomial = 0x00B8;  // LSFR with taps at positions 8, 7, 5, and 4
  unsigned short taps = 0x55;   // seed value for the sync prbs pattern
  unsigned short feedback = 0;  // lowest order tap value from the sync prbs will be replicated across this value

  for (symbol_counter = 0; symbol_counter < 256; symbol_counter++)
  {
    for (byte_counter = 0; byte_counter < DATA_WIDTH; byte_counter++)
    {
      IOWR_8DIRECT(CUSTOM_PATTERN_GENERATOR_PATTERN_ACCESS_BASE, ((symbol_counter * DATA_WIDTH) + byte_counter), taps);
      IOWR_8DIRECT(CUSTOM_PATTERN_CHECKER_PATTERN_ACCESS_BASE, ((symbol_counter * DATA_WIDTH) + byte_counter), taps);
    }
    // compute the next value in the PRBS pattern
    feedback = ((taps & 0x0001) == 1)? 0xFFFF : 0x0000;
    taps = (taps >> 1) ^ (polynomial & feedback);  // sixteen bit values so a zero will be shifted into tap position 8 and xor'ed with the feedback path, in otherwords the lowest order tap will feed into the highest order tap
  }
  
  generator_set_pattern_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 256);  
  checker_set_pattern_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, 256);
  generator_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
  checker_set_pattern_position (CUSTOM_PATTERN_GENERATOR_CSR_BASE, 0);
}




void program_custom_pattern_payload_length (unsigned long pattern_length)
{
  generator_set_payload_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE, pattern_length);  
  checker_set_payload_length (CUSTOM_PATTERN_CHECKER_CSR_BASE, pattern_length);
  
  generator_enable_start (CUSTOM_PATTERN_GENERATOR_CSR_BASE);
  checker_enable_start (CUSTOM_PATTERN_CHECKER_CSR_BASE);
}


void program_prbs_pattern_payload_length (unsigned long pattern_length)
{
  prbs_generator_set_payload_length (PRBS_PATTERN_GENERATOR_BASE, pattern_length);  
  prbs_checker_set_payload_length (PRBS_PATTERN_CHECKER_BASE, pattern_length);
  
  prbs_generator_enable_start (PRBS_PATTERN_GENERATOR_BASE);
  prbs_checker_enable_start (PRBS_PATTERN_CHECKER_BASE);
}



int start_test(unsigned long long test_base, unsigned long test_length, unsigned long block_size, unsigned long block_trail_distance, unsigned char concurrent_access_enable)
{
  ram_test_controller_set_base_address (RAM_TEST_CONTROLLER_BASE, test_base);
  
  if (ram_test_controller_set_transfer_length (RAM_TEST_CONTROLLER_BASE, test_length) != 0)
  {
    #if(ENABLE_SMALL_PRINTF == 1)
      alt_printf("\nYou must set the transfer length to be at least 32 bytes\n");
    #else
      printf("\nYou must set the transfer length to be at least 32 bytes\n");
    #endif
    return 2;  // fail
  }
  if (ram_test_controller_set_block_size (RAM_TEST_CONTROLLER_BASE, block_size) != 0)
  {
    #if(ENABLE_SMALL_PRINTF == 1)
      alt_printf("\nYou must set the transfer block size to be at least 32 bytes\n");
    #else
      printf("\nYou must set the transfer block size to be at least 32 bytes\n");
    #endif
    return 2;  // fail
  }
  if (ram_test_controller_set_block_trail_distance (RAM_TEST_CONTROLLER_BASE, block_trail_distance) != 0)
  {
    #if(ENABLE_SMALL_PRINTF == 1)
      alt_printf("\nYou must set the block trail distance to be 1 to 255\n");
    #else
      printf("\nYou must set the block trail distance to be 1 to 255\n");
    #endif
    return 2;  // fail
  }
  
  if(concurrent_access_enable == 1) {   ram_test_controller_enable_concurrent_accesses (RAM_TEST_CONTROLLER_BASE);  }
  else {    ram_test_controller_disable_concurrent_accesses (RAM_TEST_CONTROLLER_BASE);  }
  
  ram_test_controller_enable_start (RAM_TEST_CONTROLLER_BASE);
  
  return 0;  // pass
}



// returns 0 if pass, 1 if transfer error is detected, 2 if the test times out
int validate_results(unsigned long minor_test_number, unsigned long timeout)
{
  unsigned long counter = 0;
  int transfer_done = 0;

  do {
    if (minor_test_number == PRBS_TEST_NUMBER)
    {
      transfer_done = (prbs_checker_read_start(PRBS_PATTERN_CHECKER_BASE) == 0);
    }
    else
    {
      transfer_done = (checker_read_start(CUSTOM_PATTERN_CHECKER_CSR_BASE) == 0);
    }
    counter++;
  } while ((counter != TIMEOUT) & (transfer_done == 0));

  if (counter == TIMEOUT)
  {
    #if(ENABLE_SMALL_PRINTF == 1)
      alt_printf("\nThe transfer did not complete within the specified amount of time.\n");
    #else
      printf("\nThe transfer did not complete within the specified amount of time.\n");
    #endif
    return 2;
  }
  
  if ((minor_test_number == PRBS_TEST_NUMBER) & (prbs_checker_read_failure_detected(PRBS_PATTERN_CHECKER_BASE) == 1))  
  {   
    return 1;
  }  
  else if (checker_read_failure_detected(CUSTOM_PATTERN_CHECKER_CSR_BASE) == 1)  
  { 
    return 1; 
  }
  
  // made it through the test without errors or timeout
  return 0;
}




int main()
{
  int failure_detected = 0;
  int main_test_byte_counter = 0;
  unsigned long length_counter, block_size_counter, block_trail_distance_counter, minor_test_counter;
  int skip_test;  // will be used to determine if a particular test needs to be skipped
  int output_counter = 0;
  unsigned long test_time = 0;
  unsigned long bytes_tested = 0;

  


  #if(ENABLE_SMALL_PRINTF == 1)
    alt_printf("Starting test.\n");
  #else
    printf("Starting test.\n");
  #endif



  // throughout all the tests there will be a finite payload size used and the checker cores will not stop on a failure (test software will exit when the transfer completes)
  prbs_generator_disable_infinite_payload_length (PRBS_PATTERN_GENERATOR_BASE);
  prbs_checker_disable_infinite_payload_length (PRBS_PATTERN_CHECKER_BASE);
  prbs_checker_disable_stop_on_failure (PRBS_PATTERN_CHECKER_BASE);
  generator_disable_infinite_payload_length (CUSTOM_PATTERN_GENERATOR_CSR_BASE);
  checker_disable_infinite_payload_length (CUSTOM_PATTERN_CHECKER_CSR_BASE);
  checker_disable_stop_on_failure (CUSTOM_PATTERN_CHECKER_CSR_BASE);  
  
  ram_test_controller_set_timer_resolution(RAM_TEST_CONTROLLER_BASE, TIMER_RESOLUTION);
  
  do {  // major test sweep loop
  
    for (minor_test_counter = 0; (minor_test_counter < NUMBER_OF_MINOR_TESTS) & (failure_detected == 0); minor_test_counter++)  // minor test sweep loop
    {
      skip_test = 1;
      
      if ((minor_test_counter == WALKING_ONES_TEST_NUMBER) & (WALKING_ONES_TEST_ENABLE == 1)) { 
        skip_test = 0;
        populate_walking_ones_pattern(0);
      }
      
      if ((minor_test_counter == WALKING_ZEROS_TEST_NUMBER) & (WALKING_ZEROS_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_walking_ones_pattern(1);  // re-using walking ones and just telling it to invert the pattern for walking zeros
      }
      
      if ((minor_test_counter == LOW_FREQUENCY_TEST_NUMBER) & (LOW_FREQUENCY_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_low_frequency_pattern();
      }
      
      if ((minor_test_counter == ALTERNATING_LOW_FREQUENCY_TEST_NUMBER) & (ALTERNATING_LOW_FREQUENCY_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_alternating_low_frequency_pattern();
      }
      
      if ((minor_test_counter == HIGH_FREQUENCY_TEST_NUMBER) & (HIGH_FREQUENCY_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_high_frequency_pattern();
      }
      
      if ((minor_test_counter == ALTERNATING_HIGH_FREQUENCY_TEST_NUMBER) & (ALTERNATING_HIGH_FREQUENCY_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_alternating_high_frequency_pattern();
      }
      
      if ((minor_test_counter == SYNC_PRBS_TEST_NUMBER) & (SYNC_PRBS_TEST_ENABLE == 1)) {
        skip_test = 0;
        populate_sync_prbs_pattern();
      }
      
      if ((minor_test_counter == PRBS_TEST_NUMBER) & (PRBS_TEST_ENABLE == 1)) {
        skip_test = 0;  // there is no pattern to populate since it's all done by the hardware
      }
      
      if (skip_test != 1)
      {
      
        /*   POPULATE PATTERN AND SWITCH OVER MUX AND DEMUX HERE     */
        if (minor_test_counter == PRBS_TEST_NUMBER) {
          mux_input_select (TWO_TO_ONE_ST_MUX_BASE, 1);       // select the 'b' input
          demux_output_select (ONE_TO_TWO_ST_DEMUX_BASE, 1);  // select the 'b' output
        } else {
          mux_input_select (TWO_TO_ONE_ST_MUX_BASE, 0);       // select the 'a' input
          demux_output_select (ONE_TO_TWO_ST_DEMUX_BASE, 0);  // select the 'a' output
        }
      
        // simply doubling the test parameters otherwise this would take forever
        for (block_size_counter = BLOCK_SIZE_MINIMUM; (block_size_counter <= BLOCK_SIZE_MAXIMUM) & (failure_detected == 0); block_size_counter = block_size_counter * 2)  // block size sweep loop for the major test (block keeps doubling until the max is hit)
        {
          for (block_trail_distance_counter = BLOCK_TRAIL_DISTANCE_MINIMUM; (block_trail_distance_counter <= BLOCK_TRAIL_DISTANCE_MAXIMUM) & (failure_detected == 0); block_trail_distance_counter = block_trail_distance_counter * 2)  // block trail distance sweep loop for the major test (block trail distance keeps increasing until the max is hit)
          {
            for (length_counter = RAM_LENGTH_MINIMUM; (length_counter <= RAM_LENGTH_MAXIMUM) & (failure_detected == 0); length_counter = length_counter * 2)  // length sweep loop for the major test (length keeps doubling until the max is hit)
            {

              if (minor_test_counter == PRBS_TEST_NUMBER)
              {
                program_prbs_pattern_payload_length (length_counter);
              }
              else
              {
                program_custom_pattern_payload_length (length_counter);
              }

              ram_test_controller_set_timer(RAM_TEST_CONTROLLER_BASE, 0);  // reset the timer built into the test controller to 0
              start_test(RAM_BASE, length_counter, block_size_counter, block_trail_distance_counter, CONCURRENT_ACCESS_ENABLE);
              failure_detected = validate_results(minor_test_counter, TIMEOUT);  // just waits until the test completes, TIMEOUT will be used if the test takes too long which means the test hardware is probably in the weeds somewhere
              bytes_tested = length_counter;
              test_time = ram_test_controller_read_timer(RAM_TEST_CONTROLLER_BASE);  // the timer only runs while the masters are moving data so we can read the timer result here
			  
              if (failure_detected != 0)
              {

                #if(ENABLE_SMALL_PRINTF == 1)
                  switch (minor_test_counter)
                  {
                    case WALKING_ONES_TEST_NUMBER:
                      alt_printf("\n\nWalking ones ");
                      break;
                    case WALKING_ZEROS_TEST_NUMBER:
                      alt_printf("\n\nWalking zeros ");
                      break;
                    case LOW_FREQUENCY_TEST_NUMBER:
                      alt_printf("\n\nLow frequency ");
                      break;
                    case ALTERNATING_LOW_FREQUENCY_TEST_NUMBER:
                      alt_printf("\n\nAlternating low frequency");
                      break;
                    case HIGH_FREQUENCY_TEST_NUMBER:
                      alt_printf("\n\nHigh frequency ");
                      break;
                    case ALTERNATING_HIGH_FREQUENCY_TEST_NUMBER:
                      alt_printf("\n\nAlternating high frequency ");
                      break;
                    case SYNC_PRBS_TEST_NUMBER:
                      alt_printf("\n\nSyncronized PRBS ");
                      break;                    
                    default:
                      alt_printf("\n\nPRBS ");
                  }
                  // continue message
                  alt_printf("test failed using a block trail distance of 0x%x,\nblock size of 0x%x and transfer length of 0x%x.\n\n", block_trail_distance_counter, block_size_counter, length_counter);
                #else
                  switch (minor_test_counter)
                  {
                    case WALKING_ONES_TEST_NUMBER:
                      printf("\n\nWalking ones ");
                      break;
                    case WALKING_ZEROS_TEST_NUMBER:
                      printf("\n\nWalking zeros ");
                      break;
                    case LOW_FREQUENCY_TEST_NUMBER:
                      printf("\n\nLow frequency ");
                      break;
                    case ALTERNATING_LOW_FREQUENCY_TEST_NUMBER:
                      printf("\n\nAlternating low frequency ");
                      break;
                    case HIGH_FREQUENCY_TEST_NUMBER:
                      printf("\n\nHigh frequency ");
                      break;
                    case ALTERNATING_HIGH_FREQUENCY_TEST_NUMBER:
                      printf("\n\nAlternating high frequency ");
                      break;
                    case SYNC_PRBS_TEST_NUMBER:
                      printf("\n\nSyncronized PRBS ");
                      break;                    
                    default:
                      printf("\n\nPRBS ");
                  }
                  // continue message
                  printf("test failed using a block trail distance of %lu,\nblock size of %lu and transfer length of %lu.\n\n", block_trail_distance_counter, block_size_counter, length_counter);
                #endif

              }
            }

            output_counter++;
            if (output_counter >= OUTPUT_RATE)
            {
              output_counter = 0;
              // reporting only absolute values instead of efficiency or throughput since that'll require more code space and will not fit in an 8kB RAM
              // memory efficiency = 100% * (('bytes transferred' / DATA_WIDTH) / 'clock cycles')
              // memory throughput = 'bytes transferred' * Memory clock frequency / 'clock cycles'
              #if(ENABLE_SMALL_PRINTF == 1)
                alt_printf("0x%x bytes transferred in 0x%x clock cycles\n", 2*bytes_tested, test_time*TIMER_RESOLUTION);  // test time is a divided clock so need to bring it back up to system ticks, data is written and read back hence the 2x reported
              #else
                printf("%lu bytes transferred in %lu clock cycles\n", 2*bytes_tested, test_time*TIMER_RESOLUTION);  // test time is a divided clock so need to bring it back up to system ticks, data is written and read back hence the 2x reported
              #endif              
            }
      
          }
        }
      }
    }
  
    main_test_byte_counter += (NUM_OF_TESTS != -1)? 1 : 0;  // don't increase test_byte_counter if an infinite test has been configured
    

    #if(ENABLE_SMALL_PRINTF == 1)        
      if (failure_detected != 0)
      {    
        alt_printf("\nExiting due to an error being detected or test timeout.\n%c", 0x4);
      } 
      else
      { 
        alt_printf("\nTest cycle complete.\n");
      }      
    #else
      if (failure_detected != 0)
      {
        printf("\nExiting due to an error being detected or test timeout.\n%c", 0x4);
      } 
      else
      {
        printf("\nTest cycle complete.\n");
      }
    #endif

  
  } while (((main_test_byte_counter < NUM_OF_TESTS) | (NUM_OF_TESTS == -1)) & (failure_detected == 0));

  
  // if we reach point then all tests passed so sending out the escape character
  #if(ENABLE_SMALL_PRINTF == 1)
    alt_printf("Entire test is complete.\n\n %c", 0x4);
  #else
    printf("Entire test is complete.\n\n %c", 0x4);
  #endif


  return failure_detected;  // returns 1 if a failure was detected, a 2 if any of the tests time out, otherwise 0 is return if all the tests pass on time
}


/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2010 Altera Corporation, San Jose, California, USA.           *
* All rights reserved.                                                        *
*                                                                             *
* Permission is hereby granted, free of charge, to any person obtaining a     *
* copy of this software and associated documentation files (the "Software"),  *
* to deal in the Software without restriction, including without limitation   *
* the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
* and/or sell copies of the Software, and to permit persons to whom the       *
* Software is furnished to do so, subject to the following conditions:        *
*                                                                             *
* The above copyright notice and this permission notice shall be included in  *
* all copies or substantial portions of the Software.                         *
*                                                                             *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
* DEALINGS IN THE SOFTWARE.                                                   *
*                                                                             *
* This agreement shall be governed in all respects by the laws of the State   *
* of California and by the laws of the United States of America.              *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/
