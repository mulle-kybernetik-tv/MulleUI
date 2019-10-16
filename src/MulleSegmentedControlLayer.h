#import "CALayer.h"


//
// because we do not have NSString available and don't want to wrap each
// title in something, we maintain two different array for images and titles
// At any time there is either a title or an image for a valid index, but
// not both.
//
@interface MulleSegmentedControlLayer : CALayer 
{
   char         **_titles;
   NSUInteger   _n;
   NSUInteger   _size;
}

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property CGColorRef        textColor;

- (NSUInteger) numberOfSegments;

- (void) insertSegmentWithCString:(char *) title 
                          atIndex:(NSUInteger) segment 
                         animated:(BOOL )animated;

@end
