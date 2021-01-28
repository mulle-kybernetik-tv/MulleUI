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

@property( assign) NSRange          selection;
@property( observable) CGColorRef   selectionColor;
@property( observable) CGColorRef   textColor;
@property( observable) CGPoint      textOffset; // in pixels

// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef                               textBackgroundColor;
@property( assign) enum CATextLayerAlignmentMode   alignmentMode;
@property( assign) NSLineBreakMode                 lineBreakMode;

@property( assign, getter=isMultiLineEnabled) BOOL   multiLineEnabled;

// if editable and in focus, will draw a caret/cursor
@property( assign, getter=isEditable) BOOL           editable;
// cursor position as row/column
@property( assign) struct MulleIntegerPoint          cursorPosition;

// incoming data need not be zero terminated
- (void) setUTF8Data:(struct mulle_utf8data) data;
// returned data is zero terminated but does not show it in length
- (struct mulle_utf8data) UTF8Data;

- (char *) cString;
- (void) setCString:(char *) s;

// for debugging
- (void) setDebugNameCString:(char *) s;
- (char *) debugNameCString;

// should probably rename to fontNameAsCString and setFontNameWithCString or
// so
- (char *) fontName;
- (void) setFontName:(char *) s;
- (CGFloat) fontPixelSize;
- (void) setFontPixelSize:(CGFloat) value;

- (void) setBackgroundColor:(CGColorRef) color;
- (CGColorRef) backgroundColor;
- (void) setTextColor:(CGColorRef) color;
- (CGColorRef) textColor;

// mapped to alignmentMode of MulleTextLayer
- (UITextAlignment) textAlignment;
- (void) setTextAlignment:(UITextAlignment) value;


- (enum MulleTextLayerVerticalAlignmentMode)  mulleVerticalAlignmentMode;
- (void) mulleSetVerticalAlignmentMode:(enum MulleTextLayerVerticalAlignmentMode) mode;

// for a MulleTextLayer the descender coordinate is always at 0
// the baseline is a y offset from 0
// the ascender is lineHeight - baseLiney
- (CGFloat) fontLineHeight;
- (CGFloat) fontBaseline;
- (void) getFontTextBounds:(CGFloat [4]) bounds;

@end
