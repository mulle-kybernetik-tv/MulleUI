#include "CGGeometry.h"

char   *CGRectCStringDescription( CGRect rect);
char   *CGPointCStringDescription( CGPoint point);


static inline char   *CGVectorCStringDescription( CGVector point)
{
   return( CGPointCStringDescription( * (CGPoint *) &point));
}


static inline char   *CGSizeCStringDescription( CGSize size)
{
   return( CGPointCStringDescription( * (CGPoint *) &size));
}

