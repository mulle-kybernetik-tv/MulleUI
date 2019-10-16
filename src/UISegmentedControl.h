#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"

#import "CALayer.h"


@interface UISegmentedControl : UIView < UIControl>
{
   UIControlIvars;
}

@property( assign, setter=setContinuous:) BOOL   isContinuous;
@property( assign, setter=setMomentary:)  BOOL   isMomentary;


- (void) setBackgroundColor:(CGColorRef) color;
- (CGColorRef) backgroundColor;

@end
