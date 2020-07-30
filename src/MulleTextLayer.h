#import "CALayer.h"

// not a string in MulleUI
typedef enum CATextLayerAlignmentMode
{
   kCAAlignmentLeft = 0,
   kCAAlignmentRight,
   kCAAlignmentCenter
   // kCAAlignmentJustified,
   // kCAAlignmentNatural,
} CATextLayerAlignmentMode;


@interface MulleTextLayer : CALayer
{
   // values exist after a frame is drawn,
   // will change on next redraw possiby
@private
   NVGtextRow          _row;
   NSUInteger          _nRows;   
   NSUInteger          _nGlyphs;
	NVGglyphPosition    _glyphs[ 100];
   CGPoint             _cursor;
   CGFloat             _lineh;
}

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property( assign) char     *cString;
@property CGColorRef        textColor;
// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef        textBackgroundColor;
@property( assign) enum CATextLayerAlignmentMode  alignmentMode;

// if editable and in focus, will draw a caret/curso
@property( assign, getter=isEditable) BOOL    editable;
@property( assign) NSUInteger                 cursorPosition;

- (void) setCursorPositionToPoint:(CGPoint) point;

@end
