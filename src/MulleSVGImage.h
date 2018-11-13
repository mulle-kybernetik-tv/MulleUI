#import <MulleObjC/MulleObjC.h>

#import "CGGeometry.h"


struct NSVGimage;


@interface MulleSVGImage : NSObject
{
	struct NSVGimage   *_NSVGImage;
}

- (instancetype) initWithBytes:(void *) bytes 
                        length:(NSUInteger) length;

- (instancetype) initWithNSVGImage:(struct NSVGimage *) image;
- (instancetype) initWithContentsOfFileWithFileRepresentationString:(char *) s;
- (struct NSVGimage *) NSVGImage;

- (CGSize) size;
- (CGRect) visibleBounds;

@end
