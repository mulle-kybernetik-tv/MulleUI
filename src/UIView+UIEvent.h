#import "UIView.h"

#import "UIEvent.h"

@class UIMouseScrollEvent;


@interface UIView ( UIEvent)

- (BOOL) hitTest:(CGPoint) point
       withEvent:(UIEvent *) event;

// returns event if it hasn't been handled
- (UIEvent *) handleEvent:(UIEvent *) event;
- (UIEvent *) handleEvent:(UIEvent *) event
               atPosition:(CGPoint) position;

// translate from paren bounds to self bounds
- (CGPoint) translatedPoint:(CGPoint) point;

@end


@interface UIView ( UIEventFuture)

- (UIEvent *) scrollWheel:(UIMouseScrollEvent *) event;

@end
