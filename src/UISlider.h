#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"

#import "CALayer.h"


@interface UISlider : UIView < UIControl>
{
   UIControlIvars;
}

@property( assign, setter=setContinuous:) BOOL   isContinuous;

@end
