/*
 * PSP Software Development Kit - https://github.com/pspdev
 * -----------------------------------------------------------------------
 * Licensed under the BSD license, see LICENSE in PSPSDK root for details.
 *
 * pspexception_asm.S - Basic exception handler for applications.
 *
 * Copyright (c) 2005 James Forshaw <tyranid@gmail.com>
 *
 */

#include "as_reg_compat.h"

// Enable eret on LLVM
#define eret .word 0x42000018

	.set noreorder
	.set noat

#define BadVAddr $8  // Address for the most recent address-related exception
#define Status   $12 // Processor status and control
#define Cause    $13 // Cause of last general exception
#define EPC      $14 // Program counter at last exception
#define PRId     $15 // Processor identification and revision

#define FSR		 $31
#define FIR      $0

#define REG_GPR_0    (6*4)
#define REG_GPR_1	 (REG_GPR_0 + 4)
#define REG_GPR_2	 (REG_GPR_1 + 4)
#define REG_GPR_3	 (REG_GPR_2 + 4)
#define REG_GPR_4	 (REG_GPR_3 + 4)
#define REG_GPR_5	 (REG_GPR_4 + 4)
#define REG_GPR_6	 (REG_GPR_5 + 4)
#define REG_GPR_7	 (REG_GPR_6 + 4)
#define REG_GPR_8	 (REG_GPR_7 + 4)
#define REG_GPR_9	 (REG_GPR_8 + 4)
#define REG_GPR_10	 (REG_GPR_9 + 4)
#define REG_GPR_11	 (REG_GPR_10 + 4)
#define REG_GPR_12	 (REG_GPR_11 + 4)
#define REG_GPR_13	 (REG_GPR_12 + 4)
#define REG_GPR_14	 (REG_GPR_13 + 4)
#define REG_GPR_15	 (REG_GPR_14 + 4)
#define REG_GPR_16	 (REG_GPR_15 + 4)
#define REG_GPR_17	 (REG_GPR_16 + 4)
#define REG_GPR_18	 (REG_GPR_17 + 4)
#define REG_GPR_19	 (REG_GPR_18 + 4)
#define REG_GPR_20	 (REG_GPR_19 + 4)
#define REG_GPR_21	 (REG_GPR_20 + 4)
#define REG_GPR_22	 (REG_GPR_21 + 4)
#define REG_GPR_23	 (REG_GPR_22 + 4)
#define REG_GPR_24	 (REG_GPR_23 + 4)
#define REG_GPR_25	 (REG_GPR_24 + 4)
#define REG_GPR_26	 (REG_GPR_25 + 4)
#define REG_GPR_27	 (REG_GPR_26 + 4)
#define REG_GPR_28	 (REG_GPR_27 + 4)
#define REG_GPR_29	 (REG_GPR_28 + 4)
#define REG_GPR_30	 (REG_GPR_29 + 4)
#define REG_GPR_31	 (REG_GPR_30 + 4)

#define REG_STATUS	 (REG_GPR_31 + 4)
#define REG_LO  	 (REG_STATUS + 4)
#define REG_HI	     (REG_LO + 4)
#define REG_BADVADDR (REG_HI + 4)
#define REG_CAUSE	 (REG_BADVADDR + 4)
#define REG_EPC	 	 (REG_CAUSE + 4)

#define REG_FPR_0 	 (REG_EPC + 4)
#define REG_FPR_1	 (REG_FPR_0 + 4)
#define REG_FPR_2	 (REG_FPR_1 + 4)
#define REG_FPR_3	 (REG_FPR_2 + 4)
#define REG_FPR_4	 (REG_FPR_3 + 4)
#define REG_FPR_5	 (REG_FPR_4 + 4)
#define REG_FPR_6	 (REG_FPR_5 + 4)
#define REG_FPR_7	 (REG_FPR_6 + 4)
#define REG_FPR_8	 (REG_FPR_7 + 4)
#define REG_FPR_9	 (REG_FPR_8 + 4)
#define REG_FPR_10	 (REG_FPR_9 + 4)
#define REG_FPR_11	 (REG_FPR_10 + 4)
#define REG_FPR_12	 (REG_FPR_11 + 4)
#define REG_FPR_13	 (REG_FPR_12 + 4)
#define REG_FPR_14	 (REG_FPR_13 + 4)
#define REG_FPR_15	 (REG_FPR_14 + 4)
#define REG_FPR_16	 (REG_FPR_15 + 4)
#define REG_FPR_17	 (REG_FPR_16 + 4)
#define REG_FPR_18	 (REG_FPR_17 + 4)
#define REG_FPR_19	 (REG_FPR_18 + 4)
#define REG_FPR_20	 (REG_FPR_19 + 4)
#define REG_FPR_21	 (REG_FPR_20 + 4)
#define REG_FPR_22	 (REG_FPR_21 + 4)
#define REG_FPR_23	 (REG_FPR_22 + 4)
#define REG_FPR_24	 (REG_FPR_23 + 4)
#define REG_FPR_25	 (REG_FPR_24 + 4)
#define REG_FPR_26	 (REG_FPR_25 + 4)
#define REG_FPR_27	 (REG_FPR_26 + 4)
#define REG_FPR_28	 (REG_FPR_27 + 4)
#define REG_FPR_29	 (REG_FPR_28 + 4)
#define REG_FPR_30	 (REG_FPR_29 + 4)
#define REG_FPR_31	 (REG_FPR_30 + 4)

