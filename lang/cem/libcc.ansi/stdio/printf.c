/*
 * printf - write on the standard output stream
 */
/* $Header$ */

#include	<stdio.h>
#include	<stdarg.h>
#include	"loc_incl.h"

int
printf(const char *format, ...)
{
	va_list ap;
	int retval;

	va_start(ap, format);

	retval = _doprnt(format, ap, stdout);
	if (retval >= 0 && io_testflag(stdout,_IOLBF))
		if (fflush(stdout)) return EOF;

	va_end(ap);

	return retval;
}