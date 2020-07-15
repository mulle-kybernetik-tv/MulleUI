//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifndef mulle_js_nanovg_private_h__
#define mulle_js_nanovg_private_h__

/*
 * Images are passed to nvgFunctions inside this wrapper. The flags are
 * used for repetition.
 */
struct mulle_js_nvgimage
{
   int      handle;
   float    width;
   float    height;
   int      flags;
};

#define MULLE_JS_NVGIMAGE_TAG   "nvgImage"


void   mulle_js_push_NVGContext( js_State *J, void *pointer, float w, float h);
void   mulle_js_push_NVGimage( js_State *J, int handle, float w, float h, int flags);
void   mulle_js_push_NVGcolor( js_State *J, struct NVGcolor color);

// ugliness...
int   mulle_js_parse_repetition( char *s, int flags);

#endif
