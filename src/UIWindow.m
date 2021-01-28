#define _GNU_SOURCE

#import "UIWindow.h"

#import "UIWindow+UIEvent.h"

#import "import-private.h"

#import "CAAnimation.h"
#import "CALayer.h"  // for color
#import "CALayer+CAAnimation.h"  // for color
#import "CGContext.h"
#import "CGGeometry+CString.h"
#import "UIEvent.h"
#import "UIView+CGGeometry.h"
#import "UIView+NSArray.h"
#import "UIView+UIEvent.h"
#import "UIView+Layout.h"
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
// #define PRINTF_PROFILE_LAYOUT

@implementation UIWindow


+ (void) initialize
{
   [self os_initialize];
}


+ (CGFloat) primaryMonitorPPI
{
   return( [self os_primaryMonitorPPI]);
}


- (void) syncFrameWithWindow
{
   [self os_syncFrameWithWindow];
}


- (id) initWithFrame:(CGRect) frame
        titleCString:(char *) title
           styleMask:(NSUInteger) styleMask
{
   _primaryMonitorPPI = [UIWindow primaryMonitorPPI];
   if( _primaryMonitorPPI == 0.0)
   {
      // no monitor connected, so lets just bail
      [self release];
      return( nil);
   }

   _window = [self os_createWindowWithFrame:frame
                               titleCString:title
                                  styleMask:styleMask];
   if( ! _window)
   {
      [self release];
      return( nil);
   }

   // assume window has a title bar for contentRect calculation
   // (No difference to frame for me here on Linux)
   [self syncFrameWithWindow];
   assert( frame.size.height == _frame.size.height);
   assert( frame.size.width == _frame.size.width);

   _mouseLocation = CGPointMake( -1.0, -1.0);

   // initialize various plane for the future, currently only
   // _contentPlane can be used
   frame.origin = CGPointZero;

   _contentPlane = [[[UIView alloc] initWithFrame:frame] autorelease];
   [_contentPlane setDebugNameCString:"Window/ContentPlane"];
   [self addSubview:_contentPlane];

   _toolTipPlane = [[[UIView alloc] initWithFrame:frame] autorelease];
   [_toolTipPlane setDebugNameCString:"Window/ToolTipPlane"];
   [self addSubview:_toolTipPlane];
   [_toolTipPlane setHidden:YES];

   _menuPlane = [[[UIView alloc] initWithFrame:frame] autorelease];
   [_menuPlane setDebugNameCString:"Window/MenuPlane"];
   [self addSubview:_menuPlane];
   [_menuPlane setHidden:YES];

   _dragAndDropPlane = [[[UIView alloc] initWithFrame:frame] autorelease];
   [_dragAndDropPlane setDebugNameCString:"Window/DragAndDropPlane"];
   [self addSubview:_dragAndDropPlane];
   [_dragAndDropPlane setHidden:YES];

   _alertPlane = [[[UIView alloc] initWithFrame:frame] autorelease];
   [_alertPlane setDebugNameCString:"Window/AlertPlane"];
   [_alertPlane setHidden:YES];
   [self addSubview:_alertPlane];

   _renderContextLock = [NSLock new];

   _scrollWheelSensitivity = 20.0;

   [self setNeedsLayout:YES];

   [self os_initEvents];

   return( self);
}


- (id) initWithFrame:(CGRect) frame
{
   return( [self initWithFrame:frame
                     styleMask:0]);
}


- (CGContext *) createContext 
{
   CGContext  *context;

   [self os_startRender];
   context = [CGContext object];
   [self os_endRender];

   return( context);
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

   [_renderContextLock release];

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

   assert( info);

   // glfwGetWindowContentScale( _window, &scale_x, &scale_y);
   scale_x = 1.0;
   scale_y = 1.0;

   info->frame           = _frame;
   info->windowSize      = [self os_windowSize];
   info->framebufferSize = [self os_framebufferSize];
   info->UIScale         = CGVectorMake( scale_x, scale_y);
	info->pixelRatio      = info->framebufferSize.width / info->windowSize.width;
   info->isPerfEnabled   = NO;
   info->renderFrame     = _didRender;

   // does not do refreshRate yet, the renderloop does this
}


