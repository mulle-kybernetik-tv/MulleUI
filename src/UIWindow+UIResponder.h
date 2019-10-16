#import "UIWindow.h"
#import "UIResponder.h"

@interface UIWindow (UIResponder)

- (id<UIResponder>)firstResponder;
- (BOOL)makeFirstResponder:(id<UIResponder>)responder;

@end
