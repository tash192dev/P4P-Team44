
#ifndef CUSTOM_INSTRUCTION_H
#define CUSTOM_INSTRUCTION_H

#define CONV_IN(VAL_1, VAL_2, F3) ({ \
 int output; \
 asm volatile (".insn r 0x0B, %[FUNCT3], (0x00), %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2), [FUNCT3] "i" (F3)); \
    output;  \
})



#define CONV_OUT(VAL_1, VAL_2, F3) ({ \
 int output; \
 asm volatile (".insn r 0x0B, %[FUNCT3], (0x01), %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2), [FUNCT3] "i" (F3)); \
    output;  \
})

#define KERNEL_SET(VAL_1, VAL_2, F3) ({ \
 int output; \
 asm volatile (".insn r 0x0B, %[FUNCT3], (0x02), %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2), [FUNCT3] "i" (F3)); \
    output;  \
})


#define LOAD_BIAS(VAL_1, VAL_2, F3) ({ \
 int output; \
 asm volatile (".insn r 0x0B, %[FUNCT3], (0x03), %[out], %[input1], %[input2]" \
    : [out] "=r" (output) \
    : [input1] "r" (VAL_1), [input2] "r" (VAL_2), [FUNCT3] "i" (F3)); \
    output;  \
})

#endif //CUSTOM_INSTRUCTION_H