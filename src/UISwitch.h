#import "UIView.h"
#import "UIControl.h"
#import "UIView+UIResponder.h"

#import "CALayer.h"


@interface UISwitch : UIView < UIControl>
{
   UIControlIvars;
}

@end


@interface UISwitch( CACheckBoxLayerForwarding)

- (void) setTextColor:(CGColorRef)color;
- (CGColorRef) textColor;

- (char *) cString;
- (void) setCString:(char *)s;
- (char *) fontName;
- (void) setFontName:(char *)s;
- (CGFloat) fontPixelSize;
- (void) setFontPixelSize:(CGFloat)s;

@end
