#import "UIWindow.h"

@interface UIWindow( UIEvent)

- (id) _firstResponder;

+ (void) sendEmptyEvent;
- (void) waitForEvents:(double) hz;
- (void) setupQuadtree;

// Use -[UIView addTrackingAreaWithRect:toWindow:userInfo:]. It will call 
// -[UIWindow addTrackingView:] eventually
- (void) addTrackingView:(UIView *) view;
- (void) removeTrackingView:(UIView *) view;

@end


@interface UIWindow( OSEvents)

+ (void) os_sendEmptyEvent;
- (void) os_initEvents;
- (void) os_pollEvents;
- (void) os_waitEventsTimeout:(CGFloat) seconds;

@end


@interface UIWindow( OSInputEvents)

- (void) _charCallback:(unsigned int) codepoint;
- (void) _keyCallback:(int) key
             scancode:(int) scancode
               action:(int) action
            modifiers:(int) mods;  

- (void) _mouseMoveCallback:(CGPoint) pos;
- (void) _mouseButtonCallback:(int) button
                       action:(int) action
                    modifiers:(int) mods;            
- (void) _mouseScrollCallback:(CGPoint) offset;

@end
