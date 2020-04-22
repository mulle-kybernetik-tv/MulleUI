#import "UIView.h"
#import "UIControl.h"
#import "MulleControlBackgroundImage.h"
#import "UIView+UIResponder.h"
#import "MulleSegmentedControlLayer.h"  // expose methods for fowarding
#import "CALayer.h"

enum
{
   UISegmentedControlNoSegment = -1
};

@interface UISegmentedControl : UIView < MulleControlBackgroundImage, UIControl>
{
   UIControlIvars;
   MulleControlBackgroundImageIvars;
}

UIControlProperties;
MulleControlBackgroundImageProperties;

@property( assign, setter=setContinuous:) BOOL   isContinuous;
@property( assign, setter=setMomentary:)  BOOL   isMomentary;
@property( assign, setter=setAllowsMultipleSelection:)  BOOL  allowsMultipleSelection;
@property( assign, setter=setAllowsEmptySelection:)     BOOL  allowsEmptySelection;

@end


@interface UISegmentedControl( CACheckBoxLayerForwarding)

@property( assign) char     *fontName;
@property( assign) CGFloat  fontPixelSize;
@property CGColorRef        textColor;
// for cleartype it's important to know the color the text is drawn on
// if the layer backgroundColor is transparent, use this color to supply
// the correct color to use
@property CGColorRef        textBackgroundColor;

// not really a tint, just a different backgroundColor for the segment
@property CGColorRef        selectedSegmentTintColor;

- (NSUInteger) numberOfSegments;

- (void) insertSegmentWithTitleCString:(char *) title 
                               atIndex:(NSUInteger) segment 
                              animated:(BOOL) animated;
// - (void) insertSegmentWithImage:(UIImage *) image 
//                        atIndex:(NSUInteger) segment 
//                       animated:(BOOL) animated;

- (void) setContentOffset:(CGSize) offset 
        forSegmentAtIndex:(NSUInteger) segment;
- (void) setBackgroundColor:(CGColorRef) color 
          forSegmentAtIndex:(NSUInteger) segment;

- (NSUInteger) segmentIndexAtPoint:(CGPoint) point;
- (void) selectSegmentAtIndex:(NSUInteger) index;
- (void) deselectSegmentAtIndex:(NSUInteger) index;
- (BOOL) isSelectedSegmentAtIndex:(NSUInteger) index;
- (NSUInteger) numberOfSelectedSegments;

- (NSUInteger) selectedSegmentIndex;
- (void) setSelectedSegmentIndex:(NSUInteger) index;

// private: used during events only
- (void) memorizeSelectedSegments;
- (void) recallSelectedSegments;

@end
