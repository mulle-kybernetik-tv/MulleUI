//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#define _GNU_SOURCE

#import "MulleJS.h"

#import "CALayer.h"
#import "import-private.h"

#include <string.h>
#include <stdlib.h>
#include <math.h>


static void jsB_gc(js_State *_state)
{
   int report = js_toboolean(_state, 1);
   js_gc(_state, report);
   js_pushundefined(_state);
}

static void jsB_load(js_State *_state)
{
   int i, n = js_gettop(_state);
   for (i = 1; i < n; ++i) {
      js_loadfile(_state, js_tostring(_state, i));
      js_pushundefined(_state);
      js_call(_state, 0);
      js_pop(_state, 1);
   }
   js_pushundefined(_state);
}

static void jsB_compile(js_State *_state)
{
   const char *source = js_tostring(_state, 1);
   const char *filename = js_isdefined(_state, 2) ? js_tostring(_state, 2) : "[string]";
   js_loadstring(_state, filename, source);
}

static void jsB_print(js_State *_state)
{
   int i, top = js_gettop(_state);
   for (i = 1; i < top; ++i) {
      const char *s = js_tostring(_state, i);
      if (i > 1) putchar(' ');
      fputs(s, stdout);
   }
   putchar('\n');
   js_pushundefined(_state);
}

static void jsB_write(js_State *_state)
{
   int i, top = js_gettop(_state);
   for (i = 1; i < top; ++i) {
      const char *s = js_tostring(_state, i);
      if (i > 1) putchar(' ');
      fputs(s, stdout);
   }
   js_pushundefined(_state);
}


static void jsB_read(js_State *_state)
{
   const char *filename = js_tostring(_state, 1);
   FILE *f;
   char *s;
   int n, t;

   f = fopen(filename, "rb");
   if (!f) {
      js_error(_state, "cannot open file '%s': %s", filename, strerror(errno));
   }

   if (fseek(f, 0, SEEK_END) < 0) {
      fclose(f);
      js_error(_state, "cannot seek in file '%s': %s", filename, strerror(errno));
   }

   n = ftell(f);
   if (n < 0) {
      fclose(f);
      js_error(_state, "cannot tell in file '%s': %s", filename, strerror(errno));
   }

   if (fseek(f, 0, SEEK_SET) < 0) {
      fclose(f);
      js_error(_state, "cannot seek in file '%s': %s", filename, strerror(errno));
   }

   s = malloc(n + 1);
   if (!s) {
      fclose(f);
      js_error(_state, "out of memory");
   }

   t = fread(s, 1, n, f);
   if (t != n) {
      free(s);
      fclose(f);
      js_error(_state, "cannot read data from file '%s': %s", filename, strerror(errno));
   }
   s[n] = 0;

   js_pushstring(_state, s);
   free(s);
   fclose(f);
}

static void jsB_quit(js_State *_state)
{
   exit(js_tonumber(_state, 1));
}

static void jsB_repr(js_State *_state)
{
   js_repr(_state, 1);
}

static const char *require_js =
   "function require(name) {\n"
   "var cache = require.cache;\n"
   "if (name in cache) return cache[name];\n"
   "var exports = {};\n"
   "cache[name] = exports;\n"
   "Function('exports', read(name+'.js'))(exports);\n"
   "return exports;\n"
   "}\n"
   "require.cache = Object.create(null);\n"
;

static const char *stacktrace_js =
   "Error.prototype.toString = function() {\n"
   "if (this.stackTrace) return this.name + ': ' + this.message + this.stackTrace;\n"
   "return this.name + ': ' + this.message;\n"
   "};\n"
;


#pragma mark - example begin 


#define MULLEJS_TAG     "MulleJS"      // used for objectForKey:
#define NVGCONTEXT_TAG  "nvgContext"
#define NVGPAINT_TAG    "nvgPaint"


