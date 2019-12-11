#import "UIView.h"

#import "CALayer.h"

@interface UILabel : UIView


// points
- (CGFloat) fontSize;
- (void) setFontSize:(CGFloat) s;

@end

@interface UILabel( Forwarding)

- (void) setCString:(char *) s;
- (char *) cString;
- (char *) fontName;
- (void) setFontName:(char *) s;
- (CGFloat) fontPixelSize;
- (void) setFontPixelSize:(CGFloat) value;

- (void) setBackgroundColor:(CGColorRef) color;
- (CGColorRef) backgroundColor;
- (void) setTextColor:(CGColorRef) color;
- (CGColorRef) textColor;

@end
