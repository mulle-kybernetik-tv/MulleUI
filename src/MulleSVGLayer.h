#import "CALayer.h"

#import "CGBase.h"


@class MulleSVGImage;


@interface MulleSVGLayer : CALayer
{
   CGPoint   _offset;
}
@property( retain, nonatomic) MulleSVGImage   *SVGImage;

- (instancetype) initWithSVGImage:(MulleSVGImage *) image;

@end
