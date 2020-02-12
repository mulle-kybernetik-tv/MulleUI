
#ifndef mulle_timespec_h__
#define mulle_timespec_h__

#include "mulle-time.h"


static inline mulle_time_comparison_t   timespec_compare( struct timespec a,
                                                          struct timespec b)
{
   if( a.tv_sec > b.tv_sec)
      return( MulleTimeDescending);
   if( a.tv_sec < b.tv_sec)
      return( MulleTimeAscending);
   if( a.tv_nsec > b.tv_nsec)
      return( MulleTimeDescending);
   if( a.tv_nsec < b.tv_nsec)
      return( MulleTimeAscending);
   return( MulleTimeSame);
}


#ifndef NS_IN_S
# define NS_IN_S (1000*1000*1000)
#endif

static inline struct timespec   timespec_add( struct timespec a,
                                              struct timespec b)
{
   struct timespec   result;
   int               carry;

   result.tv_nsec = a.tv_nsec + b.tv_nsec;
   carry = result.tv_nsec >= NS_IN_S;
   if( carry)
      result.tv_nsec -= NS_IN_S;
   result.tv_sec = a.tv_sec + b.tv_sec + carry;
   return( result);
}


static inline struct timespec   timespec_sub( struct timespec a,
                                              struct timespec b)
{
   struct timespec   result;
   int               carry;

   result.tv_nsec = a.tv_nsec - b.tv_nsec;
   carry = result.tv_nsec < 0;
   if( carry)
      result.tv_nsec += NS_IN_S;
   result.tv_sec = a.tv_sec - b.tv_sec - carry;
   return( result);
}

#endif
