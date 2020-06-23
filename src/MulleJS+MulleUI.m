//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "MulleJS+MulleUI.h"

#import "import-private.h"

#import "CALayer.h"
#import "UIImage.h"
#import "CGContext.h"
#include <math.h>


@implementation MulleJS ( MulleUI)


#define CGCONTEXT_TAG      "CGContext"
#define NVGCONTEXT_TAG     "nvgContext"
#define NVGPAINT_TAG       "nvgPaint"
#define NVGCOLOR_TAG       "nvgColor"
#define MULLEJSIMAGE_TAG   "MulleJSImage"


static void   NVGContext_function_generic( js_State *J, 
                                           void (*f)( struct NVGcontext *))
{
   struct NVGcontext  *nvg;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   (*f)( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_function_generic_int( js_State *J, 
                                               void (*f)( struct NVGcontext *, int))
{
   struct NVGcontext  *nvg;
   int                 value;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   value = js_tointeger( J, 1 + offset);
 
   (*f)( nvg, value);
   
   js_pushundefined( J);
}

static void   NVGContext_function_generic_int2( js_State *J, 
                                               void (*f)( struct NVGcontext *, int, int))
{
   struct NVGcontext  *nvg;
   int                value1;
   int                value2;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   value1 = js_tointeger( J, 1 + offset);
   value2 = js_tointeger( J, 2 + offset);
 
   (*f)( nvg, value1, value2);
   
   js_pushundefined( J);
}



static void   NVGContext_function_generic_int4( js_State *J, 
                                               void (*f)( struct NVGcontext *, int, int, int, int))
{
   struct NVGcontext  *nvg;
   int                value1;
   int                value2;
   int                value3;
   int                value4;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   value1 = js_tointeger( J, 1 + offset);
   value2 = js_tointeger( J, 2 + offset);
   value3 = js_tointeger( J, 1 + offset);
   value4 = js_tointeger( J, 2 + offset);
 
   (*f)( nvg, value1, value2, value3, value4);
   
   js_pushundefined( J);
}


static void   NVGContext_function_generic_float( js_State *J, 
                                                 void (*f)( struct NVGcontext *, float))
{
   struct NVGcontext  *nvg;
   float              value;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   value = js_tonumber( J, 1 + offset);
 
   (*f)( nvg, value);
   
   js_pushundefined( J);
}


static void   NVGContext_function_generic_float2( js_State *J, 
                                                       void (*f)( struct NVGcontext *, float, float))
{
   struct NVGcontext  *nvg;
   float              x;
   float              y;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1 + offset);
   y = js_tonumber( J, 2 + offset);
 
   (*f)( nvg, x, y);
   
   js_pushundefined( J);
}


static void   NVGContext_function_generic_float3( js_State *J, 
                                                 void (*f)( struct NVGcontext *, float, float, float))
{
   struct NVGcontext  *nvg;
   float              x;
   float              y;
   float              w;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1 + offset);
   y = js_tonumber( J, 2 + offset);
   w = js_tonumber( J, 3 + offset);

   (*f)( nvg, x, y, w);
   
   js_pushundefined( J);
}


static void   NVGContext_function_generic_float4( js_State *J, 
                                                 void (*f)( struct NVGcontext *, float, float, float, float))
{
   struct NVGcontext  *nvg;
   float              x;
   float              y;
   float              w;
   float              h;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1 + offset);
   y = js_tonumber( J, 2 + offset);
   w = js_tonumber( J, 3 + offset);
   h = js_tonumber( J, 4 + offset);

   (*f)( nvg, x, y, w, h);
   
   js_pushundefined( J);
}


static void   NVGContext_function_save(js_State *J)
{
   NVGContext_function_generic( J, nvgSave);
}


/* only used globally */
static void   NVGContext_function_resetTransform(js_State *J)
{
   NVGContext_function_generic( J, nvgResetTransform);
}


/* only used by canvas */
static void   NVGContext_function_setTransform(js_State *J)
{
   struct NVGcontext  *nvg;
   float              a, b, c, d, e, f;
   int                offset;

   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   a = js_tonumber( J, 1 + offset);
   b = js_tonumber( J, 2 + offset);
   c = js_tonumber( J, 3 + offset);
   d = js_tonumber( J, 4 + offset);
   e = js_tonumber( J, 5 + offset);
   f = js_tonumber( J, 6 + offset);

   nvgResetTransform( nvg);
   nvgTransform( nvg, a, b, c, d, e, f);

   js_pushundefined( J);
}


static void   NVGContext_function_transform(js_State *J)
{
   struct NVGcontext  *nvg;
   float              a, b, c, d, e, f;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);


   a = js_tonumber( J, 1 + offset);
   b = js_tonumber( J, 2 + offset);
   c = js_tonumber( J, 3 + offset);
   d = js_tonumber( J, 4 + offset);
   e = js_tonumber( J, 5 + offset);
   f = js_tonumber( J, 6 + offset);

   nvgTransform( nvg, a, b, c, d, e, f);

   js_pushundefined( J);
}


static void   NVGContext_function_arc(js_State *J)
{
   struct NVGcontext   *nvg;
   float               cx, cy, r, startAngle, endAngle;
   int                 direction;
   int                 offset;

   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   direction   = NVG_CW;

   cx          = js_tonumber( J, 1 + offset);
   cy          = js_tonumber( J, 2 + offset);
   r           = js_tonumber( J, 3 + offset);
   startAngle  = js_tonumber( J, 4 + offset);
   endAngle    = js_tonumber( J, 5 + offset);
   if( js_isdefined( J, 6 + offset))
      direction = js_toboolean( J, 6 + offset) ? NVG_CCW : NVG_CW;

   nvgArc( nvg, cx, cy, r, startAngle, endAngle, direction);

   js_pushundefined( J);
}


static void   NVGContext_function_arcTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x1, y1, x2, y2, r;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x1 = js_tonumber( J, 1 + offset);
   y1 = js_tonumber( J, 2 + offset);
   x2 = js_tonumber( J, 3 + offset);
   y2 = js_tonumber( J, 4 + offset);
   r  = js_tonumber( J, 5 + offset);

   nvgArcTo( nvg, x1, y1, x2, y2, r);

   js_pushundefined( J);
}


static void   NVGContext_function_bezierCurveTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              c1x, c1y, c2x, c2y, x, y;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   c1x = js_tonumber( J, 1 + offset);
   c1y = js_tonumber( J, 2 + offset);
   c2x = js_tonumber( J, 3 + offset);
   c2y = js_tonumber( J, 4 + offset);
   x   = js_tonumber( J, 5 + offset);
   y   = js_tonumber( J, 6 + offset);

   nvgBezierTo( nvg, c1x, c1y, c2x, c2y, x, y);

   js_pushundefined( J);
}


static void   NVGContext_function_closePath(js_State *J)
{
   NVGContext_function_generic( J, nvgClosePath);   
}


static void   NVGpaint_free( js_State *J, void *data)
{
   mulle_free( data);
}


static void   NVGpaint_create(js_State *J, struct NVGpaint *paint)
{
   struct NVGpaint     *pointer;

   pointer  = mulle_malloc( sizeof( struct NVGpaint));
   *pointer = *paint;

   js_getregistry(J, "nvgPaint");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J, 
                   NVGPAINT_TAG, 
                   pointer, 
                   0,
                   0,
                   0,
                   NVGpaint_free);
}


