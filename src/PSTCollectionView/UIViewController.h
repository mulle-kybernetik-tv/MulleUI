#import "import.h"


@class UIView;


@interface UIViewController : NSObject

@property( retain) UIView   *view;

- (BOOL) isViewLoaded;
- (void) loadView;
- (void) loadViewIfNeeded;
- (void) viewDidLoad;
- (UIView *) viewIfLoaded;
- (void) viewWillAppear:(BOOL) animated;

@end
