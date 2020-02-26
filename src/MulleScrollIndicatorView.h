#import "UIView.h"

#import "CALayer.h"


@interface MulleScrollIndicatorView : UIView
@end


// TODO: put everything into a protocol ??
//
// contentLength is what we are representing, the bubbleOffset with
// bubbleLength are "inside" the contentLength, not inside the frame or
// bounds. The projection onto our bounds/frame is done inside 
// MulleScrollIndicatorLayer.
//
// UIScrollIndicatorView:
// 0         contentOffset.x    + bounds...width        contentSize.width
// |--------------+-------------+-------------------------------|
//               /             / 
// +------------------------------------------+
// |            |  bubble   |                 |
// +------------------------------------------+
// frame...x                        frame...x + frame....width
// :MulleScrollIndicatorLayer
//
@protocol MulleScrollIndicatorLayer

@property( assign) CGFloat   bubbleOffset;      // [UIScrollView contentOffset].x
@property( assign) CGFloat   bubbleLength;      // [UIScrollView bounds]...width
@property( assign) CGFloat   contentLength;     // [UIScrollView contentSize]..width

- (BOOL) isInsideBubbleAtPoint:(CGPoint) point
                      offsetAt:(CGPoint *) p_distance;

- (CGFloat) bubbleValueAtPoint:(CGPoint) point
                isInsideBubble:(BOOL *) isInsideBubble;

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
