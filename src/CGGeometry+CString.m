#include "CGGeometry+CString.h"
#include <stdio.h>
#include <mulle-allocator/mulle-allocator.h>
#include <MulleObjC/mulle-objc.h>


char   *CGPointCStringDescription( CGPoint point)
{
   auto char   buf[ 256];
   auto char  *s;
   size_t      required;

   required = snprintf( buf, sizeof( buf), "%.2f %.2f",
            point.x,
            point.y);

   if( required >= sizeof( buf))
   {
      s = mulle_malloc( required + 1);
      sprintf( s, "%.2f %.2f",
            point.x,
            point.y);      
   }
   else
      s = mulle_strdup( buf);
      
   MulleObjCAutoreleaseAllocation( s);
   return( s);
}


char   *CGRectCStringDescription( CGRect rect)
{
   auto char   buf[ 256];
   char       *s;
   size_t      required;

   required = snprintf( buf, sizeof( buf), "%.2f %.2f %.2f %.2f",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);

   if( required >= sizeof( buf))
   {
      s = mulle_malloc( required + 1);
      sprintf( s, "%.2f %.2f %.2f %.2f",
            rect.origin.x,
            rect.origin.y,
            rect.size.width,
            rect.size.height);      
   }
   else
      s = mulle_strdup( buf);

   MulleObjCAutoreleaseAllocation( s, NULL);
   return( s);
}
