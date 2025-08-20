/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_sysid_qsys_regs.h"
#include <custom_instruction.h>

void looper() {
    for (int i = 0; i < 1000; ++i) {
        printf("Hello world, this is the Nios V/g cpu checking in %d...\n", i);
    }
}

int main() {
    int kernel_1_a = 0;
    int kernel_1_b = 0;
    int kernel_2_a = 0;
    int kernel_2_b = 0;
    int kernel_3_a = 0;
    int kernel_3_b = 0;
    int kernel_4_a = 0;
    int kernel_4_b = 0;
    
    int data_1_a = 0;
    int data_1_b = 0;
    int data_2_a = 0;
    int data_2_b = 0;
    int data_3_a = 0;
    int data_3_b = 0;
    int data_4_a = 0;
    int data_4_b = 0;
    

    int output = 0;

    int sys_id;
    //set the kernel 
    KERNEL_SET(kernel_1_a, kernel_1_b, 0);
    KERNEL_SET(kernel_2_a, kernel_2_b, 1);
    KERNEL_SET(kernel_3_a, kernel_3_b, 2);
    KERNEL_SET(kernel_4_a, kernel_4_b, 3);

    LOAD_BIAS(0, 0, 0);
    LOAD_BIAS(0, 0, 1);
    LOAD_BIAS(0, 0, 2);
    LOAD_BIAS(0, 0, 3);
    
    CONV_IN(data_1_a, data_1_b,0);
    CONV_IN(data_2_a, data_2_b,1);
    CONV_IN(data_3_a, data_3_b,2);
    CONV_IN(data_4_a, data_4_b,3);


    printf("Test print%d", output);
    looper();
    usleep(1000000);
    printf ("Print the value of System ID \n");
    sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    printf ("System ID from Peripheral core is 0x%X \n",sys_id);
    printf("Bye world!\n");
    return 0;
}
