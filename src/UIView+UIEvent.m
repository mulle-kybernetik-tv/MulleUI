#import "UIView+UIEvent.h"

#import "UIWindow.h"
#import "UIWindow+UIResponder.h"
#import "UIResponder.h"
#import "UIView+CGGeometry.h"
#import "CALayer.h"  // for _NVGtransform
#import "CGGeometry+CString.h"

@interface UIResponder
@end 


@interface UIResponder( PrivateFuture)

- (UIEvent *) _handleEvent:(UIEvent *) event;

@end


// #define EVENT_DEBUG
// #define HITTEST_DEBUG

@implementation UIView ( UIEvent)

+ (CGFloat) mouseMotionSuppressionDelay
{
   return( 0.1);
}


//
// checks if point is in the visible area
// point is in the bounds coordinate system
// Does not recurse to subviews. Query those separately
//
- (BOOL) hitTest:(CGPoint) point
       withEvent:(UIEvent *) event
{
   BOOL     flag;
   CGRect   bounds;

   bounds          = [self bounds];
   bounds.origin.x = -bounds.origin.x;
   bounds.origin.y = -bounds.origin.y;
   flag            = CGRectContainsPoint( bounds, point);

#ifdef HITTEST_DEBUG
   fprintf( stderr, "%s: %s [%s] @%s -> %s\n",
                        __PRETTY_FUNCTION__,
                        [self cStringDescription],
                        CGRectCStringDescription( bounds),
                        CGPointCStringDescription( point),
                        flag ? "YES" : "NO");
#endif
   return( flag);
}


- (UIEvent *) handleMouseButtonEvent:(UIMouseButtonEvent *) event
{
   SEL   sel;
   int   action;
   int   button;

   sel    = 0;
   action = [event action];
   button = [event button];

   if( action == GLFW_PRESS)
      _clickOrDrag._suppressUntilTimestamp = [event timestamp] + _clickOrDrag._mouseMotionSuppressionDelay;

   switch( button)
   {
      case GLFW_MOUSE_BUTTON_LEFT   :
         switch( action)
         {
         case GLFW_PRESS   :
            sel = @selector( mouseDown:);
            break;
         case GLFW_RELEASE :
            sel = @selector( mouseUp:);
            break;
         }
         break;

      case GLFW_MOUSE_BUTTON_RIGHT  :
         switch( action)
         {
         case GLFW_PRESS   :
            sel = @selector( rightMouseDown:);
            break;
         case GLFW_RELEASE :
            sel = @selector( rightMouseUp:);
            break;
         }
         break;

      case GLFW_MOUSE_BUTTON_MIDDLE :
         switch( action)
         {
         case GLFW_PRESS   :
            sel = @selector( otherMouseDown:);
            break;
         case GLFW_RELEASE :
            sel = @selector( otherMouseUp:);
            break;
         }
   }

   if( sel && [self respondsToSelector:sel])
   {
      event = [self performSelector:sel
                         withObject:event];
   }
   return( event);
}


// general idea: suppress mouseDragged events, until a certain amount of 
//               time has passed.  
- (UIEvent *) handleMouseMotionEvent:(UIMouseMotionEvent *) event
{
   uint64_t   state;
   SEL        sel;

   assert( [event isKindOfClass:[UIMouseMotionEvent class]]);

   if( _clickOrDrag._suppressUntilTimestamp > [event timestamp])
      return( nil);

   sel   = 0;
   state = [event buttonStates];
   if( state)
   {
      sel = @selector( mouseDragged:);
      if( ! (state & (1 << GLFW_MOUSE_BUTTON_LEFT)))
      {
         if( state & (1 << GLFW_MOUSE_BUTTON_RIGHT))
            sel = @selector( rightMouseDragged:);
         else
            sel = @selector( otherMouseDragged:);
      }
   }

   if( sel && [self respondsToSelector:sel])
   {
      event = [self performSelector:sel
                         withObject:event];
   }

#if 0
   //
   // classically, these events do not happen when there is no tracking
   // area set up. But I don't see the point, you just don't implement
   // mouseMoved: and then this should be fairly harmless ?
   //
   if( event && [self respondsToSelector:@selector( mouseMoved:)])
   {
      event = [self performSelector:sel
                         withObject:event];
   }
#endif

   return( event);
}


- (UIEvent *) handleMouseScrollEvent:(UIMouseScrollEvent *) event
{
   // scrollWheel: taken from AppKit
   // https://developer.apple.com/documentation/appkit/nsscrollview/1403494-scrollwheel?language=objc
   //
   if( event && [self respondsToSelector:@selector( scrollWheel:)])
      event = (UIMouseScrollEvent *) [self scrollWheel:event];

   return( event);
}


