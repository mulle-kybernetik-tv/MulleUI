#define _GNU_SOURCE

#include "CATime.h"

#include <time.h>


CAAbsoluteTime   CAAbsoluteTimeNow( void)
{
   struct timespec start;

   clock_gettime( CLOCK_REALTIME, &start);
   return( CAAbsoluteTimeWithTimespec(start));
}
