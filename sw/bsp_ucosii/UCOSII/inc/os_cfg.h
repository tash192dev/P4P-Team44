/*
*********************************************************************************************************
*                                              uC/OS-II
*                                        The Real-Time Kernel
*
*                    Copyright 1992-2020 Silicon Laboratories Inc. www.silabs.com
*
*                                 SPDX-License-Identifier: APACHE-2.0
*
*               This software is subject to an open source license and is distributed by
*                Silicon Laboratories Inc. pursuant to the terms of the Apache License,
*                    Version 2.0 available at www.apache.org/licenses/LICENSE-2.0.
*
*********************************************************************************************************
*/


/*
*********************************************************************************************************
*
*                                 uC/OS-II Configuration File for V2.9x
*
* Filename : os_cfg.h
* Version  : V2.93.00
*
* Note: This file is modified from the original and only contains a small subset
*       of the OS_* define statements.  The remaining defines live in 'system.h'
*       and are parametrized through BSP settings.
*********************************************************************************************************
*/
#ifndef OS_CFG_H
#define OS_CFG_H

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

#ifndef __ASSEMBLER__ 
#include "sys/alt_alarm.h"
#endif /* __ASSEMBLER__ */


/*
 * The following uC/OS configuration options have not been defined as
 * configuration options in Nios II IDE or BSP tools; therefore they are
 * defined here rather than in the generated system.h content. As long
 * as they appear here, you may change their values in this file to change
 * the setting
 */
                                       /* ---------------------- MISCELLANEOUS ----------------------- */
#define OS_APP_HOOKS_EN           1u   /* Application-defined hooks are called from the uC/OS-II hooks */
#define OS_EVENT_MULTI_EN         1u   /* Include code for OSEventPendMulti()                          */

                                       /* -------------------- MESSAGE MAILBOXES --------------------- */
#define OS_MBOX_PEND_ABORT_EN     1u   /*     Include code for OSMboxPendAbort()                       */

                                       /* ---------------------- MESSAGE QUEUES ---------------------- */
#define OS_Q_PEND_ABORT_EN        1u   /*     Include code for OSQPendAbort()                          */

                                       /* ------------------------ SEMAPHORES ------------------------ */
#define OS_SEM_PEND_ABORT_EN      1u   /*    Include code for OSSemPendAbort()                         */

                                                                                                                     
#include "system.h"

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __OS_CFG_H__ */
