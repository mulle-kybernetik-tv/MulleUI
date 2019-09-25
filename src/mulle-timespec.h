
#ifndef mulle_timespec_h__
#define mulle_timespec_h__

typedef enum 
{
   MulleTimeSpecAscending = -1,
   MulleTimeSpecSame = 0,
   MulleTimeSpecDescending = 1
} mulle_timespec_comparison_t;


static inline mulle_timespec_comparison_t   timespec_compare( struct timespec a, 
                                                              struct timespec b)
{
   if( a.tv_sec > b.tv_sec)
      return( MulleTimeSpecDescending);
   if( a.tv_sec < b.tv_sec)
      return( MulleTimeSpecAscending);
   if( a.tv_nsec > b.tv_nsec)
      return( MulleTimeSpecDescending);
   if( a.tv_nsec < b.tv_nsec)
      return( MulleTimeSpecAscending);
   return( MulleTimeSpecSame);
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



static inline struct timespec   timespec_diff( struct timespec start, struct timespec end)
{
   struct timespec temp;

   if ((end.tv_nsec-start.tv_nsec) < 0)
   {
      temp.tv_sec  = end.tv_sec-start.tv_sec - 1;
      temp.tv_nsec = 1000000000 + end.tv_nsec - start.tv_nsec;
   } else
   {
      temp.tv_sec = end.tv_sec-start.tv_sec;
      temp.tv_nsec = end.tv_nsec-start.tv_nsec;
   }
   return( temp);
}

#endif
