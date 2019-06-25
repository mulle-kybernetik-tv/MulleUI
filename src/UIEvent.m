#import "UIEvent.h"

#import "UIWindow.h"
#import "UIView+CGGeometry.h"


@implementation UIEvent 

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
{
   _window         = window;
   _mousePosition  = pos;
   _timestamp      = clock();
   _modifiers      = mods;
   _point.x        = CGFLOAT_MIN;
   return( self);
}

- (CGPoint) mousePositionInView:(UIView *) view
{
   if( ! view)
      return( _mousePosition);
   if ( _point.x != CGFLOAT_MIN && view == [_window _firstResponder])
      return( _point);
   
   return( [view convertPoint:_mousePosition
                     fromView:NULL]);
}

- (void) _setFirstResponderPoint:(CGPoint) point
{
   assert( point.x != CGFLOAT_MIN);
   _point = point;
}

@end


@implementation UIKeyboardEvent 

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
                  key:(int) key
             scanCode:(int) scanCode
               action:(int) action
            modifiers:(int) mods
{
   self = [self initWithWindow:window
                 mousePosition:pos
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


- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
         buttonStates:(uint64_t) buttonStates
            modifiers:(int) mods
{
   self = [self initWithWindow:window
                 mousePosition:pos
                     modifiers:mods];

   _buttonStates = buttonStates;

   return( self);
}

@end


@implementation UIMouseButtonEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
               button:(int) button
               action:(int) action 
            modifiers:(int) mods
{
   self = [self initWithWindow:window
                 mousePosition:pos
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

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
         scrollOffset:(CGPoint) scrollOffset 
            modifiers:(int) mods
{
   self = [self initWithWindow:window
                 mousePosition:pos
                     modifiers:mods];
   _scrollOffset = scrollOffset;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypeScroll);
}

@end
