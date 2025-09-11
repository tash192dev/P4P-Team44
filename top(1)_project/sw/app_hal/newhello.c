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
#define OUTPUT_SIZE 3 // TODO: Figure out better way to calculate this 
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

    __int8_t kernel4[KERNEL_SIZE * KERNEL_SIZE] = {0xFF, 0x01,
                                                   0xFF, 0x01};


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
        KERNEL_SET(kernel, 0x00, 0);
    }

    for (int i = 0; i < 4; i++)
    {
        BIAS_SET(0, 0, 0);
    }

    int data_a, data_output = 0x00000000;
    for (int i = 0; i < 3; i++)
    {
        for (int row = 0; row < DATA_SIZE - 1; row++)
        {
            for (int col = 0; col < DATA_SIZE - 1; col++)
            {
                data_a = 0x00000000;

                // indices in 2x2 block
                int idx1 = row * DATA_SIZE + col;             // top-left
                int idx2 = row * DATA_SIZE + (col + 1);       // top-right
                int idx3 = (row + 1) * DATA_SIZE + col;       // bottom-left
                int idx4 = (row + 1) * DATA_SIZE + (col + 1); // bottom-right
                int data_a =
                    ((__uint8_t)data[idx1] << 24) |
                    ((__uint8_t)data[idx2] << 16) |
                    ((__uint8_t)data[idx3] << 8) |
                    ((__uint8_t)data[idx4]);

                printf("[Input] \n Window at (%d,%d): 0x%08X\n", row, col, data_a);
                data_output = CONV_IN(data_a, 0, 0);
                printf("[Output]: 0x%08X\n", data_output);
            }
        }


        // printf("Print the value of System ID \n");
        // sys_id = IORD_ALTERA_AVALON_SYSID_QSYS_ID(SYSID_QSYS_0_BASE);
        // printf("System ID from Peripheral core is 0x%X \n", sys_id);
        printf("Bye world!\n");
        return 0;
    }
}