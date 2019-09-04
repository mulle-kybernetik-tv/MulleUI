#define _GNU_SOURCE

#import "import-private.h"
#import "UIWindow.h"
#import "CGContext.h"
#import "CALayer.h"  // for color
#import "CGGeometry+CString.h"
#import "UIEvent.h"
#import "UIView+UIEvent.h"
#include <time.h>
#import "mulle-quadtree.h"


// #define DRAW_SUBDIVISION
#define DRAW_QUADTREE
// #define DRAW_MOUSE_BOX   /* figure out how laggy mouse/draw is */
// #define PRINTF_PROFILE_RENDER
// #define ADD_RANDOM_LAG  /* make drawing sluggish */

#if defined( DRAW_MOUSE_BOX) || defined(DRAW_QUADTREE)
# include <GL/gl.h>
#endif


struct timespec   timespec_diff( struct timespec start, struct timespec end)
{
   struct timespec temp;

   if ((end.tv_nsec-start.tv_nsec) < 0)
   {
      temp.tv_sec  = end.tv_sec-start.tv_sec - 1;
      temp.tv_nsec = 1000000000 + end.tv_nsec - start.tv_nsec;
   } else
   {
      temp.tv_sec = end.tv_sec-start.tv_sec;
      temp.tv_nsec = end.tv_nsec-start.tv_nsec;
   }
   return( temp);
}


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

   assert( button >= 0 && button <= 63);

   self  = glfwGetWindowUserPointer( window);

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
}


static void   mouseMoveCallback( GLFWwindow* window,
                                 double xpos,
                                 double ypos)
{
   UIWindow   *self;
   UIEvent    *event;

   self = glfwGetWindowUserPointer( window);

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

   self  = glfwGetWindowUserPointer( window);
   if( self->_discardEvents & UIEventTypeScroll)
      return;

   scrollOffset = CGPointMake( xoffset, yoffset);
   event        = [[UIMouseScrollEvent alloc] initWithWindow:self
                                               mousePosition:self->_mousePosition
                                                scrollOffset:scrollOffset
                                                   modifiers:self->_modifiers];
   [self handleEvent:event];
   [event release];
}


// TODO: move this to UIAppplication or ??
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


- (id) initWithFrame:(CGRect) frame
{
   GLFWmonitor      *monitor;
   CGFloat          ppi;

   glfwWindowHint( GLFW_CONTEXT_VERSION_MAJOR, 2);
   glfwWindowHint( GLFW_CONTEXT_VERSION_MINOR, 0);
   glfwWindowHint( GLFW_RESIZABLE, GL_FALSE);

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

   // TODO: query glfw for actual frame
   _frame         = frame;
   _mousePosition = CGPointMake( -1.0, -1.0);

   glfwMakeContextCurrent( _window);
   glfwSetWindowUserPointer( _window, self);

   glfwSetMouseButtonCallback( _window, mouseButtonCallback);
   glfwSetCursorPosCallback( _window, mouseMoveCallback);
   glfwSetKeyCallback( _window, keyCallback);
   glfwSetScrollCallback( _window, mouseScrollCallback);

   _primaryMonitorPPI = [UIWindow primaryMonitorPPI];

   return( self);
}

- (void) finalize
{
   // TODO: delete window ?
   _firstResponder = nil;
   [super finalize];
}


