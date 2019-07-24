#import "CALayer.h"

#import "CGBase.h"


@class MulleBitmapImage;
struct NVGcontext;


@interface MulleBitmapLayer : CALayer <CAImageLayer>
{
	UIImage   *_image;
}

- (instancetype) initWithBitmapImage:(MulleBitmapImage *) image;

- (BOOL) writeToBMPFileWithSystemRepresentation:(char *) filename;

@end
