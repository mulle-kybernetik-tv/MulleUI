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

#if DEBUG
   if( responder != _firstResponder)
      fprintf( stderr, "UIWindow: change firstResponder to %s\n", 
                           responder ? (char *) [responder cStringDescription] 
                                     : "nil");
#endif

   _firstResponder = responder;
   return( YES);
}


@end
