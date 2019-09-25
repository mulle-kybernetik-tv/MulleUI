#import "import.h"

#include "CGGeometry.h"

#include <time.h>

@class UIWindow;
@class UIView;


// bits suitable or bitmasking
typedef enum
{
   UIEventTypePresses = 0x1,  // Keyboard
   UIEventTypeTouches = 0x2,  // Mouse click
   UIEventTypeMotion  = 0x4,  // Mouse movemeent
   UIEventTypeScroll  = 0x8   // Mouse Scrollwheel
} UIEventType;

@interface UIEvent : NSObject
{
   UIWindow  *_window;   // assign  ??
   CGPoint   _point;
}

@property( assign, readonly) CGPoint   mousePosition;

// cpu time of event not an NSTimeStamp
@property( assign, readonly) clock_t   timestamp;

// current known state of modifier keys
@property( assign, readonly) uint64_t  modifiers;

//
// translated mousePosition to current view bounds (ephemeral)
// set by _handleEvent:position for
//
- (CGPoint) mousePositionInView:(UIView *) view;
- (void) _setFirstResponderPoint:(CGPoint) point;

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods;

@end


@interface UIEvent( Subclasses)

- (UIEventType) eventType;

@end

/*
 * Subclasses
 */

@interface UIKeyboardEvent : UIEvent

@property( assign, readonly) int   key;
@property( assign, readonly) int   scanCode;
@property( assign, readonly) int   action;

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
                  key:(int) key
             scanCode:(int) scanCode
               action:(int) action
            modifiers:(int) mods;
@end


@interface UIMouseButtonEvent : UIEvent

@property( assign, readonly) int   button;
@property( assign, readonly) int   action;

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
               button:(int) button
               action:(int) action 
            modifiers:(int) mods;
                  

@end


@interface UIMouseMotionEvent : UIEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
         buttonStates:(uint64_t) buttonStates
            modifiers:(int) mods;

@property( assign, readonly) int   buttonStates;

@end


@interface UIMouseScrollEvent : UIEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
         scrollOffset:(CGPoint) offset
            modifiers:(int) mods;

@property( assign, readonly) CGPoint   scrollOffset;

@end

