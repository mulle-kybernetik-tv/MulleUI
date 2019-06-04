#import "UIView.h"

#import <mulle-container/mulle-container.h>


//
// though a UIWindow is a UIView, it doesn't have a mainLayer
// or any sublayers
// It will erase it contents with black.
//
@interface UIWindow : UIView 
{
   void         *_window;  // GLFWwindow
	NSUInteger   _didRender;  
   CGRect       _frame;    // has its own frame
   BOOL         _discardEvents;
   BOOL         _resizing;
}

@property( retain) CGContext                  *context;
@property( retain) id                         userInfo;
@property( assign, readonly) CGPoint          mousePosition;
@property( assign, readonly) uint64_t         mouseButtonStates;
@property( assign, readonly) uint64_t         modifiers;

- (void) renderLoopWithContext:(CGContext *) context;
- (void) waitForEvents;
- (void) requestClose;
+ (void) sendEmptyEvent;

@end
