#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"
#import "UIEdgeInsets.h"
#import "CALayer.h"


@interface UISlider : UIView < UIControl>
{
   UIControlIvars;
}

@property( assign, setter=setContinuous:) BOOL   isContinuous;

UIControlProperties;

@end


@interface UISlider( MulleSliderLayerForward)

@property(assign) float  value;
@property(assign) float  minimumValue;
@property(assign) float  maximumValue;

@property( observable) CGColorRef     controlColor;
@property( observable) UIEdgeInsets   controlInsets;


// the visible rect for control value, the knob
// overshoots this by its radius though (minus some border pixels)
- (CGRect) controlRectWithFrame:(CGRect) frame;
- (CGFloat) knobRadiusWithFrame:(CGRect) frame;

@end
