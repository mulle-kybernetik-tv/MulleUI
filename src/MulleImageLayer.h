#import "CALayer.h"

#import "MulleCursorProtocol.h"


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


@interface MulleImageLayer : CALayer <CAImageLayer, MulleCursor>
{
	UIImage   *_image;
}

MULLE_CURSOR_PROPERTIES;


// currently only MulleBitmapImage supported (use MulleSVGLayer for SVG)
- (instancetype) initWithImage:(UIImage *) image;

@property( assign, getter=isSelected) BOOL   selected;
@property( observable) CGColorRef            selectionColor;

// contentMode is not in UIView, because only UIImageView supports it (for now)
@property UIViewContentMode   contentMode;

@end
