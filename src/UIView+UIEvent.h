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


//
// methods optionally implemented by UIView subclasses
//
@interface UIView ( UIFutureEvents)

- (UIEvent *) keyUp:(UIEvent *) event;
- (UIEvent *) keyDown:(UIEvent *) event;

- (UIEvent *) scrollWheel:(UIEvent *) event;

- (UIEvent *) mouseDown:(UIEvent *) event;
- (UIEvent *) otherMouseDown:(UIEvent *) event;
- (UIEvent *) rightMouseDown:(UIEvent *) event;

- (UIEvent *) mouseUp:(UIEvent *) event;
- (UIEvent *) otherMouseUp:(UIEvent *) event;
- (UIEvent *) rightMouseUp:(UIEvent *) event;

- (UIEvent *) mouseDragged:(UIEvent *) event;
- (UIEvent *) otherMouseDragged:(UIEvent *) event;
- (UIEvent *) rightMouseDragged:(UIEvent *) event;

- (UIEvent *) mouseEntered:(UIEvent *) event;
- (UIEvent *) mouseExited:(UIEvent *) event;
- (UIEvent *) mouseMoved:(UIEvent *) event;

@end
