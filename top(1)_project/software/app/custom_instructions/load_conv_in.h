#ifndef LOAD_CONV_IN_H
#define LOAD_CONV_IN_H

// Macros for loading convolution input data into the systolic array.
// func7 = 0x00 (000_0000), func3 varies from 0x0 to 0x3 for input blocks 1 to 4.

#define LOAD_CONV_IN_1(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x0, 0x00, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_CONV_IN_2(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x1, 0x00, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_CONV_IN_3(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x2, 0x00, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_CONV_IN_4(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x3, 0x00, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#endif // LOAD_CONV_IN_H
