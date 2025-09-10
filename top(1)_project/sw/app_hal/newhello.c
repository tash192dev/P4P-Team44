/*
 * Copyright (C) 2021 Intel Corporation
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_sysid_qsys_regs.h"

#define KERNEL_SIZE 2 // is KERNEL_SIZE for KERNEL_SIZE X KERNEL_SIZE MATRIX
#define DATA_SIZE 4   // is N for DATA_SIZE x DATA_SIZE MATRIX

int main()
{
    // int sys_id;

    printf("HELLO FROM NIOSV WITH NVMM HOPEFULLY IT WORKS");

    __int8_t data[DATA_SIZE * DATA_SIZE] = {0x01, 0x00, 0xFF, 0x01,
                                            0x00, 0x08, 0x0F, 0x00,
                                            0x00, 0x09, 0x09, 0xFF,
                                            0xFF, 0x09, 0x09, 0xFF};

    __int8_t kernel1[KERNEL_SIZE * KERNEL_SIZE] = {0x01, 0x01,
                                                   0xFF, 0xFF};

    __int8_t kernel2[KERNEL_SIZE * KERNEL_SIZE] = {0xFF, 0xFF,
                                                   0x01, 0x01};

    __int8_t kernel3[KERNEL_SIZE * KERNEL_SIZE] = {0x01, 0xFF,
                                                   0x01, 0xFF};

    __int8_t kernel4[KERNEL_SIZE * KERNEL_SIZE] = { 0xFF, 0x01,
                                                    0xFF, 0x01};


    int output = 0;

    // set the kernel
    // BIAS_SET(0, 0, 0);
    int kernel = 0x00000000;
    for (int i = 0; i < KERNEL_SIZE * KERNEL_SIZE; i++)
    {
       // create the kernel row  from kernel1 through to kernel3 and kernel4
       kernel |= kernel1[i] << (0);
       kernel |= kernel2[i] << (8 * 1);
       kernel |= kernel3[i] << (8 * 2);
       kernel |= kernel4[i] << (8 * 3);
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

    output = CONV_OUT(0, 0, 2);
    printf("\nThird output %x", output);

    output = CONV_OUT(0, 0, 3);
    printf("\nFourth output %x", output);

    output = CONV_OUT(0, 0, 4);
    printf("\nFifth output %x", output);

    output = CONV_OUT(0, 0, 5);
    printf("\nSixth output %x", output);

    output = CONV_OUT(0, 0, 6);
    printf("\nSeventh output %x", output);

    output = CONV_OUT(0, 0, 7);
    printf("\nEighth output %x", output);

    // printf("Print the value of System ID \n");
    // sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
    // printf("System ID from Peripheral core is 0x%X \n", sys_id);
    printf("Bye world!\n");
    return 0;
}
