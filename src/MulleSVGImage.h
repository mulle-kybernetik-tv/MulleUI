#import "UIImage.h"

#import "CGGeometry.h"


struct NSVGimage;


@interface MulleSVGImage : UIImage
{
	struct NSVGimage   *_NSVGImage;
}

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length;

- (instancetype) initWithNSVGImage:(struct NSVGimage *) image;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;

- (struct NSVGimage *) NSVGImage;

@end
