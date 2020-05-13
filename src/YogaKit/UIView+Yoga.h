#import "UIView.h"
#import "YGLayout.h"


@interface UIView( Yoga) < Yoga >

- (YGLayout *) yoga;

- (void) setNeedsLayout;

@end
