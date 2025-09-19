/******************************************************************************
*                                                                             *
* License Agreement                                                           *
*                                                                             *
* Copyright (c) 2021 Intel Corporation, Santa Clara, California, USA.         *
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
*                                                                             *
* Altera does not recommend, suggest or require that this reference design    *
* file be used in conjunction or combination with any other product.          *
******************************************************************************/

/*********************************************************************************************************
 *                                               uC/OS-II
 *                                         The Real-Time Kernel
 * File         : os_cpu_a.S
 * For          : uC/OS Real-time multitasking kernel for the Nios V/m SoftCore Processor
 * Written by   : Intel
 *
 *********************************************************************************************************/

#include "os_cfg.h"
#include "system.h"

.text

/*********************************************************************************************************
 *                                PERFORM A CONTEXT SWITCH
 *                                           void OSCtxSw(void)    - from task level
 *                                           void OSIntCtxSw(void) - from interrupt level
 *
 * Note(s): 1) Upon entry, 
 *             OSTCBCur     points to the OS_TCB of the task to suspend
 *             OSTCBHighRdy points to the OS_TCB of the task to resume
 *
 *********************************************************************************************************/
        .global OSIntCtxSw             
        .global OSCtxSw

OSIntCtxSw:
OSCtxSw:	
      /* 
       * Save the callee-saved registers, thread pointer (tp), return address (ra) to the stack, +1 for the impure ptr.
       */
#if ALT_CPU_NUM_GPR == 32
      addi sp, sp, -(14 + 1) * 4
      sw s2,   3 * 4(sp)
      sw s3,   4 * 4(sp)
      sw s4,   5 * 4(sp)
      sw s5,   6 * 4(sp)
      sw s6,   7 * 4(sp)
      sw s7,   8 * 4(sp)
      sw s8,   9 * 4(sp)
      sw s9,  10 * 4(sp)
      sw s10, 11 * 4(sp)
      sw s11, 12 * 4(sp)
      sw tp,  14 * 4(sp)
#else // 16 (RV32E)
      addi sp, sp, -(4 + 1) * 4
      sw tp,   4 * 4(sp)
#endif // ALT_CPU_NUM_GPR 
      sw ra,   0 * 4(sp)
      sw s0,   1 * 4(sp)
      sw s1,   2 * 4(sp)

#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
      /*
       * store the current value of _impure_ptr so it can be restored
       * later. _impure_ptr is assigned on a per task basis, and is used
       * by Newlib to achieve reentrancy.	
       */
      la s1, _impure_ptr
      lw s1, 0(s1)

#if ALT_CPU_NUM_GPR == 32
      sw s1, 13 * 4(sp)
#else // 16 (RV32E)
      sw s1, 3 * 4(sp)
#endif /* ALT_CPU_NUM_GPR */
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */

      /*
       * Save the current tasks stack pointer into the current tasks OS_TCB.
       * i.e. OSTCBCur->OSTCBStkPtr = sp;
       */
      la s1, OSTCBCur
      lw s1, 0(s1)  /* s1 = *OSTCBCur */
      sw sp, 0(s1)  /* sp = *s1 = OSTCBStkPtr which is the first element in the OS_TCB structure. */

      /*
       * Call the user definable OSTaskSWHook()
       */
      call OSTaskSwHook
0:

9:
    # OSPrioCur = OSPrioHighRdy;
    la s0, OSPrioHighRdy
    lb s1, 0(s0)
    la s0, OSPrioCur
    sb s1, 0(s0)

    # OSTCBCur = OSTCBHighRdy;
    la s0, OSTCBHighRdy
    lw s1, 0(s0)
    la s0, OSTCBCur
    sw s1, 0(s0)

    # sp = OSTCBHighRdy->OSTCBStkPtr;
    lw sp, 0(s1)

    /* set the stack limit value appropriately depending on whether stack checking is enabled or not */
#if defined(ALT_STACK_CHECK)
    la s0, alt_stack_limit_value
#if (OS_TASK_CREATE_EXT_EN > 0)
    # alt_stack_limit_value = OSTCBHighRdy->OSTCBStkBottom
    lw s1, 8(s1) /* load the new stack limit */
    sw s1, 0(s0)
#else
    # alt_stack_limit_value = 0x0
    sw x0, 0(s0)
#endif //OS_TASK_CREATE_EXT_EN > 0
#endif //ALT_STACK_CHECK

#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    /*
    * restore the value of _impure_ptr. _impure_ptr is asigned on a 
    * per task basis. It is used by Newlib to achieve reentrancy.	
    */
#if ALT_CPU_NUM_GPR == 32
      lw s0, 13 * 4(sp) /* load the new impure pointer */
#else // 16 (RV32E)
      lw s0, 3 * 4(sp) /* load the new impure pointer */
#endif /* ALT_CPU_NUM_GPR */
      la s1, _impure_ptr
      sw s0, 0(s1)
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */

      /*
       * Restore the saved registers for the new task.
       */
      lw ra,   0 * 4(sp)
      lw s0,   1 * 4(sp)
      lw s1,   2 * 4(sp)
#if ALT_CPU_NUM_GPR == 32
      lw s2,   3 * 4(sp)
      lw s3,   4 * 4(sp)
      lw s4,   5 * 4(sp)
      lw s5,   6 * 4(sp)
      lw s6,   7 * 4(sp)
      lw s7,   8 * 4(sp)
      lw s8,   9 * 4(sp)
      lw s9,  10 * 4(sp)
      lw s10, 11 * 4(sp)
      lw s11, 12 * 4(sp)
      lw tp,  14 * 4(sp)
      /* 
       * Restore the callee-saved registers, thread pointer (tp), return address (ra) from the stack, +1 for the impure ptr.
       */
      addi sp, sp, (14 + 1) * 4
#else // 16 (RV32E)
      lw tp, 4 * 4(sp)
      addi sp, sp, (4 + 1) * 4
#endif

      /*
       * resume execution of the new task.
       */
      ret

.set OSCtxSw_SWITCH_PC,0b-OSCtxSw

/*********************************************************************************************************
 *                                        START THE HIGHEST PRIORITY TASK
 *                                           void OSStartHighRdy(void)
 *
 * Note(s): 1) Upon entry, 
 *             OSTCBCur     points to the OS_TCB of the task to suspend
 *             OSTCBHighRdy points to the OS_TCB of the task to resume
 *
 *********************************************************************************************************/
      .global OSStartHighRdy            

OSStartHighRdy:
      /*
       * disable interrupts so that the scheduler doesn't run while
       * we're initialising this task.
       */  
       li t0, 0x8
       csrc mstatus, t0

      /*
       * Call the user definable OSTaskSWHook()
       */
      call OSTaskSwHook

      /* 
       * set OSRunning = TRUE.
       */
       la t1, OSRunning
       li t0, 1      /* set t0 to the value 'TRUE' */
       sb t0, 0(t1)  /* save this to OSRunning */

      /*
       * start execution of the new task.
       */
      j 9b

/*********************************************************************************************************
 *                                        CALL THE TASK INITILISATION FUNCTION
 *                                           void OSStartTsk(void)
 *********************************************************************************************************/

      .global OSStartTsk           

OSStartTsk:
      /* This instruction is never executed.  Its here to make the
       * backtrace work right... TODO: Is this valid for Nios V??
       */
      li sp, 0

      /* Enable interrupts */
      li t0, 0x8
      csrs mstatus, t0

      lw a0, 0(sp)
      lw t1, 4(sp)

      addi sp, sp, 8

      jalr t1

      nop
