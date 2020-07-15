#include "include-private.h"

#include "mulle-js-private.h"


int   mulle_js_isdefined_registry( js_State *J, char *key)
{
   int   isdefined;

   js_getregistry( J, key);
   isdefined = js_isdefined( J, -1);
   js_pop( J, 1);
   return( isdefined);
}


int   mulle_js_isdefined_global( js_State *J, char *key)
{
   int   isdefined;

   js_getglobal( J, key);
   isdefined = js_isdefined( J, -1);
   js_pop( J, 1);
   return( isdefined);
}
