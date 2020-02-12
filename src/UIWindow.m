#define _GNU_SOURCE

#import "import-private.h"
#import "UIWindow.h"
#import "CGContext.h"
#import "CALayer.h"  // for color
#import "CGGeometry+CString.h"
#import "CAAnimation.h"
#import "UIEvent.h"
#import "UIView+UIEvent.h"
#import "UIView+Yoga.h"
#import "UIView+NSArray.h"
#import "UIView+CGGeometry.h"
#import "mulle-pointerarray+ObjC.h"
#include <time.h>
#include "mulle-quadtree.h"
#include "mulle-timespec.h"

#import "CALayer.h"  // debugging tmp

// #define LAYOUT_ANIMATIONS
// #define CALLBACK_DEBUG
//#define MOUSE_MOTION_CALLBACK_DEBUG
#define MOUSE_BUTTON_CALLBACK_DEBUG
// #define PRINTF_PROFILE_RENDER
// #define PRINTF_PROFILE_EVENTS


@implementation UIWindow

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


static void   windowMoveCallback( GLFWwindow* window, int xpos, int ypos)
{
   UIWindow   *self;
   CGRect     frame;

   self = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

//   fprintf( stderr, "%p moved: x=%d y=%d\n", self, xpos, ypos);

   frame        = [self frame];
   frame.origin = CGPointMake( xpos, ypos);
   [self setFrame:frame];
}


static void   windowRefreshCallback( GLFWwindow* window)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

//   glfwPostEmptyEvent();
//   [self syncFrame];
//   [self frameDidChange];
}


// framebufferResize is more interesting though
static void   windowResizeCallback( GLFWwindow* window, int width, int height)
{
   UIWindow   *self;

   self = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif
}


static void   framebufferResizeCallback( GLFWwindow* window, int width, int height)
{
   UIWindow   *self;
   CGRect     frame;

   self = glfwGetWindowUserPointer( window);

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   fprintf( stderr, "%p resized: w=%d h=%d\n", self, width, height);

   frame       = [self frame];
   frame.size  = CGSizeMake( width, height);;
   [self setFrame:frame];
   self->_resizing   = YES;
}


+ (void) initialize
{
   if( ! glfwInit())
   {
      fprintf( stderr, "Couldn't get GLFW initialized\n");
      abort();
   }
   // calling glSwapInterval here is too early
}

+ (CGFloat) primaryMonitorPPI
{
   GLFWmonitor      *monitor;
   GLFWvidmode      *mode;
   int              w, h;
   CGFloat          ppi;

   //
   monitor = glfwGetPrimaryMonitor();
   glfwGetMonitorPhysicalSize( monitor, &w, &h);

   mode = (GLFWvidmode *) glfwGetVideoMode( monitor);

   // need to convert h in mm to inches
   ppi = mode->height / (h * 0.03937007874);
   return( ppi);
}


- (void) syncFrameWithWindow
{
   int   xpos;
   int   ypos;
   int   width;
   int   height;

   glfwGetWindowPos( _window, &xpos, &ypos);
   glfwGetWindowSize( _window, &width, &height);  // just to be sure...

   _frame.origin = CGPointMake( xpos, ypos);
   _frame.size   = CGSizeMake( width, height);
}


- (id) initWithFrame:(CGRect) frame
{
   GLFWmonitor      *monitor;
   CGFloat          ppi;

   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
	glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
	glfwWindowHint( GLFW_RESIZABLE, GL_TRUE);

   _window = glfwCreateWindow( frame.size.width,
                               frame.size.height,
                               "Demo",
                               0,
                               0);
   if( ! _window)
   {
      fprintf( stderr, "glfwCreateWindow failed us\n");
      [self release];
      return( nil);
//		glfwTerminate();
//		return( -1);
   }

   [self syncFrameWithWindow];

   _mousePosition = CGPointMake( -1.0, -1.0);

   glfwMakeContextCurrent( _window);
   glfwSetWindowUserPointer( _window, self);

   glfwSetMouseButtonCallback( _window, mouseButtonCallback);
   glfwSetCursorPosCallback( _window, mouseMoveCallback);
   glfwSetKeyCallback( _window, keyCallback);
   glfwSetScrollCallback( _window, mouseScrollCallback);

   _primaryMonitorPPI = [UIWindow primaryMonitorPPI];

	glfwSetMouseButtonCallback( _window, mouseButtonCallback);
	glfwSetCursorPosCallback( _window, mouseMoveCallback);
	glfwSetKeyCallback( _window, keyCallback);
	glfwSetScrollCallback( _window, mouseScrollCallback);
   glfwSetWindowSizeCallback( _window, windowResizeCallback);
   glfwSetWindowPosCallback( _window, windowMoveCallback);
   glfwSetFramebufferSizeCallback( _window, framebufferResizeCallback);
   glfwSetWindowRefreshCallback( _window, windowRefreshCallback);

   _scrollWheelSensitivity = 20.0;
   
   return( self);
}


