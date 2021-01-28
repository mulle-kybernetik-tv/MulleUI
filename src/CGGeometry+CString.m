#import "CGGeometry+CString.h"

#import "import-private.h"

#include <stdio.h>

//
// todo: use MulleObjC_asprintf here
//
char   *CGPointCStringDescription( CGPoint point)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%.2f %.2f", point.x, point.y);
   return( s);
}


char   *CGRectCStringDescription( CGRect rect)
{
   auto char  *s;

   s = MulleObjC_asprintf( "%.2f %.2f %.2f %.2f",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);
   return( s);
}
