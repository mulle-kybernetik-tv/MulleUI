#import "UIEvent.h"

#import "UIWindow+UIEvent.h"
#import "UIView+CGGeometry.h"


@implementation UIEvent 

- (id) initWithWindow:(UIWindow *) window
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
{
   _window            = window;
   _locationInWindow  = pos;
   _timestamp         = CAAbsoluteTimeNow();
   _modifiers         = mods;
   _translatedPoint.x = CGFLOAT_MIN; // not set
   return( self);
}

static int   UIEventIsFirstResponderPointSet( UIEvent *event)
{
   return( event->_translatedPoint.x != CGFLOAT_MIN);
}


- (CGPoint) mouseLocationInView:(UIView *) view
{
   CGPoint   point;
   CGPoint   translated;
   UIView    *superview;

   if( ! view)
      return( _locationInWindow);
 
   // TODO: CHECK THIS!!
#if 0   
   point = [self _translatedPointForView:view];
   if ( point.x != CGFLOAT_MIN)
   {
#if DEBUG      
      fprintf( stderr, "shortcut");
#endif      
      return( point);
   }
#endif 

   translated = [view convertPoint:_locationInWindow
                          fromView:NULL];
#ifdef DEBUG
   fprintf( stderr, "%s -> %s\n", 
               CGPointCStringDescription( _locationInWindow),
               CGPointCStringDescription( translated));
#endif               
   return( translated);
}


- (CGPoint) _translatedPointForView:(UIView *) view
{
   if( view == _translatedView)
      return( _translatedPoint);
   return( CGPointMake( CGFLOAT_MIN, CGFLOAT_MIN));
}


- (void) _setTranslatedPoint:(CGPoint) point
                     forView:(UIView *) view
{
   assert( point.x != CGFLOAT_MIN);
   assert( view);

   _translatedPoint = point;
   _translatedView  = view;
}


- (char *) cStringDescription
{
   char   *s;

   s = MulleObjC_asprintf( "<%p %s @%.1f %.1f t:%.6f>", 
                  self, 
                  class_getName( object_getClass( self)),
                  _locationInWindow.x,
                  _locationInWindow.y,
                  _timestamp);
   return( s);
}

@end


@implementation UIKeyboardEvent 

- (id) initWithWindow:(UIWindow *) window
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
                  key:(int) key
             scanCode:(int) scanCode
               action:(int) action
{
   self = [self initWithWindow:window
                 mouseLocation:pos
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
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
            character:(int) character
{
   self = [self initWithWindow:window
                 mouseLocation:pos
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
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
         buttonStates:(uint64_t) buttonStates
{
   self = [self initWithWindow:window
                 mouseLocation:pos
                     modifiers:mods];

   _buttonStates = buttonStates;

   return( self);
}

@end


@implementation UIMouseButtonEvent

- (id) initWithWindow:(UIWindow *) window
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
               button:(int) button
               action:(int) action 
{
   self = [self initWithWindow:window
                 mouseLocation:pos
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
                  _locationInWindow.x,
                  _locationInWindow.y,
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
        mouseLocation:(CGPoint) pos
            modifiers:(int) mods
         scrollOffset:(CGPoint) scrollOffset 
{
   self = [self initWithWindow:window
                 mouseLocation:pos
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