- (UIEvent *) handleKeyboardEvent:(UIKeyboardEvent *) event
{
   uint64_t   state;
   SEL        sel;

   sel   = 0;
   switch( [event action])
   {
   case GLFW_PRESS   :
      sel = @selector( keyDown:);
      break;

   case GLFW_RELEASE :
      sel = @selector( keyUp:);
      break;
   }

   if( sel && [self respondsToSelector:sel])
   {
      event = [self performSelector:sel
                         withObject:event];
   }
#ifdef EVENT_DEBUG
   fprintf( stderr, "event %p\n", event);
#endif

   if( [event key] == GLFW_KEY_ESCAPE &&
       [event action] == GLFW_PRESS)
   {
#ifdef EVENT_DEBUG
      fprintf( stderr, "request close\n");
#endif      
      [[self window] requestClose];

      return( nil);
   }

   return( event);
}


// flat, doesn't recurse
- (UIView *) subviewAtPoint:(CGPoint) point
{
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

   rover = mulle_pointerarray_reverseenumerate_nil( _subviews);
   while( (view = _mulle_pointerarrayenumerator_next( &rover)))
      if( CGRectContainsPoint( [view frame], point))
         break;
   mulle_pointerarrayenumerator_done( &rover);
   return( view);
}


- (UIEvent *) _handleEvent:(UIEvent *) event
{
   if( [self isUserInteractionEnabled] == NO)
   {
#ifdef EVENT_DEBUG
       fprintf( stderr, "Disabled view %s ignores event\n", [self cStringDescription]);
#endif      
      return( event);
   }

   switch( [event eventType])
   {
   case UIEventTypePresses :
      event = [self handleKeyboardEvent:(UIKeyboardEvent *) event];
      break;

   case UIEventTypeTouches :
      event = [self handleMouseButtonEvent:(UIMouseButtonEvent *) event];
      break;

   case UIEventTypeMotion :
      event = [self handleMouseMotionEvent:(UIMouseMotionEvent *) event];
      break;

   case UIEventTypeScroll :
      event = [self handleMouseScrollEvent:(UIMouseScrollEvent *) event];
      break;
   }
   return( event);
}


// this does the hitTest
- (UIEvent *) handleEvent:(UIEvent *) event
               atPosition:(CGPoint) position
{
   CGPoint                               translated;
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

   if( [self isHidden] || [self alpha] < 0.01)
   {
#ifdef EVENT_DEBUG
       fprintf( stderr, "Invisible view %s ignores event\n", [self cStringDescription]);
#endif      
      return( event);
   }

   // from UIView+CGGeometry
   translated = [self translatedPoint:position];

#ifdef HITTEST_DEBUG
  fprintf( stderr, "translated: %s %s -> %s\n",
               [self cStringDescription],
               CGPointCStringDescription( position),
               CGPointCStringDescription( translated));
#endif 

   if( ! [self hitTest:translated
             withEvent:event])
   {
      return( event);
   }

   if( _subviews)
   {
      rover = _mulle_pointerarray_reverseenumerate( _subviews);
      while( (view = _mulle_pointerarrayenumerator_next( &rover)))
      {
         event = [view handleEvent:event
                        atPosition:translated];
         if( ! event)
            break;
      }
      mulle_pointerarrayenumerator_done( &rover);
   }
   if( ! event)
      return( event);

   //
   // current position relative to visible bounds
   //
   [event _setFirstResponderPoint:translated];
   return( [self _handleEvent:event]);
}


- (UIEvent *) responder:(id <UIResponder>) responder
            handleEvent:(UIEvent *) event
{
#ifdef EVENT_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [responder cStringDescription]);
#endif

   do
   {
      // TODO: translate positions
      //       UIViewController could also be the responde here
      event = [(UIView *) responder _handleEvent:event];
      if( ! event)
      {
#ifdef EVENT_DEBUG
         fprintf( stderr, "Responder %s consumed event\n", [responder cStringDescription]);
#endif          
         break;
      }
#ifdef EVENT_DEBUG
      fprintf( stderr, "Responder %s did not consume event, try next\n", [responder cStringDescription]);
#endif         
      responder = [responder nextResponder];
   }
   while( responder);

   return( event);
}


//
// This is called on the window.
//
- (UIEvent *) handleEvent:(UIEvent *) event
{
   CGPoint           position;
   id<UIResponder>   responder;

#ifdef EVENT_DEBUG
   fprintf( stderr, "Event start: %s %s\n",
                        [self cStringDescription],
                        [event cStringDescription]);
#endif

   assert( self == [self window]);
   responder = [(UIWindow *) self firstResponder];
   if( responder)
   {
      event = [self responder:responder
                  handleEvent:event];
      if( ! event)
         return( event);
   }

   position = [event mousePosition];
   return( [self handleEvent:event
                  atPosition:position]);
}

@end

