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
#define MULLEJSIMAGE_TAG   "MulleJSImage"


static void   NVGContext_prototype_save(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);
   nvgSave( nvg);

   js_pushundefined( J);
}

static void   NVGContext_prototype_setTransform(js_State *J)
{
   struct NVGcontext  *nvg;
   float              a, b, c, d, e, f;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   a = js_tonumber( J, 1);
   b = js_tonumber( J, 2);
   c = js_tonumber( J, 3);
   d = js_tonumber( J, 4);
   e = js_tonumber( J, 5);
   f = js_tonumber( J, 6);

   nvgResetTransform( nvg);
   nvgTransform( nvg, a, b, c, d, e, f);

   js_pushundefined( J);
}


static void   NVGContext_prototype_transform(js_State *J)
{
   struct NVGcontext  *nvg;
   float              a, b, c, d, e, f;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   a = js_tonumber( J, 1);
   b = js_tonumber( J, 2);
   c = js_tonumber( J, 3);
   d = js_tonumber( J, 4);
   e = js_tonumber( J, 5);
   f = js_tonumber( J, 6);

   nvgTransform( nvg, a, b, c, d, e, f);

   js_pushundefined( J);
}


static void   NVGContext_prototype_arc(js_State *J)
{
   struct NVGcontext   *nvg;
   float               cx, cy, r, startAngle, endAngle;
   int                 direction;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   direction   = NVG_CW;

   cx          = js_tonumber( J, 1);
   cy          = js_tonumber( J, 2);
   r           = js_tonumber( J, 3);
   startAngle  = js_tonumber( J, 4);
   endAngle    = js_tonumber( J, 5);
   if( js_isdefined( J, 6))
      direction = js_toboolean( J, 6) ? NVG_CCW : NVG_CW;

   nvgArc( nvg, cx, cy, r, startAngle, endAngle, direction);

   js_pushundefined( J);
}


static void   NVGContext_prototype_arcTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x1, y1, x2, y2, r;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   x1 = js_tonumber( J, 1);
   y1 = js_tonumber( J, 2);
   x2 = js_tonumber( J, 3);
   y2 = js_tonumber( J, 4);
   r  = js_tonumber( J, 5);

   nvgArcTo( nvg, x1, y1, x2, y2, r);

   js_pushundefined( J);
}


static void   NVGContext_prototype_bezierCurveTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              c1x, c1y, c2x, c2y, x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   c1x = js_tonumber( J, 1);
   c1y = js_tonumber( J, 2);
   c2x = js_tonumber( J, 3);
   c2y = js_tonumber( J, 4);
   x   = js_tonumber( J, 5);
   y   = js_tonumber( J, 6);

   nvgBezierTo( nvg, c1x, c1y, c2x, c2y, x, y);

   js_pushundefined( J);
}


static void   NVGContext_prototype_closePath(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);

   nvgClosePath( nvg);   

   js_pushundefined( J);
}


static void   NVGpaint_free( js_State *J, void *data)
{
   mulle_free( data);
}

static void   NVGContext_prototype_createLinearGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   struct NVGpaint     *pointer;
   float                sx, sy, ex, ey;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   sx = js_tonumber( J, 1);
   sy = js_tonumber( J, 2);
   ex  = js_tonumber( J, 3);
   ey  = js_tonumber( J, 4);

   paint = nvgLinearGradient( nvg, sx, sy, ex, ey, 
                              getNVGColor( 0x000000FF), getNVGColor( 0xFFFFFFFF));   

   pointer  = mulle_malloc( sizeof( struct NVGpaint));
   *pointer = paint;

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


