#import "UIImage.h"

#import "CGGeometry.h"


struct NSVGimage;


// SVGImage keeps a copy of the original SVG by default (if available)
@interface MulleSVGImage : UIImage
{
	struct NSVGimage   *_NSVGImage;
}

- (instancetype) initWithNSVGImage:(struct NSVGimage *) image
                         mulleData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator;

- (struct NSVGimage *) NSVGImage;

@end
