//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#include "mulle-js-math.h"

#include "include-private.h"

#include "mulle-js-private.h"

#include <math.h>
#include <string.h>
#include <stdlib.h>


/*
 * Math
 */
#define define_math_function_1( functionname)                \
static void   Math_prototype_ ## functionname(js_State *J)   \
{                                                            \
   double   value;                                           \
   double   result;                                          \
                                                             \
   value  = js_tonumber( J, 1);                              \
   result = functionname( value);                            \
                                                             \
   js_pushnumber( J, result);                                \
}


static void   Math_prototype_abs(js_State *J)
{
   double   value;
   double   result;

   value  = js_tonumber( J, 1);
   result = (double) fabs(value);

   js_pushnumber( J, result);
}


static void   Math_prototype_fround(js_State *J)
{
   double   value;
   double   result;

   value  = js_tonumber( J, 1);
   result = (float) value;

   js_pushnumber( J, result);
}


static void   Math_prototype_random(js_State *J)
{
   double   result;

   result = (double) rand() / ((double) RAND_MAX + 1);

   js_pushnumber( J, result);
}


static void   Math_prototype_sign(js_State *J)
{
   double   value;
   double   result;

   value  = js_tonumber( J, 1);
   result = (value < 0.0)
                  ? -1.0
                  : (value > 0.0) ? 1.0 : 0.0;

   js_pushnumber( J, result);
}


static void   Math_prototype_clz32(js_State *J)
{
   double   result;

#if __has_builtin(__builtin_clz)
   result = __builtin_clz( js_toint32( J, 1));
#else
   abort();
#endif

   js_pushnumber( J, result);
}



#define define_math_function_2( functionname)                \
static void   Math_prototype_ ## functionname( js_State *J)  \
{                                                            \
   double   x;                                               \
   double   y;                                               \
   double   result;                                          \
                                                             \
   x      = js_tonumber( J, 1);                              \
   y      = js_tonumber( J, 2);                              \
   result = functionname( x, y);                             \
                                                             \
   js_pushnumber( J, result);                                \
}

static void   Math_prototype_imul(js_State *J)
{
   int32_t  x;
   int32_t  y;
   double   result;

   x      = js_toint32( J, 1);
   y      = js_toint32( J, 2);
   result = x * y;

   js_pushnumber( J, result);
}


static void   Math_prototype_max(js_State *J)
{
   double  x;
   double  y;
   double  result;

   x      = js_tonumber( J, 1);
   y      = js_tonumber( J, 2);
   result = x > y ? x : y;

   js_pushnumber( J, result);
}


static void   Math_prototype_min(js_State *J)
{
   double   x;
   double   y;
   double   result;

   x      = js_tonumber( J, 1);
   y      = js_tonumber( J, 2);
   result = x < y ? x : y;

   js_pushnumber( J, result);
}


define_math_function_1( acos)
define_math_function_1( acosh)
define_math_function_1( asin)
define_math_function_1( asinh)
define_math_function_1( atan)
define_math_function_2( atan2)
define_math_function_1( atanh)
define_math_function_1( cbrt)
define_math_function_1( ceil)
define_math_function_1( cos)
define_math_function_1( cosh)
define_math_function_1( exp)
define_math_function_1( expm1)
define_math_function_1( floor)
define_math_function_2( hypot)
define_math_function_1( log)
define_math_function_1( log10)
define_math_function_1( log1p)
define_math_function_1( log2)
define_math_function_2( pow)
define_math_function_1( round)
define_math_function_1( sin)
define_math_function_1( sinh)
define_math_function_1( sqrt)
define_math_function_1( tan)
define_math_function_1( tanh)
define_math_function_1( trunc)


