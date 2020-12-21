#import "CALayer.h"

#import "CGBase.h"

#import "MulleCursorProtocol.h"


@class MulleSVGImage;

// Should be a subclass of MulleImageLayer really...
//
// Rendering the Ghostscript Tiger with the current setup is too slow
// for reliable 60fps, if two tigers are drawn. It can do it sometimes,
// but very often it overflows. (Even when using NVG_TESS_AFD)
//
// Ubuntu 18.10, Intel(R) Xeon(R) CPU E5-2660 v3 @ 2.60GHz
// OpenGL renderer string: GeForce GTX 970/PCIe/SSE2
// OpenGL core profile version string: 4.6.0 NVIDIA 390.87
//
// It seems wise to pre-render SVG layers into bitmaps
//
@interface MulleSVGLayer : CALayer <CAImageLayer, MulleCursor>
{
	UIImage   *_image;
   CGPoint   _offset;
}

MULLE_CURSOR_PROPERTIES;

@property( assign, getter=isSelected) BOOL   selected;
@property( observable) CGColorRef            selectionColor;

- (instancetype) initWithImage:(UIImage *) image;
- (instancetype) initWithSVGImage:(MulleSVGImage *) image;

@end
