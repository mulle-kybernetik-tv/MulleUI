#import "UIResponder.h"

#import "import-private.h"

#import "UIWindow+UIResponder.h"


PROTOCOLCLASS_IMPLEMENTATION( UIResponder)

- (id <UIResponder>) nextResponder
{
   return( nil);
}

- (BOOL) canBecomeFirstResponder
{
   return( NO);
}

- (BOOL) canResignFirstResponder
{
   return( YES);
}

PROTOCOLCLASS_END()

