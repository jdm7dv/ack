        # $Header$
#include "em_abs.h"

.globl .rck

.rck:
	cmpl    r0,$4
	bneq	Lerr
	jmp	.rck4
Lerr:
	pushl	$EILLINS
	jmp     .fat
