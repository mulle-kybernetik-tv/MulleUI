#import "CALayer.h"

@interface MulleTextLayer : CALayer

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property( assign) char     *cString;
@property CGColorRef        textColor;

@end