static void   NVGContext_prototype_save(js_State *J)
{
   struct NVGcontext  *nvg;
   
   nvg = js_touserdata(J, 0, NVGCONTEXT_TAG);
   nvgSave( nvg);

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


static void   NVGContext_prototype_setFillStyle(js_State *J)
{
   struct NVGcontext  *nvg;
   char               *style;
   NVGcolor           color;

   nvg   = js_touserdata(J, 0, NVGCONTEXT_TAG);
   style = (char *) js_tostring( J, 1);
   color = MulleColorCreateFromCString( style);
   nvgFillColor(nvg, color);

   js_pushundefined( J);
}


static void   NVGContext_prototype_fillRect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;

   nvg               = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x     = js_tonumber( J, 1);
   rect.origin.y     = js_tonumber( J, 2);
   rect.size.width   = js_tonumber( J, 3);
   rect.size.height  = js_tonumber( J, 4);

   nvgBeginPath( nvg);
   nvgRect( nvg, rect.origin.x, 
                 rect.origin.y, 
                 rect.size.width, 
                 rect.size.height);
   nvgFill( nvg);   

   js_pushundefined( J);
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


// not working, need to figure out how to erase fb ?
static void   NVGContext_prototype_clearRect(js_State *J)
{
   struct NVGcontext  *nvg;
   CGRect             rect;

   nvg              = js_touserdata( J, 0, NVGCONTEXT_TAG);
   rect.origin.x    = js_tonumber( J, 1);
   rect.origin.y    = js_tonumber( J, 2);
   rect.size.width  = js_tonumber( J, 3);
   rect.size.height = js_tonumber( J, 4);

   nvgSave( nvg);
   {
      nvgBeginPath( nvg);
      nvgGlobalCompositeOperation( nvg, NVG_COPY);
      nvgFillColor( nvg, getNVGColor( 0x00000000));
      nvgRect( nvg, rect.origin.x, 
                    rect.origin.y, 
                    rect.size.width, 
                    rect.size.height);   
      nvgFill( nvg);   
   }
   nvgRestore( nvg);

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



#define mulle_js_define( x, n)  { #x, x, n }
struct function_table
{ 
   char *name; 
   void (*f)( js_State *); 
   int  n_args;
};



@implementation MulleJS


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
   NVGcolor          color;
   struct NVGpaint   *paint;

   if( js_isstring( J, -1))
   {
      style = (char *) js_tostring( J, -1);
      color = MulleColorCreateFromCString( style);
      nvgFillColor(nvg, color);
      return;
   }

   paint = js_touserdata( J, -1, NVGPAINT_TAG);
   if( paint)
      nvgFillPaint(nvg, *paint);
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


// data
// fillStyle      X	   
// font 	
// globalAlpha
// height         X	
// lineCap 	      
// lineJoin 	   
// lineWidth 	   
// miterLimit 	   
// shadowBlur 	   -
// shadowColor 	-
// shadowOffsetX 	-
// shadowOffsetY 	-
// strokeStyle    X	
// textAlign 	
// textBaseline 	
// width 	      X

static struct mulle_cstringfunctionpointerpair   propertykey_table[] =
{
   { "fillStyle",    NVGContext_setFillStyleProperty   },
   { "globalAlpha",  NVGContext_setGlobalAlphaProperty },
   { "lineCap",      NVGContext_setLineCapProperty     },
   { "lineJoin",     NVGContext_setLineJoinProperty    },
   { "lineWidth",    NVGContext_setLineWidthProperty   },
   { "miterLimit",   NVGContext_setMiterLimitProperty  },
   { "strokeStyle",  NVGContext_setStrokeStyleProperty }
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
// createLinearGradient() TODO
// createPattern() 	     TODO    
// createRadialGradient() TODO
// drawImage() 	        TODO
// fill() 	            
// fillRect() 	         
// fillText()             TODO
// getContext() 	        TODO  ???
// getImageData()         TODO
// isPointInPath() 	     nanovg currently doesn't support this (https://github.com/memononen/nanovg/issues/197)
// lineTo() 	        
// measureText() 	        TODO
// moveTo() 	         
// putImageData()         TODO
// quadraticCurveTo() 	  
// rect() 	              TODO      
// restore() 
// rotate() 	      
// save() 	
// scale() 	                      
// setTransform() 	     TODO
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
   mulle_js_define( NVGContext_prototype_clearRect, 4),
   mulle_js_define( NVGContext_prototype_closePath, 0),
   mulle_js_define( NVGContext_prototype_createLinearGradient, 4),
   mulle_js_define( NVGContext_prototype_createRadialGradient, 6),
   mulle_js_define( NVGContext_prototype_fill, 0),
   mulle_js_define( NVGContext_prototype_fillRect, 4),
   mulle_js_define( NVGContext_prototype_lineTo, 2),
   mulle_js_define( NVGContext_prototype_moveTo, 2),
   mulle_js_define( NVGContext_prototype_quadraticCurveTo, 4),
   mulle_js_define( NVGContext_prototype_restore, 0),
   mulle_js_define( NVGContext_prototype_rotate, 1),
   mulle_js_define( NVGContext_prototype_save, 0),
   mulle_js_define( NVGContext_prototype_scale, 2),
   mulle_js_define( NVGContext_prototype_setLineCap, 1),
   mulle_js_define( NVGContext_prototype_setLineWidth, 1),
   mulle_js_define( NVGContext_prototype_setStrokeStyle, 1),
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


static struct function_table  Math_function_table[] = 
{
   mulle_js_define( Math_prototype_abs, 1),
   mulle_js_define( Math_prototype_acos, 1),
   mulle_js_define( Math_prototype_acosh, 1),
   mulle_js_define( Math_prototype_asin, 1),
   mulle_js_define( Math_prototype_asinh, 1),
   mulle_js_define( Math_prototype_atan, 1),
   mulle_js_define( Math_prototype_atan2, 1),
   mulle_js_define( Math_prototype_atanh, 1),
   mulle_js_define( Math_prototype_cbrt, 1),
   mulle_js_define( Math_prototype_ceil, 1),
   mulle_js_define( Math_prototype_clz32, 1),
   mulle_js_define( Math_prototype_cos, 1),
   mulle_js_define( Math_prototype_cosh, 1),
   mulle_js_define( Math_prototype_exp, 1),
   mulle_js_define( Math_prototype_expm1, 1),
   mulle_js_define( Math_prototype_floor, 1),
   mulle_js_define( Math_prototype_fround, 1),
   mulle_js_define( Math_prototype_hypot, 1),
   mulle_js_define( Math_prototype_imul, 1),
   mulle_js_define( Math_prototype_log, 1),
   mulle_js_define( Math_prototype_log10, 1),
   mulle_js_define( Math_prototype_log1p, 1),
   mulle_js_define( Math_prototype_log2, 1),
   mulle_js_define( Math_prototype_max, 2),
   mulle_js_define( Math_prototype_min, 2),
   mulle_js_define( Math_prototype_pow, 2),
   mulle_js_define( Math_prototype_random, 1),
   mulle_js_define( Math_prototype_round, 1),
   mulle_js_define( Math_prototype_sign, 1),
   mulle_js_define( Math_prototype_sin, 1),
   mulle_js_define( Math_prototype_sinh, 1),
   mulle_js_define( Math_prototype_sqrt, 1),
   mulle_js_define( Math_prototype_tan, 1),
   mulle_js_define( Math_prototype_tanh, 1),
   mulle_js_define( Math_prototype_trunc, 1),
   { NULL, 0 }
};


void   MulleJS_initMath( MulleJS *self)
{
   NSValue              *value;
   struct NVGcontext    *nvg;
   js_State             *J;
   char                 *s;

   J = self->_state;

   js_getglobal(J, "Object");
     js_getproperty(J, -1, "prototype");
   js_newobject( J);

   {
      struct function_table   *p;

      for( p = Math_function_table; p->name; ++p)
      {
         s = strrchr( p->name, '_');
         assert( s);
         ++s;

         js_newcfunction(J, p->f, p->name, p->n_args);
         js_defproperty(J, -2, s, JS_DONTENUM);
      }
   }

   js_newnumber( J, M_E);
   js_defproperty(J, -2, "E", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_LN10);
   js_defproperty(J, -2, "LN10", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_LN2);
   js_defproperty(J, -2, "LN2", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_LOG10E);
   js_defproperty(J, -2, "LOG10E", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_LOG2E);
   js_defproperty(J, -2, "LOG2E", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_PI);
   js_defproperty(J, -2, "PI", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_SQRT1_2);
   js_defproperty(J, -2, "SQRT1_2", JS_DONTENUM|JS_READONLY);
   js_newnumber( J, M_SQRT2); 
   js_defproperty(J, -2, "SQRT_2", JS_DONTENUM|JS_READONLY);

   js_setglobal( J, "Math");
}   


static void   MulleJS_objectForKey(js_State *J)
{
   char       *s;
   NSString   *key;
   char       *type;
   id         value;
   MulleJS    *self;
   void       *pointer;

   js_getglobal( J, "MulleJS");
   self = js_touserdata(J, -1, MULLEJS_TAG);

   s     = (char *) js_tostring(J, 1);
   key   = @( s);
   value = [self objectForKey:key];
   if( ! value)
   {
      js_pushundefined( J);
      return;
   }

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

   pointer = [value pointerValue];

   js_getregistry(J, "nvgContext");
//   js_repr( J, -1);
//   fprintf( stderr, "po: %s\n", js_tostring(J, -1));
//	js_pop(J, 1)
   ;
   //   js_stacktrace( J);
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
}


#pragma mark - example end


+ (BOOL) isStrict
{
   return( YES);
}

- (instancetype) init 
{
   MulleJS   *js;

   _objectTable = [NSMutableDictionary new];

   _state = js_newstate(NULL, NULL, [[self class] isStrict] ? JS_STRICT : 0);

   // get Object.prototype on stack for js_newuserdata
   js_getglobal(_state, "Object");
   js_getproperty(_state, -1, "prototype");	
   js_newuserdata( _state, MULLEJS_TAG, self, 0);
   js_setglobal(_state, "MulleJS");

  // js_setregistry( _state, "MulleJS");

   js_newcfunction(_state, jsB_gc, "gc", 0);
   js_setglobal(_state, "gc");

   js_newcfunction(_state, jsB_load, "load", 1);
   js_setglobal(_state, "load");

   js_newcfunction(_state, jsB_compile, "compile", 2);
   js_setglobal(_state, "compile");

   js_newcfunction(_state, jsB_print, "print", 0);
   js_setglobal(_state, "print");

   js_newcfunction(_state, jsB_write, "write", 0);
   js_setglobal(_state, "write");

   js_newcfunction(_state, jsB_read, "read", 0);
   js_setglobal(_state, "read");

   js_newcfunction(_state, jsB_repr, "repr", 0);
   js_setglobal(_state, "repr");

   js_newcfunction(_state, jsB_quit, "quit", 1);
   js_setglobal(_state, "quit");

   js_newcfunction(_state, MulleJS_objectForKey, "$", 1);
   js_setglobal(_state, "$");

   js_dostring(_state, require_js);
   js_dostring(_state, stacktrace_js);

   MulleJS_initNVGcontext( self);
   MulleJS_initNVGpaint( self);
   MulleJS_initMath( self);

   return( self);
}


- (BOOL) runScriptCString:(char *) s
{
   js_newarray(_state);
//	i = 0;
//	while (xoptind < argc) {
//		js_pushstring(_state, argv[xoptind++]);
//		js_setindex(_state, -2, i++);
//	}
   js_setglobal(_state, "scriptArgs");

   if( js_dostring(_state, s))
      return( NO);
   return( YES);
} 


- (BOOL) runScriptFileCString:(char *) filename
{
   js_newarray(_state);
//	i = 0;
//	while (xoptind < argc) {
//		js_pushstring(_state, argv[xoptind++]);
//		js_setindex(_state, -2, i++);
//	}
   js_setglobal(_state, "scriptArgs");

   if( js_dofile(_state, filename))
      return( NO);
   return( YES);
} 


- (void) finalize
{
   js_gc(_state, 0);
   js_freestate(_state);
   _state = 0;

   [_objectTable release];
   _objectTable = nil;

   [super finalize];  // call at end
}


- (void *) forward:(void *) param
{
   assert( _objectTable); // window should not forward...
   return( mulle_objc_object_inlinecall_variablemethodid( _objectTable,
                                                          (mulle_objc_methodid_t) _cmd,
                                                          param));
}

@end
