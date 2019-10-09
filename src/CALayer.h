#import "import.h"

#import "CGColor.h"
#import "CATime.h"


typedef float   _NVGtransform[ 6];   


@class CGContext;
@class CAAnimation;

struct MulleFrameInfo;


@interface CALayer : NSObject < NSCopying>
{
   _NVGtransform               _transform;
   NVGscissor                  _scissor;
   CALayer                     *_snapshot;
   struct mulle_pointerarray   _animations;    
}

@property( observable) CGFloat      cornerRadius;
@property( observable) CGFloat      borderWidth;
@property( observable) CGColorRef   borderColor;
@property( observable) CGColorRef   backgroundColor;
@property( observable) CGRect       frame;
@property( observable) CGRect       bounds;

// non-observable
@property char       *cStringName;
@property void       (*drawContentsCallback)( NVGcontext *vg, 
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


- (void) setTransform:(_NVGtransform) transform
              scissor:(NVGscissor *) scissor;


- (void) addAnimation:(CAAnimation *) animation;
- (void) removeAllAnimations;
- (NSUInteger) numberOfAnimations;

- (void) animateWithAbsoluteTime:(CAAbsoluteTime) time;

//
// called by UIView to create implicit animations from snapshotted values
// the snapshot will be gone afterwards. Also cancels all other 
// animations. (?)
//
- (void) commitImplicitAnimationsWithAnimationID:(char *) animationsID
                                         context:(void *) context;

@end


@class UIImage;


@protocol CAImageLayer 

@property( retain) UIImage   *image;

@end
  
