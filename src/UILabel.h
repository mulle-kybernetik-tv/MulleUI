#import "UIView.h"

#import "CALayer.h"

@interface UILabel : UIView

- (char *) cString;
- (void) setCString:(char *) s;
- (char *) fontName;
- (void) setFontName:(char *) s;
- (CGFloat) fontSize;
- (void) setFontSize:(CGFloat) s;

- (void) setBackgroundColor:(CGColorRef) color;
- (CGColorRef) backgroundColor;
- (void) setTextColor:(CGColorRef) color;
- (CGColorRef) textColor;

@end
