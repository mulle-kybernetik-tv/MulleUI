#import "CALayer.h"

#import "CGBase.h"


@class MulleSVGImage;


@interface MulleSVGLayer : CALayer <CAImageLayer>
{
	UIImage   *_image;
   CGPoint   _offset;
}

- (instancetype) initWithSVGImage:(MulleSVGImage *) image;

@end
