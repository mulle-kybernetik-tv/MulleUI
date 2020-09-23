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

- (void) waitForEvents:(double) hz
{
   if( hz == 0.0)
      [self os_pollEvents];
   else
      [self os_waitEventsTimeout:1.0 / hz];
}


- (void) discardPendingEvents
{
   BOOL   old;

   old = _discardEvents;
   _discardEvents = ~0;  // discard all
   {
      [self os_pollEvents];
   }
   _discardEvents = old;
}


+ (void) sendEmptyEvent
{
   [self os_sendEmptyEvent];
}


- (void) _keyCallback:(int) key
             scancode:(int) scancode
               action:(int) action
            modifiers:(int) mods                          
{
   UIEvent    *event;

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   self->_modifiers = mods;
   if( self->_discardEvents & UIEventTypePresses)
      return;

   event = [[UIKeyboardEvent alloc] initWithWindow:self
                                     mouseLocation:self->_mouseLocation
                                         modifiers:mods
                                               key:key
                                          scanCode:scancode
                                            action:action];
   [self handleEvent:event];
   [event release];
}


- (void) _charCallback:(unsigned int) codepoint
{
   UIEvent    *event;

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   if( self->_discardEvents & UIEventTypeUnicode)
      return;

   event = [[UIUnicodeEvent alloc] initWithWindow:self
                                    mouseLocation:self->_mouseLocation
                                        modifiers:self->_modifiers
                                        character:codepoint];
   [self handleEvent:event];
   [event release];
}


- (void) _mouseButtonCallback:(int) button
                       action:(int) action
                    modifiers:(int) mods
{
   UIEvent    *event;
   uint64_t   bit;

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
                                        mouseLocation:self->_mouseLocation
                                            modifiers:mods
                                               button:button
                                               action:action];
   [self handleEvent:event];
   [event release];

   // [self dump];
}


- (void) _mouseMoveCallback:(CGPoint) pos
{
   UIEvent    *event;
   CGRect     frame;

#if defined( CALLBACK_DEBUG) || defined( MOUSE_MOTION_CALLBACK_DEBUG)
   fprintf( stderr, "%s %s (%.1f, %.1f)\n", __PRETTY_FUNCTION__, [self cStringDescription], pos.x, pos.y);
#endif

   //
   // Coordinates are window relative! So for screen coordinates we'd need
   // to add the window frame.x/y.
   //
   // we get not events for the window title bar
   // TODO: we might need to scale the values for DPI or ?
	self->_mouseLocation.x = pos.x;
	self->_mouseLocation.y = pos.y;

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
                                        mouseLocation:self->_mouseLocation
                                            modifiers:self->_modifiers
                                         buttonStates:self->_mouseButtonStates];
   [self handleEvent:event];
   [event release];
}


- (void) _mouseScrollCallback:(CGPoint) offset
{
   UIEvent    *event;
   uint64_t   bit;
   CGPoint    scrollOffset;
   CGFloat    sensitivity;

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   if( self->_discardEvents)
      return;

   sensitivity = [self scrollWheelSensitivity];
   if( sensitivity != 0.0)
   {
      offset.x *= sensitivity;
      offset.y *= sensitivity;
   }

   if( [self isScrollWheelNatural])
      scrollOffset = CGPointMake( offset.x, offset.y);
   else
      scrollOffset = CGPointMake( -offset.y, -offset.y);

   event = [[UIMouseScrollEvent alloc] initWithWindow:self
                                        mouseLocation:self->_mouseLocation
                                            modifiers:self->_modifiers
                                         scrollOffset:scrollOffset];
   [self handleEvent:event];
   [event release];
}


- (id) _firstResponder
{
   return( _firstResponder);
}



# pragma mark - tracking rects

- (void) addTrackingView:(UIView *) view
{
   assert( view);
   assert( [view isKindOfClass:[UIView class]]);
   assert( [view window] == self || ! [view window]);

   assert( _mulle_pointerarray_find( &_trackingViews, view) == mulle_not_found_e);
   [view retain];
   _mulle_pointerarray_add( &_trackingViews, view);
}


- (void) removeTrackingView:(UIView *) view
{
   assert( [view isKindOfClass:[UIView class]]);

   if( _mulle_pointerarray_find( &_trackingViews, view) != mulle_not_found_e)
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

   assert( ! view || [view isKindOfClass:[UIView class]]);
   assert( [view window] == self || ! [view window]);

   // don't track hidden view ..
   if( [view mulleIsEffectivelyHidden])
      return;

   n = [view numberOfTrackingAreas];
   for( i = 0; i < n; i++)
   {
      area      = [view trackingAreaAtIndex:i];
      rect      = MulleTrackingAreaGetRect( area);
      converted = [self convertRect:rect
                           fromView:view];
      assert( _quadtree);
      mulle_quadtree_insert( _quadtree, converted, view);
   }
}


- (void) setupQuadtree
{
   CGRect                                rect;
   CGRect                                bounds;
   NSUInteger                            i;
   NSUInteger                            level;
   NSUInteger                            extent;
   struct mulle_pointerarrayenumerator   rover;
   UIView                                *view;

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
   if( ! _quadtree)
      _quadtree = mulle_quadtree_create( bounds, 10, 10, MulleObjCInstanceGetAllocator( self));
   else
      mulle_quadtree_reset( _quadtree, bounds);

   rover = mulle_pointerarray_enumerate( &_trackingViews);
   while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
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

#if DEBUG
   if( [event eventType] == UIEventTypePresses)
   {
      UIKeyboardEvent   *keyEvent;

      keyEvent = (UIKeyboardEvent *) event;

      // F12 key: 301
      if( [keyEvent key] == 301)
      {
         [self dump];
         return( nil);
      }
   }
#endif

   if( [event eventType] == UIEventTypeMotion)
   {
      _mulle_pointerarray_init( &views, 16, NULL);

      point = [event locationInWindow];

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

         _mulle_pointerarray_init( &remaining, 16, _mulle_pointerarray_get_allocator( &_enteredViews));

         rover = mulle_pointerarray_enumerate( &_enteredViews);
          while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
         {
            if( _mulle_pointerarray_find( &views, view) == mulle_not_found_e)
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

         rover = mulle_pointerarray_enumerate( &views);
         while( _mulle_pointerarrayenumerator_next( &rover, (void **) &view))
         {
            if( _mulle_pointerarray_find( &remaining, view) == mulle_not_found_e)
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

