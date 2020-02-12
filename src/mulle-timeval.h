#ifndef mulle_timeval_h__
#define mulle_timeval_h__

#include "mulle-time.h"


static inline mulle_time_comparison_t   timeval_compare( struct timeval a,
                                                         struct timeval b)
{
   if( a.tv_sec > b.tv_sec)
      return( MulleTimeDescending);
   if( a.tv_sec < b.tv_sec)
      return( MulleTimeAscending);
   if( a.tv_usec > b.tv_usec)
      return( MulleTimeDescending);
   if( a.tv_usec < b.tv_usec)
      return( MulleTimeAscending);
   return( MulleTimeSame);
}


#ifndef US_IN_S
# define US_IN_S (1000L*1000L)
#endif

static inline struct timeval   timeval_add( struct timeval a,
                                            struct timeval b)
{
   struct timeval   result;
   int              carry;

   result.tv_usec = a.tv_usec + b.tv_usec;
   carry = result.tv_usec >= US_IN_S;
   if( carry)
      result.tv_usec -= US_IN_S;
   result.tv_sec = a.tv_sec + b.tv_sec + carry;
   return( result);
}


static inline struct timeval   timeval_sub( struct timeval a,
                                            struct timeval b)
{
   struct timeval   result;
   int               carry;

   result.tv_usec = a.tv_usec - b.tv_usec;
   carry = result.tv_usec < 0;
   if( carry)
      result.tv_usec += US_IN_S;
   result.tv_sec = a.tv_sec - b.tv_sec - carry;
   return( result);
}

#endif
