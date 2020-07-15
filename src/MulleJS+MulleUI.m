//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "MulleJS+MulleUI.h"

#import "import-private.h"

#import "CALayer.h"
#import "UIImage.h"
#import "CGContext.h"
#include "mulle-js-private.h"
#include "mulle-js-math.h"
#include "mulle-js-nanovg.h"
#include "mulle-js-nanovg-private.h"
#include <math.h>


@implementation MulleJS ( MulleUI)

#define CGCONTEXT_TAG   "CGContext"

//
// we want "image name" and repetition optionally
//
static void   MulleJS_loadImage(js_State *J)
{
   char                  *s;
   NSString              *key;
   char                  *type;
   id                    value;
   MulleJS               *self;
   UIImage               *image;
   CGContext             *context;
   struct MulleJSImage   *pointer;
   char                  *repetition;
   int                   flags;
   CGSize                size;

   js_getregistry( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);
   js_pop( J, 1);

   // grab the UIImage from objectForKey:
   s     = (char *) js_tostring(J, 1);
   key   = @( s);
   image = [self objectForKey:key];
   if( ! [image isKindOfClass:[UIImage class]])
   {
      fprintf( stderr, "Could not retrieve image \"%s\"\n", s);
      js_pushundefined( J);
      return;
   }

   repetition = "";
   if( js_isdefined( J, 2))
      repetition = (char *) js_tostring(J, 2);
   flags   = mulle_js_parse_repetition( repetition, 0);
   context = [self objectForKey:@"CGContext"];

   image = [image imageWithNVGImageFlags:flags];
   size  = [image size];

   mulle_js_push_NVGimage( J,
                           [context registerTextureIDForImage:image],
                           size.width,
                           size.height,
                           flags);
}


void   mulle_js_push_CGContext( js_State *J, CGContext *context)
{
   js_getregistry(J, "CGContext");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J,
                     CGCONTEXT_TAG,
                     context,
                     0,
                     0,
                     0,
                     0);
}


- (void) uiPushValue:(id) value
              forKey:(NSString *) key
{
   struct js_State *J = _state;

   if( [key isEqualToString:@"nvgContext"])
   {
      mulle_js_push_NVGContext( J,
                                [value pointerValue],
                                [[self objectForKey:@"width"] doubleValue],
                                [[self objectForKey:@"height"] doubleValue]);
      return;
   }

   if( [key isEqualToString:@"CGContext"])
   {
      mulle_js_push_CGContext( J, value);
      return;
   }

   if( [key isEqualToString:@"background"])
   {
      struct NVGcolor   color;

      [value getBytes:&color];

      // value is a NSValue of CGColorRef
      mulle_js_push_NVGcolor( J, color);
      js_setglobal( J, "background");
   }

   js_pushundefined( J);
}


static void   MulleJS_objectForKey(js_State *J)
{
   char       *s;
   NSString   *key;
   char       *type;
   id         value;
   MulleJS    *self;
   void       *pointer;

   js_getregistry( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);

   s     = (char *) js_tostring(J, 1);
   key   = @( s);
   value = [self objectForKey:key];
   if( ! value)
   {
      js_pushundefined( J);
      return;
   }

   if( [value isKindOfClass:[NSValue class]])
   {
      type  = [value objCType];
      switch( *type)
      {
      case _C_SEL       :
      case _C_CHR       :
      case _C_BOOL      :
      case _C_UCHR      :
      case _C_SHT       :
      case _C_USHT      :
      case _C_INT       :
      case _C_UINT      :
      case _C_LNG       :
      case _C_ULNG      :
      case _C_LNG_LNG   :
      case _C_ULNG_LNG  :
      case _C_FLT       :
      case _C_DBL       :
      case _C_LNG_DBL   :
         js_pushnumber( J, [value doubleValue]);
         return;
      }
   }

   [self uiPushValue:value
              forKey:key];
}


// @property( assign) NSUInteger  value;
// @property( retain) id          other;
MULLE_OBJC_DEPENDS_ON_CATEGORY( MulleJS, Math);

// - (id) method:(id) other;
- (void) includeJavaScript
{
   js_State  *J = _state;

   js_newcfunction( J, MulleJS_loadImage, "loadImage", 1);
   js_setglobal( J, "loadImage");

   js_newcfunction(J, MulleJS_objectForKey, "$", 1);
   js_setglobal(J, "$");

   mulle_js_init_nanovg_global( self->_state);
}

@end

