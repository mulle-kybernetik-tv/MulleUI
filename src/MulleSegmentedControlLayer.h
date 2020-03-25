#import "CALayer.h"

struct MulleUISegment
{
   char       *title;
   UIImage    *image;
   CGSize      offset;
   CGColorRef  backgroundColor;
   CGRect      frame;  // this value is ephemeral and used during rendering
   // these are values for UIView
   char        isSelected;
};

//
// because we do not have NSString available and don't want to wrap each
// title in something, we maintain two different array for images and titles
// At any time there is either a title or an image for a valid index, but
// not both.
//
enum
{
   UISegmentedControlNoSegment = -1
};

@interface MulleSegmentedControlLayer : CALayer 
{
   struct MulleUISegment   *_segments;
   NSUInteger               _n;
   NSUInteger               _size;
}

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property CGColorRef        textColor;
// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef        textBackgroundColor;

- (NSUInteger) numberOfSegments;


- (void) insertSegmentWithTitleCString:(char *) title 
                               atIndex:(NSUInteger) segment 
                              animated:(BOOL) animated;
- (void) insertSegmentWithImage:(UIImage *) image 
                        atIndex:(NSUInteger) segment 
                       animated:(BOOL) animated;

- (void) setContentOffset:(CGSize) offset 
        forSegmentAtIndex:(NSUInteger) segment;
- (void) setBackgroundColor:(CGColorRef) color 
          forSegmentAtIndex:(NSUInteger) segment;

@end
