#import "CALayer.h"

@class UIImage;


typedef enum
{
   UIViewContentModeScaleToFill,
   UIViewContentModeScaleAspectFit,
   UIViewContentModeScaleAspectFill,
   UIViewContentModeRedraw,
   UIViewContentModeCenter,
   UIViewContentModeTop,
   UIViewContentModeBottom,
   UIViewContentModeLeft,
   UIViewContentModeRight,
   UIViewContentModeTopLeft,
   UIViewContentModeTopRight,
   UIViewContentModeBottomLeft,
   UIViewContentModeBottomRight
} UIViewContentMode;


@interface MulleImageLayer : CALayer <CAImageLayer>
{
	UIImage   *_image;
}

- (instancetype) initWithImage:(UIImage *) image;

// contentMode is not in UIView, because only UIImageView supports it (for now)
@property UIViewContentMode   contentMode;

@end