static void   NVGContext_prototype_createRadialGradient(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      paint;
   struct NVGpaint     *pointer;
   float                cx1, cy1, cx2, cy2, inr, outr;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   cx1   = js_tonumber( J, 1);
   cy1   = js_tonumber( J, 2);
   inr   = js_tonumber( J, 3);
//   cx2   = js_tonumber( J, 4);   // ignore
//   cy2   = js_tonumber( J, 5);  // ignore
   outr  = js_tonumber( J, 6);

   paint = nvgRadialGradient( nvg, cx1, cy1, inr, outr, 
                              getNVGColor( 0x000000FF), getNVGColor( 0xFFFFFFFF));   

   // TODO: need destructor
   pointer  = mulle_malloc( sizeof( struct NVGpaint));
   *pointer = paint;

   js_getregistry(J, "nvgPaint");
   js_getproperty(J, -1, "prototype");
   js_newuserdatax(J, 
                   NVGPAINT_TAG, 
                   pointer, 
                   0,
                   0,
                   0,
                   0);
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
static void   NVGContext_prototype_createPattern(js_State *J)
{
   struct NVGcontext    *nvg;
   struct NVGpaint      *pointer;
   struct MulleJSImage  *image;
   char                 *repetition;
   int                  flags;
   int                  handle;

   nvg        = js_touserdata( J, 0, NVGCONTEXT_TAG);
   image      = js_touserdata( J, 1, MULLEJSIMAGE_TAG);
   repetition = (char *) js_tostring( J, 2);

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



static void   NVGContext_prototype_quadraticCurveTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              cx, cy, x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   cx = js_tonumber( J, 1);
   cy = js_tonumber( J, 2);
   x  = js_tonumber( J, 3);
   y  = js_tonumber( J, 4);

   nvgQuadTo( nvg, cx, cy, x, y);

   js_pushundefined( J);
}

static void   NVGContext_prototype_setStrokeStyle(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGcolor            color;

   nvg   = js_touserdata(J, 0, NVGCONTEXT_TAG);
   style = (char *) js_tostring( J, 1);
   color = MulleColorCreateFromCString( style);
   nvgStrokeColor(nvg, color);

   js_pushundefined( J);
}


static void   NVGContext_prototype_setLineCap(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *s;

   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);
   s   = (char *) js_tostring( J, 1);
   if( ! strcmp( s, "round"))
      nvgLineCap(nvg, NVG_ROUND);
   else
      nvgLineCap(nvg, NVG_BUTT);

   js_pushundefined( J);
}


static void   NVGContext_prototype_setLineWidth(js_State *J)
{
   struct NVGcontext  *nvg;
   float              value;
   
   nvg   = js_touserdata( J, 0, NVGCONTEXT_TAG);
   value = js_tonumber( J, 1);

   nvgStrokeWidth( nvg, value);

   js_pushundefined( J);
}


static void   NVGContext_prototype_fillRect(js_State *J)
{
   struct NVGcontext   *nvg;
   CGRect              rect;

   nvg              = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x    = js_tonumber( J, 1);
   rect.origin.y    = js_tonumber( J, 2);
   rect.size.width  = js_tonumber( J, 3);
   rect.size.height = js_tonumber( J, 4);

   nvgBeginPath( nvg);
   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);
   nvgFill( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_prototype_fillText(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              x, y;
   float              maxWidth;

   nvg      = js_touserdata( J, 0, NVGCONTEXT_TAG);
   text     = (char *) js_tostring( J, 1);
   x        = js_tonumber( J, 2);
   y        = js_tonumber( J, 3);
   maxWidth = js_tonumber( J, 4); // undefine == NAN

   nvgText( nvg, x, y, text, NULL);

   js_pushundefined( J);
}


//
// can only do "width" for now
//
static void   NVGContext_prototype_measureText(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *text;
   float              bounds[ 4];

   nvg  = js_touserdata( J, 0, NVGCONTEXT_TAG);
   text = (char *) js_tostring( J, 1);

   nvgTextBounds( nvg, 0, 0, text, NULL, bounds);
   js_newobject( J);
   // [xmin,ymin, xmax,ymax]   
   js_newnumber( J, bounds[ 2]); // xmax
   js_defproperty(J, -2, "width", JS_DONTENUM);
}



static void   NVGContext_prototype_strokeRect(js_State *J)
{
   struct NVGcontext   *nvg;
   CGRect              rect;

   nvg              = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x    = js_tonumber( J, 1);
   rect.origin.y    = js_tonumber( J, 2);
   rect.size.width  = js_tonumber( J, 3);
   rect.size.height = js_tonumber( J, 4);

   nvgBeginPath( nvg);
   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);
   nvgStroke( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_prototype_rect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;

   nvg               = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x     = js_tonumber( J, 1);
   rect.origin.y     = js_tonumber( J, 2);
   rect.size.width   = js_tonumber( J, 3);
   rect.size.height  = js_tonumber( J, 4);

   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);

   js_pushundefined( J);
}


