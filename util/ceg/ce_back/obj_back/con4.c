#include "mach.h"
#include "back.h"

#undef con2

#ifdef BYTES_REVERSED
#define con2(w)		{ *data++ = ((w) >> 8); *data++ = (w);}
#else
#define con2(w)		{ *data++ = (w); *data++ = ((w)>>8);}
#endif

con4( l)
FOUR_BYTES l;
{
	if ((data_cnt -= 4) < 0) mem_data();
#ifdef WORDS_REVERSED
	con2( (int)(l>>16));
	con2( (int) l);
#else
	con2( (int) l);
	con2( (int) (l>>16));
#endif
}
