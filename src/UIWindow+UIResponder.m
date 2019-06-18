#import "UIWindow+UIResponder.h"


@implementation UIWindow( UIResponder)


- (id <UIResponder>) firstResponder
{
   return( _firstResponder);
}


- (BOOL) makeFirstResponder:(id <UIResponder>) responder
{
   // the original _firstResponder if present must have resigned before 
   // we can set any non-nil value
   assert( ! responder || ! _firstResponder);

   _firstResponder = responder;
   return( YES);
}


@end
