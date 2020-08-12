//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "NSObject.h")
#  import "NSObject.h"
# endif
#endif

#import "import.h"

@class UIWindow;

//
// This is stuck via glfw to the current window. So really the
// window owns a single UIPasteboard instance. Having the pasteboard
// as its own object makes little technical sense. It's just here for
// familiarity and disoverabilty.
//
@interface UIPasteboard : NSObject

@property( assign) UIWindow   *window;

+ (instancetype) pasteboardWithWindow:(UIWindow *) window;

- (char *) cString;
- (void) setCString:(char *) s;

@end