static void   NVGContext_function_createLinearGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   struct NVGpaint     *pointer;
   float                sx, sy, ex, ey;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);


   sx = js_tonumber( J, 1 + offset);
   sy = js_tonumber( J, 2 + offset);
   ex = js_tonumber( J, 3 + offset);
   ey = js_tonumber( J, 4 + offset);

   paint = nvgLinearGradient( nvg, sx, sy, ex, ey, 
                              getNVGColor( 0x000000FF), getNVGColor( 0xFFFFFFFF));   

   NVGpaint_create( J, &paint);
}


static void   NVGContext_function_createRadialGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   float                cx1, cy1, cx2, cy2, inr, outr;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);


   cx1   = js_tonumber( J, 1 + offset);
   cy1   = js_tonumber( J, 2 + offset);
   inr   = js_tonumber( J, 3 + offset);
//   cx2   = js_tonumber( J, 4 + offset);   // ignore
//   cy2   = js_tonumber( J, 5 + offset);  // ignore
   outr  = js_tonumber( J, 6 + offset);

   paint = nvgRadialGradient( nvg, cx1, cy1, inr, outr, 
                              getNVGColor( 0x000000FF), getNVGColor( 0xFFFFFFFF));   

   NVGpaint_create( J, &paint);
}



static void   NVGContext_function_linearGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   float                sx, sy, ex, ey;
   struct NVGcolor      *color1;
   struct NVGcolor      *color2;
   int                  offset;

   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);


   sx     = js_tonumber( J, 1 + offset);
   sy     = js_tonumber( J, 2 + offset);
   ex     = js_tonumber( J, 3 + offset);
   ey     = js_tonumber( J, 4 + offset);
   color1 = js_touserdata( J, 5 + offset, NVGCOLOR_TAG);
   color2 = js_touserdata( J, 6 + offset, NVGCOLOR_TAG);

   if( ! color1 || ! color2)
   {
      js_pushundefined( J);
      return;
   }

   paint = nvgLinearGradient( nvg, sx, sy, ex, ey, *color1, *color2);   
   NVGpaint_create( J, &paint);
}


static void   NVGContext_function_boxGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   float                x, y, w, h, r, f;
   struct NVGcolor      *color1;
   struct NVGcolor      *color2;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x   = js_tonumber( J, 1 + offset);
   y   = js_tonumber( J, 2 + offset);
   w   = js_tonumber( J, 3 + offset);
   h   = js_tonumber( J, 4 + offset);
   r   = js_tonumber( J, 5 + offset);
   f   = js_tonumber( J, 6 + offset);
   color1 = js_touserdata( J, 7 + offset, NVGCOLOR_TAG);
   color2 = js_touserdata( J, 8 + offset, NVGCOLOR_TAG);

   if( ! color1 || ! color2)
   {
      js_pushundefined( J);
      return;
   }

   paint = nvgBoxGradient( nvg, x, y, w, h, r, f, *color1, *color2);   
   NVGpaint_create( J, &paint);
}


static void   NVGContext_function_radialGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   struct NVGpaint     *pointer;
   float                cx1, cy1, cx2, cy2, inr, outr;
   struct NVGcolor      *color1;
   struct NVGcolor      *color2;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   cx1   = js_tonumber( J, 1 + offset);
   cy1   = js_tonumber( J, 2 + offset);
   inr   = js_tonumber( J, 3 + offset);
   outr  = js_tonumber( J, 4 + offset);
   color1 = js_touserdata( J, 5 + offset, NVGCOLOR_TAG);
   color2 = js_touserdata( J, 6 + offset, NVGCOLOR_TAG);

   if( ! color1 || ! color2)
   {
      js_pushundefined( J);
      return;
   }

   paint = nvgRadialGradient( nvg, cx1, cy1, inr, outr, *color1, *color2);   
   NVGpaint_create( J, &paint);
}


static int   parse_repetition( char *s, int flags)
{
   if( ! s)
      return( flags);

   switch( *s)
   {
   case 'r' :
      if( ! strncmp( "repeat", s, 6))
      {
         s = &s[ 6];
         if( ! strcmp( "-x", s))
            flags = NVG_IMAGE_REPEATX;
         else
            if( ! strcmp( "-y", s))
               flags = NVG_IMAGE_REPEATY;
            else 
               flags = NVG_IMAGE_REPEATX | NVG_IMAGE_REPEATY;
      }
      break;

   case 'n' :
      if( ! strncmp( "no-repeat", s, 9))
         flags = 0;

   }
   return( flags);
}

//
// Images must be a power of two
//
static void   NVGContext_function_createPattern(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      *pointer;
   struct MulleJSImage  *image;
   char                 *repetition;
   int                  flags;
   int                  handle;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   image      = js_touserdata( J, 1, MULLEJSIMAGE_TAG);
   repetition = (char *) js_tostring( J, 2 + offset);

   flags = parse_repetition( repetition, NVG_IMAGE_REPEATX|NVG_IMAGE_REPEATY);
   if( ! image || flags != image->flags)
   {
      // must have used loadImage with proper repeat!
      js_pushundefined( J);
      return;
   }

   pointer  = mulle_malloc( sizeof( struct NVGpaint));
   *pointer = nvgImagePattern( nvg, 0, 0, image->width, image->height, 0, image->handle, 1.0);;

   js_getregistry(J, "nvgPaint");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J, 
                   NVGPAINT_TAG, 
                   pointer, 
                   0,
                   0,
                   0,
                   NVGpaint_free);
}


static void   NVGContext_function_imagePattern(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   float                ox, oy, ex, ey, angle, alpha;
   struct MulleJSImage  *image;
   struct NVGcolor      *color1;
   struct NVGcolor      *color2;
   int                  offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   ox    = js_tonumber( J, 1 + offset);
   oy    = js_tonumber( J, 2 + offset);
   ex    = js_tonumber( J, 3 + offset);
   ey    = js_tonumber( J, 4 + offset);
   angle = js_tonumber( J, 5 + offset);
   image = js_touserdata( J, 6 + offset, MULLEJSIMAGE_TAG);
   alpha = js_tonumber( J, 7 + offset);

   if( ! image)
   {
      js_pushundefined( J);
      return;
   }
   paint = nvgImagePattern( nvg, ox, oy, ex, ey, angle, image->handle, alpha);
   NVGpaint_create( J, &paint);
}



static void   NVGContext_function_quadraticCurveTo(js_State *J)
{
   NVGContext_function_generic_float4( J, nvgQuadTo);   
}

/* only used globally, not sure if argument shouldnt be a nvgColor */
static void   NVGContext_function_setStrokeColor(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGcolor           *color;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg   = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   color = js_touserdata( J, 1 + offset, NVGCOLOR_TAG);
   if( color)
      nvgStrokeColor( nvg, *color);

   js_pushundefined( J);
}


static void   NVGContext_function_setStrokePaint(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGpaint           *paint;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg   = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   paint = js_touserdata( J, 1 + offset, NVGPAINT_TAG);
   if( paint)
      nvgStrokePaint( nvg, *paint);

   js_pushundefined( J);
}



static void   NVGContext_function_setFillPaint(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGpaint           *paint;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg   = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   paint = js_touserdata( J, 1 + offset, NVGPAINT_TAG);
   if( paint)
      nvgFillPaint( nvg, *paint);

   js_pushundefined( J);
}



