#import "UIView.h"

#import "MulleTextLayer.h"


@class UIFont;


@interface UILabel : UIView

// points
- (CGFloat) fontSize;
- (void) setFontSize:(CGFloat) s;

- (void) setFont:(UIFont *) font;
- (UIFont *) font;

@end

typedef enum UITextAlignment
{
   UITextAlignmentLeft   = kCAAlignmentLeft,
   UITextAlignmentRight  = kCAAlignmentRight,
   UITextAlignmentCenter = kCAAlignmentCenter
   // kCAAlignmentJustified,
   // kCAAlignmentNatural,
} UITextAlignment;


@interface UILabel( Forwarding)

- (void) setCStringName:(char *) s;
- (char *) cStringName;
- (char *) fontName;
- (void) setFontName:(char *) s;
- (CGFloat) fontPixelSize;
- (void) setFontPixelSize:(CGFloat) value;

- (void) setBackgroundColor:(CGColorRef) color;
- (CGColorRef) backgroundColor;
- (void) setTextColor:(CGColorRef) color;
- (CGColorRef) textColor;

- (UITextAlignment) textAlignment;
- (void) setTextAlignment:(UITextAlignment) value;

@end
