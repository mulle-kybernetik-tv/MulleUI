#import "nanovg+CString.h"


char   *_NVGtransformCStringDescription( _NVGtransform value)
{
   auto char   buf[ 256];
   char       *s;
   size_t      required;

   required = snprintf( buf, sizeof( buf), "%f %f %f %f %f %f",
            value[ 0], value[ 1], value[ 2],
            value[ 3], value[ 4], value[ 5]);


   if( required >= sizeof( buf))
   {
      s = mulle_malloc( required + 1);
      sprintf( s, "%f %f %f %f %f %f",
            value[ 0], value[ 1], value[ 2],
            value[ 3], value[ 4], value[ 5]);
   }
   else
      s = mulle_strdup( buf);

   MulleObjCAutoreleaseAllocation( s, NULL);
   return( s);
}


char   *NVGscissorCStringDescription( _NVGtransform value)
{
   auto char   buf[ 256];
   char       *s;
   size_t      required;

   required = snprintf( buf, sizeof( buf), "%f %f %f %f %f %f (%f %f)",
            value[ 0], value[ 1], value[ 2],
            value[ 3], value[ 4], value[ 5],
            value[ 6], value[ 7]);


   if( required >= sizeof( buf))
   {
      s = mulle_malloc( required + 1);
      sprintf( s, "%f %f %f %f %f %f (%f %f)",
            value[ 0], value[ 1], value[ 2],
            value[ 3], value[ 4], value[ 5],
            value[ 6], value[ 7]);

   }
   else
      s = mulle_strdup( buf);

   MulleObjCAutoreleaseAllocation( s, NULL);
   return( s);
}