static struct mulle_js_function_table  Math_function_table[] =
{
   mulle_js_define_global( Math_prototype_abs, 1),
   mulle_js_define_global( Math_prototype_acos, 1),
   mulle_js_define_global( Math_prototype_acosh, 1),
   mulle_js_define_global( Math_prototype_asin, 1),
   mulle_js_define_global( Math_prototype_asinh, 1),
   mulle_js_define_global( Math_prototype_atan, 1),
   mulle_js_define_global( Math_prototype_atan2, 1),
   mulle_js_define_global( Math_prototype_atanh, 1),
   mulle_js_define_global( Math_prototype_cbrt, 1),
   mulle_js_define_global( Math_prototype_ceil, 1),
   mulle_js_define( Math_prototype_clz32, 1),
   mulle_js_define_global( Math_prototype_cos, 1),
   mulle_js_define_global( Math_prototype_cosh, 1),
   mulle_js_define_global( Math_prototype_exp, 1),
   mulle_js_define_global( Math_prototype_expm1, 1),
   mulle_js_define_global( Math_prototype_floor, 1),
   mulle_js_define( Math_prototype_fround, 1),
   mulle_js_define_global( Math_prototype_hypot, 1),
   mulle_js_define( Math_prototype_imul, 1),
   mulle_js_define_global( Math_prototype_log, 1),
   mulle_js_define_global( Math_prototype_log10, 1),
   mulle_js_define_global( Math_prototype_log1p, 1),
   mulle_js_define_global( Math_prototype_log2, 1),
   mulle_js_define_global( Math_prototype_max, 2),
   mulle_js_define_global( Math_prototype_min, 2),
   mulle_js_define_global( Math_prototype_pow, 2),
   mulle_js_define_global( Math_prototype_random, 1),
   mulle_js_define_global( Math_prototype_round, 1),
   mulle_js_define( Math_prototype_sign, 1),
   mulle_js_define_global( Math_prototype_sin, 1),
   mulle_js_define_global( Math_prototype_sinh, 1),
   mulle_js_define_global( Math_prototype_sqrt, 1),
   mulle_js_define_global( Math_prototype_tan, 1),
   mulle_js_define_global( Math_prototype_tanh, 1),
   mulle_js_define_global( Math_prototype_trunc, 1),
   { NULL, 0 }
};


static void  def_property_constant( js_State *J, char *name, double value)
{
   js_newnumber( J, value);
   js_defproperty( J, -2, name, JS_DONTENUM|JS_READONLY);
}


static void  def_global_constant( js_State *J, char *name, double value)
{
   js_newnumber( J, value);
   js_setglobal( J, name);
}



void  mulle_js_init_javascript_math( void *J)
{
   char   *s;

   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject( J);

   {
      struct mulle_js_function_table   *p;


      for( p = Math_function_table; p->name; ++p)
      {
         s = strrchr( p->name, '_');
         assert( s);
         ++s;

         js_newcfunction(J, p->f, p->name, p->n_args);
         js_defproperty(J, -2, s, JS_DONTENUM);
      }
   }

   def_property_constant( J, "E", M_E);
   def_property_constant( J, "LN10", M_LN10);
   def_property_constant( J, "LN2", M_LN2);
   def_property_constant( J, "LOG10E", M_LOG10E);
   def_property_constant( J, "PI", M_PI);
   def_property_constant( J, "SQRT1_2", M_SQRT1_2);
   def_property_constant( J, "SQRT_2", M_SQRT2);

   js_setglobal( J, "Math");
}


void  mulle_js_init_c_math( void *J)
{
   char   *s;

   {
      struct mulle_js_function_table   *p;

      for( p = Math_function_table; p->name; ++p)
      {
         if( ! p->is_global)
            continue;

         s = strrchr( p->name, '_');
         assert( s);
         ++s;

         js_newcfunction(J, p->f, p->name, p->n_args);
         js_setglobal( J, p->name);
      }
   }

   def_global_constant( J, "M_E", M_E);
   def_global_constant( J, "M_LN10", M_LN10);
   def_global_constant( J, "M_LN2", M_LN2);
   def_global_constant( J, "M_LOG10E", M_LOG10E);
   def_global_constant( J, "M_PI", M_PI);
   def_global_constant( J, "M_SQRT1_2", M_SQRT1_2);
   def_global_constant( J, "M_SQRT_2", M_SQRT2);
}

