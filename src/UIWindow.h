#import "UIView.h"

#import <mulle-container/mulle-container.h>

struct MulleFrameInfo;

typedef UIView   MulleWindowPlane;

@class UIPasteboard;
@class UIEvent;



enum MulleWindowStyleMask
{
//  MulleWindowStyleMaskClosable        = 0x1,
//  MulleWindowStyleMaskMiniaturizable  = 0x2,
  MulleWindowStyleMaskResizable       = 0x4,
  MulleWindowStyleMaskInvisible       = 0x8
};


//
// TODO: firstResponder needed for UITextField to gain keyboard
//       focus immediately
//
@interface UIWindow : UIView
{
   void               *_window;            // GLFWwindow
	NSUInteger         _didRender;
   CGRect             _frame;              // has its own frame
   NSUInteger         _discardEvents;      // bitfield of UIEventtypes ?
   id                 _firstResponder;
   void               *_quadtree;

   struct mulle_pointerarray   _trackingViews; // views with tracking areas
   struct mulle_pointerarray   _enteredViews;  // views with mouseEntered: sent

   CGRect             _originalRect;
   CGRect             _subdivideRect;
   CGRect             _dividedRects[ 4];
   NSUInteger         _nDividedRects;
   NSUInteger         _nTest;
   NSLock             *_renderContextLock;
   BOOL               _resizing;
}

@property( retain) id                   userInfo;
@property( retain) UIPasteboard         *pasteboard;
@property( assign, readonly) CGPoint    mouseLocation;
@property( assign, readonly) uint64_t   mouseButtonStates;
@property( assign, readonly) uint64_t   modifiers;
@property( assign, readonly) CGFloat    primaryMonitorPPI;
@property( assign) CGFloat              scrollWheelSensitivity;

@property( assign, getter=isScrollWheelNatural) BOOL scrollWheelNatural;

// nanovg will be done here, here is good time to do plain
// OpenGL calls, endRender won't have happened yet

//
// these callbacks will be calles in this sequence for every frame.
// It should be obvious, that you don't do any system calls in these callbacks
// and finish ASAP.
//
@property void   (*willAnimateCallback)( UIWindow *window,
                                         CGContext *context,
                                         struct MulleFrameInfo *info,
                                         CAAbsoluteTime now);
@property void   (*willLayoutCallback)( UIWindow *window,
                                        CGContext *context,
                                        struct MulleFrameInfo *info,
                                        CAAbsoluteTime now);
@property void   (*didLayoutCallback)( UIWindow *window,
                                       CGContext *context,
                                       struct MulleFrameInfo *info,
                                       CAAbsoluteTime now);

@property void   (*didAnimateCallback)( UIWindow *window,
                                        CGContext *context,
                                        struct MulleFrameInfo *info,
                                        CAAbsoluteTime now);
//
// useful to add custom drawing stuff on top. There is no willRenderCallback
// as anything draw in it would be clobbered by the window clearing itself
//
@property void   (*didRenderCallback)( UIWindow *window,
                                       CGContext *context,
                                       struct MulleFrameInfo *info);
@property UIEvent  *(*keyEventCallback)( UIWindow *window,
                                         UIEvent *event);

@property( readonly, assign) MulleWindowPlane   *alertPlane;
@property( readonly, assign) MulleWindowPlane   *dragAndDropPlane;
@property( readonly, assign) MulleWindowPlane   *menuPlane;
@property( readonly, assign) MulleWindowPlane   *toolTipPlane;
@property( readonly, assign) MulleWindowPlane   *contentPlane;

- (id) initWithFrame:(CGRect) frame;
// default visible: closable, non-resizable, non-maximizable
- (id) initWithFrame:(CGRect) frame
        titleCString:(char *) title
           styleMask:(NSUInteger) styleMask;

// does not deal with focus of events
- (void) show;
- (void) hide;

- (void) renderLoopWithContext:(CGContext *) context;
- (void) renderLoopWithContext:(CGContext *) context
              maxFramesToRender:(NSUInteger) maxFrames;
- (void) renderFrameWithContext:(CGContext *) context
                      frameInfo:(struct MulleFrameInfo *) info;

- (void) requestClose;

- (void) getFrameInfo:(struct MulleFrameInfo *) info;

+ (CGFloat) primaryMonitorPPI;

- (CGContext *) createContext;

@end


@interface UIWindow( Dump)

- (void) dump;

@end

@interface UIWindow( OSWindow)

+ (void) os_initialize;
+ (CGFloat) os_primaryMonitorPPI;

- (void) os_syncFrameWithWindow;
- (void *) os_createWindowWithFrame:(CGRect) frame
                       titleCString:(char *) title
                          styleMask:(NSUInteger) styleMask;

- (CGSize) os_windowSize;
- (CGSize) os_framebufferSize;
- (void) os_requestClose;
- (BOOL) os_windowShouldClose;

// sets and locks the current openGL context
- (void) os_startRender;
- (void) os_endRender;

- (void) os_setSwapInterval:(NSUInteger) value;
- (void) os_swapBuffers;

- (void) os_show;
- (void) os_hide;

- (CGFloat) os_primaryMonitorRefreshRate;

@end


@interface UIWindow( OSWindowEvents)

- (void) _framebufferResizeCallback:(CGSize) size;
- (void) _windowResizeCallback:(CGSize) size;
- (void) _windowRefreshCallback;
- (void) _windowMoveCallback:(CGPoint) position;

@end
