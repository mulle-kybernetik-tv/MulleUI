#import "UIEvent.h"



@implementation UIEvent 

- (id) initWithMousePosition:(CGPoint) pos
                   modifiers:(int) mods
{
   _mousePosition = pos;
   _timestamp     = clock();
   _modifiers     = mods;
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
   self = [self initWithMousePosition:pos
                         	 modifiers:mods];

   _key       = key;
   _scanCode  = scanCode;
   _action    = action;

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
   self = [self initWithMousePosition:pos
                         	 modifiers:mods];

   _buttonStates = buttonStates;

   return( self);
}

@end


@implementation UIMouseButtonEvent

- (id) initWithMousePosition:(CGPoint) pos
						    button:(int) button
							 action:(int) action 
                   modifiers:(int) mods
{
   self = [self initWithMousePosition:pos
                         	 modifiers:mods];
   _button = button;
   _action = action;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypeTouches);
}

@end


@implementation UIMouseScrollEvent

- (id) initWithMousePosition:(CGPoint) pos
					 scrollOffset:(CGPoint) scrollOffset 
                   modifiers:(int) mods
{
   self = [self initWithMousePosition:pos
                         	 modifiers:mods];
   _scrollOffset = scrollOffset;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypeScroll);
}

@end
