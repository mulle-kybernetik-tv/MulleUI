#import "import.h"

#import "CGBase.h"
#import <math.h>
#import "nanovg.h"


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


static inline size_t CGColorGetNumberOfComponents(CGColorRef color)
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


static inline BOOL   CGColorEqualToColor( CGColorRef color, CGColorRef other)
{
   // CGColorRef is not really a ref..
   return( ! memcmp( &color, &other, sizeof( CGColorRef)));
}

