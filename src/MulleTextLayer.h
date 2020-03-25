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

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property( assign) char     *cString;
@property CGColorRef        textColor;
// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef        textBackgroundColor;
@property( assign) enum CATextLayerAlignmentMode  alignmentMode;

@end
