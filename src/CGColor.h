#ifndef cg_color_h__
#define cg_color_h__

#include "CGBase.h"
#include <math.h>
#include "nanovg.h"
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>


typedef NVGcolor   CGColorRef;
typedef void       *CGColorSpaceRef;


// NVGColor is a float[ 4] in reality
static inline NVGcolor getNVGColor( uint32_t color) 
{
	return nvgRGBA(
		(color >> 24) & 0xff,
		(color >> 16) & 0xff,
		(color >> 8) & 0xff,
		(color >> 0) & 0xff);
}

static inline CGColorRef   MulleColorCreate( uint32_t color)
{
   return( getNVGColor( color));
}


static inline CGColorRef   MulleColorCreateRandom( uint32_t color, uint32_t mask)
{
   uint32_t  value;

   color &= ~mask;
   color |= ((uint32_t) rand()) & mask;
   return( getNVGColor( color));
}

static inline CGColorRef   MulleColorCreateRandomOpaque()
{
   return( MulleColorCreateRandom( 0xFF, 0xFFFFFF00));
}



static inline CGColorRef CGColorCreateGenericRGB( CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha)
{
   return( nvgRGBA( (uint32_t) round( 0xff * red),
                    (uint32_t) round( 0xff * green),
                    (uint32_t) round( 0xff * blue),
                    (uint32_t) round( 0xff * alpha)));
}


static inline CGColorRef CGColorCreate( CGColorSpaceRef space, const CGFloat *components)
{
   return( CGColorCreateGenericRGB( components[ 0], 
                                    components[ 1], 
                                    components[ 2],
                                    components[ 3]));
}


static inline int    CGColorGetNumberOfComponents(CGColorRef color)
{
   return( 4);
}


static inline void   MulleColorGetComponents(CGColorRef color, CGFloat *components)
{
   components[ 0] = color.r;
   components[ 1] = color.g;
   components[ 2] = color.b;
   components[ 3] = color.a;
}


static inline CGFloat   CGColorGetAlpha( CGColorRef color)
{
   return( color.a);
}


static inline CGColorRef   CGColorDim( CGColorRef color, CGFloat factor)
{
   assert( factor > 0.0 && factor < 1.0);
   color.a = color.a * factor;
   return( color);
}


static inline int   MulleColorIsTransparent( CGColorRef color)
{
   return( color.a < 0.5 / 32767.0);  // assume rounding up and 16 bit color depth
}

static inline int   MulleColorIsOpaque( CGColorRef color)
{
   return( color.a >= 1.0 - 0.5 / 32767.0);  // assume rounding up and 16 bit color depth
}


static inline int   CGColorEqualToColor( CGColorRef color, CGColorRef other)
{
   // CGColorRef is not really a ref..
   return( ! memcmp( &color, &other, sizeof( CGColorRef)));
}


CGColorRef   MulleColorCreateFromCString( char *s);

#endif