/* only used globally */ 
static void   NVGContext_function_setTextColor(js_State *J)
{
   struct NVGcontext  *nvg;
   NVGcolor           *textColor;
   NVGcolor           *backgroundColor;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg             = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   textColor       = js_touserdata( J, 1 + offset, NVGCOLOR_TAG);
   backgroundColor = js_touserdata( J, 2 + offset, NVGCOLOR_TAG);

   nvgTextColor( nvg, *textColor, *backgroundColor); // TODO: use textColor

   js_pushundefined( J);
}


/* only used globally */ 
static void   NVGContext_function_setFontFace(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *name;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg   = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   name  = (char *) js_tostring( J, 1 + offset);
   nvgFontFace( nvg, name);

   js_pushundefined( J);
}


static void   NVGContext_function_setFontSize(js_State *J)
{
   NVGContext_function_generic_float( J, nvgFontSize);   
}


static void   NVGContext_function_setFillColor(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGcolor           *color;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;

   nvg   = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);
   color = js_touserdata( J, 1 + offset, NVGCOLOR_TAG);
   if( color)
      nvgFillColor( nvg, *color);

   js_pushundefined( J);
}


/* only used globally */ 
static void   NVGContext_function_setLineCap(js_State *J)
{
   NVGContext_function_generic_int( J, nvgLineCap);   
}


/* only used globally */ 
static void   NVGContext_function_setFontBlur(js_State *J)
{
   NVGContext_function_generic_float( J, nvgFontBlur);   
}


/* only used globally */ 
static void   NVGContext_function_setTextLetterSpacing(js_State *J)
{
   NVGContext_function_generic_float( J, nvgTextLetterSpacing);   
}


/* only used globally */ 
static void   NVGContext_function_setTextLineHeight(js_State *J)
{
   NVGContext_function_generic_float( J, nvgTextLineHeight);   
}


/* only used globally */ 
static void   NVGContext_function_setTextAlign(js_State *J)
{
   NVGContext_function_generic_int( J, nvgTextAlign);   
}


/* only used globally */ 
static void   NVGContext_function_setFontFaceId(js_State *J)
{
   NVGContext_function_generic_int( J, nvgFontFaceId);   
}


/* only used globally */ 
static void   NVGContext_function_setPathWinding(js_State *J)
{
   NVGContext_function_generic_int( J, nvgPathWinding);   
}


/* only used globally */ 
static void   NVGContext_function_setMiterLimit(js_State *J)
{
   NVGContext_function_generic_float( J, nvgMiterLimit);   
}


/* only used globally */ 
static void   NVGContext_function_setStrokeWidth(js_State *J)
{
   NVGContext_function_generic_float( J, nvgStrokeWidth);   
}


/* only used globally */ 
static void   NVGContext_function_setGlobalCompositeOperation(js_State *J)
{
   NVGContext_function_generic_int( J, nvgGlobalCompositeOperation);   
}


/* only used globally */ 
static void   NVGContext_function_setShapeAntiAlias(js_State *J)
{
   NVGContext_function_generic_int( J, nvgShapeAntiAlias);   
}

/* only used globally */ 
static void   NVGContext_function_setBezierTessellation(js_State *J)
{
   NVGContext_function_generic_int( J, nvgBezierTessellation);   
}


/* only used globally */ 
static void   NVGContext_function_setGlobalAlpha(js_State *J)
{
   NVGContext_function_generic_float( J, nvgGlobalAlpha);   
}


/* only used globally */ 
static void   NVGContext_function_setGlobalCompositeBlendFunc(js_State *J)
{
   NVGContext_function_generic_int2( J, nvgGlobalCompositeBlendFunc);   
}

/* only used globally */ 
static void   NVGContext_function_setGlobalCompositeBlendFuncSeparate(js_State *J)
{
   NVGContext_function_generic_int4( J, nvgGlobalCompositeBlendFuncSeparate);   
}



static void   NVGContext_function_fillRect(js_State *J)
{
   struct NVGcontext   *nvg;
   CGRect              rect;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   rect.origin.x    = js_tonumber( J, 1 + offset);
   rect.origin.y    = js_tonumber( J, 2 + offset);
   rect.size.width  = js_tonumber( J, 3 + offset);
   rect.size.height = js_tonumber( J, 4 + offset);

   nvgBeginPath( nvg);
   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);
   nvgFill( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_function_fillText(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              x, y;
   float              maxWidth;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   text     = (char *) js_tostring( J, 1 + offset);
   x        = js_tonumber( J, 2 + offset);
   y        = js_tonumber( J, 3 + offset);
   maxWidth = js_tonumber( J, 4 + offset); // undefine == NAN

   nvgText( nvg, x, y, text, NULL);

   js_pushundefined( J);
}


/* only used globally */
static void   NVGContext_function_text(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              x, y;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x        = js_tonumber( J, 1 + offset);
   y        = js_tonumber( J, 2 + offset);
   text     = (char *) js_tostring( J, 3 + offset);
   // ignore, can't do it in javascript
   // end       = (char *) js_tostring( J, 4 + offset);
     
   nvgText( nvg, x, y, text, NULL);

   js_pushundefined( J);
}


/* only used globally */
static void   NVGContext_function_textBox(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              x, y;
   int                offset;
   float              w;

   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   x    = js_tonumber( J, 1 + offset);
   y    = js_tonumber( J, 2 + offset);
   w    = js_tonumber( J, 3 + offset);
   text = (char *) js_tostring( J, 4 + offset);
   // ignore, can't do it in javascript
   // end       = (char *) js_tostring( J, 5 + offset);
     
   nvgTextBox( nvg, x, y, w, text, NULL);

   js_pushundefined( J);
}


//
// can only do "width" for now
//
static void   NVGContext_function_measureText(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              bounds[ 4];
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   text = (char *) js_tostring( J, 1 + offset);

   nvgTextBounds( nvg, 0, 0, text, NULL, bounds);
   js_newobject( J);
   // [xmin,ymin, xmax,ymax]   
   js_newnumber( J, bounds[ 2]); // xmax
   js_defproperty(J, -2, "width", JS_DONTENUM);
}


static void   NVGContext_function_strokeRect(js_State *J)
{
   struct NVGcontext   *nvg;
   CGRect              rect;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   rect.origin.x    = js_tonumber( J, 1 + offset);
   rect.origin.y    = js_tonumber( J, 2 + offset);
   rect.size.width  = js_tonumber( J, 3 + offset);
   rect.size.height = js_tonumber( J, 4 + offset);

   nvgBeginPath( nvg);
   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);
   nvgStroke( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_function_rect(js_State *J)
{
   NVGContext_function_generic_float4( J, nvgRect);   
}


/* only called globally */
static void   NVGContext_function_circle(js_State *J)
{
   NVGContext_function_generic_float3( J, nvgCircle);   
}


/* only called globally */
static void   NVGContext_function_ellipse(js_State *J)
{
   NVGContext_function_generic_float4( J, nvgEllipse);   
}


/* only called globally */
static void   NVGContext_function_scissor(js_State *J)
{
   NVGContext_function_generic_float4( J, nvgScissor);   
}


/* only called globally */
static void   NVGContext_function_intersectScissor(js_State *J)
{
   NVGContext_function_generic_float4( J, nvgIntersectScissor);   
}


/* only called globally */
static void   NVGContext_function_resetScissor(js_State *J)
{
   NVGContext_function_generic( J, nvgResetScissor);   
}



/* only called globally */
static void   NVGContext_function_roundedRect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;
   float              radius;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   rect.origin.x    = js_tonumber( J, 1 + offset);
   rect.origin.y    = js_tonumber( J, 2 + offset);
   rect.size.width  = js_tonumber( J, 3 + offset);
   rect.size.height = js_tonumber( J, 4 + offset);
   radius           = js_tonumber( J, 5 + offset);
   nvgRoundedRect( nvg, rect.origin.x, 
                        rect.origin.y, 
                        rect.size.width, 
                        rect.size.height,
                        radius);   

   js_pushundefined( J);
}

/* only called globally */
static void   NVGContext_function_roundedRectVarying(js_State *J)
{
   struct NVGcontext  *nvg;
   float              value[ 8];
   int                offset;
   int                i;

   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   for( i = 1 + offset; i <= 8 + offset; i++)
      value[ 0] = js_tonumber( J, i);
   nvgRoundedRectVarying( nvg, value[ 0], value[ 1], value[ 2], value[ 3], 
                               value[ 4], value[ 5], value[ 6], value[ 7]);
   js_pushundefined( J);
}



// not working, need to figure out how to erase fb ?
static void   NVGContext_function_clearRect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;
   NSValue            *value;
   NVGcolor           backgroundColor;
   MulleJS            *self;
   int                offset;
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   rect.origin.x    = js_tonumber( J, 1 + offset);
   rect.origin.y    = js_tonumber( J, 2 + offset);
   rect.size.width  = js_tonumber( J, 3 + offset);
   rect.size.height = js_tonumber( J, 4 + offset);

   js_getglobal( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);
   js_pop( J, 1);

   value = [self objectForKey:@"backgroundColor"];
   [value getValue:&backgroundColor];

   nvgSave( nvg);
   {
      nvgBeginPath( nvg);
      nvgGlobalCompositeOperation( nvg, NVG_COPY);
      nvgFillColor( nvg, backgroundColor);
      nvgRect( nvg, rect.origin.x, 
                    rect.origin.y, 
                    rect.size.width, 
                    rect.size.height);   
      nvgFill( nvg);   
   }
   nvgRestore( nvg);

   js_pushundefined( J);
}


