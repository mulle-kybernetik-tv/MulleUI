#import "UIView.h"
#import "UIControl.h"


@class UIImage;


//
// here the compiler can't figure out that the informal protocol on
// UIControl is part of the Protocolclass. 
// a) why isn't it an optional part of the protocol then ?
//
@interface UIButton : UIView <UIControl>
{
   UIControlIvars;

   UIImage   *_backgroundImage[ 4];
}

UIControlProperties;

// UIControlState can be:
//
//    UIControlStateNormal
//    UIControlStateSelected
//    UIControlStateNormal|UIControlStateDisabled
//    UIControlStateSelected|UIControlStateDisabled
//
// Highlighting will use the inverse of the current selection state
//
- (void) setBackgroundImage:(UIImage *) image 
                   forState:(UIControlState) state;

@end