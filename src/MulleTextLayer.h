#import "CALayer.h"

// not a string in MulleUI
// TODO: rename or at least alias the k constants
typedef enum CATextLayerAlignmentMode
{
   CAAlignmentLeft = 0,
   CAAlignmentRight,
   CAAlignmentCenter

   // kCAAlignmentJustified,
   // kCAAlignmentNatural,
} CATextLayerAlignmentMode;


#define kCAAlignmentLeft    CAAlignmentLeft
#define kCAAlignmentRight   CAAlignmentRight
#define kCAAlignmentCenter  CAAlignmentCenter
  
      

@interface MulleTextLayer : CALayer
{
   // values exist after a frame is drawn,
   // will change on next redraw possiby
@private
   NVGtextRow          _row;
   NSUInteger          _nRows;   
   NSUInteger          _nGlyphs;
	NVGglyphPosition    _glyphs[ 100];
   CGPoint             _origin;
   CGFloat             _lineh;
   NSUInteger          _startSelection;
}

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property( assign) char     *cString;

//
// The selection of the UTF8 characters: the selection must not
// split graphemes and combined emoji. But MulleTextLayer won't check that.
//
@property( assign) NSRange          selection;
@property( observable) CGColorRef   textColor;
@property( observable) CGPoint      textOffset;

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