static void   NVGContext_function_drawImage(js_State *J)
{
   struct NVGcontext    *nvg;
   struct MulleJSImage  *image;    
   CGRect                src;
   CGRect                dst;
   struct NVGpaint       imagePaint;
   float                 ax, ay;
   int                offset;

   memset( &dst, 0, sizeof( dst));
   
   offset = 1;
   if( ! js_isuserdata( J, 0 + offset, NVGCONTEXT_TAG))
      offset = 0;
   nvg = js_touserdata( J, 0 + offset, NVGCONTEXT_TAG);

   image = js_touserdata( J, 1, MULLEJSIMAGE_TAG);
   if( ! image)
   {
      js_pushundefined( J);
      return;
   }

   src.origin.x    = 0;
   src.origin.y    = 0;
   src.size.width  = image->width;
   src.size.height = image->height;

   dst.size        = src.size;

   dst.origin.x    = js_tointeger( J, 2 + offset);
   dst.origin.y    = js_tointeger( J, 3 + offset);

   if( js_isdefined( J, 4 + offset))
   {
      dst.size.width  = js_tointeger( J, 4 + offset);
      dst.size.height = js_tointeger( J, 5 + offset);
   
      if( js_isdefined( J, 6 + offset))
      {
         src             = dst;
         dst.origin.x    = js_tointeger( J, 6 + offset);
         dst.origin.y    = js_tointeger( J, 7 + offset);

         if( js_isdefined( J, 8 + offset))
         {
            dst.size.width  = js_tointeger( J, 8 + offset);
            dst.size.height = js_tointeger( J, 9 + offset);
         }
      }
   }
   
	ax = dst.size.width / src.size.width;
	ay = dst.size.height / src.size.height;

	imagePaint = nvgImagePattern( nvg, 
                                 dst.origin.x - src.origin.x * ax, 
                                 dst.origin.x - src.origin.y * ay, 
                                 image->width * ax, 
                                 image->height * ay, 
                                 0, //0.0f/180.0f*NVG_PI, 
                                 image->handle, 
                                 1.0);
	nvgBeginPath( nvg);
	nvgRect( nvg, dst.origin.x, dst.origin.y, dst.size.width, dst.size.height);
	nvgFillPaint( nvg, imagePaint);
	nvgFill( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_function_beginPath(js_State *J)
{
   NVGContext_function_generic( J, nvgBeginPath);   
}


static void   NVGContext_function_moveTo(js_State *J)
{
   NVGContext_function_generic_float2( J, nvgMoveTo);   
}


static void   NVGContext_function_lineTo(js_State *J)
{
   NVGContext_function_generic_float2( J, nvgLineTo);   
}


static void   NVGContext_function_fill(js_State *J)
{
   NVGContext_function_generic( J, nvgFill);   
}


static void   NVGContext_function_stroke(js_State *J)
{
   NVGContext_function_generic( J, nvgStroke);   
}


static void   NVGContext_function_restore(js_State *J)
{
   NVGContext_function_generic( J, nvgRestore);   
}



static void   NVGContext_function_rotate(js_State *J)
{
   NVGContext_function_generic_float( J, nvgRotate);
}


static void   NVGContext_function_skewX(js_State *J)
{
   NVGContext_function_generic_float( J, nvgSkewX);
}


static void   NVGContext_function_skewY(js_State *J)
{
   NVGContext_function_generic_float( J, nvgSkewY);
}


static void   NVGContext_function_scale(js_State *J)
{
   NVGContext_function_generic_float2( J, nvgScale);
}


static void   NVGContext_function_translate(js_State *J)
{
   NVGContext_function_generic_float2( J, nvgTranslate);
}


static void   NVGcolor_free( js_State *J, void *data)
{
   mulle_free( data);
}

void  MulleColor_function_createGeneric(js_State *J, struct NVGcolor color)
{
   struct NVGcolor    *pointer;

   pointer  = mulle_malloc( sizeof( struct NVGcolor));
   *pointer = color;

   js_getregistry(J, "nvgColor");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J, 
                   NVGCOLOR_TAG, 
                   pointer, 
                   0,
                   0,
                   0,
                   NVGcolor_free);
}


static void  global_function_degToRad(js_State *J)
{
   double   value;

   value = js_tonumber( J, 1);
   js_pushnumber( J, nvgDegToRad( value));
}


static void  global_function_radToDeg(js_State *J)
{
   double   value;

   value = js_tonumber( J, 1);
   js_pushnumber( J, nvgRadToDeg( value));
}


void  MulleColor_function_createRGBf(js_State *J)
{
   float              rgba[ 3];
   struct NVGcolor    color;

   rgba[ 0] = js_tonumber( J, 1);
   rgba[ 1] = js_tonumber( J, 2);
   rgba[ 2] = js_tonumber( J, 3);

   color = nvgRGBf( rgba[ 0], rgba[ 1], rgba[ 2]);
   MulleColor_function_createGeneric( J, color);
}


void  MulleColor_function_createRGBAf(js_State *J)
{
   float              rgba[ 4];
   struct NVGcolor    color;

   rgba[ 0] = js_tonumber( J, 1);
   rgba[ 1] = js_tonumber( J, 2);
   rgba[ 2] = js_tonumber( J, 3);
   rgba[ 3] = js_tonumber( J, 4);

   color = nvgRGBAf( rgba[ 0], rgba[ 1], rgba[ 2], rgba[ 3]);
   MulleColor_function_createGeneric( J, color);
}


void  MulleColor_function_createHSL(js_State *J)
{
   float              hsl[ 3];
   struct NVGcolor    color;

   hsl[ 0] = js_tonumber( J, 1);
   hsl[ 1] = js_tonumber( J, 2);
   hsl[ 2] = js_tonumber( J, 3);

   color = nvgHSL( hsl[ 0],  hsl[ 1],  hsl[ 2]);
   MulleColor_function_createGeneric( J, color);
}


void  MulleColor_function_createLerpRGBA(js_State *J)
{
   float              value;
   struct NVGcolor    *color1;
   struct NVGcolor    *color2;
   struct NVGcolor    color;

   color1 = js_touserdata( J, 1, NVGCOLOR_TAG);
   color2 = js_touserdata( J, 2, NVGCOLOR_TAG);
   value  = js_tonumber( J, 3);

   if( color1 && color2)
   {
      color = nvgLerpRGBA( *color1,  *color2,  value);
      MulleColor_function_createGeneric( J, color);
   }
}


void  MulleColor_function_createFromCString(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *s;
   struct NVGcolor    color;

   s     = (char *) js_tostring( J, 1);
   color = MulleColorCreateFromCString( s);

   MulleColor_function_createGeneric( J, color);
}


typedef void  NVGcontextPropertyFunction( struct NVGcontext *, js_State *);

struct mulle_cstringfunctionpointerpair
{
   char                        *name;
   NVGcontextPropertyFunction  *f;
};


static struct mulle_cstringfunctionpointerpair
   *mulle_cstringfunctionpointerpair_bsearch( struct mulle_cstringfunctionpointerpair *buf,
                                              unsigned int n,
                                              char *search)
{
   int                                       first;
   int                                       diff;
   int                                       last;
   int                                       middle;
   struct mulle_cstringfunctionpointerpair   *p;

   assert( search);

   first  = 0;
   last   = n - 1;
   middle = (first + last) / 2;

   while( first <= last)
   {
      p    = &buf[ middle];
      diff = strcmp( p->name, search);
      if( diff <= 0)
      {
         if( ! diff)
            return( p);

         first = middle + 1;
      }
      else
         last = middle - 1;

      middle = (first + last) / 2;
   }

   return( NULL);
}


static void   NVGContext_setter_GlobalAlpha( struct NVGcontext *nvg, js_State *J)
{
   float      value;
   NVGcolor   color;

   value = js_tonumber( J, -1);
   nvgGlobalAlpha(nvg, value);
}


static int   parse_composite_operation( char *s)
{
   if( ! s)
      return( NVG_SOURCE_OVER);
   switch( *s)
   {
   case 's' :
      if( ! strncmp( "source-", s, 7))
      {
         s += 7;
         if( ! strcmp( "atop", s))
            return( NVG_ATOP);
         if( ! strcmp( "in", s))
            return( NVG_SOURCE_IN);
         if( ! strcmp( "out", s))
            return( NVG_SOURCE_OUT);
         return( NVG_SOURCE_OVER);
      }
   case 'd' :
      if( ! strncmp( "destination-", s, 12))
      {
         s += 12;
         if( ! strcmp( "atop", s))
            return( NVG_DESTINATION_ATOP);
         if( ! strcmp( "in", s))
            return( NVG_DESTINATION_IN);
         if( ! strcmp( "out", s))
            return( NVG_DESTINATION_OUT);
         if( ! strcmp( "over", s))
            return( NVG_DESTINATION_OUT);
         return( NVG_SOURCE_OVER);
      }
   case 'l' :
      if( ! strcmp( "lighter", s))
         return( NVG_LIGHTER);
   case 'c' :
      if( ! strcmp( "copy", s))
         return( NVG_COPY);
       // penalize mistakes
   case 'x' :
      if( ! strcmp( "xor", s))
         return( NVG_XOR);
   }   
   return( NVG_SOURCE_OVER);
}


static void   NVGContext_setter_GlobalCompositeOperation( struct NVGcontext *nvg, js_State *J)
{
   int        value;
   char       *s;

   s     = (char *) js_tostring( J, -1);
   value = parse_composite_operation( s);
   nvgGlobalCompositeOperation(nvg, value);
}


static void   NVGContext_setter_LineCap( struct NVGcontext *nvg, js_State *J)
{
   char       *s;
   NVGcolor   color;
   int        cap;

   cap = NVG_BUTT;
   s    = (char *) js_tostring( J, -1);
   if( ! strcmp( s, "round"))
      cap = NVG_ROUND;
   else
      if( ! strcmp( s, "square"))
       cap = NVG_SQUARE;

   nvgLineCap(nvg, cap);
}


static void   NVGContext_setter_LineJoin( struct NVGcontext *nvg, js_State *J)
{
   char       *s;
   NVGcolor   color;
   int        join;

   join = NVG_MITER;
   s    = (char *) js_tostring( J, -1);
   if( ! strcmp( s, "round"))
      join = NVG_ROUND;
   else
      if( ! strcmp( s, "bevel"))
       join = NVG_BEVEL;

   nvgLineJoin(nvg, join);
}


static void   NVGContext_setter_LineWidth( struct NVGcontext *nvg, js_State *J)
{
   float      value;
   NVGcolor   color;

   value = js_tonumber( J, -1);
   nvgStrokeWidth(nvg, value);
}


static void   NVGContext_setter_MiterLimit( struct NVGcontext *nvg, js_State *J)
{
   float      value;
   NVGcolor   color;

   value = js_tonumber( J, -1);
   nvgMiterLimit(nvg, value);
}


static void   NVGContext_setter_FillStyle( struct NVGcontext *nvg, js_State *J)
{
   char               *style;
   MulleJS            *self;
   NSValue            *value;
   NVGcolor           backgroundColor;
   NVGcolor           color;
   struct NVGpaint    *paint;

   if( ! js_isstring( J, -1))
   {
      paint = js_touserdata( J, -1, NVGPAINT_TAG);
      if( paint)
         nvgFillPaint(nvg, *paint);
      return;
   }

   style = (char *) js_tostring( J, -1);
   color = MulleColorCreateFromCString( style);

   js_getglobal( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);
   js_pop( J, 1);

   value = [self objectForKey:@"backgroundColor"];
   [value getValue:&backgroundColor];

   nvgTextColor( nvg, color, backgroundColor); // TODO: use textColor
   nvgFillColor( nvg, color);
}


static void   NVGContext_setter_Font( struct NVGcontext *nvg, js_State *J)
{
   char    *fontname;
   char    *end;
   float   fontsize;

   fontname = (char *) js_tostring( J, -1);
   if( ! fontname)
      return;
   
   fontsize = strtod( fontname, &end);
   if( end != fontname)
   {
      fontname = end;
      if( ! strncmp( "px", fontname, 2))
        fontname += 2; 
   }
   else
      fontsize = 10.0;

   while( *fontname == ' ')
      ++fontname;

	nvgFontSize( nvg, fontsize);
   if( *fontname)
      nvgFontFace( nvg, fontname);
}



static void   NVGContext_setter_StrokeStyle( struct NVGcontext *nvg, js_State *J)
{
   char                  *style;
   NVGcolor              color;
   struct NVGpaint      *paint;

   if( js_isstring( J, -1))
   {
      style = (char *) js_tostring( J, -1);
      color = MulleColorCreateFromCString( style);
      nvgStrokeColor(nvg, color);
      return;
   }

   paint = js_touserdata( J, -1, NVGPAINT_TAG);
   if( paint)
      nvgStrokePaint(nvg, *paint);
}


static void   NVGContext_setter_TextAlign( struct NVGcontext *nvg, js_State *J)
{
   int    align;
   char   *s;

   align = NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE;

   // start, end, left, right or center

   s = (char *) js_tostring( J, -1);
   if( s)
   {
      switch( *s)
      {
      case 's' :
         if( ! strcmp( "start", s))
            align = NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE;  // locale ?
         break;
      case 'e' :
         if( ! strcmp( "end", s))
            align = NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE;  // locale ?
         break;
      case 'l' :
         if( ! strcmp( "left", s))
            align = NVG_ALIGN_LEFT|NVG_ALIGN_MIDDLE;  
         break;
      case 'r' :
         if( ! strcmp( "right", s))
            align = NVG_ALIGN_RIGHT|NVG_ALIGN_MIDDLE; 
         break;
      case 'c' :
         if( ! strcmp( "center", s))
            align = NVG_ALIGN_CENTER|NVG_ALIGN_MIDDLE;  
         break;
      }
   }
   nvgTextAlign(nvg, align);
}


// data           -
// fillStyle      	   
// font 	         
// globalAlpha
// globalCompositeOperation
// height         -   	
// lineCap 	      
// lineJoin 	   
// lineWidth 	   
// miterLimit 	   
// shadowBlur 	   -
// shadowColor 	-
// shadowOffsetX 	-
// shadowOffsetY 	-
// strokeStyle    	
// textAlign 	
// textBaseline 	-
// width 	      

static struct mulle_cstringfunctionpointerpair   propertykey_table[] =
{
   { "fillStyle",    NVGContext_setter_FillStyle    },
   { "font",         NVGContext_setter_Font         },
   { "globalAlpha",  NVGContext_setter_GlobalAlpha  },
   { "globalCompositeOperation", NVGContext_setter_GlobalCompositeOperation },
   { "lineCap",      NVGContext_setter_LineCap      },
   { "lineJoin",     NVGContext_setter_LineJoin     },
   { "lineWidth",    NVGContext_setter_LineWidth    },
   { "miterLimit",   NVGContext_setter_MiterLimit   },
   { "strokeStyle",  NVGContext_setter_StrokeStyle  },
   { "textAlign",    NVGContext_setter_TextAlign    }
};


NVGcontextPropertyFunction  *mulle_propertyname_to_function( char *name)
{
   struct mulle_cstringfunctionpointerpair   *pair;

   if( ! name)
      return( 0);

   pair = mulle_cstringfunctionpointerpair_bsearch( propertykey_table,
                                            sizeof( propertykey_table) / sizeof( propertykey_table[ 0]),
                                            name);
   if( ! pair)
      return( 0);
   return( pair->f);
}


static int   NVGContext_GetProperty(js_State *J, void *userdata, const char *key)
{
   if( mulle_propertyname_to_function( (char *) key))
   {
      js_pushnumber(J, 0);
      return 1;
   }
   return 0;
}


static int   NVGContext_PutProperty(js_State *J, void *userdata, const char *key)
{
   char                        *style;
   NVGcolor                    color;
   struct NVGcontext           *nvg = userdata;
   NVGcontextPropertyFunction  *f;

   f = mulle_propertyname_to_function( (char *) key);
   if( f)
   {
      (*f)( nvg, J);  
      return 1;      // not popping because it crashes
   }
   return( 0);
}



static struct function_table  NVGContext_function_table[] = 
{
// arc() 	              
// arcTo() 	              
// beginPath()             
// bezierCurveTo() 	     
// clearRect() 	         
// clip() 	              nanovg can only clip to rectangles (add clipRect ?)       
// closePath()            	
// createEvent() 	        TODO ??? 
// createImageData()      TODO
// createLinearGradient() 
// createPattern() 	         
// createRadialGradient() 
// drawImage() 	        
// fill() 	            
// fillRect() 	         
// fillText()             
// getContext() 	        TODO  ???
// getImageData()         TODO
// isPointInPath() 	     nanovg currently doesn't support this (https://github.com/memononen/nanovg/issues/197)
// lineTo() 	        
// measureText() 	        TODO
// moveTo() 	         
// putImageData()         TODO
// quadraticCurveTo() 	  
// rect() 	                    
// restore() 
// rotate() 	      
// save() 	
// scale() 	                      
// setTransform() 	     
// stroke() 	         
// strokeRect()           	
// strokeText()           TODO ???
// toDataURL()            TODO ???
// transform() 	   
// translate()    	     


   mulle_js_define( NVGContext_function_arc, 6),
   mulle_js_define( NVGContext_function_arcTo, 5),
   mulle_js_define( NVGContext_function_beginPath, 0 ),
   mulle_js_define( NVGContext_function_bezierCurveTo, 6),
   mulle_js_define( NVGContext_function_clearRect, 4),  // needs fixing
   mulle_js_define( NVGContext_function_closePath, 0),
   mulle_js_define( NVGContext_function_createLinearGradient, 4),
   mulle_js_define( NVGContext_function_createPattern, 2),
   mulle_js_define( NVGContext_function_createRadialGradient, 6),
   mulle_js_define( NVGContext_function_drawImage, 9),
   mulle_js_define( NVGContext_function_fill, 0),
   mulle_js_define( NVGContext_function_fillRect, 4),
   mulle_js_define( NVGContext_function_fillText, 4),
   mulle_js_define( NVGContext_function_lineTo, 2),
   mulle_js_define( NVGContext_function_measureText, 1),
   mulle_js_define( NVGContext_function_moveTo, 2),
   mulle_js_define( NVGContext_function_quadraticCurveTo, 4),
   mulle_js_define( NVGContext_function_rect, 4),
   mulle_js_define( NVGContext_function_restore, 0),
   mulle_js_define( NVGContext_function_rotate, 1),
   mulle_js_define( NVGContext_function_save, 0),
   mulle_js_define( NVGContext_function_scale, 2),
   mulle_js_define( NVGContext_function_setTransform, 6),
   mulle_js_define( NVGContext_function_stroke, 0),
   mulle_js_define( NVGContext_function_strokeRect, 4),
   mulle_js_define( NVGContext_function_translate, 2),
   mulle_js_define( NVGContext_function_transform, 6),
   { NULL, 0 }
};


void   MulleJS_initNVGcontext( MulleJS *self)
{
   NSValue              *value;
   struct NVGcontext    *nvg;
   js_State             *J;
   char                 *s;

   J = self->_state;

// create a new property object
   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject(J);

   // our object ( now on the stack)

   {
      struct function_table   *p;

      for( p = NVGContext_function_table; p->name; ++p)
      {
         s = strrchr( p->name, '_');
         assert( s);
         ++s;

         js_newcfunction(J, p->f, p->name, p->n_args);
         js_defproperty(J, -2, s, JS_DONTENUM);
      }
   }
   js_newcconstructor(J, 0, 0, "nvgContext", 0);
   js_setregistry( J, "nvgContext");
}   


/*
 * CGContext
 */ 
void   MulleJS_initCGContext( MulleJS *self)
{
   NSValue              *value;
   js_State             *J;
   char                 *s;

   J = self->_state;

// create a new property object
   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject(J);

   js_newcconstructor(J, 0, 0, "CGContext", 0);
   js_setregistry( J, "CGContext");
}   

/*
 * Paint
 */ 
static void   NVGpaint_prototype_addColorStop( js_State *J)
{
   struct NVGpaint   *paint;
   char              *style;
   NVGcolor          color;
   double            offset;

   paint  = js_touserdata( J, 0, NVGPAINT_TAG);
   offset = js_tonumber( J, 1);
   style  = (char *) js_tostring( J, 2 + offset);
   color  = MulleColorCreateFromCString( style);

   if( offset == 0.0)
      paint->innerColor = color;
   else
      if( offset == 1.0)
         paint->outerColor = color;
 
   js_pushundefined( J);
}



static struct function_table  NVGpaint_function_table[] = 
{
   mulle_js_define( NVGpaint_prototype_addColorStop, 2),
   { NULL, 0 }
};



void   MulleJS_initNVGpaint( MulleJS *self)
{
   NSValue              *value;
   struct NVGcontext    *nvg;
   js_State             *J;
   char                 *s;

   J = self->_state;

// create a new property object
   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject(J);

   // our object ( now on the stack)

   {
      struct function_table   *p;

      for( p = NVGpaint_function_table; p->name; ++p)
      {
         s = strrchr( p->name, '_');
         assert( s);
         ++s;

         js_newcfunction(J, p->f, p->name, p->n_args);
         js_defproperty(J, -2, s, JS_DONTENUM);
      }
   }

  	js_newcconstructor(J, 0, 0, "nvgPaint", 0);
   js_setregistry( J, "nvgPaint");
}   


void   MulleJS_initNVGcolor( MulleJS *self)
{
   NSValue              *value;
   struct NVGcontext    *nvg;
   js_State             *J;
   char                 *s;

   J = self->_state;

// create a new property object
   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject(J);

   // our object ( now on the stack)
  	js_newcconstructor(J, 0, 0, "nvgColor", 0);
   js_setregistry( J, "nvgColor");
}   


/*
 * Image
 */ 
void   MulleJS_initNVGimage( MulleJS *self)
{
   NSValue              *value;
   struct NVGcontext    *nvg;
   js_State             *J;
   char                 *s;

   J = self->_state;

// create a new property object
   js_getglobal(J, "Object");
   js_getproperty(J, -1, "prototype");
   js_newobject(J);

   // our object ( now on the stack)

  	js_newcconstructor(J, 0, 0, "MulleJSImage", 0);
   js_setregistry( J, "MulleJSImage");
}   


static void   MulleJSImage_free( js_State *J, void *data)
{
   mulle_free( data);
}

//
// we want "image name" and repition optinally
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

   js_getglobal( J, "MulleJS");
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

   context = [self objectForKey:@"CGContext"];

   repetition = "";
   if( js_isdefined( J, 2))
      repetition = (char *) js_tostring(J, 2);
   flags = parse_repetition( repetition, 0);

   image = [image imageWithNVGImageFlags:flags];

   pointer         = mulle_malloc( sizeof( *pointer));
   pointer->handle = [context registerTextureIDForImage:image];
   size            = [image size];
   pointer->width  = size.width;
   pointer->height = size.height;
   pointer->flags  = flags;

   js_getregistry(J, "MulleJSImage");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J, 
                   MULLEJSIMAGE_TAG, 
                   pointer, 
                   0,
                   0,
                   0,
                   MulleJSImage_free);   
}

