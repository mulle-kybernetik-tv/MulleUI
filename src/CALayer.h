#import "import.h"

#import "CGColor.h"
#import "CATime.h"


typedef float   _NVGtransform[ 6];   


@class CGContext;
@class CAAnimation;
@class MulleAnimationDelegate;

struct MulleFrameInfo;
struct CAAnimationOptions;

@interface CALayer : NSObject < NSCopying>
{
   _NVGtransform               _transform;
   NVGscissor                  _scissor;
   CALayer                     *_snapshot;
   struct mulle_pointerarray   _animations;    
}

// animatable properties
@property( observable) CGFloat      cornerRadius;
@property( observable) CGFloat      borderWidth;
@property( observable) CGFloat      opacity;
@property( observable) CGColorRef   borderColor;
@property( observable) CGColorRef   backgroundColor;
@property( observable) CGRect       frame;


//
// With Bounds origin + width you set the transform that is done
// during the drawing. We don't have sublayers, so it doesn't affect them
// The bounds property is local to each layer and not inherited. If not set
// it's the same as { 0, 0, frame.size.width, frame.size.height }
//
@property( observable) CGRect       bounds;

// non-observable
@property BOOL       hidden;
@property char       *cStringName;

// return YES if you changed transform or scissor
@property BOOL       (*drawContentsCallback)( CALayer *layer, 
                                              CGContext *ctxt, 
                                              CGRect frame, 
                                              struct MulleFrameInfo *info);

// properties used for rendering only
@property CGRect     clipRect;


+ (instancetype) layerWithFrame:(CGRect) frame;

- (instancetype) init;
- (instancetype) initWithFrame:(CGRect) frame;

- (BOOL) drawInContext:(CGContext *) ctx;

//
// Subclasses do their drawing in these methods. The code simply draws the
// frame coordinates. If you do transformations or add to
// scissors in return YES, otherwise NO.
//
- (BOOL) drawBackgroundInContext:(CGContext *) context;
- (BOOL) drawContentsInContext:(CGContext *) ctx;
- (BOOL) drawBorderInContext:(CGContext *) context;


- (void) setTransform:(_NVGtransform) transform
              scissor:(NVGscissor *) scissor;


@end


@class UIImage;


@protocol CAImageLayer 

@property( retain) UIImage   *image;

@end
  
