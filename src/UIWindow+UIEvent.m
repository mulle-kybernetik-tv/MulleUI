#import "UIWindow+UIEvent.h"

#import "import-private.h"

#import "CGGeometry+CString.h"
#import "UIEvent.h"
#import "UIView+UIEvent.h"
#import "UIView+NSArray.h"
#import "UIView+CGGeometry.h"
#import "mulle-pointerarray+ObjC.h"
#include <time.h>
#include "mulle-quadtree.h"
#include "mulle-timespec.h"

@implementation UIWindow( UIEvent)

static void   keyCallback( GLFWwindow* window,
                           int key,
                           int scancode,
                           int action,
                           int mods)
{
   UIWindow   *self;
   UIEvent    *event;

   self = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   self->_modifiers = mods;
   if( self->_discardEvents & UIEventTypePresses)
      return;

   event = [[UIKeyboardEvent alloc] initWithWindow:self
                                     mousePosition:self->_mousePosition
                                               key:key
                                          scanCode:scancode
                                            action:action
                                         modifiers:mods];
   [self handleEvent:event];
   [event release];
}


static void   mouseButtonCallback( GLFWwindow* window,
                                   int button,
                                   int action,
                                   int mods)
{
   UIWindow   *self;
   UIEvent    *event;
   uint64_t   bit;

   self  = glfwGetWindowUserPointer( window);

#if defined( CALLBACK_DEBUG) || defined( MOUSE_BUTTON_CALLBACK_DEBUG)
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   bit = 1 << button;
   self->_mouseButtonStates &= ~bit;
   if( action == GLFW_PRESS)
      self->_mouseButtonStates |= bit;
   self->_modifiers = mods;

   if( self->_discardEvents & UIEventTypeTouches)
      return;

   event = [[UIMouseButtonEvent alloc] initWithWindow:self
                                        mousePosition:self->_mousePosition
                                               button:button
                                               action:action
                                            modifiers:mods];
   [self handleEvent:event];
   [event release];

   // [self dump];
}


static void   mouseMoveCallback( GLFWwindow* window,
                                 double xpos,
                                 double ypos)
{
   UIWindow   *self;
   UIEvent    *event;
   CGRect     frame;

   self = glfwGetWindowUserPointer( window);

#if defined( CALLBACK_DEBUG) || defined( MOUSE_MOTION_CALLBACK_DEBUG)
   fprintf( stderr, "%s %s (%.1f, %.1f)\n", __PRETTY_FUNCTION__, [self cStringDescription], xpos, ypos);
#endif

   // coordinates are window relative ?
   // we get not events for the window title bar

	self->_mousePosition.x = xpos;
	self->_mousePosition.y = ypos;

   //
   // Observed behaviour on linux: Depending on mouse sensitivity, it may 
   // become obvious that there is a rounding bug in the Linux mouse handling
   // where certain integer values are never returned. In my case this 
   // turned out to be 200,200. So don't expect the mouse to provide all 
   // possible integer coordinates for every pixel on the screen.
   //
   if( self->_discardEvents & UIEventTypeMotion)
      return;

   // TODO: wrap in autorelease pool ?
   //       + event don't leak if someone throws
   //       - latency
   event = [[UIMouseMotionEvent alloc] initWithWindow:self
                                        mousePosition:self->_mousePosition
                                         buttonStates:self->_mouseButtonStates
                                            modifiers:self->_modifiers];
   [self handleEvent:event];
   [event release];
}


static void   mouseScrollCallback( GLFWwindow *window,
                                   double xoffset,
                                   double yoffset)
{
   UIWindow   *self;
   UIEvent    *event;
   uint64_t   bit;
   CGPoint    scrollOffset;
   CGFloat    sensitivity;

   self  = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif   

   if( self->_discardEvents)
      return;

   sensitivity = [self scrollWheelSensitivity];
   if( sensitivity != 0.0)
   {
      xoffset *= sensitivity;
      yoffset *= sensitivity;
   }
   
   if( [self isScrollWheelNatural])
      scrollOffset = CGPointMake( xoffset, yoffset);
   else
      scrollOffset = CGPointMake( -xoffset, -yoffset);
     
   event        = [[UIMouseScrollEvent alloc] initWithWindow:self
                                               mousePosition:self->_mousePosition
                                                scrollOffset:scrollOffset
                                                   modifiers:self->_modifiers];
   [self handleEvent:event];
   [event release];
}



- (void) _initEvent
{
   glfwSetMouseButtonCallback( _window, mouseButtonCallback);
   glfwSetCursorPosCallback( _window, mouseMoveCallback);
   glfwSetKeyCallback( _window, keyCallback);
   glfwSetScrollCallback( _window, mouseScrollCallback);
}

- (id) _firstResponder
{
   return( _firstResponder);
}


- (void) waitForEvents:(double) hz
{
   if( hz == 0.0)
   	glfwPollEvents();
   else
     glfwWaitEventsTimeout( 1.0 / hz);    
}


- (void) discardPendingEvents
{
   BOOL   old;

   old = _discardEvents;
   _discardEvents = ~0;  // discard all
   {
      glfwPollEvents();
   }
   _discardEvents = old;
}
+ (void) sendEmptyEvent
{
   glfwPostEmptyEvent();
}