- (void) jsPushValue:(id) value
              forKey:(NSString *) key 
             jsState:(js_State *) J
{
   void   *pointer;

   if( [key isEqualToString:@"nvgContext"])
   {
      pointer = [value pointerValue];

      js_getregistry(J, "nvgContext");
      js_getproperty(J, -1, "prototype");
      js_newuserdatax(J, 
                     NVGCONTEXT_TAG, 
                     pointer, 
                     NVGContext_GetProperty,
                     NVGContext_PutProperty,
                     0,
                     0);

      js_newnumber( J, [[self objectForKey:@"width"] doubleValue]);
      js_defproperty(J, -2, "width", JS_DONTENUM|JS_READONLY);
      js_newnumber( J, [[self objectForKey:@"height"] doubleValue]);
      js_defproperty(J, -2, "height", JS_DONTENUM|JS_READONLY);
      return;
   }

   if( [key isEqualToString:@"CGContext"])
   {
      js_getregistry(J, "CGContext");
      js_getproperty(J, -1, "prototype");
      js_newuserdatax(J, 
                     CGCONTEXT_TAG, 
                     value, 
                     0,
                     0,
                     0,
                     0);
      return;
   }
   js_pushundefined( J);
}


#define nvg_constant_make( def)  { #def, def } 

static struct
{
   char  *name;
   int   value;
} nvg_constants[] = 
{
   nvg_constant_make( NVG_CCW),
   nvg_constant_make( NVG_CW),

   nvg_constant_make( NVG_SOLID),
   nvg_constant_make( NVG_HOLE),

   nvg_constant_make( NVG_BUTT),
   nvg_constant_make( NVG_ROUND),
   nvg_constant_make( NVG_SQUARE),
   nvg_constant_make( NVG_BEVEL),
   nvg_constant_make( NVG_MITER),

   nvg_constant_make( NVG_ALIGN_LEFT),
   nvg_constant_make( NVG_ALIGN_CENTER),
   nvg_constant_make( NVG_ALIGN_RIGHT),
   nvg_constant_make( NVG_ALIGN_TOP),
   nvg_constant_make( NVG_ALIGN_MIDDLE),
   nvg_constant_make( NVG_ALIGN_BOTTOM),
   nvg_constant_make( NVG_ALIGN_BASELINE),

   nvg_constant_make( NVG_ZERO),
   nvg_constant_make( NVG_ONE),
   nvg_constant_make( NVG_SRC_COLOR),
   nvg_constant_make( NVG_ONE_MINUS_SRC_COLOR),
   nvg_constant_make( NVG_DST_COLOR),
   nvg_constant_make( NVG_ONE_MINUS_DST_COLOR),
   nvg_constant_make( NVG_SRC_ALPHA),
   nvg_constant_make( NVG_ONE_MINUS_SRC_ALPHA),
   nvg_constant_make( NVG_DST_ALPHA),
   nvg_constant_make( NVG_ONE_MINUS_DST_ALPHA),
   nvg_constant_make( NVG_SRC_ALPHA_SATURATE),

   nvg_constant_make( NVG_SOURCE_OVER),
   nvg_constant_make( NVG_SOURCE_IN),
   nvg_constant_make( NVG_SOURCE_OUT),
   nvg_constant_make( NVG_ATOP),
   nvg_constant_make( NVG_DESTINATION_OVER),
   nvg_constant_make( NVG_DESTINATION_IN),
   nvg_constant_make( NVG_DESTINATION_OUT),
   nvg_constant_make( NVG_DESTINATION_ATOP),
   nvg_constant_make( NVG_LIGHTER),
   nvg_constant_make( NVG_COPY),
   nvg_constant_make( NVG_XOR),
};


