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
@property void       (*drawContentsCallback)( CALayer *layer, 
                                              CGContext *ctxt, 
                                              CGRect frame, 
                                              struct MulleFrameInfo *info);

// properties used for rendering only
@property CGRect     clipRect;


- (instancetype) init;
- (instancetype) initWithFrame:(CGRect) frame;

- (BOOL) drawInContext:(CGContext *) ctx;

//
// subclasses do their drawing in this method. The code simply draws the
// frame coordinates.
//
- (void) drawContentsInContext:(CGContext *) ctx;
- (void) drawBackgroundInContext:(CGContext *) context;
- (void) drawBorderInContext:(CGContext *) context;


- (void) setTransform:(_NVGtransform) transform
              scissor:(NVGscissor *) scissor;


@end


@class UIImage;


@protocol CAImageLayer 

@property( retain) UIImage   *image;

@end
  
