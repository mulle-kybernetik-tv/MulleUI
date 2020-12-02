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


#define EVENT_DEBUG
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
      _clickOrDrag._suppressUntilTimestamp = [event timestamp] + 
                                             _clickOrDrag._mouseMotionSuppressionDelay;

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
   case GLFW_REPEAT  :  // do keyUp: and keyDown:
      sel = @selector( keyUp:);
      if( sel && [self respondsToSelector:sel])
      {
         // keep GLFW_REPEAT as action, don't create new event
         // event return value ignored,as to not accidentally prohibit keyDown:
         [self performSelector:sel
                    withObject:event];
      }
      // fall thru

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


- (UIEvent *) handleUnicodeEvent:(UIUnicodeEvent *) event
{
   uint64_t   state;
   SEL        sel;

   sel = @selector( unicodeCharacter:);
   if( [self respondsToSelector:sel])
   {
      event = [self performSelector:sel
                         withObject:event];
   }
#ifdef EVENT_DEBUG
   fprintf( stderr, "event %p\n", event);
#endif
   return( event);
}


// flat, doesn't recurse
- (UIView *) subviewAtPoint:(CGPoint) point
{
   struct mulle_pointerarrayreverseenumerator   rover;
   UIView                                       *view;

   rover = mulle_pointerarray_reverseenumerate( _subviews);
   while( _mulle_pointerarrayreverseenumerator_next( &rover, (void **) &view))
      if( CGRectContainsPoint( [view frame], point))
         break;
   mulle_pointerarrayreverseenumerator_done( &rover);
   return( view);
}


- (CALayer *) layerAtPoint:(CGPoint) point
{
   struct mulle_pointerarrayreverseenumerator   rover;
   CALayer                                      *layer;
   CGRect                                       frame;

   frame    = [self frame];
   point.x += frame.origin.x;
   point.y += frame.origin.y;
  
   rover = mulle_pointerarray_reverseenumerate( _layers);
   while( _mulle_pointerarrayreverseenumerator_next( &rover, (void **) &layer))
      if( CGRectContainsPoint( [layer frame], point))
         break;
   mulle_pointerarrayreverseenumerator_done( &rover);
   return( layer);
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

#ifdef EVENT_DEBUG
    fprintf( stderr, "Try to handle event %s\n", [self cStringDescription]);
#endif

   switch( [event eventType])
   {
   case UIEventTypePresses :
      event = [self handleKeyboardEvent:(UIKeyboardEvent *) event];
      break;

   case UIEventTypeUnicode :
      event = [self handleUnicodeEvent:(UIUnicodeEvent *) event];
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

//
// This was written to support MulleMenu. But MulleMenu does it now
// differently.
//
- (void) mulleSubviewDidHandleEvent:(UIEvent *) event
{
   // pass it up, until noone cares anymore
   [[self superview] mulleSubviewDidHandleEvent:event];
}


- (UIView *) mulleLetSubviewHandleEvent:(UIEvent *) event
                   atTranslatedPosition:(CGPoint) translated
{
   struct mulle_pointerarrayreverseenumerator   rover;
   UIView                                       *view;
   BOOL                                         didHandleEvent;

   if( _subviews)
   {
      rover = _mulle_pointerarray_reverseenumerate( _subviews);
      while( _mulle_pointerarrayreverseenumerator_next( &rover, (void **) &view))
      {
         didHandleEvent = [view handleEvent:event
                                 atPosition:translated] == nil;
         if( didHandleEvent)
         {
            [self mulleSubviewDidHandleEvent:event];
            mulle_pointerarrayreverseenumerator_done( &rover);
            return( view);
         }
      }
      mulle_pointerarrayreverseenumerator_done( &rover);
   }

   return( nil);
}


// this does the hitTest
- (UIEvent *) handleEvent:(UIEvent *) event
               atPosition:(CGPoint) position
{
   CGPoint                               translated;
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   UIEvent                               *memo;

   assert( event);

   if( [self isHidden]) // alpha < 0.01: should we care for events ?
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
#ifdef EVENT_DEBUG
       fprintf( stderr, "Event does not hit view %s\n", [self cStringDescription]);
#endif
      return( event);
   }

   // if a subview handled the event, we are done
   view = [self mulleLetSubviewHandleEvent:event
                      atTranslatedPosition:translated];
   if( view)
   {
#ifdef EVENT_DEBUG
      fprintf( stderr, "Subview %s did consume event\n", [view cStringDescription]);
#endif      
      return( nil);
   }

   if( ! [self isUserInteractionEnabled]) // alpha < 0.01: should we care for events ?
   {
      // TODO: check if event type is of type user interaction
#ifdef EVENT_DEBUG
      fprintf( stderr, "User interaction disabled on view %s\n", [self cStringDescription]);
#endif
      return( event);
   }

   //
   // current position relative to visible bounds
   //
   [event _setTranslatedPoint:translated
                      forView:self];
   return( [self _handleEvent:event]);
}


- (UIEvent *) responder:(id <UIResponder>) responder
            handleEvent:(UIEvent *) event
{
#ifdef EVENT_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, (char *) [responder cStringDescription]);
#endif

   do
   {
      // TODO: translate positions
      //       UIViewController could also be the responde here
      event = [(UIView *) responder _handleEvent:event];
      if( ! event)
      {
#ifdef EVENT_DEBUG
         fprintf( stderr, "Responder %s consumed event\n", (char *) [responder cStringDescription]);
#endif
         break;
      }
#ifdef EVENT_DEBUG
      fprintf( stderr, "Responder %s did not consume event, try next\n", (char *) [responder cStringDescription]);
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
      {
#ifdef EVENT_DEBUG
         fprintf( stderr, "First Responder handled event: %s\n",
                        (char *) [responder cStringDescription]);
#endif         
         return( event);
      }
   }

   position = [event locationInWindow];
   return( [self handleEvent:event
                  atPosition:position]);
}

@end

