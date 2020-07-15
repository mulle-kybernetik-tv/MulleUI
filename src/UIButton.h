#import "UIView.h"
#import "MulleControlBackgroundImage.h"


@class UIImage;
@class MulleTextLayer;

//
// here the compiler can't figure out that the informal protocol on
// UIControl is part of the Protocolclass. 
// a) why isn't it an optional part of the protocol then ?
//

// INVESTIGATE: have to redeclare UIControl here to get events...
@interface UIButton : UIView < MulleControlBackgroundImage, UIControl>
{
   UIControlIvars;
   MulleControlBackgroundImageIvars;

   MulleTextLayer   *_titleLayer;
   CALayer          *_titleBackgroundLayer;
}

UIControlProperties;
MulleControlBackgroundImageProperties;

- (void) setTitleCString:(char *) s;
- (char *) titleCString;

// UIControlState can be:
//
//    UIControlStateNormal
//    UIControlStateSelected
//    UIControlStateNormal|UIControlStateDisabled
//    UIControlStateSelected|UIControlStateDisabled
//
// Highlighting will use the inverse of the current selection state
//

- (void) layoutLayersWithFrame:(CGRect) frame;

// subclasses can style by overriding these
+ (MulleTextLayer *) titleLayerWithFrame:(CGRect) rect;
+ (CALayer *) mulleTitleBackgroundLayerWithFrame:(CGRect) rect;

@end