// not working, need to figure out how to erase fb ?
static void   NVGContext_prototype_clearRect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;
   NSValue            *value;
   NVGcolor           backgroundColor;
   MulleJS            *self;

   nvg              = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x    = js_tonumber( J, 1);
   rect.origin.y    = js_tonumber( J, 2);
   rect.size.width  = js_tonumber( J, 3);
   rect.size.height = js_tonumber( J, 4);

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


static void   NVGContext_prototype_drawImage(js_State *J)
{
   struct NVGcontext    *nvg;
   struct MulleJSImage  *image;    
   CGRect                src;
   CGRect                dst;
   struct NVGpaint       imagePaint;
   float                 ax, ay;

   memset( &dst, 0, sizeof( dst));

   nvg   = js_touserdata( J, 0, NVGCONTEXT_TAG);
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

   dst.origin.x    = js_tointeger( J, 2);
   dst.origin.y    = js_tointeger( J, 3);

   if( js_isdefined( J, 4))
   {
      dst.size.width  = js_tointeger( J, 4);
      dst.size.height = js_tointeger( J, 5);
   
      if( js_isdefined( J, 6))
      {
         src             = dst;
         dst.origin.x    = js_tointeger( J, 6);
         dst.origin.y    = js_tointeger( J, 7);

         if( js_isdefined( J, 8))
         {
            dst.size.width  = js_tointeger( J, 8);
            dst.size.height = js_tointeger( J, 9);
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


static void   NVGContext_prototype_beginPath(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);
   nvgBeginPath( nvg);
   js_pushundefined( J);
}


static void   NVGContext_prototype_moveTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1);
   y = js_tonumber( J, 2);

   nvgMoveTo( nvg, x, y);

   js_pushundefined( J);
}


static void   NVGContext_prototype_lineTo(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1);
   y = js_tonumber( J, 2);

   nvgLineTo( nvg, x, y);

   js_pushundefined( J);
}


static void   NVGContext_prototype_fill(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);

   nvgFill( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_prototype_stroke(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);

   nvgStroke( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_prototype_restore(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);

   nvgRestore( nvg);   

   js_pushundefined( J);
}


static void   NVGContext_prototype_rotate(js_State *J)
{
   struct NVGcontext  *nvg;
   float              angle;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   angle = js_tonumber( J, 1);
 
   nvgRotate( nvg, angle);
   
   js_pushundefined( J);
}


static void   NVGContext_prototype_scale(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1);
   y = js_tonumber( J, 2);
 
   nvgScale( nvg, x, y);

   js_pushundefined( J);
}


