#import "CALayer.h"

#import "CGBase.h"


@class MulleSVGImage;
struct NVGcontext;


@interface MulleSVGLayer : CALayer
{
   CGPoint   _offset;
}
@property( retain, nonatomic) MulleSVGImage   *SVGImage;

- (instancetype) initWithSVGImage:(MulleSVGImage *) image;
- (BOOL) drawInContext:(struct NVGcontext *) vg;

@end
