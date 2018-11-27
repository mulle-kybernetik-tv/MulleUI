#import "import.h"

#include "CGGeometry.h"


#include <time.h>

typedef enum  {
    UIEventTypeTouches, // Mouse click
    UIEventTypeMotion,  // Mouse movemeent
    UIEventTypePresses  // Keyboard 
} UIEventType;


@interface UIEvent : NSObject


@property( assign, readonly) CGPoint       mousePosition;

// cpu time of event not an NSTimeStamp
@property( assign, readonly) clock_t  timestamp;

- (id) initWithMousePosition:(CGPoint) pos;
- (UIEventType) eventType;

@end


@interface UIKeyboardEvent : UIEvent

@property( assign, readonly) int   key;
@property( assign, readonly) int   scanCode;
@property( assign, readonly) int   action;
@property( assign, readonly) int   modifiers;

- (id) initWithMousePosition:(CGPoint) pos
                         key:(int) key
                    scanCode:(int) scanCode
                      action:(int) action
                   modifiers:(int) mods;
@end


@interface UIMouseMotionEvent : UIEvent

- (id) initWithMousePosition:(CGPoint) pos
				    buttonStates:(uint64_t) buttonStates
                   modifiers:(int) mods;

@property( assign, readonly) int   buttonStates;
@property( assign, readonly) int   modifiers;

@end


@interface UIMouseButtonEvent : UIEvent

@property( assign, readonly) int   button;
@property( assign, readonly) int   action;
@property( assign, readonly) int   modifiers;

- (id) initWithMousePosition:(CGPoint) pos
						    button:(int) button
							 action:(int) action 
                   modifiers:(int) mods;
                  

@end