static void   NVGContext_prototype_translate(js_State *J)
{
   struct NVGcontext  *nvg;
   float              x, y;
   
   nvg = js_touserdata( J, 0, NVGCONTEXT_TAG);

   x = js_tonumber( J, 1);
   y = js_tonumber( J, 2);
 
   nvgTranslate( nvg, x, y);

   js_pushundefined( J);
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


static void   NVGContext_setGlobalAlphaProperty( struct NVGcontext *nvg, js_State *J)
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


static void   NVGContext_setGlobalCompositeOperationProperty( struct NVGcontext *nvg, js_State *J)
{
   int        value;
   char       *s;

   s     = (char *) js_tostring( J, -1);
   value = parse_composite_operation( s);
   nvgGlobalCompositeOperation(nvg, value);
}


static void   NVGContext_setLineCapProperty( struct NVGcontext *nvg, js_State *J)
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


static void   NVGContext_setLineJoinProperty( struct NVGcontext *nvg, js_State *J)
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


static void   NVGContext_setLineWidthProperty( struct NVGcontext *nvg, js_State *J)
{
   float      value;
   NVGcolor   color;

   value = js_tonumber( J, -1);
   nvgStrokeWidth(nvg, value);
}


static void   NVGContext_setMiterLimitProperty( struct NVGcontext *nvg, js_State *J)
{
   float      value;
   NVGcolor   color;

   value = js_tonumber( J, -1);
   nvgMiterLimit(nvg, value);
}


static void   NVGContext_setFillStyleProperty( struct NVGcontext *nvg, js_State *J)
{
   char              *style;
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


static void   NVGContext_setFontProperty( struct NVGcontext *nvg, js_State *J)
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



static void   NVGContext_setStrokeStyleProperty( struct NVGcontext *nvg, js_State *J)
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


static void   NVGContext_setTextAlignProperty( struct NVGcontext *nvg, js_State *J)
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
   { "fillStyle",    NVGContext_setFillStyleProperty    },
   { "font",         NVGContext_setFontProperty         },
   { "globalAlpha",  NVGContext_setGlobalAlphaProperty  },
   { "globalCompositeOperation", NVGContext_setGlobalCompositeOperationProperty },
   { "lineCap",      NVGContext_setLineCapProperty      },
   { "lineJoin",     NVGContext_setLineJoinProperty     },
   { "lineWidth",    NVGContext_setLineWidthProperty    },
   { "miterLimit",   NVGContext_setMiterLimitProperty   },
   { "strokeStyle",  NVGContext_setStrokeStyleProperty  },
   { "textAlign",    NVGContext_setTextAlignProperty    }
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


static int NVGContext_GetProperty(js_State *J, void *userdata, const char *key)
{
   if( mulle_propertyname_to_function( (char *) key))
   {
      js_pushnumber(J, 0);
      return 1;
   }
   return 0;
}


static int NVGContext_PutProperty(js_State *J, void *userdata, const char *key)
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


   mulle_js_define( NVGContext_prototype_arc, 6),
   mulle_js_define( NVGContext_prototype_arcTo, 5),
   mulle_js_define( NVGContext_prototype_beginPath, 0 ),
   mulle_js_define( NVGContext_prototype_bezierCurveTo, 6),
   mulle_js_define( NVGContext_prototype_clearRect, 4),  // needs fixing
   mulle_js_define( NVGContext_prototype_closePath, 0),
   mulle_js_define( NVGContext_prototype_createLinearGradient, 4),
   mulle_js_define( NVGContext_prototype_createPattern, 2),
   mulle_js_define( NVGContext_prototype_createRadialGradient, 6),
   mulle_js_define( NVGContext_prototype_drawImage, 9),
   mulle_js_define( NVGContext_prototype_fill, 0),
   mulle_js_define( NVGContext_prototype_fillRect, 4),
   mulle_js_define( NVGContext_prototype_fillText, 4),
   mulle_js_define( NVGContext_prototype_lineTo, 2),
   mulle_js_define( NVGContext_prototype_measureText, 1),
   mulle_js_define( NVGContext_prototype_moveTo, 2),
   mulle_js_define( NVGContext_prototype_quadraticCurveTo, 4),
   mulle_js_define( NVGContext_prototype_rect, 4),
   mulle_js_define( NVGContext_prototype_restore, 0),
   mulle_js_define( NVGContext_prototype_rotate, 1),
   mulle_js_define( NVGContext_prototype_save, 0),
   mulle_js_define( NVGContext_prototype_scale, 2),
   mulle_js_define( NVGContext_prototype_setLineCap, 1),
   mulle_js_define( NVGContext_prototype_setLineWidth, 1),
   mulle_js_define( NVGContext_prototype_setStrokeStyle, 1),
   mulle_js_define( NVGContext_prototype_setTransform, 6),
   mulle_js_define( NVGContext_prototype_stroke, 0),
   mulle_js_define( NVGContext_prototype_strokeRect, 4),
   mulle_js_define( NVGContext_prototype_translate, 2),
   mulle_js_define( NVGContext_prototype_transform, 6),
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
   style  = (char *) js_tostring( J, 2);
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
   s     = (char *) js_tostring(J, 0);
   key   = @( s);
   image = [self objectForKey:key];
   if( ! [image isKindOfClass:[UIImage class]])
   {
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
   MulleJS_initNVGimage( self);
}

@end
