#import "CALayer.h"

@interface MulleCheckboxLayer : CALayer

@property(assign) char *fontName;
@property(assign) CGFloat fontPixelSize;
@property(assign) char *cString;
@property CGColorRef textColor;
@property( assign, setter=setChecked:) BOOL isChecked;
@end
