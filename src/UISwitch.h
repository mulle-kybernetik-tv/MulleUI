#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"

#import "CALayer.h"


@interface UISwitch : UIView < UIControl>
{
   UIControlIvars;
}

- (char *)cString;
- (void)setCString:(char *)s;
- (char *) fontName;
- (void) setFontName:(char *)s;
- (CGFloat) fontPixelSize;
- (void) setFontPixelSize:(CGFloat)s;

- (void) setBackgroundColor:(CGColorRef)color;
- (CGColorRef) backgroundColor;
- (void) setTextColor:(CGColorRef)color;
- (CGColorRef) textColor;

@end
