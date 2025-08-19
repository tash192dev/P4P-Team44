#ifndef LOAD_BIAS_H
#define LOAD_BIAS_H

// Macros for loading bias data into the systolic array via custom instructions.
// func7 = 0x30 (011_0000), func3 varies from 0x0 to 0x3 for bias blocks 1 to 4.

#define LOAD_BIAS_1(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x0, 0x30, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_BIAS_2(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x1, 0x30, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_BIAS_3(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x2, 0x30, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#define LOAD_BIAS_4(VAL_1, VAL_2) ({ \
    int output; \
    asm volatile (".insn r 0x0B, 0x3, 0x30, %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2)); \
    output; \
})

#endif // LOAD_BIAS_H
