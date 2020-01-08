#import "CALayer.h"

// not a string in MulleUIKit
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
@property( assign) enum CATextLayerAlignmentMode  alignmentMode;

@end