- (void) setAlpha:(CGFloat) value 
{
   assert( 0 && "don't set alpha on window");
}


- (CGFloat) alpha 
{
   return( 1.0);
}


- (void) finalize
{
   // TODO: delete window ?
   //       remove from screen ?

   _firstResponder = nil;
   [super finalize];
}


- (void) dealloc
{
   mulle_pointerarray_release_all( &_trackingViews);
   mulle_pointerarray_done( &_trackingViews);
   mulle_pointerarray_release_all( &_enteredViews);
   mulle_pointerarray_done( &_enteredViews);
         
   mulle_quadtree_destroy( _quadtree);

   // TODO: delete window ?
   [super dealloc];
}


- (id) _firstResponder
{
   return( _firstResponder);
}


- (void) addLayer:(CALayer *) layer
{
   abort();
}

- (void) getFrameInfo:(struct MulleFrameInfo *) info
{
   float   scale_x, scale_y;
   int     winWidth, winHeight;
   int     fbWidth, fbHeight;

   assert( info);

   // glfwGetWindowContentScale( _window, &scale_x, &scale_y);
   scale_x = 1.0; scale_y = 1.0;
   glfwGetWindowSize( _window, &winWidth, &winHeight);
   glfwGetFramebufferSize( _window, &fbWidth, &fbHeight);  

   info->frame           = _frame;
   info->windowSize      = CGSizeMake( winWidth, winHeight);
   info->framebufferSize = CGSizeMake( fbWidth, fbHeight);
   info->UIScale         = CGVectorMake( scale_x, scale_y);
	info->pixelRatio      = info->framebufferSize.width / info->windowSize.width;
   info->isPerfEnabled   = NO;
   info->renderFrame     = _didRender;
   // does not do refreshRate yet, the renderloop does this
}


// glitch hunt:
//
// a) we sometimes overflow the current frame
// b) we are doublebuffering
// c) the glitch occurs when there is already drawing on the screen
// d) the glitch looks like the buffer is cleared and then not swapped
//
static void   error_callback(int code, const char* description)
{
   fprintf( stderr, "GLFW Error #%d: \"%s\"\n", code, description);
}

