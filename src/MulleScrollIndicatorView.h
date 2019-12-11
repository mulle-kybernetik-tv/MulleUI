#import "UIView.h"

#import "CALayer.h"


@interface MulleScrollIndicatorView : UIView
@end


// TODO: put everything into a protocol ??
@protocol MulleScrollIndicatorLayer

@property( assign) CGFloat   bubbleOffset;
@property( assign) CGFloat   bubbleLength;
@property( assign) CGFloat   contentLength;

- (CGPoint) contentOffsetAtPoint:(CGPoint) point;
- (CGRect) bubbleFrameWithBounds:(CGRect) bounds;

@end

@interface MulleScrollIndicatorLayer : CALayer  <MulleScrollIndicatorLayer> 
{
   CGFloat   _bubbleOffset;
   CGFloat   _bubbleLength;
   CGFloat   _contentLength;   
}
@end


// TODO: test what this actually does!
@interface MulleScrollIndicatorView( MulleScrollIndicatorLayerForwarding) <MulleScrollIndicatorLayer>
@end
