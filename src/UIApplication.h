#import "import.h"


@class UIWindow;

@interface UIApplication : NSObject <MulleObjCSingleton>
{
   struct mulle_array   _windows;   
}

- (void) addWindow:(UIWindow *) window;
// does not call [UIWindow terminate]
- (void) removeWindow:(UIWindow *) window;

// call terminate on all windows and then remove all of them 
- (void) terminate;

@end


@interface UIApplication( OS)

- (void) os_terminate;

@end
