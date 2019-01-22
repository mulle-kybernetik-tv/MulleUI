#import "UIView+UIEvent.h"

#import "UIWindow.h"
#import "CALayer.h"  // for _NVGtransform
#import "CGGeometry+CString.h"


@implementation UIView ( UIEvent)

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


//
// position is a point in the bounds of the view
// transform is the current transform used to convert screen coordinates to
// our bounds
//
- (UIEvent *) _handleEvent:(UIEvent *) event
                atPosition:(CGPoint) point
{
   struct mulle_pointerarray_enumerator   rover;
   CGRect    bounds;
   CGRect    frame;
   CGPoint   scale;
   CGPoint   converted;
   UIView    *view;

   if( ! [self hitTest:point
             withEvent:event])
      return( event);

   if( _subviews)
   {
      rover = mulle_pointerarray_enumerate( _subviews);
      while( view = mulle_pointerarray_enumerator_next( &rover))
      {
         event = [view handleEvent:event
                        atPosition:point];
         if( ! event)
            break;
      }
      mulle_pointerarray_enumerator_done( &rover);
   }

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


//
// Transform for incoming values of the superview to translate into 
// bounds space of the view. For hit tests.
//
- (void) updateTransformWithFrameAndBounds:(float *) transform
{
   CGRect          frame;
   CGRect          bounds;
   CGPoint         scale;
   _NVGtransform   tmp;

   frame  = [self frame];
   bounds = [self bounds];

   nvgTransformTranslate( tmp, -bounds.origin.x, -bounds.origin.y);
   nvgTransformPremultiply( transform, tmp);

   scale.x = bounds.size.width / frame.size.width;
   scale.y = bounds.size.height / frame.size.height;

   nvgTransformScale( tmp, scale.x, scale.y);
   nvgTransformPremultiply( transform, tmp);
 
   nvgTransformTranslate( tmp, -frame.origin.x, -frame.origin.y);
   nvgTransformPremultiply( transform, tmp);
}


- (UIEvent *) handleEvent:(UIEvent *) event
               atPosition:(CGPoint) position
{
   CGPoint         translated;
   _NVGtransform   transform;

   nvgTransformIdentity( transform);
   [self updateTransformWithFrameAndBounds:transform];
   nvgTransformPoint( &translated.x, &translated.y, transform, position.x, position.y);   

  // fprintf( stderr, "translated: %s %s -> %s\n", 
  //             [self cStringDescription],
  //             CGPointCStringDescription( position),
  //             CGPointCStringDescription( translated));

   return( [self _handleEvent:event
                   atPosition:translated]);
}


//
// This is called on the window.
//
- (UIEvent *) handleEvent:(UIEvent *) event
{
   CGPoint         position;

   position = [event mousePosition];
//   fprintf( stderr, "Event start: %s %s\n", 
//                        [self cStringDescription], 
//                        CGPointCStringDescription( position));
   return( [self handleEvent:event
                  atPosition:position]);
}

@end

