#import "UIView.h"
#import "YGLayout.h"

//
// The problem with Yoga is, that internally it rounds to integer values.
// with YGRoundValueToPixelGrid. When it distributes free space across flexboxes
// which are supposed to be even, then in a row of three. two flexboxes get
// lets say 101 and one gets 100. For a 302 width. That wouldn't be terrible
// on its own, but it seems these values are then cached and reused again 
// later, which makes errors accumulate.
//
@interface UIView( Yoga) < Yoga >

- (YGLayout *) yoga;

- (void) setNeedsLayout;

@end
