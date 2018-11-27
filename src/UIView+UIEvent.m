#import "UIView+UIEvent.h"

#import "UIWindow.h"


@implementation UIView ( UIEvent)

- (BOOL) hitTest:(CGPoint) point
       withEvent:(UIEvent *) event
{
   return( CGRectContainsPoint( [self frame], point));
}


- (UIEvent *)  handleMouseButtonEvent:(UIMouseButtonEvent *) event
{
   SEL   sel;

   sel   = 0;
   switch( [event button])
   {
      case GLFW_MOUSE_BUTTON_LEFT   :
         switch( [event action])
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
         switch( [event action])
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
         switch( [event action])
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


- (UIEvent *) handleMouseMotionEvent:(UIMouseMotionEvent *) event
{
   uint64_t   state;
   SEL        sel;

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

   if( event && [self respondsToSelector:@selector( mouseMoved:)])
   {
      event = [self performSelector:sel
                         withObject:event];
   }

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

   fprintf( stderr, "event %p\n", event);

   if( [event key] == GLFW_KEY_ESCAPE && 
       [event action] == GLFW_PRESS) 
   {
      fprintf( stderr, "request close\n");
      [[self window] requestClose];
      
      return( nil);
   }

   return( event);
}


- (UIEvent *) handleEvent:(UIEvent *) event
{
   struct mulle_pointerarray_enumerator   rover;
   BOOL      handled;
   CGPoint   point;
   UIView    *view;

   handled = NO;
   if( _subviews)
   {
      point = [event mousePosition];
      rover = mulle_pointerarray_enumerate( _subviews);
      while( view = mulle_pointerarray_enumerator_next( &rover))
         if( [view hitTest:point
                 withEvent:event])
         {
            event = [view handleEvent:event];
            if( ! event)
               break;
         }
   }
   mulle_pointerarray_enumerator_done( &rover);

   if( event)
   {
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
      }
   }
   return( event);
}


@end

