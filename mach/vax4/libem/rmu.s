        # $Header$
#include "em_abs.h"

.globl .rmu

.rmu:
	cmpl    r0,$4
	bneq	Lerr
	jsb	.rmu4
	pushl	r0
	rsb
Lerr:
	pushl	$EILLINS
	jmp     .fat
