#import "UIEvent.h"

#import "UIWindow+UIEvent.h"
#import "UIView+CGGeometry.h"


@implementation UIEvent 

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
{
   _window         = window;
   _mousePosition  = pos;
   _timestamp      = CAAbsoluteTimeNow();
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

- (CGPoint) _firstResponderPoint
{
   return( _point);
}

- (void) _setFirstResponderPoint:(CGPoint) point
{
   assert( point.x != CGFLOAT_MIN);
   _point = point;
}


- (char *) cStringDescription
{
   char   *s;

   s = MulleObjC_asprintf( "<%p %s @%.1f %.1f t:%.6f>", 
                  self, 
                  class_getName( object_getClass( self)),
                  _mousePosition.x,
                  _mousePosition.y,
                  _timestamp);
   return( s);
}

@end


@implementation UIKeyboardEvent 

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
                  key:(int) key
             scanCode:(int) scanCode
               action:(int) action
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



// Receive a OS unicode character (w/o key press)
@implementation UIUnicodeEvent

- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
            character:(int) character
{
   self = [self initWithWindow:window
                 mousePosition:pos
                     modifiers:mods];

   _character = character;

   return( self);
}

- (UIEventType) eventType
{
   return( UIEventTypeUnicode);
}

            
@end


@implementation UIMouseMotionEvent 

- (UIEventType) eventType
{
   return( UIEventTypeMotion);
}


- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
         buttonStates:(uint64_t) buttonStates
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
            modifiers:(int) mods
               button:(int) button
               action:(int) action 
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


- (char *) cStringDescription
{
   char   *s;

   s = MulleObjC_asprintf( "<%p %s @%.1f %.1f t:%.6f b:%d a:%d>", 
                  self, 
                  class_getName( object_getClass( self)),
                  _mousePosition.x,
                  _mousePosition.y,
                  _timestamp,
                  _button,
                  _action);
   return( s);
}

@end


@implementation UIMouseScrollEvent

static struct
{
   CGFloat   _acceleration;
} Self = 
{ 
   3.0
};


- (id) initWithWindow:(UIWindow *) window
        mousePosition:(CGPoint) pos
            modifiers:(int) mods
         scrollOffset:(CGPoint) scrollOffset 
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


+ (CGFloat) scrollWheelAcceleration
{
   return( Self._acceleration);
}


+ (void) setScrollWheelAcceleration:(CGFloat) value
{
   Self._acceleration = value;
}

- (CGPoint) acceleratedScrollOffset
{
   CGPoint   offset;

   offset.x = _scrollOffset.x * Self._acceleration;
   offset.y = _scrollOffset.y * Self._acceleration;

   return( offset);
}


@end
