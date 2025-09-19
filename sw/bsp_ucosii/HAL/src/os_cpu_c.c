/***********************************************************************************************
 *                                               uC/OS-II
 *                                         The Real-Time Kernel
 * File         : os_cpu_c.c
 * For          : uC/OS Real-time multitasking kernel for the Nios V soft core processor
 * Written by   : NK
 * Based on     : Nios port done by JS
 *
 * Functions defined in this module:
 *
 ***********************************************************************************************/
#include <string.h>
#include <stddef.h>

#define  OS_CPU_GLOBALS
#include "includes.h" /* Standard includes for uC/OS-II */

#include "sys/alt_tls.h"
#include "system.h"

/* Pull in the Newlib reentrancy struct only as needed */
#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
#include <reent.h>
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */

/* This used to be
 *    extern alt_u32 OSStartTsk;  
 * but that results in a fatal error when compiling -mgpopt=global
 * because gcc assumes they are normal C variables in .sdata
 * and therefore addressable from gp using a 16-bit offset,
 * when in fact they are special values defined by linker.x
 * and located nowhere near .sdata. 
 * Specifying __attribute__((section(".data"))) will force these
 * in .data. (CASE:258384 or CASE:362640)
 */
extern alt_u32 OSStartTsk __attribute__((section(".data")));    /* The entry point for all tasks. */

extern char __tls_size[]; 

#if OS_TMR_EN > 0
static  INT16U  OSTmrCtr;
#endif

#ifdef ALT_CPU_EIC_PRESENT
#error Nios V does not support uC/OS-II if EIC is enabled.
#endif

/*
*********************************************************************************************************
*                                        INITIALIZE A TASK'S STACK
*
* Description: This function is called by either OSTaskCreate() or OSTaskCreateExt() to initialize the
*              stack frame of the task being created.  This function is highly processor specific.
*
* Arguments  : task          is a pointer to the task code
*
*              p_arg         is a pointer to a user supplied data area that will be passed to the task
*                            when the task first executes.
*
*              p_tos         is a pointer to the top of stack.  It is assumed that 'ptos' points to
*                            a 'free' entry on the task stack.  If OS_STK_GROWTH is set to 1 then
*                            'ptos' will contain the HIGHEST valid address of the stack.  Similarly, if
*                            OS_STK_GROWTH is set to 0, the 'ptos' will contains the LOWEST valid address
*                            of the stack.
*
*              opt           specifies options that can be used to alter the behavior of OSTaskStkInit().
*                            (see uCOS_II.H for OS_TASK_OPT_xxx).
*
* Returns    : Always returns the location of the new top-of-stack once the processor registers have
*              been placed on the stack in the proper order.
*
* Note        : We will save these 12 callee-saved registers + ra, tp = 14 registers to save
*               ra, tp, fp, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11
*********************************************************************************************************
*/
OS_STK  *OSTaskStkInit (void   (*task)(void *p_arg),
                        void    *p_arg,
                        OS_STK  *p_tos,
                        INT16U  opt)
{
    OS_STK   *frame_pointer;
    OS_STK   *p_stk;

/* First set up the rentrancy struct if Newlib and C library thread safety is required */
#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
   struct _reent* local_impure_ptr;   

    /* 
    * create and initialise the impure pointer used for Newlib thread local storage.
    * This is only done if the C library is being used in a thread safe mode. Otherwise
    * a single reent structure is used for all threads, which saves memory.
    */
    local_impure_ptr = (struct _reent*)(((OS_STK)(p_tos) & ~0xF) - sizeof(struct _reent));
    _REENT_INIT_PTR (local_impure_ptr);
     
    /* 
    * create a stack frame below the top of the stack leaving space for the 
    * reentrant data structure.
    */
    frame_pointer = (OS_STK*) ((OS_STK)(local_impure_ptr) & ~0xF);
#else
    frame_pointer = (OS_STK*) ((OS_STK)(p_tos) & ~0xF);
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */

    /* Initialize thread local data if used, and reserve some space for it */
    void *local_tls_data = (void *) 0; /* Unused if there is no thread local data */
    if ((alt_u32)__tls_size > 0)
    {
        /* Set up thread-local support */
        local_tls_data = (void *)((OS_STK)(frame_pointer) - (OS_STK)__tls_size);
        alt_init_tls_block(local_tls_data);
        
        /* 
        * create a stack frame below the top of the stack leaving space for the 
        * thread local data.
        */
        frame_pointer = (OS_STK*) ((OS_STK)(local_tls_data) & ~0xF);
    }

#if ALT_CPU_NUM_GPR == 32
    p_stk = frame_pointer - (2 + 1 + 14); /* 2 for task + arg, 1 for impure pointer, 14 for the saved regs */
    /* Now fill the stack frame. */
    p_stk[16] = (OS_STK)task;           /* task address (ra) */
    p_stk[15] = (OS_STK)p_arg;          /* first register argument (a0) */
    p_stk[14] = (OS_STK)local_tls_data; /* TLS data pointer for this thread (tp) */
#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    p_stk[13] = (OS_STK)local_impure_ptr; /* value of _impure_ptr for this thread */
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */
#else  // 16 (RV32E)
    p_stk = frame_pointer - (2 + 1 + 4); /* 2 for task + arg, 1 for impure pointer, 4 for the saved regs */
    /* Now fill the stack frame. */
    p_stk[6] = (OS_STK)task;           /* task address (ra) */
    p_stk[5] = (OS_STK)p_arg;          /* first register argument (a0) */
    p_stk[4] = (OS_STK)local_tls_data; /* TLS data pointer for this thread (tp) */
#if defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC)
    p_stk[3] = (OS_STK)local_impure_ptr; /* value of _impure_ptr for this thread */
#endif /* defined(OS_THREAD_SAFE_C_LIBRARY) && !defined(USE_PICOLIBC) */
#endif /* ALT_CPU_NUM_GPR */

    p_stk[0]  = ((OS_STK)&OSStartTsk) + 4; /* return address (ra) */  

    /* The next three lines don't generate any code, they just put symbols into
    * the debug information which will later be used to navigate the thread
    * data structures
    */
    __asm__ (".set OSTCBNext_OFFSET,%0" :: "i" (offsetof(OS_TCB, OSTCBNext)));
    __asm__ (".set OSTCBPrio_OFFSET,%0" :: "i" (offsetof(OS_TCB, OSTCBPrio)));
    __asm__ (".set OSTCBStkPtr_OFFSET,%0" :: "i" (offsetof(OS_TCB, OSTCBStkPtr)));
  
    return p_stk;
}

