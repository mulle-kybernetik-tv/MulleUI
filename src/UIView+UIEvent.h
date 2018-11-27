#import "UIView.h"

#import "UIEvent.h"


@interface UIView ( UIEvent)

- (BOOL) hitTest:(CGPoint) point
       withEvent:(UIEvent *) event;

// returns event if it hasn't been handled
- (UIEvent *) handleEvent:(UIEvent *) event;

@end