- (void) dealloc
{
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

#ifdef DRAW_MOUSE_BOX

- (void) renderWithContext:(CGContext *) context
{
      double   x,y;
      double   pixelsX,pixelsY;

      // poll to get most up to date value
      // this makes a difference on Linux X.org at least
      glfwGetCursorPos( _window, &x, &y);

//      assert( x == ctxt.mouse_x);
//      assert( y == ctxt.mouse_y);

      glColor3f(1.0, 1.0, 1.0);

      glBegin(GL_QUADS);

      // assume 0.0,0.0 is in the middle of the screen
      x = (x - (_frame.size.width / 2.0)) / (_frame.size.width / 2.0);
      y = ((_frame.size.height / 2.0) - y) / (_frame.size.height / 2.0);

      pixelsX = 32 / _frame.size.width;
      pixelsY = 32 / _frame.size.height;
      glVertex3f ( x - pixelsX, y - pixelsY, 0.0);
      glVertex3f ( x + pixelsX, y - pixelsY, 0.0);
      glVertex3f ( x + pixelsX, y + pixelsY, 0.0);
      glVertex3f ( x - pixelsX, y + pixelsY, 0.0);

      glEnd();
}
#endif


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
}

// glitch hunt:
//
// a) we sometimes overflow the current frame
// b) we are doublebuffering
// c) the glitch occurs when there is already drawing on the screen
// d) the glitch looks like the buffer is cleared and then not swapped
//
- (void) renderLoopWithContext:(CGContext *) context
{
   struct timespec         start;
   struct timespec         end;
   struct timespec         diff;
   struct timespec         sleep;
   GLFWmonitor             *monitor;
   GLFWvidmode             *mode;
   int                     refresh;
   long                    nsperframe;
   struct MulleFrameInfo   info;

//   _discardEvents = UIEventTypeMotion;

   glfwSwapInterval( 0);  // need for smooth pointer/control sync

#ifdef PRINTF_PROFILE_RENDER
   monitor = glfwGetPrimaryMonitor();
   mode    = (GLFWvidmode *) glfwGetVideoMode( monitor);
   refresh = mode->refreshRate;

   nsperframe = (1000000000L + (mode->refreshRate - 1)) / mode->refreshRate;
   fprintf( stderr, "Refresh: %d (%09ld ns/frame)\n", mode->refreshRate, nsperframe);
#endif

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
#ifdef PRINTF_PROFILE_RENDER
         clock_gettime( CLOCK_REALTIME, &start);
#endif
         [self getFrameInfo:&info];
         [self updateRenderCachesWithContext:context 
                                   frameInfo:&info];

         info.isPerfEnabled = YES;
         [context startRenderWithFrameInfo:&info];
         [self renderWithContext:context];
         [context endRender];

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
}


- (CGRect) frame
{
   return( _frame);
}


