#include <time.h>

#define YEARSIZE(year)	((year) % 4 ? 365 : 366)
#define FIRSTSUNDAY(t)	(((t)->tm_yday - (t)->tm_wday + 420) % 7)
#define SUNDAY(day, t)	((day) < 58 ? \
			  ((day) < FIRSTSUNDAY(t) ? FIRSTSUNDAY(t) :
static int
last_sunday(d, t)
	register int d;
	register struct tm *t;
{
	int first = FIRSTSUNDAY(t);

	if (d >= 58 && YEARSIZE(t->tm_year)) d++;
	if (d < first) return first;
	return d - (d - first) % 7;
}

extern struct tm *gmtime();

struct tm *
localtime(clock)
	long *clock;
{
	register struct tm *gmt;
	long cl;
	int begindst, enddst;
	extern int daylight;
	extern long timezone;

	tzset();
	cl = *clock - timezone;
	gmt = gmtime(&cl);
	if (daylight) {
		/* daylight saving time.
		   Unfortunately, rules differ for different countries.
		   Implemented here are heuristics that got it right
		   in Holland, over the last couple of years.
		   Of course, there is no algorithm. It is all
		   politics ...
		*/
		begindst = last_sunday(89, gmt); /* last Sun before Apr */
		enddst = last_sunday(272, gmt);  /* last Sun in Sep */
	    	if ((gmt->tm_yday>begindst ||
		     (gmt->tm_yday==begindst && gmt->tm_hour>=2)) &&
	    	    (gmt->tm_yday<enddst || 
		     (gmt->tm_yday==enddst && gmt->tm_hour<3))) {
			cl += 1*60*60;
			gmt = gmtime(&cl);
			gmt->tm_isdst++;
		}
	}
	return gmt;
}
