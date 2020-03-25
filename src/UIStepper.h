#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"

#import "CALayer.h"


@interface UIStepper : UIView < UIControl>
{
   UIControlIvars;
}

UIControlProperties;

// not part of the stepper
// as its not displaying anything 
@property(assign) float  value;
@property(assign) float  minimumValue;
@property(assign) float  maximumValue;
@property( nonatomic) float   stepValue;

@property( assign, setter=setContinuous:) BOOL   isContinuous;
@property( assign) BOOL   wraps;
@property( assign) BOOL   autorepeat;  // not autorepeats :(

@end