- (CGRect) bounds
{
   return( CGRectMake( 0.0, 0.0, _frame.size.width, _frame.size.height));
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


#ifdef DRAW_QUADTREE

static void  clear_area( CGRect rect, void *payload, void *quadtree)
{
   mulle_quadtree_change_payload( quadtree, rect, (void *) 1, (void *) 0);
}


static void  draw_area( CGRect rect, void *payload, void *info)
{
   NVGcontext  *vg = info;

   nvgBeginPath( vg);
   nvgRect( vg, rect.origin.x, rect.origin.y,
                rect.size.width, rect.size.height);

   if( payload)
      nvgFillColor( vg, getNVGColor( 0xFFFF00FF));
   else
      nvgFillColor( vg, getNVGColor( 0x2020F0FF));
   nvgFill( vg);  
}

- (void) renderWithContext:(CGContext *) context
{
   mulle_quadtree_walk( _quadtree, draw_area, [context nvgContext]);
}

#define EXTENT  3.0

- (void) setupQuadtree
{
   CGRect       rect;
   CGRect       bounds;
   NSUInteger   i;
   NSUInteger   level;
   NSUInteger   extent;

   bounds    = [self bounds];
   extent    = round( bounds.size.width < bounds.size.height ? bounds.size.width : bounds.size.height);
   level     = 0;
   while( extent > 2)
   {
      level++;
      extent >>= 1;
   }

   _quadtree = mulle_quadtree_create( bounds, level, 10, NULL);
   for( i = 0; i < 10000; i++)
   {
      rect = CGRectMake( rand() % (int) (_frame.size.width - EXTENT),
                         rand() % (int) (_frame.size.height - EXTENT),
                         EXTENT,
                         EXTENT);
      mulle_quadtree_insert( _quadtree, rect, NULL);
   }

#if 0
   mulle_quadtree_dump( _quadtree, stderr);
#endif   
}
#endif

static CGRect  RandomRectOfSize( CGSize size)
{
   CGRect  rect;

   rect.origin.x = rand() % (int) size.width;
   rect.origin.y = rand() % (int) size.height;

   do
      rect.size.width  = rand() % (int) size.width;
   while( rect.size.width < 10.0);

   do
      rect.size.height = rand() % (int) size.height;
   while( rect.size.height < 10.0);
   return( rect);
}

static CGRect   testRectangles[] =
{
   { 0, 0, 320, 200 },
   { 320, 0, 320, 200 },
   { 0, 200, 320, 200 },
   { 320, 200, 320, 200 }
};
#define n_testRectangles   (sizeof( testRectangles) / sizeof( CGRect))

- (void) newSubdividedRects
{
   NSUInteger   i;

   _originalRect  = CGRectMake( 100, 50, 640 - 200, 400 - 100);
   i = _nTest++;
   if( i < n_testRectangles)
      _subdivideRect = testRectangles[ i];
   else
      _subdivideRect = RandomRectOfSize( [self frame].size);

   _nDividedRects = MulleRectSubdivideByRect( _originalRect, _subdivideRect, _dividedRects);
}


- (UIEvent *) handleEvent:(UIEvent *) event
{
#ifdef DRAW_QUADTREE
   NSUInteger    n;
   CGRect        rect;

   if( [event eventType] == UIEventTypeMotion)
   {
      rect.origin = [event mousePosition];
      rect.size   = CGSizeMake( 1.0, 1.0);
      n = mulle_quadtree_change_payload( _quadtree, rect, (void *) 0, (void *) 1);
//      if( n)
//         mulle_quadtree_walk( _quadtree, clear_area, _quadtree);
//      mulle_quadtree_change_payload( _quadtree, rect, (void *) 0, (void *) 1);
   }
#endif

#ifdef DRAW_SUBDIVISION
   if( [event eventType] == UIEventTypePresses)
   {
      if( [event action])
         [self newSubdividedRects];
   }
#endif
   if( [event isKindOfClass:[UIMouseScrollEvent class]])
      [self dump];
   return( [super handleEvent:event]);
}

#ifdef DRAW_SUBDIVISION
- (void) renderWithContext:(CGContext *) context
{
   NVGcontext   *vg;
   NSUInteger   i;
   
   vg = [context nvgContext];   

   nvgBeginPath( vg);
   nvgRect( vg, _originalRect.origin.x, 
                _originalRect.origin.y, 
                _originalRect.size.width, 
                _originalRect.size.height);

   nvgStrokeWidth( vg, 3);
   nvgStrokeColor( vg, getNVGColor( 0xFF0000FF));
   nvgStroke( vg);  

   nvgBeginPath( vg);
   nvgRect( vg, _subdivideRect.origin.x, 
                _subdivideRect.origin.y, 
                _subdivideRect.size.width, 
                _subdivideRect.size.height);

   nvgStrokeWidth( vg, 2);
   nvgStrokeColor( vg, getNVGColor( 0x0000FFFF));
   nvgStroke( vg);  
  
   assert( _nDividedRects <= 4);
   for( i = 0; i < _nDividedRects; i++)
   {
      nvgBeginPath( vg);
      nvgRect( vg, _dividedRects[ i].origin.x, 
                   _dividedRects[ i].origin.y, 
                   _dividedRects[ i].size.width, 
                   _dividedRects[ i].size.height);
     
      nvgFillColor( vg, getNVGColor( (0xF0000000 >> i) | (0x001F0000 << i) | 0xC0));
      nvgFill( vg);  
   }
}
#endif


@end

