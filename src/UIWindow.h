#import "UIView.h"

#import <mulle-container/mulle-container.h>


@interface UIWindow : UIView 
{
   void         *_window;  // GLFWwindow
	NSUInteger   _didRender;  
   CGRect       _frame;    // has its own frame
}

@property( retain) CGContext                  *context;
@property( retain) id                         userInfo;
@property( assign, readonly) CGPoint          mousePosition;
@property( assign, readonly) uint64_t         mouseButtonStates;
@property( assign, readonly) uint64_t         modifiers;

- (void) renderLoopWithContext:(CGContext *) context;
- (void) waitForEvents;
- (void) requestClose;

@end
