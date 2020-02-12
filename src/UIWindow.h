#import "UIView.h"

#import <mulle-container/mulle-container.h>

struct MulleFrameInfo;


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

   BOOL               _resizing;
}

@property( retain) CGContext                  *context;
@property( retain) id                         userInfo;
@property( assign, readonly) CGPoint          mousePosition;
@property( assign, readonly) uint64_t         mouseButtonStates;
@property( assign, readonly) uint64_t         modifiers;
@property( assign, readonly) CGFloat          primaryMonitorPPI;
@property( assign) CGFloat                    scrollWheelSensitivity;

@property( assign, getter=isScrollWheelNatural) BOOL scrollWheelNatural;

// nanovg will be done here, here is good time to do plain
// OpenGL calls
@property void   (*drawWindowCallback)( UIWindow *window, 
                                        struct MulleFrameInfo *info);
- (void) renderLoopWithContext:(CGContext *) context;
- (void) waitForEvents:(double) hz;
- (void) requestClose;
+ (void) sendEmptyEvent;

- (id) _firstResponder;

+ (CGFloat) primaryMonitorPPI;

- (void) setupQuadtree;

- (void) addTrackingView:(UIView *) view;
- (void) removeTrackingView:(UIView *) view;

@end
