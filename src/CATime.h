#import "import.h"

#include <time.h>

typedef double    CARelativeTime;

static inline void   CARelativeTimeInit( CARelativeTime *p, double value)
{
   if( p)
      *p = value;
}


struct CARelativeTimeRange
{
   CARelativeTime   delay;
   CARelativeTime   duration;
};

static inline struct CARelativeTimeRange   
   CARelativeTimeRangeMake( CARelativeTime delay, CARelativeTime duration) 
{
    struct CARelativeTimeRange result = { delay, duration };
    return result;
}

static inline void   CARelativeTimeRangeInit( struct CARelativeTimeRange *p, 
                                              CARelativeTime delay,
                                              CARelativeTime duration)
{
   if( p)
   {
      p->delay    = delay;
      p->duration = duration;
   }
}


typedef double    CAAbsoluteTime;


static inline void   CAAbsoluteTimeInit( CAAbsoluteTime *p, double value)
{
   if( p)
      *p = value;
}

struct CAAbsoluteTimeRange
{
   CAAbsoluteTime   start;
   CAAbsoluteTime   end;
};

static inline struct CAAbsoluteTimeRange   
   CAAbsoluteTimeRangeMake( CAAbsoluteTime start, CAAbsoluteTime end) 
{
    struct CAAbsoluteTimeRange result = { start, end };
    return result;
}

static inline void   CAAbsoluteTimeRangeInit( struct CAAbsoluteTimeRange *p, 
                                              CAAbsoluteTime start,
                                              CAAbsoluteTime end)
{
   if( p)
   {
      p->start = start;
      p->end   = end;
   }
}


#ifndef NS_IN_S
# define NS_IN_S (1000*1000*1000)
#endif

static inline CAAbsoluteTime   CAAbsoluteTimeWithTimespec( struct timespec a)
{
   return( a.tv_sec + a.tv_nsec / (double) NS_IN_S);
}


static inline CAAbsoluteTime   CAAbsoluteTimeWithSecondsAndNanoseconds( int tv_sec, long tv_nsec)
{
   return( tv_sec + tv_nsec / (double) NS_IN_S);
}

static inline CARelativeTime   CARelativeTimeWithSecondsAndNanoseconds( int tv_sec, long tv_nsec)
{
   return( tv_sec + tv_nsec / (double) NS_IN_S);
}


static inline double   CATimeAdd( double a, double b)
{
   return( a + b);
}


static inline double   CATimeSubtract( double a, double b)
{
   return( a - b);
}
