#import "UIView.h"
#import "UIControl.h"


@class UIImage;


@interface UIButton : UIView <UIControl>
{
   UIControlIvars;

   UIImage   *_backgroundImage[ 4];
}

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