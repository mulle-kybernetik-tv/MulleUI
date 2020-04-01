#import "UIView.h"
#import "UIControl.h"
#import "MulleControlBackgroundImage.h"
#import "UIView+UIResponder.h"
#import "MulleSegmentedControlLayer.h"  // expose methods for fowarding
#import "CALayer.h"

enum
{
   UISegmentedControlNoSegment = -1
};

@interface UISegmentedControl : UIView < MulleControlBackgroundImage, UIControl>
{
   UIControlIvars;
   MulleControlBackgroundImageIvars;
}

UIControlProperties;
MulleControlBackgroundImageProperties;

@property( assign, setter=setContinuous:) BOOL   isContinuous;
@property( assign, setter=setMomentary:)  BOOL   isMomentary;

@end