#if OS_CPU_HOOKS_EN
/*
*********************************************************************************************************
*                                          TASK CREATION HOOK
*
* Description: This function is called when a task is created.
*
* Arguments  : ptcb   is a pointer to the task control block of the task being created.
*
* Note(s)    : 1) Interrupts are disabled during this call.
*********************************************************************************************************
*/
void OSTaskCreateHook (OS_TCB *ptcb)
{
    ptcb = ptcb;                       /* Prevent compiler warning */
}


/*
*********************************************************************************************************
*                                           TASK DELETION HOOK
*
* Description: This function is called when a task is deleted.
*
* Arguments  : ptcb   is a pointer to the task control block of the task being deleted.
*
* Note(s)    : 1) Interrupts are disabled during this call.
*********************************************************************************************************
*/
void OSTaskDelHook (OS_TCB *ptcb)
{
    ptcb = ptcb;                       /* Prevent compiler warning                                     */
}

/*
*********************************************************************************************************
*                                           TASK SWITCH HOOK
*
* Description: This function is called when a task switch is performed.  This allows you to perform other
*              operations during a context switch.
*
* Arguments  : none
*
* Note(s)    : 1) Interrupts are disabled during this call.
*              2) It is assumed that the global pointer 'OSTCBHighRdy' points to the TCB of the task that
*                 will be 'switched in' (i.e. the highest priority task) and, 'OSTCBCur' points to the
*                 task being switched out (i.e. the preempted task).
*********************************************************************************************************
*/
void OSTaskSwHook (void)
{
}

/*
*********************************************************************************************************
*                                           STATISTIC TASK HOOK
*
* Description: This function is called every second by uC/OS-II's statistics task.  This allows your
*              application to add functionality to the statistics task.
*
* Arguments  : none
*********************************************************************************************************
*/
void OSTaskStatHook (void)
{
}

/*
*********************************************************************************************************
*                                               TICK HOOK
*
* Description: This function is called every tick.
*
* Arguments  : none
*
* Note(s)    : 1) Interrupts may or may not be ENABLED during this call.
*********************************************************************************************************
*/

void OSTimeTickHook (void)
{
#if OS_TMR_EN > 0
    OSTmrCtr++;
    if (OSTmrCtr >= (OS_TICKS_PER_SEC / OS_TMR_CFG_TICKS_PER_SEC)) {
        OSTmrCtr = 0;
        OSTmrSignal();
    }
#endif
}

void OSInitHookBegin(void)
{
#if OS_TMR_EN > 0
    OSTmrCtr = 0;
#endif
}

void OSInitHookEnd(void)
{
}

void OSTaskIdleHook(void)
{
}

void  OSTaskReturnHook(OS_TCB  *ptcb)
{
}

void OSTCBInitHook(OS_TCB *ptcb)
{
}

#endif
