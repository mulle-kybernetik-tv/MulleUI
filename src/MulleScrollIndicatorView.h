#import "UIView.h"

#import "CALayer.h"


@interface MulleScrollIndicatorView : UIView

- (CGPoint) contentOffsetAtPoint:(CGPoint) point;

@end


@interface MulleScrollIndicatorLayer : CALayer 

@property( assign) CGFloat   bubbleOffset;
@property( assign) CGFloat   bubbleLength;
@property( assign) CGFloat   contentLength;

@end
