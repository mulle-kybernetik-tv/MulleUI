#import "import.h"

#include "CGGeometry.h"
#include "CATime.h"

@class UIWindow;
@class UIView;


// bits suitable or bitmasking
typedef enum
{
   UIEventTypePresses = 0x01,  // Keyboard
   UIEventTypeUnicode = 0x02,  // Unicode char (interpreted Keyboard)
   UIEventTypeTouches = 0x04,  // Mouse click
   UIEventTypeMotion  = 0x08,  // Mouse movemeent
   UIEventTypeScroll  = 0x10   // Mouse Scrollwheel
} UIEventType;


@interface UIEvent : NSObject
{
   UIWindow  *_window;   // assign  ??
   CGPoint   _point;
}

@property( assign, readonly) CGPoint   mousePosition;

// clock() vs clock_gettime() tests on linux show, that that clock
// is 25% faster. That's IMO not enough to forego the convenience of 
// CAAbsoluteTime here
@property( assign, readonly) CAAbsoluteTime   timestamp;

// current known state of modifier keys
@property( assign, readonly) uint64_t  modifiers;

//
// translated mousePosition to current view bounds (ephemeral)
// set by _handleEvent:position for
//
- (CGPoint) mousePositionInView:(UIView *) view;
- (void) _setFirstResponderPoint:(CGPoint) point;
- (CGPoint) _firstResponderPoint;

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
            modifiers:(int) mods
                  key:(int) key
             scanCode:(int) scanCode
               action:(int) action;
@end


// Receive a OS unicode character (w/o key press)
@interface UIUnicodeEvent : UIEvent

@property( assign, readonly) int   character;

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
            character:(int) key;

@end


@interface UIMouseButtonEvent : UIEvent

@property( assign, readonly) int   button;
@property( assign, readonly) int   action;

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
               button:(int) button
               action:(int) action;
                  

@end


@interface UIMouseMotionEvent : UIEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
         buttonStates:(uint64_t) buttonStates;

@property( assign, readonly) int   buttonStates;

@end


@interface UIMouseScrollEvent : UIEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
         scrollOffset:(CGPoint) offset;

@property( assign, readonly) CGPoint   scrollOffset;

+ (CGFloat) scrollWheelAcceleration;
+ (void) setScrollWheelAcceleration:(CGFloat) value;

- (CGPoint) acceleratedScrollOffset;

@end

