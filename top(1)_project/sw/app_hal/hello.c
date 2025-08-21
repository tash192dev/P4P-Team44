/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_sysid_qsys_regs.h"

#define KERNEL_SIZE 25 // is KERNEL_SIZE for KERNEL_SIZE X KERNEL_SIZE MATRIX
#define DATA_SIZE 25   // is N for DATA_SIZE x DATA_SIZE MATRIX

int main()
{
    // int sys_id;

    printf("HELLO FROM NIOSV WITH NVMM HOPEFULLY IT WORKS");

    __int8_t kernel_1[KERNEL_SIZE] = {0x00, 0x00, 0x01, 0x01, 0x00,
                                      0x01, 0x00, 0x01, 0x00, 0x00,
                                      0x00, 0x01, 0x00, 0x01, 0x00,
                                      0x00, 0x00, 0x01, 0x00, 0x01,
                                      0x00, 0x00, 0x00, 0x01, 0x00};

    __int8_t kernel_2[KERNEL_SIZE] = {0x01, 0x00, 0x01, 0x00, 0x01,
                                      0x00, 0x01, 0x00, 0x01, 0x00,
                                      0x01, 0x00, 0x01, 0x00, 0xFF,
                                      0x00, 0xFF, 0x00, 0xFF, 0x00,
                                      0xFF, 0x00, 0xFF, 0x00, 0xFF};

    __int8_t Data[DATA_SIZE] = {0x00, 0x01, 0x02, 0x03, 0x04,
                                0x05, 0x06, 0x07, 0x08, 0x09,
                                0x0A, 0x0B, 0x0C, 0x0D, 0x0E,
                                0x0F, 0x10, 0x11, 0x12, 0x13,
                                0x14, 0x15, 0x16, 0x17, 0x18};


    


    // int data_in_a = 0;
    // int data_in_b = 0;



    int output = 0;

    // set the kernel
    // BIAS_SET(0, 0, 0);
    int kernel_a = 0x00000000;
    for (int i = 0; i < KERNEL_SIZE; i++)
    {
        // only the first 2 kernels are being set currently
        kernel_a = 0x00000000;
        kernel_a |= kernel_1[i] << 0;
        kernel_a |= kernel_2[i] << 8;
         KERNEL_SET(kernel_a, 0, 0);
        // rest remain empty
//        printf("Kernel A %x, index %d", kernel_a, i);
        KERNEL_SET(0, 0, 1);
        KERNEL_SET(0, 0, 2);
        KERNEL_SET(0, 0, 3);
    }
    
    BIAS_SET(0, 0, 1);
    BIAS_SET(0, 0, 2);
    BIAS_SET(0, 0, 3);

    int data_a, data_b = 0x00000000;
    for (int i = 0; i < 3; i++)
    {
        data_a = 0x00000000;
        data_b = 0x00000000;

        data_a |= Data[0 + i * 8] << 0;
        data_a |= Data[1 + i * 8] << 8;
        data_a |= Data[2 + i * 8] << 16;
        data_a |= Data[3 + i * 8] << 24;

        data_b |= Data[4 + i * 8] << 0;
        data_b |= Data[5 + i * 8] << 8;
        data_b |= Data[6 + i * 8] << 16;
        data_b |= Data[7 + i * 8] << 24;
        for (int i = 0; i < 3; i++)
        {
            switch (i)
            {
            case 0:
                CONV_IN(data_a, data_b, 0);
                break;
            case 1:
                CONV_IN(data_a, data_b, 1);
                break;
            case 2:
                CONV_IN(data_a, data_b, 2);
                break;
            }
        }
    }
    // Hard coded cause why not lol
    data_a = Data[25] << 0;
    CONV_IN(data_a, 0, 3);
    
    usleep(1000000);
    
    // print results
    output = CONV_OUT(0, 0, 0);

    printf("\nFirst output %x", output);

    output = CONV_OUT(0, 0, 1);

    printf("\nSecond output %x", output);

    // printf("Print the value of System ID \n");
    // sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    // printf("System ID from Peripheral core is 0x%X \n", sys_id);
    printf("Bye world!\n");
    return 0;
}
