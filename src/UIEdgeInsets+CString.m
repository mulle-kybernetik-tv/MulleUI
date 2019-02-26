#include "UIEdgeInsets+CString.h"
#include <stdio.h>
#include <mulle-allocator/mulle-allocator.h>
#include <MulleObjC/mulle-objc.h>



// cast this to CGRect as the code is identical ?
char   *UIEdgeInsetsCStringDescription( UIEdgeInsets insets)
{
   auto char   buf[ 256];
   char       *s;
   size_t      required;

   required = snprintf( buf, sizeof( buf), "%.2f %.2f %.2f %.2f",
            insets.top,
            insets.left,
            insets.bottom,
            insets.right);

   if( required >= sizeof( buf))
   {
      s = mulle_malloc( required + 1);
      sprintf( s, "%.2f %.2f %.2f %.2f",
            insets.top,
            insets.left,
            insets.bottom,
            insets.right);   
   }
   else
      s = mulle_strdup( buf);

   MulleObjCAutoreleaseAllocation( s, NULL);
   return( s);
}
