#import "UIView.h"
#import "YGLayout.h"


//
// an idea is to map this to Yoga flex box properties 
//
enum
{
   UIViewAutoresizingNone = 0,
   UIViewAutoresizingFlexibleLeftMargin = 1 << 0,
   UIViewAutoresizingFlexibleWidth = 1 << 1,
   UIViewAutoresizingFlexibleRightMargin = 1 << 2,
   UIViewAutoresizingFlexibleTopMargin = 1 << 3,
   UIViewAutoresizingFlexibleHeight = 1 << 4,
   UIViewAutoresizingFlexibleBottomMargin = 1 << 5
};

@interface UIView( Yoga)

- (YGLayout *) yoga;
- (void) setAutoresizingMask:(NSUInteger) mask;

@end
