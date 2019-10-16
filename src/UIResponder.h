#import "import.h"


PROTOCOLCLASS_INTERFACE0( UIResponder)

- (BOOL) becomeFirstResponder;
- (BOOL) resignFirstResponder;
- (BOOL) isFirstResponder;

@optional

- (id<UIResponder>) nextResponder;
- (BOOL) canBecomeFirstResponder;
- (BOOL) canResignFirstResponder;

PROTOCOLCLASS_END()

