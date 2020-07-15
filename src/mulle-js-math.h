//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef mulle_js_math_h__
#define mulle_js_math_h__

/*
 * add Math package (Math.cos, Math.PI) to mujs
 */
void  mulle_js_init_javascript_math( void *J);

/*
 * add C global functions and constants like "cos", "M_PI" to mujs
 */
void  mulle_js_init_c_math( void *J);

#endif