- (void) renderLoopWithContext:(CGContext *) context
{
   struct timespec         start;
   struct timespec         end;
   struct timespec         diff;
   struct timespec         sleep;
   GLFWmonitor             *monitor;
   GLFWvidmode             *mode;
   long                    nsperframe;
   struct MulleFrameInfo   info;

//   _discardEvents = UIEventTypeMotion;

   glfwSetErrorCallback( error_callback); 
   glfwSwapInterval( 0);  // need for smooth pointer/control sync

   // should check the monitor where the window is on really
   monitor          = glfwGetPrimaryMonitor();
   mode             = (GLFWvidmode *) glfwGetVideoMode( monitor);
   info.refreshRate = mode->refreshRate;

#ifdef PRINTF_PROFILE_RENDER
   nsperframe = (1000000000L + (mode->refreshRate - 1)) / mode->refreshRate;
   fprintf( stderr, "Refresh: %d (%09ld ns/frame)\n", mode->refreshRate, nsperframe);
#endif

   [self layoutIfNeeded];

   // glfwMakeContextCurrent( _window );
   //
   // gut feeling: when we do onw swap buffers first, once, we know we have enough
   // time on the first refresh (didn't work)
   //
   glfwSwapBuffers( _window);
   [context clearFramebuffer];

   while( ! glfwWindowShouldClose( _window))
   {
      if( 1)
      {
         // nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);
         clock_gettime( CLOCK_REALTIME, &start);

         [self getFrameInfo:&info];
         [self updateRenderCachesWithContext:context 
                                   frameInfo:&info];

         info.isPerfEnabled = YES;
         [context startRenderWithFrameInfo:&info];
         [self renderWithContext:context];
         [context endRender];

         if( _drawWindowCallback)
            (*_drawWindowCallback)( self, &info);

#ifdef PRINTF_PROFILE_RENDER
         clock_gettime( CLOCK_REALTIME, &end);
         diff = timespec_diff( start, end);
         if( diff.tv_sec > 0 || diff.tv_nsec >= nsperframe)
            fprintf( stderr, "frame #%ld: @%ld:%09ld render end, OVERFLW %.4f frames\n",
                                 _didRender,
                                 end.tv_sec,
                                 end.tv_nsec,
                                 diff.tv_sec ? 9999.9999 : (diff.tv_nsec / (double) nsperframe) - 1);
#endif
         glfwSwapBuffers( _window);
         _didRender++;

#ifdef ADD_RANDOM_LAG
         sleep.tv_sec  = 0.0;
         sleep.tv_nsec = nsperframe / 10 * (rand() % 100);
         nanosleep( &sleep, NULL);
#endif

         //
         // GL_COLOR_BUFFER_BIT brauchen wir, wenn wir nicht selber per
         // Hand abschnittsweise löschen
         // GL_STENCIL_BUFFER_BIT braucht nanovg
         // GL_DEPTH_BUFFER_BIT ?
         //
         // glClearColor( 1.0 - _didRender / 120.0, 1.0 - _didRender / 120.0, 1.0 - _didRender / 240.0, 0.0f );
         [context clearFramebuffer];
      }

      // do this before the animation step, as this will generate animations
#if LAYOUT_ANIMATIONS      
      [self startLayoutWithFrameInfo:&info];
#endif      
      [self layoutSubviewsIfNeeded];
#if LAYOUT_ANIMATIONS      
      [self endLayout];
#endif
      {
         CAAbsoluteTime   renderTime;

         renderTime = CAAbsoluteTimeWithTimespec( start);
         [self animateWithAbsoluteTime:renderTime];
      }

      [self setupQuadtree];

#ifdef PRINTF_PROFILE_EVENTS
      clock_gettime( CLOCK_REALTIME, &start);
      printf( "@%ld:%09ld events start\n", start.tv_sec, start.tv_nsec);
#endif

      // use at max 200 Hz refresh rate (0: polls)
      [self waitForEvents:0.0];

#ifdef PRINTF_PROFILE_EVENTS
      clock_gettime( CLOCK_REALTIME, &end);
      diff = timespec_diff( start, end);
      printf( "@%ld:%09ld events end, elapsed : %09ld\n", end.tv_sec, end.tv_nsec,
                                                  diff.tv_sec ? 999999999 : diff.tv_nsec);
#endif
   }
   [self dump];
}


- (void) frameDidChange
{
   UIView     *contentView;
   YGLayout   *yoga;
   CGRect     frame;

   contentView = [[self subviews] objectAtIndex:0];
   assert( contentView);

   frame        = _frame;
   frame.origin = CGPointZero;
   [contentView setFrame:frame];
   assert( [contentView layer]);
/*   
   [[contentView layer] setBackgroundColor:getNVGColor( ((uint32_t) frame.size.width * 0xFFFF +
                                                (uint32_t) frame.size.height * 0xFF) |
                                                0xFF)];
*/                                                
/*   yoga = [contentView yoga];
   [yoga setWidth:YGPointValue( frame.size.width)];
   [yoga setHeight:YGPointValue( frame.size.height)];   

   [contentView setNeedsLayout];
   */
}


- (void) setFrame:(CGRect) frame
{
   if( CGRectEqualToRect( _frame, frame))
      return;

   _frame = frame;
   [self frameDidChange];
}


- (CGRect) frame
{
   return( _frame);
}


- (CGRect) bounds
{
   return( CGRectMake( 0.0, 0.0, _frame.size.width, _frame.size.height));
}


- (void) waitForEndOfResize
{
   double   waitEnd;

   //
   // keep viewport as is, so that resize scales the window
   // hopefully
   //
   for(;;)
   {
      waitEnd = glfwGetTime() + 1.0 / 5.0;
      glfwWaitEventsTimeout( 1.0 / 5.0);
      if( waitEnd >= glfwGetTime())
      {
         glViewport( 0.0, 0.0, _frame.size.width, _frame.size.height);
         _resizing = NO;
         break;
      }
   }
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

- (void) requestClose
{
   glfwSetWindowShouldClose( _window, GL_TRUE);
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

