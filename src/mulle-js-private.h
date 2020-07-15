#ifndef mulle_js_private_h__
#define mulle_js_private_h__

#define mulle_js_define( x, n)         { #x, x, n, 0 }
#define mulle_js_define_global( x, n)  { #x, x, n, 1 }


struct mulle_js_function_table
{
   char *name;
   void (*f)( js_State *);
   char  n_args;
   char  is_global;
};


int   mulle_js_isdefined_registry( js_State *J, char *key);
int   mulle_js_isdefined_global( js_State *J, char *key);

#endif