#define REG_FSR		 (REG_FPR_31 + 4)
#define REG_FIR      (REG_FSR + 4)
#define REG_FP       (REG_FIR + 4)

	.extern _pspDebugExceptRegs
	.extern _pspDebugTrapEntry

	.global pspDebugResumeFromException
	.ent    pspDebugResumeFromException
pspDebugResumeFromException:

	break

	.end    pspDebugResumeFromException

	.global _pspDebugExceptionHandler
	.ent    _pspDebugExceptionHandler
_pspDebugExceptionHandler:
	nop
	nop
	la		$v1, pspDebugResumeFromException
	mfc0    $v0, EPC
	beq     $v0, $v1, _pspDebugExceptionResume
	nop

	la		$v0, _pspDebugExceptRegs
	sw		$0, REG_GPR_0($v0)
	sw		$1, REG_GPR_1($v0)

	.word 0x40412000 // cfc0	$1, $4					# Get original v0
	sw		$1, REG_GPR_2($v0)
	.word 0x40412800 // cfc0 	$1, $5					# Get original v1
	sw		$1, REG_GPR_3($v0)
	sw		$4, REG_GPR_4($v0)
	sw		$5, REG_GPR_5($v0)
	sw		$6, REG_GPR_6($v0)
	sw		$7, REG_GPR_7($v0)
	sw		$8, REG_GPR_8($v0)
	sw		$9, REG_GPR_9($v0)
	sw		$10, REG_GPR_10($v0)
	sw		$11, REG_GPR_11($v0)
	sw		$12, REG_GPR_12($v0)
	sw		$13, REG_GPR_13($v0)
	sw		$14, REG_GPR_14($v0)
	sw		$15, REG_GPR_15($v0)
	sw		$16, REG_GPR_16($v0)
	sw		$17, REG_GPR_17($v0)
	sw		$18, REG_GPR_18($v0)
	sw		$19, REG_GPR_19($v0)
	sw		$20, REG_GPR_20($v0)
	sw		$21, REG_GPR_21($v0)
	sw		$22, REG_GPR_22($v0)
	sw		$23, REG_GPR_23($v0)
	sw		$24, REG_GPR_24($v0)
	sw		$25, REG_GPR_25($v0)
	sw		$26, REG_GPR_26($v0)
	sw		$27, REG_GPR_27($v0)
	sw		$28, REG_GPR_28($v0)
	sw		$29, REG_GPR_29($v0)
	sw		$30, REG_GPR_30($v0)
	sw		$31, REG_GPR_31($v0)

	mflo	$v1
	sw		$v1,  REG_LO($v0)
	mfhi	$v1
	sw		$v1,  REG_HI($v0)
	mfc0	$v1,  BadVAddr
	sw		$v1,  REG_BADVADDR($v0)
	mfc0	$v1,  Cause
	sw		$v1,  REG_CAUSE($v0)
	mfc0	$v1,  EPC
	sw		$v1,  REG_EPC($v0)
	mfc0	$v1,  Status
	sw		$v1,  REG_STATUS($v0)

# Check if cop1 is enable and skip if not
	lui		$a0, 0x2000
	and		$a0, $a0, $v1
	beq		$a0, $0, 1f
	nop

	swc1		$0, REG_FPR_0($v0)
	swc1		$1, REG_FPR_1($v0)
	swc1		$2, REG_FPR_2($v0)
	swc1		$3, REG_FPR_3($v0)
	swc1		$4, REG_FPR_4($v0)
	swc1		$5, REG_FPR_5($v0)
	swc1		$6, REG_FPR_6($v0)
	swc1		$7, REG_FPR_7($v0)
	swc1		$8, REG_FPR_8($v0)
	swc1		$9, REG_FPR_9($v0)
	swc1		$10, REG_FPR_10($v0)
	swc1		$11, REG_FPR_11($v0)
	swc1		$12, REG_FPR_12($v0)
	swc1		$13, REG_FPR_13($v0)
	swc1		$14, REG_FPR_14($v0)
	swc1		$15, REG_FPR_15($v0)
	swc1		$16, REG_FPR_16($v0)
	swc1		$17, REG_FPR_17($v0)
	swc1		$18, REG_FPR_18($v0)
	swc1		$19, REG_FPR_19($v0)
	swc1		$20, REG_FPR_20($v0)
	swc1		$21, REG_FPR_21($v0)
	swc1		$22, REG_FPR_22($v0)
	swc1		$23, REG_FPR_23($v0)
	swc1		$24, REG_FPR_24($v0)
	swc1		$25, REG_FPR_25($v0)
	swc1		$26, REG_FPR_26($v0)
	swc1		$27, REG_FPR_27($v0)
	swc1		$28, REG_FPR_28($v0)
	swc1		$29, REG_FPR_29($v0)
	swc1		$30, REG_FPR_30($v0)
	swc1		$31, REG_FPR_31($v0)

	cfc1 		$t0, FSR
	sw			$t0, REG_FSR($v0)
	cfc1		$t0, FIR
	sw			$t0, REG_FIR($v0)
	ctc1		$0, FSR			# Clear any cause flags

