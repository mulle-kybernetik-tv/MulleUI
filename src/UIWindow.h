#import "UIView.h"

#import <mulle-container/mulle-container.h>


@interface UIWindow : UIView
{
   void               *_window;  // GLFWwindow
	NSUInteger         _didRender;
   CGRect             _frame;    // has its own frame
   NSUInteger         _discardEvents; // bitfield of UIEventtypes ?
   id                 _firstResponder;
   void               *_quadtree;

   CGRect       _originalRect;
   CGRect       _subdivideRect;
   CGRect       _dividedRects[ 4];
   NSUInteger   _nDividedRects;
   NSUInteger   _nTest;
}

@property( retain) CGContext                  *context;
@property( retain) id                         userInfo;
@property( assign, readonly) CGPoint          mousePosition;
@property( assign, readonly) uint64_t         mouseButtonStates;
@property( assign, readonly) uint64_t         modifiers;
@property( assign, readonly) CGFloat          primaryMonitorPPI;

- (void) renderLoopWithContext:(CGContext *) context;
- (void) waitForEvents:(double) hz;
- (void) requestClose;
+ (void) sendEmptyEvent;

- (id) _firstResponder;

+ (CGFloat) primaryMonitorPPI;

- (void) setupQuadtree;
- (void) newSubdividedRects;

@end
