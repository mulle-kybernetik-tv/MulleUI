#import "CALayer.h"

@class UIImage;


@interface MulleImageLayer : CALayer <CAImageLayer>
{
	UIImage   *_image;
}

- (instancetype) initWithImage:(UIImage *) image;

@end
