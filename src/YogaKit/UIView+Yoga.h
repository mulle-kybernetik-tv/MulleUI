#import "UIView.h"
#import "YGLayout.h"


//
// an idea is to map this to Yoga flex box properties 
// Seems this not doable, as you can not size a child to fill the container
// at least it didn't seem possible in the javascript site
//
enum
{
   UIViewAutoresizingNone                 = 0,
   UIViewAutoresizingFlexibleTopMargin    = 1 << 0,
   UIViewAutoresizingFlexibleBottomMargin = 1 << 1,
   UIViewAutoresizingFlexibleLeftMargin   = 1 << 2,
   UIViewAutoresizingFlexibleRightMargin  = 1 << 3,
   UIViewAutoresizingFlexibleHeight       = 1 << 4,
   UIViewAutoresizingFlexibleWidth        = 1 << 5
};

@interface UIView( Yoga) < Yoga >

- (YGLayout *) yoga;
- (void) setAutoresizingMask:(NSUInteger) mask;
- (NSUInteger) autoresizingMask;

- (void) setNeedsLayout;
- (void) layoutSubviews;

@end