#define nvg_global_function_make( f, name, n)  { (js_CFunction) f, name, n } 

static struct
{
   js_CFunction  f;
   char          *name;
   int            n_args;
} nvg_global_functions[] = 
{
   nvg_global_function_make( NVGContext_function_arc, "nvgArc", 7),
   nvg_global_function_make( NVGContext_function_arcTo, "nvgArcTo", 6),
   nvg_global_function_make( NVGContext_function_beginPath, "nvgBeginPath", 1),
   nvg_global_function_make( NVGContext_function_bezierCurveTo, "nvgBezierTo", 7),
   nvg_global_function_make( NVGContext_function_boxGradient, "nvgBoxGradient", 9),
   nvg_global_function_make( NVGContext_function_circle, "nvgCircle", 5),
   nvg_global_function_make( NVGContext_function_closePath, "nvgClosePath", 1),
   nvg_global_function_make( NVGContext_function_ellipse, "nvgEllipse", 5),
   nvg_global_function_make( NVGContext_function_fill, "nvgFill", 1),
   nvg_global_function_make( NVGContext_function_imagePattern, "nvgImagePattern", 8),
   nvg_global_function_make( NVGContext_function_intersectScissor, "nvgIntersectScissor", 5),
   nvg_global_function_make( NVGContext_function_linearGradient, "nvgLinearGradient", 7),
   nvg_global_function_make( NVGContext_function_lineTo, "nvgLineTo", 3),
   nvg_global_function_make( NVGContext_function_moveTo, "nvgMoveTo", 3),
   nvg_global_function_make( NVGContext_function_quadraticCurveTo, "nvgQuadTo", 5),
   nvg_global_function_make( NVGContext_function_radialGradient, "nvgRadialGradient", 7),
   nvg_global_function_make( NVGContext_function_rect, "nvgRect", 5),
   nvg_global_function_make( NVGContext_function_resetScissor, "nvgResetScissor", 1),
   nvg_global_function_make( NVGContext_function_resetTransform, "nvgResetTransform", 1),
   nvg_global_function_make( NVGContext_function_restore, "nvgRestore", 1),
   nvg_global_function_make( NVGContext_function_rotate, "nvgRotate", 2),
   nvg_global_function_make( NVGContext_function_roundedRect, "nvgRoundedRect", 6),
   nvg_global_function_make( NVGContext_function_roundedRectVarying, "nvgRoundedRectVarying", 9),
   nvg_global_function_make( NVGContext_function_save, "nvgSave", 1),
   nvg_global_function_make( NVGContext_function_scale, "nvgScale", 3),
   nvg_global_function_make( NVGContext_function_scissor, "nvgScissor", 5),
   nvg_global_function_make( NVGContext_function_setBezierTessellation, "nvgBezierTessellation", 2),
   nvg_global_function_make( NVGContext_function_setFillColor, "nvgFillColor", 2),
   nvg_global_function_make( NVGContext_function_setFillPaint, "nvgFillPaint", 2),
   nvg_global_function_make( NVGContext_function_setFontBlur, "nvgFontBlur", 2),
   nvg_global_function_make( NVGContext_function_setFontFace, "nvgFontFace", 2),
   nvg_global_function_make( NVGContext_function_setFontFaceId, "nvgFontFaceId", 2),
   nvg_global_function_make( NVGContext_function_setFontSize, "nvgFontSize", 2),
   nvg_global_function_make( NVGContext_function_setGlobalAlpha, "nvgGlobalAlpha", 2),
   nvg_global_function_make( NVGContext_function_setGlobalCompositeBlendFunc, "nvgGlobalCompositeBlendFunc", 3),
   nvg_global_function_make( NVGContext_function_setGlobalCompositeBlendFuncSeparate, "nvgGlobalCompositeBlendFuncSeparate", 5),
   nvg_global_function_make( NVGContext_function_setGlobalCompositeOperation, "nvgGlobalCompositeOperation", 2),
   nvg_global_function_make( NVGContext_function_setLineCap, "nvgLineCap", 2),
   nvg_global_function_make( NVGContext_function_setMiterLimit, "nvgMiterLimit", 2),
   nvg_global_function_make( NVGContext_function_setPathWinding, "nvgPathWinding", 2),
   nvg_global_function_make( NVGContext_function_setShapeAntiAlias, "nvgShapeAntiAlias", 2),
   nvg_global_function_make( NVGContext_function_setStrokeColor, "nvgStrokeColor", 2),
   nvg_global_function_make( NVGContext_function_setStrokePaint, "nvgStrokePaint", 2),
   nvg_global_function_make( NVGContext_function_setStrokeWidth, "nvgStrokeWidth", 2),
   nvg_global_function_make( NVGContext_function_setTextAlign, "setTextAlign", 2),
   nvg_global_function_make( NVGContext_function_setTextColor, "nvgTextColor", 3),
   nvg_global_function_make( NVGContext_function_setTextLetterSpacing, "nvgTextLetterSpacing", 2),
   nvg_global_function_make( NVGContext_function_setTextLineHeight, "nvgTextLineHeight", 2),
   nvg_global_function_make( NVGContext_function_skewX, "nvgSkewX", 2),
   nvg_global_function_make( NVGContext_function_skewY, "nvgSkewY", 2),
   nvg_global_function_make( NVGContext_function_stroke, "nvgStroke", 1),
   nvg_global_function_make( NVGContext_function_text, "nvgText", 5),
   nvg_global_function_make( NVGContext_function_textBox, "nvgTextBox", 6),
   nvg_global_function_make( NVGContext_function_transform, "nvgTransform", 7),
   nvg_global_function_make( NVGContext_function_translate, "nvgTranslate", 3)
};


