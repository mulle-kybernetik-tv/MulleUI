#import "import.h"

#import "CGBase.h"

#import "nanovg.h"

typedef NVGcolor   CGColorRef;


static inline NVGcolor getNVGColor( uint32_t color) 
{
	return nvgRGBA(
		(color >> 24) & 0xff,
		(color >> 16) & 0xff,
		(color >> 8) & 0xff,
		(color >> 0) & 0xff);
}


typedef float   _NVGtransform[ 6];   


@class CGContext;


@interface CALayer : NSObject  
{
   _NVGtransform   _transform;
   NVGscissor      _scissor;
}


- (instancetype) init;
- (instancetype) initWithFrame:(CGRect) frame;

- (BOOL) drawInContext:(CGContext *) ctx;

@property CGFloat cornerRadius;
@property CGFloat borderWidth;
@property CGColorRef borderColor;
@property CGColorRef backgroundColor;

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
  