# Jump target for ignore cop1
1:

	sw			$sp, REG_FP($v0)

	la		$2, _pspDebugTrapEntry
	mtc0	$2, $14
	nop
	nop
	eret
	nop
	nop

	.end _pspDebugExceptionHandler

	.ent	_pspDebugExceptionResume

_pspDebugExceptionResume:

# Resume from the exception in user mode (possibly, could be kernel but we don't really know that)

	la		$v0, _pspDebugExceptRegs

	lw		$v1,  REG_STATUS($v0)

# Check if cop1 is enable and skip if not
	lui		$a0, 0x2000
	and		$a0, $a0, $v1
	beq		$a0, $0, 1f
	nop

	lwc1		$0, REG_FPR_0($v0)
	lwc1		$1, REG_FPR_1($v0)
	lwc1		$2, REG_FPR_2($v0)
	lwc1		$3, REG_FPR_3($v0)
	lwc1		$4, REG_FPR_4($v0)
	lwc1		$5, REG_FPR_5($v0)
	lwc1		$6, REG_FPR_6($v0)
	lwc1		$7, REG_FPR_7($v0)
	lwc1		$8, REG_FPR_8($v0)
	lwc1		$9, REG_FPR_9($v0)
	lwc1		$10, REG_FPR_10($v0)
	lwc1		$11, REG_FPR_11($v0)
	lwc1		$12, REG_FPR_12($v0)
	lwc1		$13, REG_FPR_13($v0)
	lwc1		$14, REG_FPR_14($v0)
	lwc1		$15, REG_FPR_15($v0)
	lwc1		$16, REG_FPR_16($v0)
	lwc1		$17, REG_FPR_17($v0)
	lwc1		$18, REG_FPR_18($v0)
	lwc1		$19, REG_FPR_19($v0)
	lwc1		$20, REG_FPR_20($v0)
	lwc1		$21, REG_FPR_21($v0)
	lwc1		$22, REG_FPR_22($v0)
	lwc1		$23, REG_FPR_23($v0)
	lwc1		$24, REG_FPR_24($v0)
	lwc1		$25, REG_FPR_25($v0)
	lwc1		$26, REG_FPR_26($v0)
	lwc1		$27, REG_FPR_27($v0)
	lwc1		$28, REG_FPR_28($v0)
	lwc1		$29, REG_FPR_29($v0)
	lwc1		$30, REG_FPR_30($v0)
	lwc1		$31, REG_FPR_31($v0)

	lw			$t0, REG_FSR($v0)
	li			$t1, 0xFFFC0F83
	and			$t0, $t0, $t1	# Clear the cause and flags before ret
	ctc1 		$t0, FSR
1:

#	lw		$0, REG_GPR_0($v0)
#	lw		$1, REG_GPR_1($v0)
# Don't do 2 yet
	lw		$3, REG_GPR_3($v0)
	lw		$4, REG_GPR_4($v0)
	lw		$5, REG_GPR_5($v0)
	lw		$6, REG_GPR_6($v0)
	lw		$7, REG_GPR_7($v0)
	lw		$8, REG_GPR_8($v0)
	lw		$9, REG_GPR_9($v0)
	lw		$10, REG_GPR_10($v0)
	lw		$11, REG_GPR_11($v0)
	lw		$12, REG_GPR_12($v0)
	lw		$13, REG_GPR_13($v0)
	lw		$14, REG_GPR_14($v0)
	lw		$15, REG_GPR_15($v0)
	lw		$16, REG_GPR_16($v0)
	lw		$17, REG_GPR_17($v0)
	lw		$18, REG_GPR_18($v0)
	lw		$19, REG_GPR_19($v0)
	lw		$20, REG_GPR_20($v0)
	lw		$21, REG_GPR_21($v0)
	lw		$22, REG_GPR_22($v0)
	lw		$23, REG_GPR_23($v0)
	lw		$24, REG_GPR_24($v0)
	lw		$25, REG_GPR_25($v0)
	lw		$26, REG_GPR_26($v0)
	lw		$27, REG_GPR_27($v0)
	lw		$28, REG_GPR_28($v0)
	lw		$29, REG_GPR_29($v0)
	lw		$30, REG_GPR_30($v0)
	lw		$31, REG_GPR_31($v0)

	lw		$1,  REG_EPC($v0)
	mtc0    $1,  EPC

# Restore 1 + 2 now
	lw		$1, REG_GPR_1($v0)
	lw		$2, REG_GPR_2($v0)

	nop
	nop
	eret

	.end	_pspDebugExceptionResume