# pragma mark - tracking rects  

- (void) addTrackingView:(UIView *) view
{
   assert( view);
   assert( [view isKindOfClass:[UIView class]]);

   assert( _mulle_pointerarray_find( &_trackingViews, view) == -1);
   [view retain];
   _mulle_pointerarray_add( &_trackingViews, view);
}


- (void) removeTrackingView:(UIView *) view
{
   assert( [view isKindOfClass:[UIView class]]);

   if( _mulle_pointerarray_find( &_trackingViews, view) != -1)
   {
        abort();
      //mulle_pointerarray_remove( &_trackingViews, view);
      [view autorelease];
   }
}


- (void) addTrackingAreasOfView:(UIView *) view
{
   NSUInteger                 i;
   NSUInteger                 n;
   struct MulleTrackingArea   *area;
   CGRect                     rect;
   CGRect                     converted;

   n = [view numberOfTrackingAreas];
   for( i = 0; i < n; i++)
   {
      area      = [view trackingAreaAtIndex:i];
      rect      = MulleTrackingAreaGetRect( area);
      converted = [self convertRect:rect 
                           fromView:view];
      mulle_quadtree_insert( _quadtree, converted, view);
   }
}


- (void) setupQuadtree
{
   CGRect       rect;
   CGRect       bounds;
   NSUInteger   i;
   NSUInteger   level;
   NSUInteger   extent;
   struct mulle_pointerarrayenumerator   rover;
   UIView       *view;

   bounds = [self bounds];
   extent = round( bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height);
   level  = 0;
   while( extent > 2)
   {
      level++;
      extent >>= 1;
   }

   //
   // 1. create quadtree only, when we get an event ?
   // 2. create quadtree for every frame ?
   // 3. create quadtree only when scene (views with tracking rects change ?)
   // 4. do not create quadtree when scrolling ?
   // 5. cache freed quadtree nodes in a mulle_pointerarray ?
   //
   mulle_quadtree_reset( _quadtree, bounds);

   rover = mulle_pointerarray_enumerate_nil( &_trackingViews);
   while( (view = _mulle_pointerarrayenumerator_next( &rover)))
      [self addTrackingAreasOfView:view];
   mulle_pointerarrayenumerator_done( &rover);
}


static void   collect_hit_views( CGRect rect, void *payload, void *userinfo)
{
   struct mulle_pointerarray   *array = userinfo;
   UIView                      *view = payload;

   _mulle_pointerarray_add( array, view);
}


- (UIEvent *) handleEvent:(UIEvent *) event
{
   CGRect                                rect;
   CGPoint                               point;
   struct mulle_pointerarray             views;
   struct mulle_pointerarray             remaining;
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;
   unsigned int                          n;
   BOOL                                  isDrag;

   if( [event eventType] == UIEventTypeMotion)
   {
      _mulle_pointerarray_init( &views, 16, 0, NULL);

      point = [event mousePosition];
      
      //
      // this could be a dragging event though, which needs to be handled
      // without tracking areas (...). But we only handle these events if
      // a button is pressed. We don't send mouseMoved: then though (useful ?)
      //
      isDrag = [(UIMouseMotionEvent *) event buttonStates] != 0;
      n      = mulle_quadtree_find_point( _quadtree, 
                                          point,
                                          collect_hit_views, 
                                          &views);
      //
      // if we have no entered views and nothing is hit, then there is nothing
      // to do
      //
      if( n || mulle_pointerarray_get_count( &_enteredViews))
      {
         // first remove all views from enteredViews which are not in views
         // and send them a MouseExited event
         // send MouseMoved: events to all remaining enteredViews

         _mulle_pointerarray_init( &remaining, 16, 0, _mulle_pointerarray_get_allocator( &_enteredViews));
        
         rover = mulle_pointerarray_enumerate_nil( &_enteredViews);
         while( (view = _mulle_pointerarrayenumerator_next( &rover)))
         {
            if( _mulle_pointerarray_find( &views, view) == -1)
            {
               [view mouseExited:event];
            }
            else
            {
               // will be sent later by regular event handling code anyway
               if( ! isDrag)
                  [view mouseMoved:event];
               _mulle_pointerarray_add( &remaining, view);
            }
         }
         mulle_pointerarrayenumerator_done( &rover);      

         // remaining are now the remaining active enteredViews

         rover = mulle_pointerarray_enumerate_nil( &views);
         while( (view = _mulle_pointerarrayenumerator_next( &rover)))
         {
            if( _mulle_pointerarray_find( &remaining, view) == -1)
            {
               [view mouseEntered:event];
               _mulle_pointerarray_add( &remaining, view);
            }
         }
         mulle_pointerarrayenumerator_done( &rover);      

         // now move remaining to _enteredViews and switch to remaining
         mulle_pointerarray_done( &_enteredViews);
         memcpy( &_enteredViews, &remaining, sizeof( struct mulle_pointerarray));
      }
      mulle_pointerarray_done( &views);

      if( ! isDrag)
         return( nil);
   }


//   if( [event isKindOfClass:[UIMouseScrollEvent class]])
//      [self dump];
   return( [super handleEvent:event]);
}

@end 

