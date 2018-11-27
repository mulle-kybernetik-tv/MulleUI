#import "UIEvent.h"



@implementation UIEvent 

- (id) initWithMousePosition:(CGPoint) pos
{
   _mousePosition = pos;
   _timestamp     = clock();
   return( self);
}

@end


@implementation UIKeyboardEvent 

- (id) initWithMousePosition:(CGPoint) pos
                         key:(int) key
                    scanCode:(int) scanCode
                      action:(int) action
                   modifiers:(int) mods
{
   self = [self initWithMousePosition:pos];

   _key       = key;
   _scanCode  = scanCode;
   _action    = action;
   _modifiers = mods;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypePresses);
}


@end


@implementation UIMouseMotionEvent 

- (UIEventType) eventType
{
   return( UIEventTypeMotion);
}

- (id) initWithMousePosition:(CGPoint) pos
				    buttonStates:(uint64_t) buttonStates
                   modifiers:(int) mods
{
   self = [self initWithMousePosition:pos];

   _buttonStates = buttonStates;
   _modifiers = mods;

   return( self);
}

@end


@implementation UIMouseButtonEvent

- (id) initWithMousePosition:(CGPoint) pos
						    button:(int) button
							 action:(int) action 
                   modifiers:(int) mods
{
   self = [self initWithMousePosition:pos];

   _button    = button;
   _action    = action;
   _modifiers = mods;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypeTouches);
}

@end
