#define _GNU_SOURCE

#import "import-private.h"

#import "UIWindow.h"
#import "CGContext.h"
#import "UIEvent.h"
#import "UIView+UIEvent.h"
#import "UIView+Yoga.h"
#import "UIView+NSArray.h"
#include <time.h>

#import "CALayer.h"  // debugging tmp

#define CALLBACK_DEBUG
//#define PRINTF_PROFILE_RENDER
#define PRINTF_PROFILE_EVENTS

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

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   self->_modifiers = mods;
   if( self->_discardEvents)
      return;

   event = [[UIKeyboardEvent alloc] initWithMousePosition:self->_mousePosition
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

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   bit = 1 << button;
   self->_mouseButtonStates &= ~bit;
   if( action == GLFW_PRESS)
      self->_mouseButtonStates |= bit;
   self->_modifiers = mods;

   if( self->_discardEvents)
      return;
   
   event = [[UIMouseButtonEvent alloc] initWithMousePosition:self->_mousePosition
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

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

	self->_mousePosition.x = xpos;
	self->_mousePosition.y = ypos;
   if( self->_discardEvents)
      return;

   event = [[UIMouseMotionEvent alloc] initWithMousePosition:self->_mousePosition
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

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif   

   if( self->_discardEvents)
      return;
   
   scrollOffset = CGPointMake( xoffset, yoffset);
   event        = [[UIMouseScrollEvent alloc] initWithMousePosition:self->_mousePosition
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

   fprintf( stderr, "%p moved: x=%d y=%d\n", self, xpos, ypos);

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
   glfwSetWindowSizeCallback( _window, windowResizeCallback);
   glfwSetWindowPosCallback( _window, windowMoveCallback);
   glfwSetFramebufferSizeCallback( _window, framebufferResizeCallback);
   glfwSetWindowRefreshCallback( _window, windowRefreshCallback);

   return( self);
}


- (void) dealloc
{
   // delete window
   [super dealloc];
}


- (void) addLayer:(CALayer *) layer
{
   abort();
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
   struct timespec   start;
   struct timespec   end;
   struct timespec   diff;
   struct timespec   sleep;
   GLFWmonitor       *monitor;
   GLFWvidmode       *mode;
   int               refresh;
   long              nsperframe;
   double            x, y;
   int               w, h;
   CGSize            framebufferSize;
   CGSize            windowSize;
   CGVector          scale;
   float             xscale, yscale;

   monitor = glfwGetPrimaryMonitor();
   mode    = glfwGetVideoMode( monitor);
   refresh = mode->refreshRate;

   nsperframe = (1000000000L + (mode->refreshRate - 1)) / mode->refreshRate;
#ifdef PRINTF_PROFILE_RENDER   
   fprintf( stderr, "Refresh: %d (%09ld ns/frame)\n", mode->refreshRate, nsperframe);
#endif
	#define PAINT_FRAMES  2 //  60 * 5

   // glfwMakeContextCurrent( _window );
   glfwSwapInterval( 0);  // makes no difference

   //
   // gut feeling: when we do onw swap buffers first, once, we know we have enough 
   // time on the first refresh (didn't work)
   //
   glfwSwapBuffers( _window);
   glClearColor( 1.0f, 1.0f, 1.0f, 1.0f );
   glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

	while( ! glfwWindowShouldClose( _window)) 
	{
			// nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);
#ifdef PRINTF_PROFILE_RENDER   
      clock_gettime( CLOCK_REALTIME, &start);
#endif
      // get those values now here, instead of callbacks because they are
      // more uptodate
      glfwGetCursorPos( _window, &x, &y);
      _mousePosition.x = x;
      _mousePosition.y = y;

      // 
      glfwGetWindowSize( _window, &w, &h);
      windowSize = CGSizeMake( w, h);

      // framebuffer is size in pixels of what we draw to
      glfwGetFramebufferSize( _window, &w, &h);
      framebufferSize = CGSizeMake( w, h);

      // not sure how to use this though (upscale stuff ?)
      glfwGetWindowContentScale( _window, &xscale, &yscale);
      scale = CGVectorMake( xscale, yscale);

       // _frame is the frame buffer size, where stuff gets drawn to
      // the ratio is frameBufferWidth / windowWidth to cope with HiDPI
      [context startRenderToFramebufferSize:framebufferSize
                                 windowSize:windowSize
                                      scale:scale];

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


//            sleep.tv_sec  = 0.0;
//            sleep.tv_nsec = nsperframe / 10 * (rand() % 100);
//            nanosleep( &sleep, NULL);
      glClear( GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);

#ifdef PRINTF_PROFILE_EVENTS   
      clock_gettime( CLOCK_REALTIME, &start);
      printf( "@%ld:%09ld events start\n", start.tv_sec, start.tv_nsec);
#endif
      [self waitForEvents];

#ifdef PRINTF_PROFILE_EVENTS   
      clock_gettime( CLOCK_REALTIME, &end);
      diff = timespec_diff( start, end);
      printf( "@%ld:%09ld events end, elapsed : %09ld\n", end.tv_sec, end.tv_nsec,
                                                  diff.tv_sec ? 999999999 : diff.tv_nsec);
#endif
	}
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
   assert( [contentView mainLayer]);
   [[contentView mainLayer] setBackgroundColor:getNVGColor( ((uint32_t) frame.size.width * 0xFFFF +
                                                (uint32_t) frame.size.height * 0xFF) |
                                                0xFF)];
   yoga = [contentView yoga];
   [yoga setWidth:YGPointValue( frame.size.width)];
   [yoga setHeight:YGPointValue( frame.size.height)];   

   [contentView setNeedsLayout];
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


- (void) waitForEvents
{
   glfwWaitEvents();
   if( _resizing)
      [self waitForEndOfResize];
}



- (void) discardPendingEvents
{
   BOOL   old;

   old = _discardEvents;
   _discardEvents = YES;
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


- (CALayer *) mainLayer
{
   assert( 0 && "dont ask the window for its mainLayer, it has none");
   return( nil);
}


- (UIEvent *) handleEvent:(UIEvent *) event
{
	if( [event isKindOfClass:[UIMouseScrollEvent class]])
   	[self dump];
   return( [super handleEvent:event]);
}

@end

