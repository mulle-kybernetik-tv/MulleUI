#define _GNU_SOURCE

#import "UIWindow.h"

#import "UIWindow+UIEvent.h"

#import "import-private.h"

#import "CAAnimation.h"
#import "CALayer.h"  // for color
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "UIEvent.h"
#import "UIView+CGGeometry.h"
#import "UIView+NSArray.h"
#import "UIView+UIEvent.h"
#import "UIView+Yoga.h"
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

   [self _initEvent];

   _primaryMonitorPPI = [UIWindow primaryMonitorPPI];

   glfwSetWindowSizeCallback( _window, windowResizeCallback);
   glfwSetWindowPosCallback( _window, windowMoveCallback);
   glfwSetFramebufferSizeCallback( _window, framebufferResizeCallback);
   glfwSetWindowRefreshCallback( _window, windowRefreshCallback);

   _scrollWheelSensitivity = 20.0;
   
   return( self);
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


/*
 * petty accessors
 */

- (void) setAlpha:(CGFloat) value 
{
   assert( 0 && "don't set alpha on window");
}


- (CGFloat) alpha 
{
   return( 1.0);
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


- (void) requestClose
{
   glfwSetWindowShouldClose( _window, GL_TRUE);
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

@end

