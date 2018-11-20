#import "CALayer.h"

#import "CGBase.h"


@class MulleBitmapImage;
struct NVGcontext;


@interface MulleBitmapLayer : CALayer

@property( retain) MulleBitmapImage   *image;

- (instancetype) initWithBitmapImage:(MulleBitmapImage *) image;
- (BOOL) drawInContext:(struct NVGcontext *) vg;

@end
