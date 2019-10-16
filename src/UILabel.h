#import "UIView.h"

#import "CALayer.h"

@interface UILabel : UIView

- (void) setCString:(char *) s;

// points
- (CGFloat) fontSize;
- (void) setFontSize:(CGFloat) s;

@end

@interface UILabel( Forwarding)

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
