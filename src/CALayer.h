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

typedef float   _NVGtransform[ 6];   


@class CGContext;
struct MulleFrameInfo;

@interface CALayer : NSObject  
{
   _NVGtransform   _transform;
   NVGscissor      _scissor;
}


- (instancetype) init;
- (instancetype) initWithFrame:(CGRect) frame;

- (BOOL) drawInContext:(CGContext *) ctx;

//
// subclasses do their drawing in this method. The code simply draws the
// frame coordinates.
//
- (void) drawContentsInContext:(CGContext *) ctx;

@property CGFloat cornerRadius;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property CGColorRef backgroundColor;
@property void       (*drawContentsCallback)( NVGcontext *vg, 
                                              CGRect frame, 
                                              struct MulleFrameInfo *info);
@property CGRect frame;
@property CGRect bounds;

@property char  *cStringName;

// properties used for rendering only
@property CGRect   clipRect;

- (void) setTransform:(_NVGtransform) transform
              scissor:(NVGscissor *) scissor;


@end


@class UIImage;


@protocol CAImageLayer 

@property( retain) UIImage   *image;

@end
  