static void  MulleJS_initNVG( MulleJS *self)
{
   js_State   *J;
   int        i;

   J = self->_state;


   /* TODO: make this and above tables (like MulleJS+Math.m)*/

   for( i = 0; i < sizeof( nvg_global_functions) / sizeof( nvg_global_functions[ 0]); i++)
   {
      js_newcfunction(J, nvg_global_functions[ i].f, 
                         nvg_global_functions[ i].name, 
                         nvg_global_functions[ i].n_args);
      js_setglobal(J, nvg_global_functions[ i].name);  
   }


   for( i = 0; i < sizeof( nvg_constants) / sizeof( nvg_constants[ 0]); i++)
   {
      js_newnumber( J, (double) nvg_constants[ i].value);
      js_setglobal(J, nvg_constants[ i].name);  
   }

   /*
    *
    */

   js_newcfunction(J, MulleColor_function_createRGBf, "nvgRGBf", 3);
   js_setglobal(J, "nvgRGBf");  

   js_newcfunction(J, MulleColor_function_createRGBAf, "nvgRGBAf", 4);
   js_setglobal(J, "nvgRGBAf");  

   js_newcfunction(J, MulleColor_function_createLerpRGBA, "nvgLerpRGBA", 3);
   js_setglobal(J, "nvgLerpRGBA");  

   js_newcfunction(J, MulleColor_function_createHSL, "nvgHSL", 3);
   js_setglobal(J, "nvgHSL");  

   js_newcfunction(J, MulleColor_function_createFromCString, "MulleColorCreateFromCString", 2);
   js_setglobal(J, "MulleColorCreateFromCString");   

   /*
    *
    */
   js_newcfunction(J, global_function_degToRad, "nvgDegToRad", 1);
   js_setglobal(J, "nvgDegToRad");  

   js_newcfunction(J, global_function_radToDeg, "nvgRadToDeg", 1);
   js_setglobal(J, "nvgRadToDeg");  

   js_pushundefined(J);
   js_setglobal(J, "NULL");
}



// @property( assign) NSUInteger  value;
// @property( retain) id          other;

// - (id) method:(id) other;
- (void) addMulleUI
{
   js_newcfunction(_state, MulleJS_loadImage, "loadImage", 1);
   js_setglobal(_state, "loadImage");

   MulleJS_initNVGcontext( self);
   MulleJS_initCGContext( self);   
   MulleJS_initNVGpaint( self);
   MulleJS_initNVGcolor( self);
   MulleJS_initNVGimage( self);
   MulleJS_initNVG( self);
}


@end