- (void) requestClose
{
   [self os_requestClose];
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
      waitEnd = CAAbsoluteTimeNow() + 1.0 / 5.0;
      [self os_waitEventsTimeout:1.0 / 5.0];
      if( waitEnd >= CAAbsoluteTimeNow())
      {
         // move to CGContext ?
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
- (void) renderFrameWithContext:(CGContext *) context
                      frameInfo:(struct MulleFrameInfo *) info
{
   struct timespec   diff;
   struct timespec   start;
   struct timespec   end;
   struct timespec   sleep;
   long              nsperframe;

   clock_gettime( CLOCK_REALTIME, &start);

#ifdef PRINTF_PROFILE_LAYOUT
      printf( "@%ld:%09ld layout start\n", start.tv_sec, start.tv_nsec);
#endif
   /*
    * Layout and animate
    */
   @autoreleasepool
   {
      CAAbsoluteTime   renderTime;

      renderTime = CAAbsoluteTimeWithTimespec( start);

      if( _willAnimateCallback)
         (*_willAnimateCallback)( self, context, info, renderTime);

      // this must run before layouting
      [self willAnimateWithAbsoluteTime:renderTime];

      if( _willLayoutCallback)
         (*_willLayoutCallback)( self, context, info, renderTime);

      // do layout before the animation step, as this will generate animations
#if LAYOUT_ANIMATIONS
      [self startLayoutWithFrameInfo:info];
#endif
      [self layoutIfNeeded];

#if LAYOUT_ANIMATIONS
      [self endLayout];
#endif

      if( _didLayoutCallback)
         (*_didLayoutCallback)( self, context, info, renderTime);

      [self animateWithAbsoluteTime:renderTime];

      if( _didAnimateCallback)
         (*_didAnimateCallback)( self, context, info, renderTime);
   }

#ifdef PRINTF_PROFILE_LAYOUT
   clock_gettime( CLOCK_REALTIME, &end);
   diff = timespec_sub( end, start);
   printf( "@%ld:%09ld lavout end, elapsed : %09ld\n", end.tv_sec, end.tv_nsec,
                                                  diff.tv_sec ? 999999999 : diff.tv_nsec);
#endif

#ifdef PRINTF_PROFILE_RENDER
   clock_gettime( CLOCK_REALTIME, &start);
   printf( "@%ld:%09ld render start\n", start.tv_sec, start.tv_nsec);
#endif

   /*
    * Render
    */
   @autoreleasepool
   {
      // nvgGlobalCompositeOperation( ctxt->vg, NVG_ATOP);

      [self updateRenderCachesWithContext:context
                                frameInfo:info];

      [context startRenderWithFrameInfo:info];
      [self renderWithContext:context];

      if( _didRenderCallback)
         (*_didRenderCallback)( self, context, info);

      [context endRender];
   }
#ifdef PRINTF_PROFILE_RENDER
   clock_gettime( CLOCK_REALTIME, &end);
   diff = timespec_diff( start, end);
   nsperframe = (1000000000L + (info.refreshRate - 1)) / info.refreshRate;
   if( diff.tv_sec > 0 || diff.tv_nsec >= nsperframe)
      fprintf( stderr, "frame #%ld: @%ld:%09ld render end, OVERFLW %.4f frames\n",
                           _didRender,
                           end.tv_sec,
                           end.tv_nsec,
                           diff.tv_sec ? 9999.9999 : (diff.tv_nsec / (double) nsperframe) - 1);
#endif
}


// 0 is forever
- (void) renderLoopWithContext:(CGContext *) context
             maxFramesToRender:(NSUInteger) maxFrames
{
   struct MulleFrameInfo         info;
   struct timespec               diff;
   struct timespec               start;
   struct timespec               end;
   struct timespec               sleep;
   long                          nsperframe;
   CGRect                        oldFrame;
   NSUInteger                    frames;

   // take renderlock here, relinquish later when wating for events
   // or when someone closes the window

   [self os_startRender];
   [self os_setSwapInterval:0];  // need for smooth pointer/control sync

   // should check the monitor where the window is on really
   info.refreshRate = [self os_primaryMonitorRefreshRate];

#ifdef PRINTF_PROFILE_RENDER
   nsperframe = (1000000000L + (info.refreshRate - 1)) / info.refreshRate;
   fprintf( stderr, "Refresh: %d (%09ld ns/frame)\n", info.refreshRate, nsperframe);
#endif

   // this is done during open already
   // glfwMakeContextCurrent( _window );
   //
   // gut feeling: when we do onw swap buffers first, once, we know we have enough
   // time on the first refresh (didn't work)
   //
   [self os_swapBuffers];
   [context clearFramebuffer];

   oldFrame           = _frame;
   info.isPerfEnabled = YES;
   frames             = 0;

   while( ! [self os_windowShouldClose])
   {
      if( maxFrames && frames == maxFrames)
         break;
      ++frames;

      [self getFrameInfo:&info];  // retrieve newest geometry
      [self renderFrameWithContext:context
                         frameInfo:&info];

      [self os_swapBuffers];
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
      [self os_endRender];

#ifdef DEBUG
      if( ! CGRectEqualToRect( _frame, oldFrame))
      {
         [self dump];
         oldFrame = _frame;
      }
#endif

#ifdef PRINTF_PROFILE_RENDER
      clock_gettime( CLOCK_REALTIME, &end);
      diff = timespec_sub( end, start);
      printf( "@%ld:%09ld render end, elapsed : %09ld\n", end.tv_sec, end.tv_nsec,
                                                  diff.tv_sec ? 999999999 : diff.tv_nsec);
#endif

#ifdef PRINTF_PROFILE_EVENTS
      clock_gettime( CLOCK_REALTIME, &start);
      printf( "@%ld:%09ld events start\n", start.tv_sec, start.tv_nsec);
#endif


      /*
       * Event handling
       */
      @autoreleasepool
      {
         [self setupQuadtree];
         // use at max 200 Hz refresh rate (0: polls)
         // use 0.001Hz for event debugging. The wait time is "max", events
         // will be processed if something comes in and then render will be
         // immediate anyway. Animations won't be processed though..
         [self waitForEvents:60.0]; // 0.001];
      }

#ifdef PRINTF_PROFILE_EVENTS
      clock_gettime( CLOCK_REALTIME, &end);
      diff = timespec_sub( end, start);
      printf( "@%ld:%09ld events end, elapsed : %09ld\n", end.tv_sec, end.tv_nsec,
                                                  diff.tv_sec ? 999999999 : diff.tv_nsec);
#endif
      [self os_startRender];

   }
   [self os_endRender];

   [self dump];
}


- (void) renderLoopWithContext:(CGContext *) context
{
   [self renderLoopWithContext:context 
             maxFramesToRender:0];
}


- (void) layoutSubviews
{
   CGRect     frame;

   assert( [_contentPlane layer]);

   frame.origin = CGPointZero;
   frame.size   = _frame.size;

   [_contentPlane setFrame:frame];
   [_menuPlane setFrame:frame];
   [_dragAndDropPlane setFrame:frame];
   [_toolTipPlane setFrame:frame];
   [_alertPlane setFrame:frame];

   // don't use setNeedsLayout as we are inside a layout already
   [_contentPlane setNeedsLayout:YES];
   [_menuPlane setNeedsLayout:YES];
   [_dragAndDropPlane setNeedsLayout:YES];
   [_toolTipPlane setNeedsLayout:YES];
   [_alertPlane setNeedsLayout:YES];
}


- (void) setFrame:(CGRect) frame
{
   if( CGRectEqualToRect( _frame, frame))
      return;

   _frame = frame;
}


- (CGRect) frame
{
   return( _frame);
}


- (CGRect) bounds
{
   return( CGRectMake( 0.0, 0.0, _frame.size.width, _frame.size.height));
}

//
// callbacks from window events (via GLFW)
//
- (void) _windowResizeCallback:(CGSize) size
{
#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif
}


- (void) _framebufferResizeCallback:(CGSize) size
{
   CGRect   frame;

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

   fprintf( stderr, "%p resized: w=%.1f h=%.1f\n", self, size.width, size.height);

   frame       = [self frame];
   frame.size  = size;;
   [self setFrame:frame];
   [self setNeedsLayout:YES];
   self->_resizing = YES;
}


- (void) _windowRefreshCallback
{
#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

//   glfwPostEmptyEvent();
//   [self syncFrame];
//   [self frameDidChange];
}


- (void) _windowMoveCallback:(CGPoint) position
{
   CGRect     frame;

#ifdef CALLBACK_DEBUG
   fprintf( stderr, "%s %s\n", __PRETTY_FUNCTION__, [self cStringDescription]);
#endif

//   fprintf( stderr, "%p moved: x=%d y=%d\n", self, xpos, ypos);

   frame        = [self frame];
   frame.origin = position;
   [self setFrame:frame];
   [self setNeedsLayout:YES];
}

@end

