#import "UIWindow.h"

@interface UIWindow( UIEvent)

- (void) _initEvent;
- (id) _firstResponder;

+ (void) sendEmptyEvent;
- (void) waitForEvents:(double) hz;
- (void) setupQuadtree;

- (void) addTrackingView:(UIView *) view;
- (void) removeTrackingView:(UIView *) view;

@end
